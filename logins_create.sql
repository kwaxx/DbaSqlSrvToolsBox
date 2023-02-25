USE [master]

GO

CREATE LOGIN [KLINGON\prdsql.reportpbifo] FROM WINDOWS WITH DEFAULT_DATABASE=[master]

GO

-- from https://www.sqlshack.com/move-or-copy-sql-logins-with-assigning-roles-and-permissions/

SELECT 'IF (SUSER_ID('+QUOTENAME(SP.name,'''')+') IS NULL) BEGIN CREATE LOGIN ' +QUOTENAME(SP.name)+
               CASE 
                    WHEN SP.type_desc = 'SQL_LOGIN' THEN ' WITH PASSWORD = ' +CONVERT(NVARCHAR(MAX),SL.password_hash,1)+ ' HASHED, CHECK_EXPIRATION = ' 
                        + CASE WHEN SL.is_expiration_checked = 1 THEN 'ON' ELSE 'OFF' END +', CHECK_POLICY = ' +CASE WHEN SL.is_policy_checked = 1 THEN 'ON,' ELSE 'OFF,' END
                    ELSE ' FROM WINDOWS WITH'
                END 
       +' DEFAULT_DATABASE=[' +SP.default_database_name+ '], DEFAULT_LANGUAGE=[' +SP.default_language_name+ '] END;' COLLATE SQL_Latin1_General_CP1_CI_AS AS [-- Logins To Be Created --]
FROM sys.server_principals AS SP 
LEFT JOIN sys.sql_logins AS SL ON SP.principal_id = SL.principal_id
WHERE SP.type IN ('S','G','U')
        AND SP.name NOT LIKE '##%##'
        AND SP.name NOT LIKE 'NT AUTHORITY%'
        AND SP.name NOT LIKE 'NT SERVICE%'
        AND SP.name <> ('sa')
        AND SP.name <> 'distributor_admin'

SELECT 
'EXEC master..sp_addsrvrolemember @loginame = N''' + SL.name + ''', @rolename = N''' + SR.name + ''';
' AS [-- Roles To Be Assigned --]
FROM master.sys.server_role_members SRM
INNER JOIN master.sys.server_principals SR ON SR.principal_id = SRM.role_principal_id
    JOIN master.sys.server_principals SL ON SL.principal_id = SRM.member_principal_id
WHERE SL.type IN ('S','G','U')
        AND SL.name NOT LIKE '##%##'
        AND SL.name NOT LIKE 'NT AUTHORITY%'
        AND SL.name NOT LIKE 'NT SERVICE%'
        AND SL.name <> ('sa')
        AND SL.name <> 'distributor_admin';