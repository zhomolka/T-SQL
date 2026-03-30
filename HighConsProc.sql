SELECT 
    DB_NAME(qs.database_id) AS [DatabaseName],
    OBJECT_NAME(qs.object_id, qs.database_id) AS [ProcedureName],
    qs.execution_count,
    qs.total_worker_time / qs.execution_count AS [AvgCPUTime],
    qs.total_elapsed_time / qs.execution_count AS [AvgElapsedTime],
    qs.total_logical_reads / qs.execution_count AS [AvgLogicalReads],
    qs.total_logical_writes / qs.execution_count AS [AvgLogicalWrites]
FROM 
    sys.dm_exec_procedure_stats AS qs
WHERE 
    qs.database_id = DB_ID('YourDatabaseName')
ORDER BY 
    [AvgCPUTime] DESC;