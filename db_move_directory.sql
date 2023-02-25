select db_name(database_id) Dbname,
	type,
	name,
	physical_name,
	state
from sys.master_files 
-- where name like '%data%'

select * from sys.master_files where database_id > 4
 
use master
-- alter database [INFRASTRUCTURE.CONFIG] set offline with rollback immediate
alter database DataListenerOrchestrator
modify file ( 
				NAME = 'DataListenerOrchestratorIndexes',
				FILENAME = 'E:\DataListenerOrchestrator_INDEXES.ndf'
			)

alter database [INFRASTRUCTURE.CONFIG]
modify file ( 
				NAME = 'INFRASTRUCTURE.CONFIG_Log',
				FILENAME = 'L:\INFRA_CONFIG_log.LDF'
			)
-- alter database [INFRASTRUCTURE.CONFIG] set online

/*
alter database DataListenerOrchestrator set emergency
alter database DataListenerOrchestrator set multi_user
exec sp_detach_db 'DataListenerOrchestrator'
EXEC sp_attach_single_file_db @DBName = 'DataListenerOrchestrator', @physname = N'L:\DataListenerOrchestrator_log.ldf'
*/
