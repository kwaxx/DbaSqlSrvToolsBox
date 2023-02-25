declare  @string varchar(max)
set @string = ('AvisPTGUAT
    - CitroenPtgUAT
    - FiatPtgUAT
    - FordPtgUAT
    - KiaPtgUAT
    - NissanPtgUAT
    - GMPtgUAT
    - PeugeotPtgUAT
    - SeatPtgUAT
    - ToyotaPtgUAT
	')
declare @delimiter varchar(max) 
set @delimiter = '-'
declare @xml xml
declare @output table(datasplit varchar(max))

set @xml = cast(('<a>'+replace(@string,@delimiter,'</a><a>')+'</a>') AS XML)
 
INSERT INTO @output (datasplit)
	SELECT replace(replace(replace(ltrim(rtrim(A.value('.', 'varchar(max)'))),char(9),''),char(10),''),char(13),'') FROM @Xml.nodes('a') AS FN(a)

if OBJECT_ID('tempdb..#DbNames') is not null
    DROP TABLE #DbNames

CREATE TABLE #DbNames(
Id int,
name varchar(max)
)

INSERT INTO #DbNames(Id, name)
	select ROW_NUMBER() OVER(ORDER BY datasplit ASC) id, datasplit  from @output

declare @i int
declare @DbName VARCHAR(MAX)

set @i = 0

while (@i < (select count(*) from @output))
begin
	SET @i +=1
	SET @DbName = (select name from #DbNames where Id = @i)
	PRINT (@i)
	PRINT (@DbName)
	
	/*
	IF EXISTS (select 1 from sys.objects where name = 'DATA_EXTRACTION') 
	BEGIN
		EXEC ('USE [' + @DbName + ']' +
				'CREATE SCHEMA [DATA_EXTRACTION] AUTHORIZATION [dbo]' +
				'GRANT ALTER, DELETE, EXECUTE, SELECT, UPDATE ON SCHEMA :: DATA_EXTRACTION TO [KLINGON\ACC.dataextraction]'
			)
	END
	*/

	/*
	EXEC ('ALTER DATABASE [' + @DbName + '] '
		+ 'SET CHANGE_TRACKING = ON'
		+ '(CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON)'
		)
	*/
end

/*
select DB_NAME(database_id),* from sys.change_tracking_databases
select DB_NAME(database_id),* from sys.change_tracking_databases where DB_NAME(database_id) in ('AvisPTGUAT', 'CitroenPtgUAT', 'FiatPtgUAT', 'FordPtgUAT', 'KiaPtgUAT', 'NissanPtgUAT', 'GMPtgUAT', 'PeugeotPtgUAT', 'SeatPtgUAT', 'ToyotaPtgUAT')
### CHANGE TRACKING ACTIVE ###
ALTER DATABASE [DB] 
SET CHANGE_TRACKING = ON  
(CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON)
--------------------
### CREATION DE SHEMA ###
CREATE SCHEMA DATA_EXTRACTION [AUTHORIZATION dbo]
GRANT ALTER, DELETE, EXECUTE, SELECT, UPDATE ON SCHEMA :: DATA_EXTRACTION TO [KLINGON\DEV.dataextraction]
GRANT ALTER, DELETE, EXECUTE, SELECT, UPDATE ON SCHEMA :: DATA_EXTRACTION TO [KLINGON\PRD.dataextraction]
*/
