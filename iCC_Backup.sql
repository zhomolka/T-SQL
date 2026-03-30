/* Pokud jsou tyto parametry definovány v prostředí Windows, přesuňte následující 2 znaky za poslední příkaz :setvar */
:setvar FS_CUSTOM FS_CUSTOM
:setvar ICC ICC

---
IF  NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'Icc_Backup')
    BEGIN
      CREATE DATABASE [Icc_Backup]
    END
IF NOT EXISTS (SELECT * FROM [Icc_Backup].SYS.EXTENDED_PROPERTIES WHERE Name = 'description')
    EXEC [Icc_Backup].sys.sp_addextendedproperty @name=N'description', @value=N'BackUp of iCC config tables or manually changed records'
--GO /**/


USE Icc_Backup
GO --
--
IF object_id('Icc_Backup..Backup_Table2') IS NOT NULL
 BEGIN
  DROP  PROCEDURE [dbo].Backup_Table2
 END


GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <14.04.2020>
-- Description:	Záloha 1 (konfigurační) tabulky do iCC_Backup
-- =============================================

CREATE PROCEDURE [dbo].[Backup_Table2]
@TableName NVARCHAR(50)
AS
BEGIN
  DECLARE @OrigName AS NVARCHAR(100) = 'Icc_Backup..'+@TableName
  DECLARE @NewName AS NVARCHAR(100) = @TableName+'_old'
  --PRINT DB_NAME()
 	IF OBJECT_ID(N'Icc_Backup..'+@TableName, N'U') IS NOT NULL -- Tabulka existuje
	  BEGIN
	    IF OBJECT_ID(N'Icc_Backup..'+@TableName+'_old', N'U') IS NOT NULL -- Tabulka existuje 
		  EXEC('DROP TABLE Icc_Backup.dbo.'+@TableName+'_old')--DROP TABLE Icc_Backup.dbo.Agent_old
	    EXEC sp_rename @OrigName, @NewName
	  END
	 EXEC('select * into Icc_Backup.dbo.'+@TableName+' from $(ICC).dbo.'+@TableName)-- select * into Icc_Backup.dbo.Agent from $(ICC).dbo.Agent

 END

 GO

IF object_id('Icc_Backup..Backup_DB') IS NOT NULL
 BEGIN
  DROP  PROCEDURE [dbo].Backup_DB
 END
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <20.05.2020>
-- Description:	DB iCC_Backup backup to file iCC_Backupyymmdd.bak on destination
-- =============================================

CREATE PROCEDURE [dbo].[Backup_DB]
@BackupPath AS NVARCHAR(100)
AS
BEGIN
 DECLARE @BackupFile AS NVARCHAR(150)= @BackupPath+'Icc_Backup'+convert(varchar(25), getdate(), 12)+'.bak'
 EXEC Icc_Backup.dbo.Backup_Table2 'ActionTrigger' 
