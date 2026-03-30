
USE [iCC]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [CXF_Done_InProgress]    Script Date: 29.03.2021 9:33:20 ******/
CREATE NONCLUSTERED INDEX [CXF_Done_InProgress] ON [dbo].[ChangeRequest]
(
       [ChangeRequestTimeUtc] ASC,
       [Command] ASC,
       [TimeUtc] ASC
)
INCLUDE (     [ChangeRequestId],
       [Number],
       [ReferenceId],
       [SubjectId],
       [DataId],
       [ActorId],
       [Result],
       [Done],
       [InProgress]) 
WHERE ([Done]<>(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



/****** Delete ChangeRequest ******/
delete from iCC.dbo.ChangeRequest where Command not in ('BulkMessageImport','CampaignImport','OutboundListImport','OutboundListExport','DataQueryExport','ExportEventsAsCsv')
                                                                                            and ChangeRequestTimeUtc < DATEADD(DAY,-7,GETutcDATE()) and Done = 1


