-- ### Restore from last full backup ###
set nocount on

declare @databasename nvarchar(32) = '%'
declare @PrintBackFile int = 0
--	restore filelistonly from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\ACCDBMS-05_MSSQL_UAT_07_VolvoDeuUAT_Full_Copy_Only_2019_12_31.bak'

declare @sqlversion int = (select SUBSTRING(@@VERSION,CHARINDEX('Server',@@VERSION)+ 7,4))

declare @datafilepath nvarchar(512) 
declare @logfilepath nvarchar(512)

declare @dbname nvarchar(256)
declare @physical_device_name nvarchar(512)
declare @datafile nvarchar(256)
declare @logfile nvarchar(256)

declare @datafilename nvarchar(512)
declare @indexfilename nvarchar(512)
declare @logfilename nvarchar(512)

declare @i int = 0
declare @qry nvarchar(max)
declare @readbckfile int = 0

use [master]
select @datafilepath = substring(physical_name,0,LEN(physical_name)-CHARINDEX('\', reverse(physical_name))+1) + '\'
from sys.master_files 
where type = 0 and data_space_id = 1
and database_id = db_id()

select @logfilepath = substring(physical_name,0,LEN(physical_name)-CHARINDEX('\', reverse(physical_name))+1) + '\'
from sys.master_files 
where type = 1
and database_id = db_id()

if object_id('tempdb..#BackupFilelist') is not null begin drop table #BackupFilelist end 
create table #BackupFilelist (
	LogicalName nvarchar(128)
	,PhysicalName nvarchar(512)
	,Type nvarchar(1)
	,FileGroupName nvarchar(32)
	,Size numeric(25, 0)
	,MaxSize numeric(25, 0)
	,FileId smallint
	,CreateLSN numeric(25, 0)
	,DropLSN smallint
	,UniqueId uniqueidentifier
	,ReadOnlyLSN smallint
	,ReadWriteLSN smallint
	,BackupSizeInBytes numeric(25, 0)
	,SourceBlockSize	numeric(25, 0)
	,FileGroupId	int
	,LogGroupGUID uniqueidentifier
	,DifferentialBaseLSN numeric(25, 0)
	,DifferentialBaseGUID uniqueidentifier
	,IsReadOnly smallint
	,IsPresent smallint
	--following columns introduced in SQL 2008
	,TDEThumbprint nvarchar(4)
)
if @sqlversion > 2014 begin alter table #BackupFilelist add Snapshoturl nvarchar(4) end

if object_id('tempdb..#bakfiles') is not null begin drop table #bakfiles end
create table #bakfiles(id int, dbname nvarchar(512), physical_device_name nvarchar(max), sizemo int)
insert into #bakfiles
select 	row_number() over (order by bs0.database_name) id,
	bs0.database_name,
	physical_device_name,
	cast(backup_size /1024/1024 as integer) 'size_mo'
from [msdb].[dbo].[backupmediafamily] bmf0
	inner join [msdb].[dbo].[backupset] bs0 on bs0.media_set_id = bmf0.media_set_id
	inner join( select bs.database_name,
					max(bmf.media_set_id) media_set_id, 
					max(backup_start_date) backup_start_date
				from [msdb].[dbo].[backupmediafamily] bmf
					inner join [msdb].[dbo].[backupset] bs on bs.media_set_id = bmf.media_set_id
				where type = 'D' 
				group by bs.database_name
				) LastBkp on LastBkp.media_set_id = bs0.media_set_id and LastBkp.backup_start_date = bs0.backup_start_date
where bs0.database_name like @databasename

if @PrintBackFile = 1 begin select * from #bakfiles end

while (@i < (select count(*) from #bakfiles))
begin
	set @i +=1
	set @qry = ''
	set @physical_device_name = (select physical_device_name from #bakfiles where id = @i)
	set @dbname = (select dbname from #bakfiles where id = @i)
	
	begin try
		delete from #BackupFilelist
		insert into #BackupFilelist
		exec('restore filelistonly from disk = ''' + @physical_device_name + '''')

		set @datafilename = (select LogicalName from #BackupFilelist where Type = 'D' and FileGroupName = 'PRIMARY')
		
		set @qry = 'restore database [' + @dbname + '] '+
				'from disk='''+ @physical_device_name + ''' ' +
				'with file = 1, ' +
				'move ''' + @datafilename +  ''' to ''' + @datafilepath + @Dbname + '.mdf'',' 

		
		declare @ndffiles int = (select count(*) from #BackupFilelist where lower(PhysicalName) like '%.ndf')
		declare @j int = 0
		while @ndffiles > @j
		begin
			set @qry += 'move ''' + (select top 1 LogicalName from #BackupFilelist where lower(PhysicalName) like '%.ndf') + ''' to ''' + @datafilepath + @dbname + '_'+ cast(@j+1 as varchar(3)) +'.ndf'', '
			delete from #BackupFilelist where FileId = (select top 1 FileId from #BackupFilelist where lower(PhysicalName) like '%.ndf')
			set @j +=1
		end
	
		declare @ldffiles int = (select count(*) from #BackupFilelist where lower(PhysicalName) like '%.ldf')
		set @j = 0
		while @ldffiles > @j
		begin
			if @ldffiles = 1
			begin
				set @qry += 'move ''' + (select LogicalName from #BackupFilelist where lower(PhysicalName) like '%.ldf') + ''' to ''' + @logfilepath + @dbname + '_log.ldf'', ' 
			end
			else
			begin
				set @qry += 'move ''' + (select LogicalName from #BackupFilelist where lower(PhysicalName) like '%.ldf') + ''' to ''' + @logfilepath + @dbname + '_log'+ cast(@j+1 as varchar(3))+ '.ldf'', ' 
			end
		
			set @j +=1
		end

		set @qry +=	'replace, stats = 5, recovery ' +			
				'exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_LogicialFiles_Name] ['+ @dbname +'] ' +
				'exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_Database_Owner] ['+ @dbname +'],''sa'' ' +
				'exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].Update_Compatibility_Level ['+ @dbname +'] ' +
				'exec [INFRASTRUCTURE.COMMAND].[DBA.SECURITY].[Update_Users] ['+ @dbname +'] '
		print(@qry)
	end try
	begin catch
		print '--' + quotename(@dbname) +' unable read backup:' + @physical_device_name
	end catch
end
