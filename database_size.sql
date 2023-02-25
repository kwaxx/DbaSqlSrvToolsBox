dbcc sqlperf(logspace)

SELECT DB_NAME(database_id) AS DatabaseName,
Name AS Logical_Name,
Physical_Name, 
(size*8)/1024 SizeMB
FROM sys.master_files
order by (size*8)/1024 desc

SELECT DB_NAME() AS DbName, 
name AS FileName, 
size/128.0 AS CurrentSizeMB, 
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB 
FROM sys.database_files; 
