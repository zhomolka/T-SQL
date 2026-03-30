USE [Icc_Backup]
GO

/****** Object:  StoredProcedure [dbo].[Backup_DB]    Script Date: 15.01.2024 13:09:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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
EXEC Icc_Backup.dbo.Backup_Table2 'ActionTrigger','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Agent',''
EXEC Icc_Backup.dbo.Backup_Table2 'BusyCondition',''
EXEC Icc_Backup.dbo.Backup_Table2 'BusyConditionRule',''
EXEC Icc_Backup.dbo.Backup_Table2 'CallResultDetail',''
EXEC Icc_Backup.dbo.Backup_Table2 'Campaign',''
EXEC Icc_Backup.dbo.Backup_Table2 'ClientAlert',''
EXEC Icc_Backup.dbo.Backup_Table2 'ClientAlertComposition',''
EXEC Icc_Backup.dbo.Backup_Table2 'Configuration',''
EXEC Icc_Backup.dbo.Backup_Table2 'ContactModel',''
EXEC Icc_Backup.dbo.Backup_Table2 'Crew',''
EXEC Icc_Backup.dbo.Backup_Table2 'CrewMember',''
EXEC Icc_Backup.dbo.Backup_Table2 'DataQuery',''
EXEC Icc_Backup.dbo.Backup_Table2 'DataQueryColumn',''
EXEC Icc_Backup.dbo.Backup_Table2 'Device',''
EXEC Icc_Backup.dbo.Backup_Table2 'Editor',''
EXEC Icc_Backup.dbo.Backup_Table2 'EditorTab',''
EXEC Icc_Backup.dbo.Backup_Table2 'EditorTask','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Gateway','' 
EXEC Icc_Backup.dbo.Backup_Table2 'GatewayCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Holiday','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ChatGateway','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ChatGateCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ChatProjectCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ImrScript','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ImrStep','' 
EXEC Icc_Backup.dbo.Backup_Table2 'IssueCondition',''
EXEC Icc_Backup.dbo.Backup_Table2 'IvrEntry',''
EXEC Icc_Backup.dbo.Backup_Table2 'IvrScript',''
EXEC Icc_Backup.dbo.Backup_Table2 'IvrStep','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Language','' 
EXEC Icc_Backup.dbo.Backup_Table2 'LiteralLookup','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Message',' WHERE MessageType Like ''Tmp%'' AND MessageResult = 0' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessagePostCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessagePreCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessageProjectCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessageScheduleCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessageWaitPostCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Navigation','' 
EXEC Icc_Backup.dbo.Backup_Table2 'OutboundList',''
EXEC Icc_Backup.dbo.Backup_Table2 'Permission',''
EXEC Icc_Backup.dbo.Backup_Table2 'Phase',''
EXEC Icc_Backup.dbo.Backup_Table2 'PhaseTransition',''
EXEC Icc_Backup.dbo.Backup_Table2 'PhoneBook','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Pilot','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Portal','' 
EXEC Icc_Backup.dbo.Backup_Table2 'PostCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'PreCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Predictor','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Proficiency','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Project','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ProjectCondition',''
EXEC Icc_Backup.dbo.Backup_Table2 'Queue',''
EXEC Icc_Backup.dbo.Backup_Table2 'Redirector',''
EXEC Icc_Backup.dbo.Backup_Table2 'Role','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Scenario','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ScenarioCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Scope','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Screen','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ScreenControl','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ScreenControlParameter','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Seating','' 
EXEC Icc_Backup.dbo.Backup_Table2 'SchedulePostCondition',''
EXEC Icc_Backup.dbo.Backup_Table2 'Skill','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Status',''
EXEC Icc_Backup.dbo.Backup_Table2 'SubTopic',''
EXEC Icc_Backup.dbo.Backup_Table2 'Topic','' 
EXEC Icc_Backup.dbo.Backup_Table2 'WaitingQueue','' 
EXEC Icc_Backup.dbo.Backup_Table2 'WaitPostCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'WebSiteRouting',''
EXEC Icc_Backup.dbo.Backup_Table2 'WebSiteTemplate',''
EXEC Icc_Backup.dbo.Backup_Table2 'Workflow','' 
EXEC Icc_Backup.dbo.Backup_Table2 'WorkPlace','' 
EXEC Icc_Backup.dbo.Backup_Table2 'WorkflowStep','' 

 BACKUP DATABASE Icc_Backup TO DISK = @BackupFile
END

GO

