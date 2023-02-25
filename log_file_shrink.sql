dbcc sqlperf(logspace)

/*
-- a little check that recovery is not full mode 
select name, recovery_model, recovery_model_desc, state
from sys.databases
where recovery_model != 3

use [dbname]
select db_name() AS dbname, 
	name AS filename, 
	size / 128.0 AS currentsizeMB, 
	size / 128.0 - cast(fileproperty(name, 'SpaceUsed') as int)/128.0 as freespaceMB 
from sys.database_files; 
*/

if object_id('tempdb..#dbnames') is not null drop table #dbnames

create table #dbnames(id int, name varchar(max))

insert into #DbNames(id, name)
select row_number() over (order by name) id, name 
from sys.databases
where state = 0
and name not in ('master','model','msdb', 'tempdb')

declare @i int
declare @dbname varchar(max)
set @i = 0

while (@i < (select count(*) from #dbnames))
begin
	set @i +=1
	set @DbName = (select name from #dbnames where id = @i)
	
	print ('use [' + @DbName + ']  
			declare @logname varchar(max) 
			set @logname = (select name from sys.database_files where type = 1)			
			dbcc shrinkfile(@LogName)
			')
end

use ExtabDCEspIATT
select name, physical_name, size * 8 / 1024 'size_mo' from sys.database_files



