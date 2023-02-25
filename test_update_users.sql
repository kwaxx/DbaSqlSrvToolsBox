/*
db restauration et application des droits
instance ACCDBMS-01\MSSQL_UAT_10
SiCiblePtgV2

BACKUP_LOCATION = \\auto-contact.com\das\Environnements\PRD\SQLBackup\ATLANTIS3_MSSQLPROD07\Full\SiCiblePTGV2_BackUp_Full.bak
*/
use master
restore headeronly from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\ATLANTIS3_MSSQLPROD07\Full\SiCiblePTGV2_BackUp_Full.bak'
restore filelistonly from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\ATLANTIS3_MSSQLPROD07\Full\SiCiblePTGV2_BackUp_Full.bak'

restore database [SiCiblePTGV2]
from disk = '\\auto-contact.com\das\Environnements\PRD\SQLBackup\ATLANTIS3_MSSQLPROD07\Full\SiCiblePTGV2_BackUp_Full.bak'
with file = 1,
MOVE 'SICiblePTGV2' to 'E:\ADM\SICiblePTGV2.mdf',
MOVE 'SICiblePTGV2_Index' to 'E:\ADM\SICiblePTGV2_idx.mdf',
MOVE 'SICiblePTGV2_log' to 'L:\ADM\SICiblePTGV2_log.ldf',
STATS = 5
go

exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_LogicialFiles_Name] [SiCiblePTGV2]
/*
The logical file 'SiCiblePTGV2' is already in use !
The file name 'SiCiblePTGV2_1' has been set.
Changing logical file name from 'SICiblePTGV2_Index' to 'SiCiblePTGV2_1' !
The logical file 'SiCiblePTGV2_Log' is already in use !
*/
exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_Database_Owner] [SiCiblePTGV2],'sa' 
exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].Update_Compatibility_Level [SiCiblePTGV2]
exec [INFRASTRUCTURE.COMMAND].[DBA.SECURITY].[Update_Users] [SiCiblePTGV2], '%', 1, 1, 1

/*
@Database_Name AS SYSNAME,
@User_Name AS SYSNAME='%',
@keepPreviousRights AS BIT =0,
@Output AS BIT=0,
@Debug AS BIT=0
*/

select * from sys.server_principals where name like 'AutoContact'
select * from sys.server_role_members where member_principal_id = 272

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
