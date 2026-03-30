USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[ReplaceSmiles]    Script Date: 7.4.2020 8:29:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[ReplaceSmiles]
@Messageid AS Uniqueidentifier
AS
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <14.12.2018>
-- Description:	<Odstraňuje smajlíky z těla a předmětu zprávy
-- =============================================

BEGIN
  DECLARE @Loguj AS Bit=1
  DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
  DECLARE @Popis AS nvarchar(MAX)
  UPDATE iCC.dbo.Message
  SET  BodyText =  .dbo.ReplaceSmilyes(BodyText),SubjectField = .dbo.ReplaceSmilyes(SubjectField)
  WHERE  (MessageId = @MessageId)
  SET @Popis = 'Přepis smajlíků na zprávě MessageId='+CONVERT(NVARCHAR(50),@MessageId)
  EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
END
