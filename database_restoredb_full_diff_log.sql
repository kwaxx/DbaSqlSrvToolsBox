/*
Restauration 
ACCDBMS-03\MSSQL_IATF_04 
	GVFSqlIatf
	GVFAzureIatf

full: \\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Full.bak
position: 1
diff: \\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Diff.bak
position: 1
log: \\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Log.bak
position: 1 - 9

test restaure on bastion
*/
set nocount on
use [Labs]

declare @PrintHeadersFile int = 1

declare @BackupFilelist table (
LogicalName nvarchar(128),
PhysicalName nvarchar(512),
Type nvarchar(1),
FileGroupName nvarchar(32),
Size numeric(25, 0),
MaxSize numeric(25, 0),
FileId smallint,
CreateLSN numeric(25, 0),
DropLSN smallint,
UniqueId uniqueidentifier,
ReadOnlyLSN smallint,
ReadWriteLSN smallint,
BackupSizeInBytes numeric(25, 0),
SourceBlockSize	numeric(25, 0),
FileGroupId	int,
LogGroupGUID uniqueidentifier,	
DifferentialBaseLSN numeric(25, 0),
DifferentialBaseGUID uniqueidentifier,
IsReadOnly smallint,
IsPresent smallint,
TDEThumbprint nvarchar(4),
Snapshoturl nvarchar(128))

declare @BackupHeader table (
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
		--following columns introduced in SQL 2012
		,Containment tinyint 
		--following columns introduced in SQL 2014
		,KeyAlgorithm nvarchar(32)
		,EncryptorThumbprint varbinary(20)
		,EncryptorType nvarchar(32))

declare @dbname nvarchar(32) = 'GVFSqlIatf'

declare @fromfullfilepath nvarchar(512) = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Full.bak'
declare @fullposition varchar(32) = '1'

