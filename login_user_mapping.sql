declare @login varchar(max)
declare @user varchar(max)

set @login = 'KLINGON\PRDiis.app'  
set @user = 'KLINGON\preprdiis.app'

if object_id('tempdb..#DbNames') is not null
    drop table #DbNames

Create table #DbNames(
	id int,
	name varchar(max)
)

insert into #DbNames(id, name)
	select row_number() over (order by name) id, name
	from master.sys.databases 
	where state = 0
	and database_id > 4

declare @i int
declare @DbName varchar(max)
declare @Qry varchar(max)
set @i = 0

while(@i < (select count(*) from #DbNames))
begin
	set @i +=1
	set @DbName = (select name from #DbNames where Id = @i)
	set @Qry = 'use [' +@DbName + ']' + ' 
				if exists(select distinct 1 from sys.database_principals where name like '''+ @login + ''')
				begin
					ALTER USER ['''+ @user + '''] WITH login = ['''+ @login + ''']
				end
				'
	print (@Qry)
end
