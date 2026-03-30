USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[MessageInspect]    Script Date: 1/27/2020 8:45:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ZbH 27.01.2020
-- Kontrola zprávy
 
CREATE PROCEDURE [dbo].[MessageInspect]
       @MessageId as uniqueidentifier
AS
BEGIN
       -- Ma byt vyvolano pri prechodu do stavu Accepted
       SET NOCOUNT ON;
	       DECLARE @Loguj AS Bit=1
	DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
	DECLARE @Popis AS nvarchar(MAX)
	SET @Popis = 'Start'
	EXEC  [FS_Custom].[dbo].[WriteEvent] @Loguj, @ProcName, @Popis

 declare @MessageIssueId as uniqueidentifier = (select top 1 IssueId from iCC.dbo.Message with (nolock) where MessageId=@MessageId)
 IF @MessageIssueId IS NULL
   BEGIN
	SET @Popis = 'Message ID= '+CONVERT(NVARCHAR(40),@MessageId)+' is without issue.'
	EXEC  [FS_Custom].[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
   END
	
END
GO

