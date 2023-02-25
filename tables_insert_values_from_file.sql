/* 
PREPROD: PPRDDBMS-01\PREPROD_03
TABLE:	[INFRASTRUCTURE.CONFIG].CONFIG.PROPERTY
		[INFRASTRUCTURE.CONFIG.BUSINESS].LNS.*

USE [INFRASTRUCTURE.CONFIG]
select @@IDENTITY
DBCC CHECKIDENT ('[INFRASTRUCTURE.CONFIG].CONFIG.PROPERTY', RESEED, 0)
*/
-- delete from CONFIG.PROPERTY where Property_Id = 0
-- delete from CONFIG.PROPERTY
-- INSERT INTO CONFIG.PROPERTY(Name, Label, Description, Property_Category_Fk, Property_Target_Type_Fk, Default_Value) VALUES ('SQL_SERVICE_URL	','	SQL_SERVICE_URL	','		',	3	,	1	,'	http://sqlservices-preprd.dekra-automotivesolutions.com	')

select * from [INFRASTRUCTURE.CONFIG.BUSINESS].LNS.PARAMETRAGE
-- update CONFIG.PROPERTY(Name, Label, Description, Property_Category_Fk, Property_Target_Type_Fk, Default_Value)

UPDATE LNS.PARAMETRAGE
SET LNS.PARAMETRAGE.PAR_NOM = TTRIM.PAR_NOM,
	LNS.PARAMETRAGE.PAR_DESACTIVABLE = TTRIM.PAR_DESACTIVABLE,
	LNS.PARAMETRAGE.PAR_TYPE = TTRIM.PAR_TYPE,
	LNS.PARAMETRAGE.PAR_DESCRIPTION = TTRIM.PAR_DESCRIPTION,
	LNS.PARAMETRAGE.CAT_ID = TTRIM.CAT_ID
FROM (select PAR_ID,	
rtrim(ltrim(replace(replace(replace(PAR_NOM,char(9),' '),char(10),' '),char(13),' '))) 'PAR_NOM', 
rtrim(ltrim(replace(replace(replace(PAR_DESACTIVABLE,char(9),' '),char(10),' '),char(13),' '))) 'PAR_DESACTIVABLE', 
rtrim(ltrim(replace(replace(replace(PAR_TYPE,char(9),' '),char(10),' '),char(13),' '))) 'PAR_TYPE', 
rtrim(ltrim(replace(replace(replace(PAR_DESCRIPTION,char(9),' '),char(10),' '),char(13),' '))) 'PAR_DESCRIPTION', 
rtrim(ltrim(replace(replace(replace(CAT_ID,char(9),' '),char(10),' '),char(13),' '))) 'CAT_ID'
from LNS.PARAMETRAGE
) TTRIM
WHERE LNS.PARAMETRAGE.PAR_ID = TTRIM.PAR_ID

select * from LNS.PARAMETRAGE
