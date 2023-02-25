-- dbcc inputbuffer

select loginame, * 
from sys.sysprocesses 
where spid > 50
and status not in ('sleeping', 'dormant', 'suspended','background')
-- and spid = 105
and spid != @@SPID
order by cpu desc

select req.session_id,
	req.database_id,
	DB_NAME(req.database_id) DbName,
	req.user_id,
	USER_NAME(req.user_id) UserName,
	req.blocking_session_id,
	req.cpu_time,
	req.total_elapsed_time, 
	req.transaction_id,
	st.text,
	ses.host_name,
	ses.program_name,
	ses.login_name,
	ses.nt_domain,
	ses.nt_user_name,
	ses.cpu_time,
	ses.memory_usage,
	ses.total_scheduled_time,
	ses.total_elapsed_time,
	ses.last_request_start_time,
	ses.last_request_end_time,
	ses.reads,
	ses.writes,
	ses.logical_reads,
	ses.is_user_process,
	ses.original_login_name
from sys.dm_exec_requests req
	cross apply sys.dm_exec_sql_text(sql_handle) st
	left join sys.dm_exec_sessions ses on ses.session_id = req.session_id
where req.status not in ('sleeping', 'suspended', 'background')
and req.session_id != @@SPID
order by req.cpu_time desc

SELECT
sysprc.spid,
sysprc.waittime,
sysprc.lastwaittype,
DB_NAME(sysprc.dbid) AS database_name,
sysprc.cpu,
sysprc.physical_io,
sysprc.login_time,
sysprc.last_batch,
sysprc.status,
sysprc.hostname,
sysprc.[program_name],
sysprc.cmd,
sysprc.loginame,
sysprc.sql_handle,
OBJECT_NAME(sqltxt.objectid) AS [object_name],
sqltxt.text
FROM master.sys.sysprocesses sysprc
OUTER APPLY master.sys.dm_exec_sql_text(sysprc.sql_handle) sqltxt
where DB_NAME(sysprc.dbid) = 'IrisFormsProd'
order by last_batch desc, cpu desc
