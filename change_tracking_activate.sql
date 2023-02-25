-- ### change tracking ###
set nocount on
print '-- '+ @@servername

if object_id('tempdb..#DbNames') is not null begin drop table #DbNames end
create table #DbNames( id int, name varchar(max))

-- ? dbs 
insert into #DbNames(id, name)
	select row_number() over (order by name) id, name
	from master.sys.databases
	where state = 0
		and name in ( 'GVFSra', 'labs', 'perceval')

declare @i int = 1
declare @dbname varchar(max)

-- ? retention
while (@i < (select count(*) from #DbNames))
begin	
	set @dbname = (select name from #dbnames where id = @i)
	set @i +=1
	print ('alter database [' + @DbName + '] set change_tracking = on (change_retention = 2 days, auto_cleanup = on)')	
end
