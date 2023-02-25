-- ### db size ###
-- sp_helpdb
select
	@@SERVERNAME 'servername',
	type,
	db_name(database_id) 'dbname',	
	name 'file',
	size,
	size * 8/1024 'size (MB)',
	size * 8/1024/1024 'size (GO)',
	sum(size * 8/1024/1024) over(partition by name) 'size total (GO)',
	max_size
from sys.master_files m
where database_id > 4
	and name not like 'INFRASTRUCTURE.%'
order by db_name(database_id) 