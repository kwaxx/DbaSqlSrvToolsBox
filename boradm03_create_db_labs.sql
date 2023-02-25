use master
-- alter database [Labs] set single_user
drop database if exists [Labs]

create database [Labs]
on primary (name = 'Labs', 
			filename = 'E:\ADM\labs.mdf' , 
			size = 512MB , 
			filegrowth = 256MB )
 log on (name = 'Labs_log', 
		filename = 'L:\ADM\labs_log.ldf' , 
		size = 4MB , 
		filegrowth = 4MB )
collate Latin1_General_CI_AS

alter database [Labs] set compatibility_level = 130
alter database [Labs] set recovery simple
alter authorization on database::[Labs] to [sa]

/*
restore database [Perceval]
from disk='\\auto-contact.com\das\Environnements\PRD\SQLBackup\tmp\BRAX_Perceval_Full_Copy_Only_2019_11_19_182103.bak'with file = 1, 
move 'Perceval' to 'E:\ADM\Perceval.mdf' ,
move 'Perceval_log' to 'L:\ADM\Perceval_log.mdf ' ,
replace, stats = 5, 
recovery exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_LogicialFiles_Name] [Perceval] 
exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_Database_Owner] [Perceval],'sa' 
exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].Update_Compatibility_Level [Perceval]
*/

use Perceval
exec [INFRASTRUCTURE.COMMAND].[DBA.SECURITY].[Update_Users] [Perceval],'%', 1, 1, 1

use [INFRASTRUCTURE.COMMAND]
SELECT name FROM [DBA.SECURITY.CONFIG].vwServer_Login
