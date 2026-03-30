USE [iCC]
GO

/****** Object:  StoredProcedure [dbo].[Delete_Emails]    Script Date: 27.5.2016 8:47:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbynek Homolka>
-- Create date: <27.05.2016>
-- Description:	<Maže staré emaily>
-- =============================================
CREATE PROCEDURE [dbo].[Delete_Emails] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @from AS datetime=convert(date,'2016.09.23 22:00')
DECLARE @to AS datetime=convert(date,'2016.09.25 00:00')
BEGIN TRANSACTION

SELECT MessageId INTO #TEMP from Icc.dbo.Message where TimeUTC >=  @from AND TimeUTC <  @to AND MessageType<>'TmpEmail' AND SubjectField LIKE '%Undelivered Mail Returned to Sender%'


delete from Icc.dbo.Attachment where MessageId IN (SELECT * FROM #TEMP)
delete from Icc.dbo.MessageEvent where MessageId IN (SELECT * FROM #TEMP)
update Icc.dbo.ScenarioResult set MessageId = NULL where MessageId in (SELECT * FROM #TEMP)
update Icc.dbo.Message set RelatedMessageId = NULL where RelatedMessageId in (SELECT * FROM #TEMP)

delete from Icc.dbo.Message where MessageId in (SELECT * FROM #TEMP)
--COMMIT TRANSACTION
ROLLBACK TRANSACTION
DROP TABLE #TEMP
END

GO

