USE Lab
dbcc sqlperf(logspace)
select name, physical_name, (size * 8) / 1024 'SizeMB' from sys.master_files where name like '%lab%'
-- TEMPDb Size =>8Mo

use tempdb
select * from sys.databases where name like '%lab%'

-- exec sp_helpdb
select OBJECT_ID('tempdb..#GrownTbl')
-- drop table #GrownTbl
create table #GrownTbl(id float)

declare @i int
set @i = 0
while (@i < 1000000)
begin	
	set @i +=1
	insert into #GrownTbl(id) values (rand())
end

select count(*) from #GrownTbl
select sum(id) from #GrownTbl

/*
use tempdb
   go
   dbcc shrinkfile (tempdev, 5)
   go
   -- this command shrinks the primary data file
   dbcc shrinkfile (templog, 8)
   go
   -- this command shrinks the log file, examine the last paragraph.

Alter database lab modify file (name = 'lab', size = 8)
*/
Alter database tempdb modify file (name = 'tempdev', size = 8)

use tempdb
exec sp_spaceused @updateusage = true
