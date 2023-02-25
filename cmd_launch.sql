-- select * from sys.configurations where name in ('show advanced options', 'optimize for ad hoc workloads', 'xp_cmdshell')
select * from sys.master_files order by name desc
declare @sql varchar(400) = 'dir /b e:\adm'

if (select object_id('tempdb..#output')) is not null begin drop table tempdb.#output end 
create table #output (line varchar(255))
insert #output exec xp_cmdshell @sql

select * from #output
