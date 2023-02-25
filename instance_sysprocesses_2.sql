set transaction isolation level read uncommitted
select top 10
    creation_time,
    last_execution_time,
    case 
        when sql_handle IS NULL then ' '
        else(substring(st.text,(qs.statement_start_offset+2)/2,(
            case
                when qs.statement_end_offset =-1 then len(convert(nvarchar(MAX),st.text))*2      
                else qs.statement_end_offset    
            end - qs.statement_start_offset)/2  ))
    end as query_text,
    db_name(st.dbid)as db_name,
    object_schema_name(st.objectid, st.dbid)+'.'+object_name(st.objectid, st.dbid) as object_name
FROM sys.dm_exec_query_stats  qs
     cross apply sys.dm_exec_sql_text(sql_handle) st
ORDER BY last_execution_time desc, db_name, object_name

select top 100 * from sys.dm_exec_query_stats order by execution_count desc

select *, sqltext.objectid, sqltext.text
from sys.dm_exec_query_stats 
	cross apply sys.dm_exec_sql_text(sql_handle) sqltext


SELECT 
	qry.session_id,
	qry.status,
	qry.command,
	qry.cpu_time,
	qry.total_elapsed_time,
	sqltext.TEXT
FROM sys.dm_exec_requests qry
	CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext
order by qry.cpu_time desc, qry.total_elapsed_time desc

-- sp_who '320'
-- DBCC INPUTBUFFER (SPID)

select top 100 session_id, * 
from sys.dm_exec_requests

select count(*) from sys.dm_exec_requests

select  session_id, status, command, start_time
from sys.dm_exec_requests

select *
from sys.sysprocesses
		CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext
order by cpu desc, login_time desc

select distinct status from sys.sysprocesses
