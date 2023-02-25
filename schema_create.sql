-- ### Schema create in dbs ###
-- fill ~dbs param
-- select database_id, name from sys.databases order by database_id
print @@servername + ',' + db_name()

declare @schema varchar(32) = 'DATA_EXTRACTION'
declare @userpermission varchar(64) = 'KLINGON\ACC.dataextraction'
declare @permission varchar(256) = 'ALTER, DELETE, EXECUTE, SELECT, UPDATE' --  SELECT, INSERT, DELETE, UPDATE, ALTER, EXECUTE, REFERENCES, VIEW DEFINITION, VIEW CHANGE TRACKING

declare @i int = 0
declare @dbname varchar(max)
if object_id('tempdb..#DbNames') is not null begin drop table #dbnames end
create table #dbnames(id int, name varchar(max))

insert into #dbnames(id, name)
	select row_number() over(order by name) id, name
	from master.sys.databases 
	where state = 0
	-- ~dbs
	and name in ('Labs', 'GVFSra', 'Perceval')

while (@i < (select count(*) from #DbNames))
begin
	set @i +=1
	set @Dbname = (select name from #DbNames where Id = @i)	
		print(	'use ' + QUOTENAME(@DbName) + 
				' exec (''create schema ' + quotename(@schema) + ' authorization [dbo]' +
				' grant ' + @permission + ' on schema :: '+ @schema +' to ' + quotename(@userpermission) + ''')')
end
