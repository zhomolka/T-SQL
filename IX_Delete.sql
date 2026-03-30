USE [msdb]
GO

/****** Object:  Job [Duplicate indexes delete]    Script Date: 8. 2. 2021 13:37:55 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 8. 2. 2021 13:37:56 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
DECLARE @Date AS Integer=YEAR(GETDATE()) * 10000 + MONTH(GETDATE()) * 100 + DAY(GETDATE())
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Duplicate indexes delete', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete IX]    Script Date: 8. 2. 2021 13:37:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete IX', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @qry NVARCHAR(MAX);
SELECT @qry = (SELECT  ''DROP INDEX ['' + ix.name + ''] ON '' + OBJECT_NAME(ix.ID) + ''; ''
       FROM  sysindexes ix
	   LEFT JOIN sysindexes ax ON ax.name= ''AX_''+OBJECT_NAME(ix.ID)+''_''+SUBSTRING(ix.name,4,50)
       WHERE   ix.Name IS NOT NULL AND SUBSTRING(ix.Name, 1, 3) = ''IX_''
	   AND ax.Name IS NOT NULL
       --AND OBJECT_NAME(ID) = ''Message'' --lze omezit na jednu tabulku
       FOR XML PATH('''')
);
SELECT @qry --náhled textu pøíkazu - vypadá jako jeden øádek, ale ten je hooodnì dlouhý
EXEC SP_EXECUTESQL @qry --provede smazání indexù IX_ - pravdìpodobnì nemáte odvahu to dìlat v pracovní dobì KC? Napíše (1 row affected), ale to je eufemismus.', 
		@database_name=N'iCC', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Evening run', 
		@enabled=1, 
		@freq_type=1, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=@Date, 
		@active_end_date=99991231, 
		@active_start_time=220000, 
		@active_end_time=235959, 
		@schedule_uid=N'ebe58914-158d-4c3d-87d3-15607454f3fa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


