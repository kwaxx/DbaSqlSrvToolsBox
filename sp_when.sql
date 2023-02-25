-- when whas the last database access
SELECT @@servername, 
	d.name,
	d.state,
last_user_seek = MAX(last_user_seek),
last_user_scan = MAX(last_user_scan),
last_user_lookup = MAX(last_user_lookup),
last_user_update = MAX(last_user_update)
FROM sys.databases d 
	left JOIN sys.dm_db_index_usage_stats i ON i.database_id=d.database_id
GROUP BY d.name, d.state
-- having lower(d.name) like '%adfs%'
order by d.name asc, last_user_update desc
