USE [iCC]
GO
IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Kontrola nahrávek ZbH')
INSERT [dbo].[ActionTrigger] ( [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted]) 
VALUES ( N'Kontrola nahrávek ZbH', NULL, N'Admin', N'EXEC FS_custom.dbo.CheckRecAndEmlActivity2', NULL, NULL, N'Interval', 30, N'DayInWeek', CAST(N'2017-01-02 07:45:00.000' AS DateTime), CAST(N'2017-01-06 20:10:59.900' AS DateTime), NULL, CAST(N'2018-07-09 10:50:27.247' AS DateTime), NULL, 0, 0)