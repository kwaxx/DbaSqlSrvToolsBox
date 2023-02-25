/*
### Restore from backups files ###
select SUBSTRING(@@VERSION,CHARINDEX('Server',@@VERSION)+ 7,4)
declare @backup varchar(256) = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\_DBA\GVFProd_20191205_1515\GVFProd_BackUp_log.bak'
restore filelistonly from disk = @backup
restore headeronly from disk = @backup
*/
set nocount on
use [master]
declare @sqlversion int = (select SUBSTRING(@@VERSION,CHARINDEX('Server',@@VERSION)+ 7,4))

declare @PrintHeadersFile int = 1

-- script parameters
declare @dbname nvarchar(32) = 'GVFSqlIatf'
declare @fromfullfilepath nvarchar(512) = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\_DBA\GVFProd_20191205_1515\GVFProd_BackUp_Full.bak'
declare @fullposition varchar(32) = '1'
declare @fromdifffilepath nvarchar(512) = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\_DBA\GVFProd_20191205_1515\GVFProd_BackUp_diff.bak'
declare @diffposition varchar(32) = '1'
declare @fromlogfilepath nvarchar(512) = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\_DBA\GVFProd_20191205_1515\GVFProd_BackUp_log.bak'
declare @logposition varchar(32) = '1,2,3,4,5,6,7,8,9'

declare @todatapath nvarchar(256)  
declare @tologpath nvarchar(256)

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

if object_id('tempdb..#BackupHeader') is not null begin drop table #BackupHeader end 
create table #BackupHeader (
	 BackupName nvarchar(128)
	,BackupDescription nvarchar(255)
	,BackupType smallint
	,ExpirationDate datetime
	,Compressed tinyint
	,Position smallint
	,DeviceType tinyint
	,UserName nvarchar(128)
	,ServerName nvarchar(128)
	,DatabaseName nvarchar(128)
	,DatabaseVersion int
	,DatabaseCreationDate datetime
	,BackupSize numeric(20,0)
	,FirstLSN numeric(25,0)
	,LastLSN numeric(25,0)
	,CheckpointLSN numeric(25,0)
	,DatabaseBackupLSN numeric(25,0)
	,BackupStartDate datetime
	,BackupFinishDate datetime
	,SortOrder smallint
	,CodePage smallint
	,UnicodeLocaleId int
	,UnicodeComparisonStyle int
	,CompatibilityLevel tinyint
	,SoftwareVendorId int
	,SoftwareVersionMajor int
	,SoftwareVersionMinor int
	,SoftwareVersionBuild int
	,MachineName nvarchar(128)
	,Flags int
	,BindingID uniqueidentifier
	,RecoveryForkID uniqueidentifier
	 --following columns introduced in SQL 2008
	,Collation nvarchar(128)
	,FamilyGUID uniqueidentifier
	,HasBulkLoggedData bit
	,IsSnapshot bit
	,IsReadOnly bit
	,IsSingleUser bit
	,HasBackupChecksums bit
	,IsDamaged bit
	,BeginsLogChain bit
	,HasIncompleteMetaData bit
	,IsForceOffline bit
	,IsCopyOnly bit
	,FirstRecoveryForkID uniqueidentifier
	,ForkPointLSN numeric(25,0)
	,RecoveryModel nvarchar(60)
	,DifferentialBaseLSN numeric(25,0)
	,DifferentialBaseGUID uniqueidentifier
	,BackupTypeDescription nvarchar(60)
	,BackupSetGUID uniqueidentifier NULL 
	,CompressedBackupSize bigint
)
if @sqlversion >= 2012 begin alter table #BackupHeader add Containment tinyint end
if @sqlversion >= 2014 begin alter table #BackupHeader add KeyAlgorithm nvarchar(32),EncryptorThumbprint varbinary(20),EncryptorType nvarchar(32)  end

declare @qry nvarchar(max)

