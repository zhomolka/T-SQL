USE [msdb]
GO

/****** Object:  Job [monitor -  velikosti databází]    Script Date: 27. 2. 2019 14:57:41 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Monitor]    Script Date: 27. 2. 2019 14:57:41 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Monitor' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Monitor'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'monitor -  velikosti databází', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job monitoruje každý den velikost všech databází', 
		@category_name=N'Monitor', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Monitoring]    Script Date: 27. 2. 2019 14:57:41 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Monitoring', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
/*Uloženi velikosti databazi*/
INSERT INTO [DBUdrzbaSnimky]
               ([idDatabase]
               ,[DBname]
               ,[SizeMB]
               ,[disk]
               ,[physical_name]
               ,[dtCreate])
     
SELECT 
            database_id,
            name, 
            size*1.0/128 AS [Size in MBs],
            substring(physical_name ,1,1)as disk,
            physical_name,
            Getdate()as dtsnimek         
FROM master.sys.master_files  where database_id >4

/*Uložení místa na disku serveru*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[DISKSPACE]'') AND type in (N''U''))
CREATE TABLE [dbo].[DISKSPACE](
	[LogicalName] [nvarchar](256) NULL,
	[Drive] [nvarchar](256) NULL,
	[FreeSpaceInMB] [int] NULL,
	[DtInsert] smalldatetime
) ON [PRIMARY]


INSERT INTO [DISKSPACE]
           ([LogicalName]
           ,[Drive]
           ,[FreeSpaceInMB]
           ,DtInsert)

SELECT DISTINCT 
			dovs.logical_volume_name AS LogicalName,
			dovs.volume_mount_point AS Drive,
			CONVERT(INT,dovs.available_bytes/1048576.0) AS FreeSpaceInMB,
			convert(smalldatetime,convert(varchar,getdate(),104),104)
FROM sys.master_files mf
CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs
ORDER BY FreeSpaceInMB ASC


/*Uložení počtu VLF sounorů logu*/
/****** Object:  Table [dbo].[VLFCOUNT]    Script Date: 03/17/2016 15:54:09 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[VLFCOUNT]'') AND type in (N''U''))

CREATE TABLE [dbo].[VLFCOUNT](
	[dbname] [sysname] NOT NULL,
	[vlfcount] [int] NULL,
	[database_id] [int] NOT NULL,
	[dtInsert] [smalldatetime] NOT NULL
) ON [PRIMARY]

--variables to hold each ''iteration''  
declare @query varchar(100)  
declare @dbname sysname  
declare @vlfs int  
  
--table variable used to ''loop'' over databases  
declare @databases table (dbname sysname)  
insert into @databases  
--only choose online databases  
select name from sys.databases where state = 0  
  
--table variable to hold results  
declare @vlfcounts table  
    (dbname sysname,  
    vlfcount int)  
  
  
--table variable to capture DBCC loginfo output  
--changes in the output of DBCC loginfo from SQL2012 mean we have to determine the version 
 
declare @MajorVersion tinyint  
set @MajorVersion = LEFT(CAST(SERVERPROPERTY(''ProductVersion'') AS nvarchar(max)),CHARINDEX(''.'',CAST(SERVERPROPERTY(''ProductVersion'') AS nvarchar(max)))-1) 
 
if @MajorVersion < 11 -- pre-SQL2012 
begin 
    declare @dbccloginfo table  
    (  
        fileid tinyint,  
        file_size bigint,  
        start_offset bigint,  
        fseqno int,  
        [status] tinyint,  
        parity tinyint,  
        create_lsn numeric(25,0)  
    )  
  
    while exists(select top 1 dbname from @databases)  
    begin  
  
        set @dbname = (select top 1 dbname from @databases)  
        set @query = ''dbcc loginfo ('' + '''''''' + @dbname + '''''') ''  
  
        insert into @dbccloginfo  
        exec (@query)  
  
        set @vlfs = @@rowcount  
  
        insert @vlfcounts  
        values(@dbname, @vlfs)  
  
        delete from @databases where dbname = @dbname  
  
    end --while 
end 
else 
begin 
    declare @dbccloginfo2012 table  
    (  
        RecoveryUnitId int, 
        fileid tinyint,  
        file_size bigint,  
        start_offset bigint,  
        fseqno int,  
        [status] tinyint,  
        parity tinyint,  
        create_lsn numeric(25,0)  
    )  
  
    while exists(select top 1 dbname from @databases)  
    begin  
  
        set @dbname = (select top 1 dbname from @databases)  
        set @query = ''dbcc loginfo ('' + '''''''' + @dbname + '''''') ''  
  
        insert into @dbccloginfo2012  
        exec (@query)  
  
        set @vlfs = @@rowcount  
  
        insert @vlfcounts  
        values(@dbname, @vlfs)  
  
        delete from @databases where dbname = @dbname  
  
    end --while 
end 
  
--output the full list  

INSERT INTO [VLFCOUNT]
           ([dbname]
           ,[vlfcount]
           ,[database_id]
           ,[dtInsert])

select 
			C.dbname,
			C.vlfcount,
			DB.database_id,
			convert(smalldatetime,convert(varchar,getdate(),104),104)

from @vlfcounts C 
Join master.sys.databases DB ON C.dbname = DB.name collate Czech_CI_AS
order by C.vlfcount

', 
		@database_name=N'UDRZBA_SERVERU', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'denně v 7:00 rano', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160204, 
		@active_end_date=99991231, 
		@active_start_time=70000, 
		@active_end_time=235959, 
		@schedule_uid=N'93c03df1-1fd1-4918-8d61-f90a5ce6656a'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

