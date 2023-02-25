declare  @string varchar(max)
set @string = ('* DEVDBMSBI-01\DEV_BI,1433
				* DEVSSIS-01\MSSQL_DEV_SSIS,1433
				* ACCDBMSBI-02\UAT_BI,1434
				* ACCSSIS-01\UAT_SSIS,1492
				* PPRDDBMS-01\PREPROD_01,1492
				* PPRDDBMS-01\PREPROD_02,1789
				* PPRDDBMS-01\PREPROD_03,1433
				* AS-PRD-BI-SQL01\DECIUSDB_01,14003
				* AS-PRD-BI-SSI01\ETLDB_PRD,14003
				* PRDDBMS-02\PRD_KAS,2866
				* PRDDBMS-02\PRD_MAN,2867
				* PRDTFS-01\HPALM,2866
				* REGULON\MONITORING01,49533
				')
declare @delimiter varchar(max) 
set @delimiter = '*'
declare @xml xml
declare @output table(datasplit varchar(max))

set @xml = cast(('<a>'+replace(@string,@delimiter,'</a><a>')+'</a>') as xml)

select replace(replace(replace(ltrim(rtrim(a.value('.', 'varchar(max)'))),char(9),''),char(10),''),char(13),'') 
from @Xml.nodes('a') AS FN(a)
where a.value('.', 'varchar(max)') != ''

print (':CONNECT DEVDBMSBI-01\DEV_BI,1433
		select @@SERVERNAME
')
