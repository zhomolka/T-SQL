USE [iCC]
GO
IF NOT EXISTS(SELECT * FROM [dbo].[ActionTrigger] WHERE DisplayName= 'Denní údržba' )
INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted], [Offset], [LaunchTime]) VALUES (N'7a982dcb-e4c5-4a09-86db-52542909b406', N'Denní údržba', NULL, N'ADMIN', N'EXEC FS_Custom.[dbo].[Daily_Maintenance]', NULL, NULL, N'PeriodDay', NULL, NULL, NULL, NULL, NULL, CAST(N'2019-12-14 03:00:00.000' AS DateTime), NULL, 0, 0, NULL, CAST(N'2019-12-12 04:00:00.000' AS DateTime))
GO
