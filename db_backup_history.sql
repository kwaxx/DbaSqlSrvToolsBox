/*
### Databases Retrieve last backup execution ###
Full, Diff, Log

select top 10 * from [msdb].[dbo].[restorehistory]
select top 10 * from [msdb].[dbo].[restorefilegroup]
select top 10 * from [msdb].[dbo].[backupset]
select top 10 * from [msdb].[dbo].[restorefile]
select top 10 * from [msdb].[dbo].[backupmediafamily]
*/
declare @dbname varchar(32) = '%bmw%'
declare @recovery varchar(8) = '%Log%' -- param => '%Full%', '%Diff%', '%Log%'

select @@SERVERNAME 'ServeurName',
	d.name 'DbName',
	DbBkp.name 'bakup_name',
	create_date 'db_crate_date',
	DbBkp.backup_start_date,
	DbBkp.backup_finish_date,
	cast (DbBkp.backup_size / 1024 /1024 as integer) 'bak_size_mo',
	cast (DbBkp.compressed_backup_size / 1024 /1024 as integer) 'bak_size_zip_mo',
	state_desc,
	recovery_model_desc,
	DbBkp.user_name 'bakup_user_name',
	physical_device_name
from sys.databases d
	inner join (select 	bs.name,
						user_name,
						database_creation_date,
						backup_start_date,
						bs.backup_finish_date,
						backup_size,
						bs.database_name,
						server_name,
						machine_name,
						recovery_model,
						compressed_backup_size,
						physical_device_name
					from [msdb].[dbo].[backupset] bs
						inner join [msdb].[dbo].[backupmediafamily] bmf on bmf.media_set_id = bs.media_set_id
						inner join (select	name, 
											max(backup_finish_date) backup_finish_date,	
											database_name
									from [msdb].[dbo].[backupset] 
									group by name, database_name
									) LastBkp on LastBkp.name = bs.name and LastBkp.backup_finish_date = bs.backup_finish_date
				) DbBkp on DbBkp.database_name = d.name
where d.name like @dbname
	and DbBkp.name like @recovery
order by  d.name,DbBkp.backup_finish_date desc
