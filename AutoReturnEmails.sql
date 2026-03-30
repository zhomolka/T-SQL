USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[AutoReturnEmails]    Script Date: 2. 11. 2017 9:09:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Roman Petersky
-- Create date: 9.5.2016
-- Description:	Vrati prirazene neprijate emaily po dobe z konfigurace
-- =============================================
CREATE PROCEDURE [dbo].[AutoReturnEmails]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
declare @MaxMessageReadDuration as int = (
SELECT ConfigurationValue FROM icc.dbo.Configuration where ConfigurationName = 'MaxMessageReadDuration'
)
select @MaxMessageReadDuration

select MessageId, TimeUtc, SubjectField into #MessagesToReturn from icc.dbo.Message m left join icc.dbo.Agent a on m.AgentId=a.AgentId
where a.Activity = 'Pause' and m.MessagePhase IN ('Received', 'Read') AND DATEDIFF(MINUTE,m.ReceivedSentTime,GETDATE()) >= @MaxMessageReadDuration

INSERT INTO icc.[dbo].[ChangeRequest]
           ([ChangeRequestId]
           ,[ChangeRequestTimeUtc]
           ,[Command]
           ,[Text]
           ,[Number]
           ,[TimeUtc]
           ,[ReferenceId]
           ,[SubjectId]
           ,[DataId]
           ,[ActorId]
           ,[Result]
           ,[Done])
     SELECT
           newid()
           ,getutcdate()
           ,'ReturnMessage'
           ,'AUTORETURN '+SubjectField
           ,NULL
           ,TimeUtc
           ,NULL
           ,MessageId
           ,NULL
           ,'4354b36d-e2ab-46ad-bc78-347edcd9b293' -- nejake id agenta
           ,NULL
           ,0
	FROM #MessagesToReturn
drop table #MessagesToReturn
END

GO

