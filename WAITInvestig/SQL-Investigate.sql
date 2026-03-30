SET NOCOUNT ON
GO
PRINT'===================================================='
PRINT'==================@@SERVERNAME======================'
SELECT @@SERVERNAME AS 'SQL Server Name' 
GO 
PRINT'===================@@VERSION========================'
SELECT @@VERSION AS 'Build Version' 
GO 
PRINT'===================Memory========================'
SELECT name, value_in_use FROM sys.configurations WHERE name in ('Ad Hoc Distributed Queries', 'cost threshold for parallelism', 'max degree of parallelism', 'max worker threads', 'max server memory (MB)', 'min server memory (MB)') 
GO
PRINT'===================MSInfo32========================'
GO
xp_msver
GO
PRINT'===================SP_Configure========================'
GO
sp_configure 'show advanced options',1
GO
Reconfigure
GO
sp_configure 
GO
PRINT'===================ClusterNodes========================'
SELECT * FROM sys.dm_os_cluster_nodes 
GO
PRINT'===================CurrentNodeName========================'
SELECT SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [CurrentNodeName] 
SELECT SERVERPROPERTY('MachineName') AS [MachineName] 
SELECT SERVERPROPERTY('ServerName') AS [ServerName] 
SELECT SERVERPROPERTY('IsClustered') AS [IsClustered] 
GO
PRINT'===================OS_sys_info========================'
SELECT sqlserver_start_time FROM sys.dm_os_sys_info
GO
PRINT'===================SP_Helpdb========================'
GO
Sp_helpdb
GO
PRINT'===================Tempdb========================'
GO
sp_helpdb 'tempdb'
GO 
PRINT'===================Databases========================'
SELECT db_name(database_id) snapshot_isolation_state,snapshot_isolation_state_desc,is_read_committed_snapshot_on, * from sys.databases 
PRINT'===================Loaded Modules========================'
SELECT product_version, company, description, name FROM sys.dm_os_loaded_modules WHERE company not like '%Microsoft Corp%'
GO
PRINT'===================Traces========================'
DBCC traceon(3604)
GO
DBCC tracestatus ()
GO
PRINT'===================CurrentTime========================'
PRINT N'Current Time (UTC)       ' + Convert(NChar(23), Current_TimeStamp, 121) + N' (' + Convert(NChar(23), GetUTCDate(), 121) + N')';  
PRINT'========================================================='
PRINT'=======================END================================'
SET NOCOUNT OFF
GO
