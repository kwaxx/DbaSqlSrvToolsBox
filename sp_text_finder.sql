IF OBJECT_ID('tempdb..#DbNames') IS NOT NULL
    DROP TABLE #DbNames

CREATE TABLE #DbNames(
Id int,
name varchar(max)
)

INSERT INTO #DbNames(Id, name)
	SELECT row_number() OVER (ORDER BY name) Id, name
	FROM master.sys.databases 
	WHERE state = 0
	AND name not like '%tempdb%'

DECLARE @i int
DECLARE @DbName varchar(max)
SET @i = 0

DECLARE @NbDB int
SET @NbDb = (select count(*) from #DbNames)

PRINT ('---- Nombre de bases ----')
PRINT (@NbDb)

WHILE(@i < @NbDb)
BEGIN
	SET @i +=1
	SET @DbName = (select name from #DbNames where Id = @i)
	PRINT (@i)
	PRINT (@DbName)
	
	EXEC (
		'USE [' + @DbName + '] ' +
		'select db_name() DbName, name, definition
		from sys.objects obj
			inner join sys.sql_modules mod on mod.object_id = obj.object_id
		where obj.type = ''P''
			and lower(definition) like ''%kanda%'' or definition like(''%172.16.1.33%'')'
		)
END
