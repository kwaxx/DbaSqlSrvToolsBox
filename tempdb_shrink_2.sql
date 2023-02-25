select * from sys.databases where name like 'tempdb'

select DB_NAME(database_id) DB, 
Type_Desc,
CAST( ((SUM(Size)* 8) / 1024.0) AS DECIMAL(18,2) ) DB_SIZE
from sys.master_files
Group by DB_NAME(database_id), Type_Desc
having DB_NAME(database_id) = 'tempdb'

dbcc opentran(tempdb)

SELECT SUM(unallocated_extent_page_count) AS [free pages],
(SUM(unallocated_extent_page_count)*1.0/128) AS [free space in MB]
FROM sys.dm_db_file_space_usage;

/*
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

DBCC SHRINKFILE (TEMPDEV, 20480);   --- New file size in MB
GO


2
3
4
5
6
7
8
9
10
	
USE [tempdb]
GO
DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS 
DBCC FREESYSTEMCACHE ('ALL')
DBCC FREESESSIONCACHE
DBCC SHRINKDATABASE(tempdb, 100)
DBCC SHRINKFILE ('tempdev') 
DBCC SHRINKFILE ('templog') 
GO
*/

 -- Determining the Amount of Free Space in TempDB
SELECT SUM(unallocated_extent_page_count) AS [free pages],
  (SUM(unallocated_extent_page_count)*1.0/128) AS [free space in MB]
FROM sys.dm_db_file_space_usage;

-- Determining the Amount Space Used by the Version Store
SELECT SUM(version_store_reserved_page_count) AS [version store pages used],
  (SUM(version_store_reserved_page_count)*1.0/128) AS [version store space in MB]
FROM sys.dm_db_file_space_usage;

-- Determining the Amount of Space Used by Internal Objects
SELECT SUM(internal_object_reserved_page_count) AS [internal object pages used],
  (SUM(internal_object_reserved_page_count)*1.0/128) AS [internal object space in MB]
FROM sys.dm_db_file_space_usage;

-- Determining the Amount of Space Used by User Objects
SELECT SUM(user_object_reserved_page_count) AS [user object pages used],
  (SUM(user_object_reserved_page_count)*1.0/128) AS [user object space in MB]
FROM sys.dm_db_file_space_usage;
