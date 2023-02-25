select spid, qry.text,  sp.dbid, db_name(sp.dbid) db, hostname, program_name, loginame, login_time, last_batch, status
from sys.sysprocesses sp
	cross apply sys.dm_exec_sql_text(sp .sql_handle) qry
-- where db_name(sp.dbid) like '%iris%'
order by cpu desc

declare @errorlog table (logdate datetime, processinfo varchar(max), text varchar(max))
insert into @errorlog exec master..xp_readerrorlog 0, 1

select * from @errorlog order by logdate desc

dbcc traceon(1222)
dbcc traceon(1204)
dbcc tracestatus(1204, 1222)

select * from sys.messages where text like '%dead%'and language_id = 1033 order by message_id desc

select * from msdb.dbo.restorehistory order by restore_date desc
-- INFRASTRUCTURE.COMMAND => restore date 20/11/2019

select * from sys.dm_os_performance_counters 
-- sys.dm_os_tasks

SELECT  
    task_address,  
    task_state,  
    context_switches_count,  
    pending_io_count,  
    pending_io_byte_count,  
    pending_io_byte_average,  
    scheduler_id,  
    session_id,  
    exec_context_id,  
    request_id,  
    worker_address,  
    host_address  
  FROM sys.dm_os_tasks  
  ORDER BY session_id, request_id;  

  SELECT STasks.session_id, SThreads.os_thread_id  
  FROM sys.dm_os_tasks AS STasks  
  INNER JOIN sys.dm_os_threads AS SThreads  
    ON STasks.worker_address = SThreads.worker_address  
  WHERE STasks.session_id IS NOT NULL  
  ORDER BY STasks.session_id;  
GO  
