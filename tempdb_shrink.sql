CHECKPOINT;
GO
DBCC DROPCLEANBUFFERS;
GO

DBCC FREEPROCCACHE;
GO

DBCC FREESYSTEMCACHE ('ALL');
GO

DBCC FREESESSIONCACHE;
GO

select * FROM tempdb.sys.database_files

SELECT SUM(size)*1.0/128 AS [size in MB]
FROM tempdb.sys.database_files

USE tempdb
DBCC SHRINKFILE(tempdev,1000)
DBCC SHRINKDATABASE(templog, 1000);

/*
USE master;
    GO
    ALTER DATABASE tempdb
    MODIFY FILE (NAME = tempdev, SIZE=100Mb);
    GO
    ALTER DATABASE tempdb
    MODIFY FILE (NAME = templog, SIZE=100Mb);
    GO
*/


SELECT name, file_id, type_desc, size * 8 / 1024 [TempdbSizeInMB]
FROM sys.master_files
WHERE DB_NAME(database_id) = 'tempdb'
ORDER BY type_desc DESC, file_id 

select * from tempdb

sp_helpdb