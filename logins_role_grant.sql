/*
-- ### logins and users rights ###
select principal_id, type_desc, name, create_date, modify_date 
from sys.server_principals 
where type_desc like '%LOGIN%' 
	and name not like '%##%' 
order by name
*/
declare @login varchar(64) = '%'
declare @cmdprint int = 1

-- login
select *
from
(
select 'LOGIN' 'login', spm.name, spr.type_desc, spr.name collate SQL_Latin1_General_CP1_CI_AI 'right'
from sys.server_role_members srm
	left join sys.server_principals spm on spm.principal_id = srm.member_principal_id
	left join sys.server_principals spr on spr.principal_id = srm.role_principal_id
union
select'LOGIN' 'login',  pr.name, per.state_desc, per.permission_name 'right'
from sys.server_permissions per
	inner join sys.server_principals pr on pr.principal_id = per.grantee_principal_id 
) T
where name like @login

-- users
declare @db table (id int, name nvarchar(64)) 
insert into @db select row_number() over(order by name)id , name from sys.databases where state = 0
declare @i int = 1
declare @qry varchar(max)

declare @userights table (usr varchar(4), db varchar(32), schem varchar(32), nam varchar(64), type_desc varchar(64), rights varchar(max))

while @i < (select count(*) from @db)
begin
	set @qry =	'use [' + (select name from @db where id = @i) + '] ' +
				'select ''USER'' ''user'', '' ' + (select name from @db where id = @i) + ' '' '' db '', * 
				from
					(
					select spm.default_schema_name ''schem'', spm.name, spr.type_desc, spr.name collate SQL_Latin1_General_CP1_CI_AI ''right''
					from sys.database_role_members srm
						left join sys.database_principals spm on spm.principal_id = srm.member_principal_id
						left join sys.database_principals spr on spr.principal_id = srm.role_principal_id
					union
					select pr.default_schema_name ''schem'', pr.name, per.state_desc, per.permission_name ''right''
					from sys.database_permissions per
						inner join sys.database_principals pr on pr.principal_id = per.grantee_principal_id 
					) T
					where name like'+ QUOTENAME(@login, '''')
	insert into @userights exec (@qry)
	set @i+=1
end
	select * from @userights -- where rights like '%owner%'