insert into @BackupHeader exec('restore headeronly from disk =''' + @fromfullfilepath + '''')
if (select count(*) from @BackupHeader) > 1 begin print 'CAUTION, N full backup header' end
if @PrintHeadersFile = 1 begin select 'FULL' 'headers', BackupName, UserName, ServerName, DatabaseName, cast((BackupSize /1024 /1014) as int) BackupSizeMo, Position, BackupStartDate, MachineName, RecoveryModel from @BackupHeader end

declare @fromdifffilepath nvarchar(512) = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Diff.bak'
declare @diffposition varchar(32) = '1'
delete from @BackupHeader
insert into @BackupHeader exec('restore headeronly from disk =''' + @fromdifffilepath + '''')
if @PrintHeadersFile = 1  and (select count(*) from @BackupHeader) > 1 begin select 'DIFF' 'headers', BackupName, UserName, ServerName, DatabaseName, cast((BackupSize /1024 /1014) as int) BackupSizeMo, Position, BackupStartDate, MachineName, RecoveryModel from @BackupHeader end

declare @fromlogfilepath nvarchar(512) = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Log.bak'
declare @logposition varchar(32) = '1,2,3,4,5,6,7,8,9'
delete from @BackupHeader
insert into @BackupHeader exec('restore headeronly from disk =''' + @fromlogfilepath + '''')
if @PrintHeadersFile = 1 and (select count(*) from @BackupHeader) > 1 begin select 'LOG' 'headers', BackupName, UserName, ServerName, DatabaseName, cast((BackupSize /1024 /1014) as int) BackupSizeMo, Position, BackupStartDate, MachineName, RecoveryModel from @BackupHeader end

insert into @BackupFilelist exec('restore filelistonly from disk = ''' + @fromfullfilepath + '''')

declare @todatapath nvarchar(256)  
declare @tologpath nvarchar(256) 

declare @qry nvarchar(max)

declare @delimiter varchar(max) 
set @delimiter = ','
declare @xml xml
declare @output table(datasplit varchar(max))

declare @countpositions int

select @todatapath = substring(physical_name,0,LEN(physical_name)-CHARINDEX('\', reverse(physical_name))+1) + '\'
from sys.master_files 
where type = 0 and data_space_id = 1
and database_id = db_id()

select @tologpath = substring(physical_name,0,LEN(physical_name)-CHARINDEX('\', reverse(physical_name))+1) + '\'
from sys.master_files 
where type = 1
and database_id = db_id()

if exists(select 1 from sys.databases where name like @dbname) begin
	set @qry = 'alter database ' + QUOTENAME(@dbname) + ' set single_user' 
	print @qry
end

print '-- FULL'
set @qry =	'restore database ' + QUOTENAME(@dbname) + 
			' from disk = ''' + @fromfullfilepath + '''' +
			' with file = ' + @fullposition +
			', move ''' + (select LogicalName from @BackupFilelist where lower(PhysicalName) like '%.mdf') + ''' to ''' + @todatapath + @dbname + '.mdf'', ' +  
			'move ''' + (select LogicalName from @BackupFilelist where lower(PhysicalName) like '%.ndf') + ''' to ''' + @todatapath + @dbname + '_1.ndf'', ' +
			'move ''' + (select LogicalName from @BackupFilelist where lower(PhysicalName) like '%.ldf') + ''' to ''' + @tologpath + @dbname + '_log.ldf'', ' +
			'nounload, replace, stats = 5, ' 
if (@diffposition = '' and @logposition = '') begin set @qry += 'recovery' end else begin set @qry += 'norecovery' end
print @qry

print '-- DIFF'
set @qry = ''

if @diffposition != ''
begin
	set @qry =	'restore database ' + QUOTENAME(@dbname) + 
				' from disk = ''' + @fromdifffilepath + '''' +
				' with file = ' + @diffposition +
				' , nounload, stats = 5, norecovery' 
	print @qry
end

print '-- LOG'
set @qry = ''

if @logposition != ''
begin
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

/*
restore database [GVFSqlIatf]
from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Diff.bak'
with file =1, nounload, STATS = 5, norecovery

restore log [GVFSqlIatf]
from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Log.bak'
with file = 1, stats = 5, norecovery
restore log [GVFSqlIatf]
from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Log.bak'
with file = 2, stats = 5, norecovery
restore log [GVFSqlIatf]
from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Log.bak'
with file = 3, stats = 5, norecovery
restore log [GVFSqlIatf]
from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Log.bak'
with file = 4, stats = 5, norecovery
restore log [GVFSqlIatf]
from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Log.bak'
with file = 5, stats = 5, norecovery
restore log [GVFSqlIatf]
from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Log.bak'
with file = 6, stats = 5, norecovery
restore log [GVFSqlIatf]
from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Log.bak'
with file = 7, stats = 5, norecovery
restore log [GVFSqlIatf]
from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Log.bak'
with file = 8, stats = 5, norecovery
restore log [GVFSqlIatf]
from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Log.bak'
with file = 9, stats = 5, recovery

alter database [GVFSqlIatf] set recovery simple
alter database [GVFSqlIatf] set multi_user

exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_LogicialFiles_Name] [GVFSqlIatf]
exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_Database_Owner] [GVFSqlIatf],'sa'
exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].Update_Compatibility_Level [GVFSqlIatf]
exec [INFRASTRUCTURE.COMMAND].[DBA.SECURITY].[Update_Users] [GVFSqlIatf]
----------------------------
alter database [GVFAzureIatf] set single_user

restore database [GVFAzureIatf] 
from disk= '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\GVFProd_20191205_1515\GVFProd_BackUp_Full.bak' 
with file = 1,  
move 'GVFProd' to 'E:\Microsoft SQL Server\MSSQL12.MSSQL_IATF_04\MSSQL\DATA\GVFAzureIatf.MDF',  
move 'GVFProd_1' to 'E:\Microsoft SQL Server\MSSQL12.MSSQL_IATF_04\MSSQL\DATA\GVFAzureIatf.NDF',  
move 'GVFProd_Log' to 'F:\Microsoft SQL Server\MSSQL12.MSSQL_IATF_04\MSSQL\Data\GVFAzureIatf_log.LDF',  
REPLACE, STATS = 5, NORECOVERY

restore database [GVFAzureIatf]
from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\20191113_GVFProd\ATLANTIS_MSSQLPRODAC01_GVFProd_Differential_2019_11_13_043712.bak'
with file =1, STATS = 5, NORECOVERY 

restore log [GVFAzureIatf]
from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\TMP\20191113_GVFProd\ATLANTIS_MSSQLPRODAC01_GVFProd_Log_2019_11_13_044500.trn'
with recovery

exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_LogicialFiles_Name] [GVFAzureIatf]
exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_Database_Owner] [GVFAzureIatf],'sa'
exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].Update_Compatibility_Level [GVFAzureIatf]
exec [INFRASTRUCTURE.COMMAND].[DBA.SECURITY].[Update_Users] [GVFAzureIatf]

use [GVFAzureIatf]
alter database [GVFAzureIatf] set recovery simple

dbcc sqlperf(logspace)
select * from sys.database_files where type = 1
dbcc shrinkfile(GVFAzureIatf_Log)

*/