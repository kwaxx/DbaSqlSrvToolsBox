/*
### TODO ###
Copier les les procédure stockées d'une instance vers une autre

AldPPRD
dbo.spa_www_ListerApplications
exec sp_helptext 'AldPPRD.dbo.spa_www_ListerApplications'

*/
select * from sys.objects
select distinct type, type_desc from sys.objects

declare @stored_procedures varchar(max)
