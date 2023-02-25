select s.name as schema_name, 
    s.schema_id,
    u.name as schema_owner
from sys.schemas s
    inner join sys.sysusers u
        on u.uid = s.principal_id
order by s.name

select OBJECT_SCHEMA_NAME(id) Shema,
	type,
	name,
	crdate
from sys.sysobjects
order by OBJECT_SCHEMA_NAME(id)
