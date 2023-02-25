use master

select * from sys.master_files where database_id = DB_ID('tempdb')

alter database tempdb modify file (name= tempdev, filename = 't:\tempdb.mdf')
alter database tempdb modify file (name = templog, filename = 'l:\templog.ldf')

alter database tempdb modify file (name= temp2, filename = 't:\tempdb2.mdf')
alter database tempdb modify file (name= temp3, filename = 't:\tempdb3.mdf')
alter database tempdb modify file (name= temp4, filename = 't:\tempdb4.mdf')

use tempdb
go
exec sp_helpfile
dbcc shrinkfile ('temp2', EMPTYFILE)
-- alter database tempdb MODIFY FILE (NAME = N'temp2', size = 0KB)
alter database tempdb remove file temp4

