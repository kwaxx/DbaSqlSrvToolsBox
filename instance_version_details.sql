-- SELECT @@servername, serverproperty('instancename'), SERVERPROPERTY('productversion')as VERSION, SERVERPROPERTY ('productlevel') as SP, serverproperty('ProductUpdateLevel') as CU, SERVERPROPERTY ('edition') as EDITION

select 
	CASE 
		WHEN CHARINDEX('\',@@SERVERNAME) > 0 THEN
			LEFT(@@SERVERNAME,CHARINDEX('\',@@SERVERNAME)-1)
		ELSE
			@@SERVERNAME
	END 'server',
	substring(@@VERSION,0,26) 'version_sql', 
	CASE 
		WHEN CHARINDEX('(SP',@@VERSION) > 0 THEN
			SUBSTRING(@@VERSION,CHARINDEX('(SP',@@VERSION)+1,3)
		ELSE
			''
	END 'sp',
	CASE 
		WHEN CHARINDEX('-CU',@@VERSION) > 0 THEN
			replace(replace(SUBSTRING(@@VERSION,CHARINDEX('-CU',@@VERSION)+1,4), '-', ''),')','')
		ELSE
			''
	END 'cu',
		CASE 
		WHEN CHARINDEX('(KB',@@VERSION) > 0 THEN
			replace(replace(SUBSTRING(@@VERSION,CHARINDEX('(KB',@@VERSION)+1,10), '-', ''),')','')
		ELSE
			''
	END 'kb',	
	CASE 
		WHEN CHARINDEX('(X64)',@@VERSION) > 0 THEN
			replace(replace(SUBSTRING(@@VERSION,CHARINDEX('(X64)',@@VERSION)-13,12),CHAR(10), ''),char(13),'')
		ELSE
			''
	END '(X64)',
	@@VERSION 'version_full'

