-- ### instance program running ###
declare @dbname varchar(32) = '%'
declare @hostname varchar(32) = '%'
declare @program_name varchar(32) = '%'
declare @PrintTranRunning int = 0

select program_name,
	db_name(sp.dbid) Dbname,
	convert(varchar,login_time,103) login_date,
	convert(varchar,login_time,108) login_hour,
	convert(varchar,last_batch,103) last_batch_date,
	convert(varchar,last_batch,108) last_batch_hour,
	hostname,
	sp.loginame,
	cpu, 
	physical_io,
	status,
	cmd,
	sqltxt.text
from sys.sysprocesses sp
	cross apply sys.dm_exec_sql_text(sql_handle) sqltxt
where status not in ('sleeping', 'dormant', 'background')
	and hostname like @hostname
	and program_name like @program_name
order by last_batch, cpu desc

-- return currently active request to the lock manager
if @PrintTranRunning = 1
begin
	select
		trn.request_session_id,
		trn.resource_database_id,
		db_name(trn.resource_database_id) AS dbname,
		case
			when resource_type = 'object' then object_name(trn.resource_associated_entity_id)
			else object_name(pr.object_id)
		end 'ObjectName',
		pr.index_id,
		idx.name index_name,
		trn.resource_type,
		trn.resource_description,
		trn.resource_associated_entity_id,
		trn.request_mode,
		trn.request_status
	from sys.dm_tran_locks trn
		left join sys.partitions pr on pr.hobt_id = trn.resource_associated_entity_id
		join sys.indexes idx on idx.object_id = pr.object_id AND idx.index_id = pr.index_id
	where resource_associated_entity_id > 0
		and db_name(trn.resource_database_id) like @dbname
	order by request_session_id, resource_associated_entity_id 
end