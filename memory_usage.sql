SELECT SUM(allocated_bytes) / (1024 * 1024) AS total_allocated_MB, 
       SUM(used_bytes) / (1024 * 1024) AS total_used_MB
FROM sys.dm_xtp_system_memory_consumers; 


SELECT memory_consumer_type, 
       memory_consumer_type_desc, 
       allocated_bytes / 1024 [allocated_bytes_kb], 
       used_bytes / 1024 [used_bytes_kb], 
       allocation_count
FROM sys.dm_xtp_system_memory_consumers;

SELECT type clerk_type, 
       name, 
       memory_node_id, 
       pages_kb / 1024 pages_mb
FROM sys.dm_os_memory_clerks
WHERE type LIKE '%xtp%';

select
(physical_memory_in_use_kb/1024)Phy_Memory_usedby_Sqlserver_MB,
(locked_page_allocations_kb/1024 )Locked_pages_used_Sqlserver_MB,
(virtual_address_space_committed_kb/1024 )Total_Memory_UsedBySQLServer_MB,
process_physical_memory_low,
process_virtual_memory_low
from sys. dm_os_process_memory
