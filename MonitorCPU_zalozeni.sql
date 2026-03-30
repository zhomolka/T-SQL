USE [FS_custom]
GO

create table fs_custom.dbo.SnapshotCPU
(EventTime datetime,
SQLServerProcessCPUUtilization int,
SystemIdleProcess int,
OtherProcessCPUUtilization int
)

GO

/****** Object:  StoredProcedure [dbo].[SaveSnapshotSL]    Script Date: 20.04.2022 14:17:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SaveSnapshotCPU]
AS
BEGIN
SET NOCOUNT ON;

DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks)FROM sys.dm_os_sys_info); 

INSERT INTO fs_custom.[dbo].[SnapshotCPU]
     --     ([EventTime]
     --     ,[SqlServerProcessCPUUtilization]
     --     ,[SystemIdleProcess]
     --  ,[OtherProcessCPUUtilization]
     --     )
     --VALUES
 
		SELECT  TOP 1
				DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [EventTime],
				SQLProcessUtilization AS [SQLServerProcessCPUUtilization], 
				SystemIdle AS [SystemIdleProcess], 
				100 - SystemIdle - SQLProcessUtilization AS [OtherProcessCPUUtilization] 
			FROM 
				( SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
				record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle], 
				record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [SQLProcessUtilization], 
				[timestamp] 
				FROM 
					( SELECT [timestamp], 
					CONVERT(xml, record) AS [record] FROM sys.dm_os_ring_buffers 
					WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' AND record LIKE '%<SystemHealth>%') AS x ) AS y ORDER BY record_id DESC
				
END

GO

insert into icc.dbo.ActionTrigger
values ('3e9081cd-496b-46a1-869a-b1d4d0344041',	'Snapshoting CPU',	NULL,	'General',	'exec fs_custom.dbo.SaveSnapshotCPU',	NULL,	NULL,	'Interval',	1,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	0,	NULL,	NULL)

GO

---test procedury

exec fs_custom.dbo.SaveSnapshotCPU