if @fromfullfilepath != ''
begin
	insert into #BackupHeader exec('restore headeronly from disk =''' + @fromfullfilepath + '''')
	if (select count(*) from #BackupHeader) > 1 begin print 'CAUTION, N full backup header' end
	if @PrintHeadersFile = 1 begin select 'FULL' 'headers', BackupName, UserName, ServerName, DatabaseName, cast((BackupSize /1024 /1014) as int) BackupSizeMo, Position, BackupStartDate, MachineName, RecoveryModel from #BackupHeader end
	
	insert into #BackupFilelist exec('restore filelistonly from disk = ''' + @fromfullfilepath + '''')
end

if @fromdifffilepath != ''
begin
	delete from #BackupHeader
	insert into #BackupHeader exec('restore headeronly from disk =''' + @fromdifffilepath + '''')
	if @PrintHeadersFile = 1  and (select count(*) from #BackupHeader) > 1 begin select 'DIFF' 'headers', BackupName, UserName, ServerName, DatabaseName, cast((BackupSize /1024 /1014) as int) BackupSizeMo, Position, BackupStartDate, MachineName, RecoveryModel from #BackupHeader end
end

if @fromlogfilepath != ''
begin
	delete from #BackupHeader
	insert into #BackupHeader exec('restore headeronly from disk =''' + @fromlogfilepath + '''')
	if @PrintHeadersFile = 1 and (select count(*) from #BackupHeader) > 1 begin select 'LOG' 'headers', BackupName, UserName, ServerName, DatabaseName, cast((BackupSize /1024 /1014) as int) BackupSizeMo, Position, BackupStartDate, MachineName, RecoveryModel from #BackupHeader end
end

select @todatapath = substring(physical_name,0,LEN(physical_name)-CHARINDEX('\', reverse(physical_name))+1) + '\'
from sys.master_files 
where type = 0 and data_space_id = 1
and database_id = db_id()

select @tologpath = substring(physical_name,0,LEN(physical_name)-CHARINDEX('\', reverse(physical_name))+1) + '\'
from sys.master_files 
where type = 1
and database_id = db_id()

if exists(select 1 from sys.databases where name like @dbname) begin
	set @qry = 'alter database ' + QUOTENAME(@dbname) + ' set single_user with rollback immediate' 
	print @qry
end

if @fullposition != ''
begin 
	print '-- FULL'

	set @qry =	'restore database ' + QUOTENAME(@dbname) + 
				' from disk = ''' + @fromfullfilepath + '''' +
				' with file = ' + @fullposition +
				', move ''' + (select LogicalName from #BackupFilelist where lower(PhysicalName) like '%.mdf') + ''' to ''' + @todatapath + @dbname + '.mdf'', ' 
	
	declare @ndffiles int = (select count(*) from #BackupFilelist where lower(PhysicalName) like '%.ndf')
	declare @j int = 0
	while @ndffiles > @j
	begin
		set @qry += 'move ''' + (select top 1 LogicalName from #BackupFilelist where lower(PhysicalName) like '%.ndf') + ''' to ''' + @todatapath + @dbname + '_'+ cast(@j+1 as varchar(3)) +'.ndf'', '
		delete from #BackupFilelist where FileId = (select top 1 FileId from #BackupFilelist where lower(PhysicalName) like '%.ndf')
		set @j +=1
	end
	
	declare @ldffiles int = (select count(*) from #BackupFilelist where lower(PhysicalName) like '%.ldf')
	set @j = 0
	while @ldffiles > @j
	begin
		if @ldffiles = 1
		begin
			set @qry += 'move ''' + (select LogicalName from #BackupFilelist where lower(PhysicalName) like '%.ldf') + ''' to ''' + @tologpath + @dbname + '_log.ldf'', ' 
		end
		else
		begin
			set @qry += 'move ''' + (select LogicalName from #BackupFilelist where lower(PhysicalName) like '%.ldf') + ''' to ''' + @tologpath + @dbname + '_log'+ cast(@j+1 as varchar(3))+ '.ldf'', ' 
		end
		
		set @j +=1
	end

	set @qry +='nounload, replace, stats = 5, ' 
	
	if (@diffposition = '' and @logposition = '') begin set @qry += 'recovery' end else begin set @qry += 'norecovery' end

	print @qry
end

if @diffposition != ''
begin
	print '-- DIFF'
	set @qry =	'restore database ' + QUOTENAME(@dbname) + 
				' from disk = ''' + @fromdifffilepath + '''' +
				' with file = ' + @diffposition +
				' , nounload, stats = 5, norecovery' 
	print @qry
end


if @logposition != ''
begin
	print '-- LOG'
	declare @delimiter varchar(max) 
	set @delimiter = ','
	declare @xml xml
	declare @output table(datasplit varchar(max))

	declare @countpositions int

	set @xml = cast(('<a>'+replace(@logposition,@delimiter,'</a><a>')+'</a>') AS XML)
	
	insert into @output (datasplit) 
		select replace(replace(replace(ltrim(rtrim(A.value('.', 'varchar(max)'))),char(9),''),char(10),''),char(13),'') FROM @Xml.nodes('a') AS FN(a)

	set @countpositions = (select count(datasplit) from @output)

	while (select count(datasplit) from @output) != 0
	begin 
		set @qry = 'restore log ' + QUOTENAME(@dbname) + 
			' from disk = ''' + @fromlogfilepath + '''' +
			' with file = ' + (select top 1 datasplit from @output)  +
			', nounload, stats = 5, '
			
		if (select count(datasplit) from @output) = 1 begin set @qry += 'recovery' end else begin set @qry += 'norecovery' end
		delete from @output where datasplit = (select top 1 datasplit from @output) 
	
		print @qry
	end
end

if exists(select 1 from sys.databases where name like @dbname) begin
	set @qry = 'alter database ' + QUOTENAME(@dbname) + ' set multi_user' 
	print @qry
end

print '-- alter database ' + QUOTENAME(@dbname) + ' set recovery simple'

print 'exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_LogicialFiles_Name] ' + QUOTENAME(@dbname) 
print 'exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_Database_Owner] ' + QUOTENAME(@dbname) + ',''sa'''
print 'exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].Update_Compatibility_Level ' + QUOTENAME(@dbname)
print 'exec [INFRASTRUCTURE.COMMAND].[DBA.SECURITY].[Update_Users] ' + QUOTENAME(@dbname)

print '-- dbcc sqlperf(logspace)'
print '-- use '+ QUOTENAME(@dbname)
print '-- select * from sys.database_files where type = 1'
print '-- dbcc shrinkfile(' + @dbname + '_Log)'
