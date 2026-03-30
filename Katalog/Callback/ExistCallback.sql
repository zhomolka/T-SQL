USE [FS_Custom]
GO
/****** Object:  StoredProcedure [dbo].[ExistCallback]    Script Date: 8/31/2022 10:44:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Jakub Pospíchal,Václav Kubát
-- Create date: 17.8.2017
-- Description:	pouziti pro IVR - kontrola, zda uz existuji nejake naplanovane hovory
-- =============================================
ALTER PROCEDURE [dbo].[ExistCallback]
	@CallId as uniqueidentifier
AS
BEGIN

	declare @Number as nvarchar(50) = (SELECT CallerNumber FROM icc.dbo.InboundCall WHERE InboundCallId=@CallId)
	declare @Project as uniqueidentifier = (SELECT ProjectId FROM icc.dbo.InboundCall WHERE InboundCallId=@CallId)
	declare @CBCount as int = (SELECT count(*) FROM iCC.dbo.OutboundCall WHERE  DisplayName = 'Callback' 
									and CallResult='Scheduled'
									and CallerNumber=@Number
									and projectid = @Project
									and exists (select * from iCC.dbo.CallEvent as ce 
												where ce.OutboundCallId = ce.OutboundCallId 
													and EventType = 'CallBack'
													and ReferenceData = 'Ivr'
													and ReferenceId in (select ProjectTransitionId from iCC.dbo.ProjectTransition)))
	declare @Callback as nvarchar(50)

	SELECT @Callback=(CASE WHEN @CBCount>0 THEN 'CallBackExists' ELSE 'NoCallback' END)
	SELECT @Callback AS 'IVR_Callback'


END


