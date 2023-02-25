select * from sys.database_principals pr where name = 'bidataread-sql'
select * from sys.database_role_members where member_principal_id = 7
select * from sys.database_principals where principal_id in (select role_principal_id from sys.database_role_members  where member_principal_id = 7)

select member_principal_id,
dpr.name,
dpr.create_date,
dpr.modify_date,
dprr.name
from sys.database_role_members drm
	inner join sys.database_principals dpr on dpr.principal_id = drm.member_principal_id
	inner join sys.database_principals dprr on dprr.principal_id = drm.role_principal_id
-- order by dpr.name
where dpr.name = 'bidataread-sql'

select 
    class_desc 
    ,USER_NAME(grantee_principal_id) as user_or_role
    ,CASE WHEN class = 0 THEN DB_NAME()
          WHEN class = 1 THEN ISNULL(SCHEMA_NAME(o.uid)+'.','')+OBJECT_NAME(major_id)
          WHEN class = 3 THEN SCHEMA_NAME(major_id) END [Securable]
    ,permission_name
    ,state_desc
    ,'revoke ' + permission_name + ' on ' +
        isnull(schema_name(o.uid)+'.','')+OBJECT_NAME(major_id)+ ' from [' +
        USER_NAME(grantee_principal_id) + ']' as 'revokeStatement'
    ,'grant ' + permission_name + ' on ' +
        isnull(schema_name(o.uid)+'.','')+OBJECT_NAME(major_id)+ ' to ' +
        USER_NAME(grantee_principal_id) + ']' as 'grantStatement'
from sys.database_permissions dp
	left outer join sysobjects o on o.id = dp.major_id
where USER_NAME(grantee_principal_id) in ('bidataread-sql')
order by 	class_desc desc,
			USER_NAME(grantee_principal_id),
			CASE WHEN class = 0 THEN DB_NAME()
				WHEN class = 1 THEN isnull(schema_name(o.uid)+'.','')+OBJECT_NAME(major_id)
				WHEN class = 3 THEN SCHEMA_NAME(major_id) end,
			permission_name
