SELECT dm_tran_locks.request_session_id,
       dm_tran_locks.resource_database_id,
       DB_NAME(dm_tran_locks.resource_database_id) AS dbname,
       CASE
           WHEN resource_type = 'object'
               THEN OBJECT_NAME(dm_tran_locks.resource_associated_entity_id)
           ELSE OBJECT_NAME(partitions.OBJECT_ID)
       END AS ObjectName,
       partitions.index_id,
       indexes.name AS index_name,
       dm_tran_locks.resource_type,
       dm_tran_locks.resource_description,
       dm_tran_locks.resource_associated_entity_id,
       dm_tran_locks.request_mode,
       dm_tran_locks.request_status
FROM sys.dm_tran_locks
LEFT JOIN sys.partitions ON partitions.hobt_id = dm_tran_locks.resource_associated_entity_id
JOIN sys.indexes ON indexes.OBJECT_ID = partitions.OBJECT_ID AND indexes.index_id = partitions.index_id
WHERE resource_associated_entity_id > 0
  AND resource_database_id = DB_ID()
ORDER BY request_session_id, resource_associated_entity_id 

SELECT * 
FROM sys.dm_exec_requests
WHERE DB_NAME(database_id) = 'LIGIS' 
AND blocking_session_id <> 0


SELECT * 
FROM sys.dm_exec_requests 
CROSS APPLY sys.dm_exec_sql_text(sql_handle) 
where session_id IN (
						SELECT blocking_session_id 
						FROM sys.dm_exec_requests 
						WHERE DB_NAME(database_id)='LIGIS' 
							and blocking_session_id <>0
					)