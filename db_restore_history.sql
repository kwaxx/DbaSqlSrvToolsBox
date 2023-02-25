-- ### Retrieve backups restore history ###
declare @dbname varchar(32) = 'GVFAzureIatf'

select rh.destination_database_name 'db',
	case 
		when rh.restore_type = 'D' then 'Database'
		when rh.restore_type = 'F' then 'File'
		when rh.restore_type = 'I' then 'Diff'
		when rh.restore_type = 'L' then 'Log'
	else rh.restore_type 
	end 'restore_type',
	rh.restore_date,
	bmf.physical_device_name 'source', 
	rf.destination_phys_name 'restore_file',
	rh.user_name 'restore_by'
from msdb.dbo.restorehistory rh
	inner join msdb.dbo.backupset bs on rh.backup_set_id = bs.backup_set_id
	inner join msdb.dbo.restorefile rf on rh.restore_history_id = rf.restore_history_id
	inner join msdb.dbo.backupmediafamily bmf on bmf.media_set_id = bs.media_set_id
where rh.destination_database_name like @dbname
order by rh.restore_history_id desc
