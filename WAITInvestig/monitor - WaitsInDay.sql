USE [msdb]
GO

/****** Object:  Job [monitor - WaitsInDay]    Script Date: 27. 2. 2019 14:58:50 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Monitor]    Script Date: 27. 2. 2019 14:58:50 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Monitor' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Monitor'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'monitor - WaitsInDay', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Monitor', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [WaitsInDay]    Script Date: 27. 2. 2019 14:58:50 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'WaitsInDay', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WITH [Waits] AS
				(SELECT
					[wait_type],
					[wait_time_ms] / 1000.0 AS [WaitS],
					([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
					[signal_wait_time_ms] / 1000.0 AS [SignalS],
					[waiting_tasks_count] AS [WaitCount],
				   100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
					ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum],
					getdate() as dtsnimek

				FROM sys.dm_os_wait_stats
				WHERE [wait_type] NOT IN (
					N''BROKER_EVENTHANDLER'', N''BROKER_RECEIVE_WAITFOR'',
					N''BROKER_TASK_STOP'', N''BROKER_TO_FLUSH'',
					N''BROKER_TRANSMITTER'', N''CHECKPOINT_QUEUE'',
					N''CHKPT'', N''CLR_AUTO_EVENT'',
					N''CLR_MANUAL_EVENT'', N''CLR_SEMAPHORE'',
 
					-- Maybe uncomment these four if you have mirroring issues
					N''DBMIRROR_DBM_EVENT'', N''DBMIRROR_EVENTS_QUEUE'',
					N''DBMIRROR_WORKER_QUEUE'', N''DBMIRRORING_CMD'',
 
					N''DIRTY_PAGE_POLL'', N''DISPATCHER_QUEUE_SEMAPHORE'',
					N''EXECSYNC'', N''FSAGENT'',
					N''FT_IFTS_SCHEDULER_IDLE_WAIT'', N''FT_IFTSHC_MUTEX'',
 
					-- Maybe uncomment these six if you have AG issues
					N''HADR_CLUSAPI_CALL'', N''HADR_FILESTREAM_IOMGR_IOCOMPLETION'',
					N''HADR_LOGCAPTURE_WAIT'', N''HADR_NOTIFICATION_DEQUEUE'',
					N''HADR_TIMER_TASK'', N''HADR_WORK_QUEUE'',
 
					N''KSOURCE_WAKEUP'', N''LAZYWRITER_SLEEP'',
					N''LOGMGR_QUEUE'', N''MEMORY_ALLOCATION_EXT'',
					N''ONDEMAND_TASK_QUEUE'',
					N''PREEMPTIVE_XE_GETTARGETSTATE'',
					N''PWAIT_ALL_COMPONENTS_INITIALIZED'',
					N''PWAIT_DIRECTLOGCONSUMER_GETNEXT'',
					N''QDS_PERSIST_TASK_MAIN_LOOP_SLEEP'', N''QDS_ASYNC_QUEUE'',
					N''QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP'',
					N''QDS_SHUTDOWN_QUEUE'', N''REDO_THREAD_PENDING_WORK'',
					N''REQUEST_FOR_DEADLOCK_SEARCH'', N''RESOURCE_QUEUE'',
					N''SERVER_IDLE_CHECK'', N''SLEEP_BPOOL_FLUSH'',
					N''SLEEP_DBSTARTUP'', N''SLEEP_DCOMSTARTUP'',
					N''SLEEP_MASTERDBREADY'', N''SLEEP_MASTERMDREADY'',
					N''SLEEP_MASTERUPGRADED'', N''SLEEP_MSDBSTARTUP'',
					N''SLEEP_SYSTEMTASK'', N''SLEEP_TASK'',
					N''SLEEP_TEMPDBSTARTUP'', N''SNI_HTTP_ACCEPT'',
					N''SP_SERVER_DIAGNOSTICS_SLEEP'', N''SQLTRACE_BUFFER_FLUSH'',
					N''SQLTRACE_INCREMENTAL_FLUSH_SLEEP'',
					N''SQLTRACE_WAIT_ENTRIES'', N''WAIT_FOR_RESULTS'',
					N''WAITFOR'', N''WAITFOR_TASKSHUTDOWN'',
					N''WAIT_XTP_RECOVERY'',
					N''WAIT_XTP_HOST_WAIT'', N''WAIT_XTP_OFFLINE_CKPT_NEW_LOG'',
					N''WAIT_XTP_CKPT_CLOSE'', N''XE_DISPATCHER_JOIN'',
					N''XE_DISPATCHER_WAIT'', N''XE_TIMER_EVENT'')
				AND [waiting_tasks_count] > 0
             )


INSERT INTO [UDRZBA_SERVERU].[monitor].[WaitsInDay]
           ([WaitType]
           ,[Wait_S]
           ,[Resource_S]
           ,[Signal_S]
           ,[WaitCount]
           ,[Percentage]
           ,[AvgWait_S]
           ,[AvgRes_S]
           ,[AvgSig_S]
           ,[Help/Info URL]
		    ,dtSnimek)
SELECT
    MAX ([W1].[wait_type]) AS [WaitType],
    CAST (MAX ([W1].[WaitS]) AS DECIMAL (16,2)) AS [Wait_S],
    CAST (MAX ([W1].[ResourceS]) AS DECIMAL (16,2)) AS [Resource_S],
    CAST (MAX ([W1].[SignalS]) AS DECIMAL (16,2)) AS [Signal_S],
    MAX ([W1].[WaitCount]) AS [WaitCount],
    CAST (MAX ([W1].[Percentage]) AS DECIMAL (5,2)) AS [Percentage],
    CAST ((MAX ([W1].[WaitS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgWait_S],
    CAST ((MAX ([W1].[ResourceS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgRes_S],
    CAST ((MAX ([W1].[SignalS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgSig_S],
    CAST (''https://www.sqlskills.com/help/waits/'' + MAX ([W1].[wait_type]) as XML) AS [Help/Info URL],
	GETDATE()
FROM [Waits] AS [W1]
INNER JOIN [Waits] AS [W2]
    ON [W2].[RowNum] <= [W1].[RowNum]
GROUP BY [W1].[RowNum]
HAVING SUM ([W2].[Percentage]) - MAX( [W1].[Percentage] ) < 95; -- percentage threshold
GO
 ', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DriveLevelLatency]    Script Date: 27. 2. 2019 14:58:50 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DriveLevelLatency', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'INSERT INTO [UDRZBA_SERVERU].[monitor].[DriveLevelLatency]
           ([Drive]
           ,[Read Latency]
           ,[Write Latency]
           ,[Overall Latency]
           ,[Avg Bytes/Read]
           ,[Avg Bytes/Write]
           ,[Avg Bytes/Transfer]
           ,[dtSnimek])
 SELECT [Drive],
 CASE 
  WHEN num_of_reads = 0 THEN 0 
  ELSE (io_stall_read_ms/num_of_reads) 
 END AS [Read Latency],
 CASE 
  WHEN io_stall_write_ms = 0 THEN 0 
  ELSE (io_stall_write_ms/num_of_writes) 
 END AS [Write Latency],
 CASE 
  WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
  ELSE (io_stall/(num_of_reads + num_of_writes)) 
 END AS [Overall Latency],
 CASE 
  WHEN num_of_reads = 0 THEN 0 
  ELSE (num_of_bytes_read/num_of_reads) 
 END AS [Avg Bytes/Read],
 CASE 
  WHEN io_stall_write_ms = 0 THEN 0 
  ELSE (num_of_bytes_written/num_of_writes) 
 END AS [Avg Bytes/Write],
 CASE 
  WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
  ELSE ((num_of_bytes_read + num_of_bytes_written)/(num_of_reads + num_of_writes)) 
 END AS [Avg Bytes/Transfer],
 GETdate() as dtSnimek
FROM (SELECT LEFT(mf.physical_name, 2) AS Drive, SUM(num_of_reads) AS num_of_reads,
          SUM(io_stall_read_ms) AS io_stall_read_ms, SUM(num_of_writes) AS num_of_writes,
          SUM(io_stall_write_ms) AS io_stall_write_ms, SUM(num_of_bytes_read) AS num_of_bytes_read,
          SUM(num_of_bytes_written) AS num_of_bytes_written, SUM(io_stall) AS io_stall
      FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
      INNER JOIN sys.master_files AS mf WITH (NOLOCK)
      ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
      GROUP BY LEFT(mf.physical_name, 2)) AS tab
ORDER BY [Overall Latency] OPTION (RECOMPILE);

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SignalWaitTime]    Script Date: 27. 2. 2019 14:58:50 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SignalWaitTime', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'INSERT INTO [UDRZBA_SERVERU].[monitor].[SignalWaitTime]
           ([TotalSignalWaitTime]
           ,[PercentageSignalWaitsOfTotalTime]
           ,[dtSnimek])

SELECT SUM(signal_wait_time_ms) AS TotalSignalWaitTime ,
( SUM(CAST(signal_wait_time_ms AS NUMERIC(20, 2)))
/ SUM(CAST(wait_time_ms AS NUMERIC(20, 2))) * 100 )
AS PercentageSignalWaitsOfTotalTime,
getdate() as dtSnimek
FROM sys.dm_os_wait_stats', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'v 18:00', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160729, 
		@active_end_date=99991231, 
		@active_start_time=180000, 
		@active_end_time=235959, 
		@schedule_uid=N'cb6cfd7e-f4c2-45e6-82ad-a93d32b47cc9'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

