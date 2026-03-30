USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[DelOldMails]    Script Date: 1/28/2021 12:01:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <28.01.2021>
-- Description:	<Odmazávání mailů starších 3 měsíce na žádost pana Ulče>
-- =============================================
-- CREATE
CREATE
 PROCEDURE [dbo].[DelOldMails]
AS
BEGIN
   DECLARE @to AS date=DATEADD(month,-3,GETDATE())
   EXEC  .[dbo].[WriteEvent] 1,'DelOldMails','Vstupní bod'

   IF OBJECT_ID(N'tempdb..##TEMP', N'U') IS NOT NULL 
     DROP TABLE ##TEMP
   select MessageId into ##TEMP from iCC.dbo.Message WHERE  ReceivedSentTime < @TO
   PRINT ('Delete old data from Attachment:')
   DELETE FROM iCC.dbo.Attachment WHERE MessageId IN (SELECT * FROM ##TEMP)
   PRINT ('Delete old data from MessageEvent:')
   DELETE FROM iCC.dbo.MessageEvent WHERE MessageId IN (SELECT * FROM ##TEMP)
   update iCC.dbo.ScenarioResult set MessageId = NULL WHERE MessageId IN (SELECT * FROM ##TEMP)
   update iCC.dbo.Message set RelatedMessageId = NULL where RelatedMessageId in (SELECT * FROM ##TEMP)
   PRINT ('Delete old data from Message:')
   DELETE FROM iCC.dbo.Message WHERE  ReceivedSentTime < @TO
   IF OBJECT_ID (N'##TEMP', N'U') IS NOT NULL 
    DROP TABLE ##TEMP

   EXEC  .[dbo].[WriteEvent] 1,'DelOldMails','Konec procedury'

END
GO

