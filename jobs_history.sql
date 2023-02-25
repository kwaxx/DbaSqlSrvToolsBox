-- view launch jobs (hexa)
declare @enablejobs int = 1
declare @db varchar(64) = 'tempdb%'
declare @jobidhexa varchar(64) = '%'

select jb.job_id,
upper(master.dbo.fn_varbintohexstr(jb.job_id)) 'job_id_hexa',
database_name,
enabled,
name,
step_id,
command,
last_run_outcome,
last_run_duration,
last_run_retries,
last_run_date,
last_run_time,
jblog.log
from msdb.dbo.sysjobs jb
	inner join msdb.dbo.sysjobsteps jbs on jbs.job_id = jb.job_id
	left join msdb.dbo.sysjobstepslogs jblog on jblog.step_uid = jbs.step_uid
where enabled = @enablejobs
	and database_name like @db
	and upper(master.dbo.fn_varbintohexstr(jb.job_id)) like @jobidhexa
order by database_name, jb.name, jbs.step_id

/*
exec msdb.dbo.sp_start_job @job_name='Job_test'
go
exec msdb.dbo.sp_stop_job @job_name='Job_test'
go

select * from sys.sysprocesses where program_name like '%agent%'
*/
