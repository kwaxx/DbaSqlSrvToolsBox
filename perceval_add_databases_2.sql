-- ### SERVER ###
declare @servername varchar(32) = 'ACCDBMS-01\MSSQL_UAT_10,1433'
declare @servertype int = ''
declare @server_desc varchar(128) = ''
declare @server_prod int = ''
declare @server_hdesk_overseeing int = ''
declare @server_emergency_accessallowed int = ''
declare @server_loc varchar(16) = null

select * from [server] order by SERVER_NAME
/*
SRVTYPE_PK	SRVTYPE_NAME	SRVTYPE_DESC
0			N.S.			Not Specified
1			SQL2K			Serveurs MS SQL 2000
2			SQL2K5			Serveurs MS SQL 2005
10			SQL2K8			Serveurs MS SQL 2008
11			SQL2012			Serveurs MS SQL 2012
12			SQL2014			Serveurs MS SQL 2014
13			SQL2016			Serveurs MS SQL 2016
14			SQL2017			Serveurs MS SQL 2017
*/

select * from [database]
/*
DBTYPE_PK	DBTYPE_NAME	DBTYPE_DESC
-----------------------------------
1			DEV			Bases de développement
2			PREPROD		Bases de pré-production
3			PROD		Bases de production
4			RECETTE		Bases de recette
5			HDESK		Bases dédiées au Help Desk
6			TECH		Bases dédiées au Service Technique
7			MEP			Bases dédiées aux tests de mise en production
8			TEMP		Bases temporaires
*/
