-- Count active processes of program runnning in database
select top 100 @@servername 'servername',
	db_name(dbid) 'db', 
	program_name 'program', 
	count(*) 'Nb_process'
from master.sys.sysprocesses 
group by program_name, db_name(dbid)
order by count(*) desc

-- last processes most cpu consuming
select convert(char(4), spid) spid,  
	convert(char(4), blocked) blk,  
	convert(char(4), cpu) cpu,  
	left(loginame,15) 'Users',  
	left(hostname, 15) 'Host',  
	left(db_name(dbid),15) db,  
	convert(char(20), cmd) command,  
	convert(char(12), program_name) program ,  
	convert(char(10), status) status  
from master..sysprocesses  
where  spid <> @@spid  
AND status not in ( 'background', 'sleeping', 'dormant')  
order by cpu desc

-- last processes most cpu consuming details
select spr.spid,
	spr.waittime,
	spr.lastwaittype,
	db_name(spr.dbid) db,
	spr.cpu,
	spr.physical_io,
	spr.login_time,
	spr.last_batch,
	spr.status,
	spr.hostname,
	spr.program_name,
	spr.cmd,
	spr.loginame,
	object_name(qry.objectid) 'object_name',
	qry.text
FROM master.sys.sysprocesses spr
	outer apply master.sys.dm_exec_sql_text(spr.sql_handle) qry
where spr.dbid > 100
order by cpu desc
