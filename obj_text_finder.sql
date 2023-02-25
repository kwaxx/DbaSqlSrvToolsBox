/*
### sp_text_finder 2 ###

select db_name() 'db', sh.name 'schema', type_desc, obj.name 'object', definition 
from sys.sql_modules mod
	left join sys.objects obj on obj.object_id = mod.object_id
	left join sys.schemas sh on sh.schema_id = obj.schema_id
*/
set nocount on
declare @lookfor varchar(max) = 'osql' -- xp_cmdshell, osql
declare @dblookfor varchar(max) = '%'
declare @i int = 1
declare @objectfound table(db nvarchar(64), shema nvarchar(256), object_type nvarchar(64), nam nvarchar(256), def nvarchar(max)) 
declare @qry varchar(max)

declare @dbnames table( id int, name varchar(max))
insert into @dbnames(id, name)
	select row_number() over(order by name) Id, name
	from master.sys.databases
	where state = 0
		and name like @dblookfor

declare @delimiter varchar(max) 
set @delimiter = ','
declare @xml xml
declare @output table(datasplit varchar(max))
declare @countpositions int
set @xml = cast(('<a>'+replace(@lookfor,@delimiter,'</a><a>')+'</a>') AS XML)
 
while @i<= (select count(*) from @dbnames)
begin
	insert into @output (datasplit) 
		select replace(replace(replace(ltrim(rtrim(A.value('.', 'varchar(max)'))),char(9),''),char(10),''),char(13),'') FROM @Xml.nodes('a') AS FN(a)
	set @countpositions = (select count(datasplit) from @output)

	set @qry = 'use ' + quotename((select name from @dbnames where id = @i)) +
				' select db_name(), sh.name, type_desc, obj.name, definition 
				from sys.sql_modules mod
					left join sys.objects obj on obj.object_id = mod.object_id
					left join sys.schemas sh on sh.schema_id = obj.schema_id
				'
	while (select count(datasplit) from @output) !=0
	begin
		if @countpositions = (select count(datasplit) from @output)
		begin
			set @qry += 'where definition like ''%' + (select top 1 datasplit from @output) + '%'' '
		end
		else
		begin
			set @qry += 'or definition like ''%' + (select top 1 datasplit from @output)+ '%'' '
		end
		delete from @output where datasplit = (select top 1 datasplit from @output) 
	end

	set @i += 1
	insert into @objectfound exec (@qry)
end
select * from @objectfound
