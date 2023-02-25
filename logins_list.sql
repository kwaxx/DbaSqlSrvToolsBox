select distinct usr.principal_id, usr.name, usr.type_desc, rol.name 'role'
from sys.server_principals as usr
	left join sys.server_role_members rlm on rlm.member_principal_id = usr.principal_id
	left join sys.server_principals rol on rol.principal_id = rlm.role_principal_id
where usr.type in ('S', 'U', 'G')
and usr.is_disabled != 1
order by usr.name

select * 
from sys.server_principals 
order by type, create_date desc

select *
from sys.database_permissions

select sp.name as login,
       sp.type_desc as login_type,
       sl.password_hash,
       sp.create_date,
       sp.modify_date,
       case when sp.is_disabled = 1 then 'Disabled'
            else 'Enabled' end as status
from sys.server_principals sp
left join sys.sql_logins sl
          on sp.principal_id = sl.principal_id
where sp.type not in ('G', 'R')
order by sp.name;