EXEC Icc_Backup.dbo.Backup_Table2 'Agent'
EXEC Icc_Backup.dbo.Backup_Table2 'Campaign'
EXEC Icc_Backup.dbo.Backup_Table2 'Configuration'
EXEC Icc_Backup.dbo.Backup_Table2 'DataQuery'
EXEC Icc_Backup.dbo.Backup_Table2 'DataQueryColumn'
EXEC Icc_Backup.dbo.Backup_Table2 'Editor'
EXEC Icc_Backup.dbo.Backup_Table2 'EditorTab'
EXEC Icc_Backup.dbo.Backup_Table2 'EditorTask' 
EXEC Icc_Backup.dbo.Backup_Table2 'Gateway' 
EXEC Icc_Backup.dbo.Backup_Table2 'GatewayCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'Holiday' 
EXEC Icc_Backup.dbo.Backup_Table2 'ChatGateway' 
EXEC Icc_Backup.dbo.Backup_Table2 'ChatProjectCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'ImrScript' 
EXEC Icc_Backup.dbo.Backup_Table2 'ImrStep' 
EXEC Icc_Backup.dbo.Backup_Table2 'IssueCondition'
EXEC Icc_Backup.dbo.Backup_Table2 'IvrEntry'
EXEC Icc_Backup.dbo.Backup_Table2 'IvrScript'
EXEC Icc_Backup.dbo.Backup_Table2 'IvrStep' 
EXEC Icc_Backup.dbo.Backup_Table2 'Language' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessagePostCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessagePreCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessageProjectCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessageScheduleCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessageWaitPostCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'Navigation' 
EXEC Icc_Backup.dbo.Backup_Table2 'OutboundList'
EXEC Icc_Backup.dbo.Backup_Table2 'Phase'
EXEC Icc_Backup.dbo.Backup_Table2 'PhaseTransition'
EXEC Icc_Backup.dbo.Backup_Table2 'PhoneBook' 
EXEC Icc_Backup.dbo.Backup_Table2 'Pilot' 
EXEC Icc_Backup.dbo.Backup_Table2 'Portal' 
EXEC Icc_Backup.dbo.Backup_Table2 'PostCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'PreCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'Predictor' 
EXEC Icc_Backup.dbo.Backup_Table2 'Proficiency' 
EXEC Icc_Backup.dbo.Backup_Table2 'Project' 
EXEC Icc_Backup.dbo.Backup_Table2 'ProjectCondition'
EXEC Icc_Backup.dbo.Backup_Table2 'Queue'
EXEC Icc_Backup.dbo.Backup_Table2 'Redirector'
EXEC Icc_Backup.dbo.Backup_Table2 'Role' 
EXEC Icc_Backup.dbo.Backup_Table2 'Scenario' 
EXEC Icc_Backup.dbo.Backup_Table2 'ScenarioCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'Scope' 
EXEC Icc_Backup.dbo.Backup_Table2 'Screen' 
EXEC Icc_Backup.dbo.Backup_Table2 'ScreenControl' 
EXEC Icc_Backup.dbo.Backup_Table2 'ScreenControlParameter' 
EXEC Icc_Backup.dbo.Backup_Table2 'Seating' 
EXEC Icc_Backup.dbo.Backup_Table2 'SchedulePostCondition'
EXEC Icc_Backup.dbo.Backup_Table2 'Skill' 
EXEC Icc_Backup.dbo.Backup_Table2 'Status'
EXEC Icc_Backup.dbo.Backup_Table2 'SubTopic'
EXEC Icc_Backup.dbo.Backup_Table2 'Topic' 
EXEC Icc_Backup.dbo.Backup_Table2 'WaitingQueue' 
EXEC Icc_Backup.dbo.Backup_Table2 'WaitPostCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'WebSiteTemplate'
EXEC Icc_Backup.dbo.Backup_Table2 'Workflow' 
EXEC Icc_Backup.dbo.Backup_Table2 'WorkflowStep' 
 BACKUP DATABASE Icc_Backup TO DISK = @BackupFile
END

GO

IF NOT EXISTS(SELECT * FROM $(ICC).[dbo].[ActionTrigger] WHERE DisplayName= 'Daily conf backup' )
INSERT $(ICC).[dbo].[ActionTrigger] (ActionTriggerId,[DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted], [Offset], [LaunchTime])
 VALUES ('2C87A16A-C1A3-4CC0-96AD-5ABFAD7706AC', N'Daily conf backup', NULL, N'ADMIN', N'EXEC iCC_Backup.[dbo].[Backup_DB] ''D:\Atlantis-Backup\DB\''', NULL, NULL, N'PeriodDay', NULL, NULL, NULL, NULL, NULL, CAST(N'2019-12-14 03:00:00.000' AS DateTime), NULL, 0, 0, NULL, CAST(N'2019-12-12 04:00:00.000' AS DateTime))
GO