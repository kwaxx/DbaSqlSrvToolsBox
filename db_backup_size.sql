-- sys.master_files
-- is_percent_growth, 

select DB_NAME(database_id) DB, 
Type_Desc,
CAST( ((SUM(Size)* 8) / 1024.0) AS DECIMAL(18,2) ) DB_SIZE
from sys.master_files
Group by DB_NAME(database_id), Type_Desc

select top 10 * 
FROM msdb.dbo.backupset

SELECT
[database_name] AS "Database",
DATEPART(month,[backup_start_date]) AS "Month",
AVG([backup_size]/1024/1024) AS "Backup Size MB"
FROM msdb.dbo.backupset
WHERE [type] = 'D'
GROUP BY [database_name],DATEPART(mm,[backup_start_date])
order by [database_name], DATEPART(month,[backup_start_date]) asc
