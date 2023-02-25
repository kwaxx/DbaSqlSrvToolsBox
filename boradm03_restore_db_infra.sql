restore filelistonly from disk = 'E:\Backup\INFRASTRUCTURE.CONFIG_BackUp_Full.bak' 

use [master]

restore database [INFRASTRUCTURE.CONFIG] 
from disk = 'E:\Backup\INFRASTRUCTURE.CONFIG_BackUp_Full.bak' 
with file = 1,  
move 'INFRASTRUCTURE.CONFIG' TO N'E:\ADM\infra_config.mdf',  
move 'INFRASTRUCTURE.CONFIG_Log' TO N'L:\ADM\infra_config_log.ldf',  
replace, stats = 5, recovery

restore database [INFRASTRUCTURE.COMMAND] 
from disk = 'E:\Backup\INFRASTRUCTURE.COMMAND_BackUp_Full.bak' 
with file = 1,  
move 'INFRASTRUCTURE.COMMAND' TO N'E:\ADM\infra_command.mdf',  
move 'INFRASTRUCTURE.COMMAND_Log' TO N'L:\ADM\infra_command_log.ldf',  
replace, stats = 5, recovery

exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_LogicialFiles_Name] [INFRASTRUCTURE.CONFIG] 
exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_Database_Owner] [INFRASTRUCTURE.CONFIG] , 'sa'
exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].Update_Compatibility_Level [INFRASTRUCTURE.CONFIG] 
exec [INFRASTRUCTURE.COMMAND].[DBA.SECURITY].[Update_Users] [INFRASTRUCTURE.CONFIG] 

alter database [INFRASTRUCTURE.COMMAND] set recovery simple
alter database [INFRASTRUCTURE.CONFIG] set recovery simple
