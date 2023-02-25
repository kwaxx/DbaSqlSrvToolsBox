-- sp_who3 => https://gallery.technet.microsoft.com/SPWHO3-74fb1c35
SELECT r.session_id, se.host_name, se.login_name, Db_name(r.database_id) AS dbname, r.status, r.command,
	   CAST(((DATEDIFF(s,start_time,GetDate()))/3600) as varchar) + ' hour(s), '
		+ CAST((DATEDIFF(s,start_time,GetDate())%3600)/60 as varchar) + 'min, '
		+ CAST((DATEDIFF(s,start_time,GetDate())%60) as varchar) + ' sec' as running_time,
	   r.blocking_session_id AS BlkBy, r.open_transaction_count AS NoOfOpenTran, r.wait_type,
	   CAST(ROUND((r.granted_query_memory / 128.0)  / 1024,2) AS NUMERIC(10,2))AS granted_memory_GB,
	   object_name = OBJECT_SCHEMA_NAME(s.objectid,s.dbid) + '.' + OBJECT_NAME(s.objectid, s.dbid),
	   program_name = se.program_name, p.query_plan AS query_plan,
	   sql_text = SUBSTRING	(s.text,r.statement_start_offset/2,
			(CASE WHEN r.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(MAX), s.text)) * 2
				ELSE r.statement_end_offset	END - r.statement_start_offset)/2),
		r.cpu_time,	start_time, percent_complete,		
		CAST((estimated_completion_time/3600000) as varchar) + ' hour(s), '
		+ CAST((estimated_completion_time %3600000)/60000 as varchar) + 'min, '
		+ CAST((estimated_completion_time %60000)/1000 as varchar) + ' sec' as est_time_to_go,
		dateadd(second,estimated_completion_time/1000, getdate()) as est_completion_time
FROM sys.dm_exec_requests r WITH (NOLOCK) 
	JOIN sys.dm_exec_sessions se WITH (NOLOCK) ON r.session_id = se.session_id 
	OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) s 
	OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) p 
WHERE  r.session_id <> @@SPID AND se.is_user_process = 1

-- who is consuming the memory
SELECT session_id, granted_memory_kb 
FROM sys.dm_exec_query_memory_grants WITH (NOLOCK) 
ORDER BY 1 DESC

-- who has cached plans that consumed the most cumulative CPU (top 10)
SELECT TOP 10 DatabaseName = DB_Name(t.dbid),
				sql_text = SUBSTRING (t.text, qs.statement_start_offset/2,
							(CASE WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(MAX), t.text)) * 2
							ELSE qs.statement_end_offset END - qs.statement_start_offset)/2),
				ObjectName = OBJECT_SCHEMA_NAME(t.objectid,t.dbid) + '.' + OBJECT_NAME(t.objectid, t.dbid),
				qs.execution_count AS [Executions], qs.total_worker_time AS [Total CPU Time],
				qs.total_physical_reads AS [Disk Reads (worst reads)],	qs.total_elapsed_time AS [Duration], 
				qs.total_worker_time/qs.execution_count AS [Avg CPU Time],qs.plan_generation_num,
					qs.creation_time AS [Data Cached], qp.query_plan
FROM sys.dm_exec_query_stats qs WITH(NOLOCK) 
	CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t
	CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
ORDER BY DatabaseName, qs.total_worker_time DESC;

-- who is connected and how many sessions it has 
SELECT login_name, [program_name],No_of_Connections = COUNT(session_id)
FROM sys.dm_exec_sessions WITH (NOLOCK)
WHERE session_id > 50 
GROUP BY login_name, [program_name] 
ORDER BY COUNT(session_id) DESC

-- who is idle that have open transactions
SELECT s.session_id, login_name, login_time, host_name, host_process_id, status 
FROM sys.dm_exec_sessions AS s WITH (NOLOCK)
WHERE EXISTS (SELECT * FROM sys.dm_tran_session_transactions AS t WHERE t.session_id = s.session_id)
	AND NOT EXISTS (SELECT * FROM sys.dm_exec_requests AS r WHERE r.session_id = s.session_id)

-- who is running tasks that use tempdb (top 5)
SELECT TOP 5 session_id, request_id,  user_objects_alloc_page_count + internal_objects_alloc_page_count as task_alloc
FROM tempdb.sys.dm_db_task_space_usage  WITH (NOLOCK)
WHERE session_id > 50 
ORDER BY user_objects_alloc_page_count + internal_objects_alloc_page_count DESC

-- who is blocking
SELECT DB_NAME(lok.resource_database_id) as db_name,lok.resource_description,lok.request_type,lok.request_status,lok.request_owner_type
,wat.session_id as wait_session_id,wat.wait_duration_ms,wat.wait_type,wat.blocking_session_id
FROM  sys.dm_tran_locks lok WITH (NOLOCK) 
	JOIN sys.dm_os_waiting_tasks wat WITH (NOLOCK) ON lok.lock_owner_address = wat.resource_address 
