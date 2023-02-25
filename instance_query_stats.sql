-- stored procedures
select db_name(database_id) as database_name, object_name(object_id, database_id) as object_name, *
from sys.dm_exec_procedure_stats s
outer apply sys.dm_exec_sql_text(s.sql_handle) st
order by s.total_worker_time desc

-- triggers
select db_name(s.database_id) as database_name, object_name(s.object_id, s.database_id) as trigger_name, s.*, t.text
from sys.dm_exec_trigger_stats s
outer apply sys.dm_exec_sql_text(s.sql_handle) t
order by s.total_worker_time desc

-- queries
SELECT db_name(t.dbid) AS database_name
,object_name(t.objectid, t.dbid) AS object_name
,s.*
,t.dbid
,t.objectid AS objectid
,t.TEXT
FROM sys.dm_exec_query_stats s
OUTER APPLY sys.dm_exec_sql_text(s.plan_handle) t
ORDER BY total_worker_time DESC