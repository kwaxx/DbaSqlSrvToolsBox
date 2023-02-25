/*
use master
alter database [BMWItlDev] set single_user with rollback immediate
drop database [BMWItlDev]

restore database [BMWItlDev]
from disk='\\auto-contact.com\das\Environnements\PRD\SQLBackup\ATLANTIS_MSSQLPRODAC01\Full\BMWItlProd_BackUp_Full.bak'
with file = 1, 
move 'BMWItlProd' to 'E:\ADM\BMWItlDev.mdf',
move 'BMWItlProd_Log' to 'L:\ADM\BMWItlDev_log.mdf ',
replace, stats = 5, recovery 

exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_LogicialFiles_Name] [BMWItlDev] 
exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].[Change_Database_Owner] [BMWItlDev],'sa' 
exec [INFRASTRUCTURE.COMMAND].[DBA.DATABASE].Update_Compatibility_Level [BMWItlDev] 
exec [INFRASTRUCTURE.COMMAND].[DBA.SECURITY].[Update_Users]
															@Database_Name AS SYSNAME,
															@User_Name AS SYSNAME='%',
															@keepPreviousRights AS BIT =0,
															@Output AS BIT=0,
															@Debug AS BIT=0
*/

-- select 'LOGIN' 'login', * from sys.server_principals where type in ('S', 'U') and name not like ('NT %') and name not like ('##%##') and name not like ('sa')
-- select 'USER' 'user',db_name() 'db', * from sys.database_principals where type in ('S', 'U') and name like '%prd%'

-- exec [INFRASTRUCTURE.COMMAND].[DBA.SECURITY].[Update_Users] [BMWItlDev], '%', 1, 1, 1
-- select * from sys.databases 
use BMWItlDev
set nocount on
declare @fromenv nvarchar(4) = 'prd'
declare @toenv nvarchar(4) = 'dev'

if object_id('tempdb..#logins_users_stmt') is not null begin drop table #logins_users_stmt end
create table #logins_users_stmt(
id int,
login_create_qry nvarchar(max),
user_mapping_qry varchar(max)
)

insert into #logins_users_stmt(id, login_create_qry, user_mapping_qry)
select row_number() over (order by name),
		case 
			when type_desc = 'WINDOWS_USER' then 
				'if (suser_id('+quotename(replace(name,@fromenv,@toenv),'''')+') is null)' +
					'begin create login ' + quotename(replace(name,@fromenv,@toenv)) + 
					' from windows with default_database=[master]' +
				' end;'
			else 'NOT A WINDOWS USER'
		end 'login_create_stmt',
		case
			when type_desc = 'WINDOWS_USER' then 
				'alter user [' + name +'] with login = [' + replace(name,@fromenv,@toenv) + '];'
			end 'map_login_user'
from sys.database_principals 
where type in ('S', 'U') 
and name like '%'+@fromenv+'%'

declare @i int = 0
declare @login_create_qry nvarchar(max)
declare @user_mapping_qry nvarchar(max)
while (@i <= (select count(*) from #logins_users_stmt))
begin
	set @login_create_qry = (select login_create_qry from #logins_users_stmt where id = @i) 
	set @user_mapping_qry = (select user_mapping_qry from #logins_users_stmt where id = @i) 
	print @login_create_qry
	print @user_mapping_qry
	set @i +=1
end
