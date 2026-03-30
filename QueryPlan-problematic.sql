DECLARE @from AS datetime=DATEADD(DAY,-7,GETDATE())
SELECT * FROM (
SELECT TOP 100
    TextData           = qt.text 
    ,ObjectName          = OBJECT_SCHEMA_NAME(qt.objectid,qt.dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)
	,QueryPlan = qp.query_plan
	,CASE WHEN CAST(qp.query_plan AS nvarchar(max)) LIKE '%MissingIndex%' THEN 'Missing' ELSE '' END as Miss
    ,DiskReads          = qs.total_physical_reads   -- The worst reads, disk reads
    ,MemoryReads        = qs.total_logical_reads    --Logical Reads are memory reads
    ,Executions         = qs.execution_count
    ,TotalCPUTime       = qs.total_worker_time
    ,AverageCPUTime     = qs.total_worker_time/qs.execution_count
    ,DiskWaitAndCPUTime = qs.total_elapsed_time
    ,MemoryWrites       = qs.max_logical_writes
    ,DateCached         = qs.creation_time
    ,LastExecutionTime  = qs.last_execution_time
    ,DatabaseName       = DB_Name(qt.dbid)
from sys.dm_exec_query_stats as qs
 OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) as qp
 CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
where qs.last_execution_time>@from --časová podmínka
ORDER BY qs.total_worker_time DESC) as phase1
WHERE 1=1
 and Miss='Missing'
 and TextData NOT LIKE '%FROM Message%'
-- and DatabaseName LIKE '%srec%'
-- and TextData LIKE '%srec%'