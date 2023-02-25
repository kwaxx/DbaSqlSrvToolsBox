set nocount on
use master

if object_id('tempdb..#Db') is not null begin drop table #Db end
create table #db(id int, name varchar(max))
insert into #db select row_number() over (order by name) id,name from sys.databases where state = 0
declare @i int = 1
declare @qry varchar(max)

while @i <= (select count(*) from #db)
begin
	set @qry = 'use [' + (select name from #db where id = @i) + ']; '
	set @qry += 'select db_name() db from sys.database_principals where name like ''KLINGON\prdsql.agent''; '
	set @i += 1
end

