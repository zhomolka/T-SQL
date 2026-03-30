SELECT 
    r.session_id as SessionID,
    r.start_time as StartTime,
    r.[status] as Status, 
    r.wait_type as WaitType, 
    r.blocking_session_id as BlockedBySessionID,
	qt.text,
    sessions.login_name as BlockedByUser,
    SUBSTRING(qt.[text],r.statement_start_offset / 2, 
        (CASE 
            WHEN r.statement_end_offset = -1 
            THEN LEN(CONVERT(NVARCHAR(MAX), qt.[text])) * 2 
            ELSE r.statement_end_offset 
            END - r.statement_start_offset) / 2) AS SQLStatement,
    DB_NAME(qt.[dbid]) AS DatabaseName, 
    r.cpu_time as CPUTime, 
    r.total_elapsed_time as TotalElapsedTime, 
    Round(r.total_elapsed_time / 1000.0 / 60.0,1) as TotalElapsedTimeInMinutes,
    r.reads as Reads, 
    r.writes as Write, 
    r.logical_reads as LogicalReads
FROM sys.dm_exec_requests AS r 
    OUTER APPLY sys.dm_exec_sql_text(sql_handle) AS qt
    LEFT OUTER JOIN sys.dm_exec_sessions sessions ON sessions.session_id = r.blocking_session_id
WHERE r.session_id > 50 -- This eliminates system requests
ORDER BY r.[status],r.blocking_session_id DESC
--ORDER BY r.start_time
-- Pøíkazem KILL SessionID se zastavuje bìžící proces:
-- KILL 68