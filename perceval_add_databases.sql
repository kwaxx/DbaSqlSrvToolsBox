/*
USE PErceval
PERCEVAL: ADD SERVER
*/

SELECT * FROM dbo.[SERVER] WHERE SERVER_NAME like '%ACCDBMS-05\MSSQL_UAT_07%'

select * from [DATABASE] where SERVER_PK = 140
-- select * from [DATABASE] where RESTORE_FILE is null
select * from [DATABASE] where BASE_NAME like 'Lineos3Dev'

select * from [dbo].[DATABASE_TYPE]

select * from [DATABASE] order by BASE_PK desc
/*
BEGIN TRAN
	INSERT INTO [DATABASE] VALUES (188, 'MNG_IT_DWH', 1, NULL, NULL, NULL, 'F:\Program Files\Microsoft SQL Server\MSSQL13.DEV_BI\MSSQL\Data\', 'G:\Program Files\Microsoft SQL Server\MSSQL13.DEV_BI\MSSQL\Data\')
	INSERT INTO [DATABASE] VALUES (188, 'MNG_IT_FRAMEWORK', 1, NULL, NULL, NULL, 'F:\Program Files\Microsoft SQL Server\MSSQL13.DEV_BI\MSSQL\Data\', 'G:\Program Files\Microsoft SQL Server\MSSQL13.DEV_BI\MSSQL\Data\')
	INSERT INTO [DATABASE] VALUES (188, 'MNG_IT_STG', 1, NULL, NULL, NULL, 'F:\Program Files\Microsoft SQL Server\MSSQL13.DEV_BI\MSSQL\Data\', 'G:\Program Files\Microsoft SQL Server\MSSQL13.DEV_BI\MSSQL\Data\')
	
	SELECT * from [DATABASE] where SERVER_PK = 188
ROLLBACK TRAN
*/

select * from [DATABASE] where BASE_NAME like 'Lineos3Dev'
/*
OLD=> '\\accanon-fs-01\SQLDBANON\BcEspProd_BackUp_Full.bak'
NEW => '\\accanon-fs-01\SQLDBANON\KiaDeuProd_BackUp_Full.bak'

BEGIN TRAN
	select * from [DATABASE] where BASE_NAME like 'Lineos3Dev'

	UPDATE [DATABASE]
	SET RESTORE_FILE = '\\accanon-fs-01\SQLDBANON\KiaDeuProd_BackUp_Full.bak',
		BASE_DESC = 'ticket 300987'
	where BASE_NAME like 'Lineos3Dev'

	select * from [DATABASE] where BASE_NAME like 'Lineos3Dev'
COMMIT TRAN
*/

/*
BEGIN TRAN
	SELECT * from [DATABASE] where SERVER_PK = 140
	
	INSERT INTO [DATABASE] VALUES (140, 'Lineos3UAT', 1, 'ticket 300987', NULL, '\\accanon-fs-01\SQLDBANON\KiaDeuProd_BackUp_Full.bak', 'D:\Microsoft SQL Server\MSSQL12.MSSQL_UAT_07\MSSQL\DATA', 'E:\Microsoft SQL Server\MSSQL12.MSSQL_UAT_07\MSSQL\DATA')
	
	SELECT * from [DATABASE] where SERVER_PK = 140
COMMIT TRAN
*/
