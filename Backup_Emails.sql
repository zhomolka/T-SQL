USE [iCC]
GO

/****** Object:  StoredProcedure [dbo].[Backup_Emails]    Script Date: 27.5.2016 8:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbynek Homolka>
-- Create date: <27.05.2016>
-- Description:	<Zálohuje staré emaily>
-- =============================================
CREATE PROCEDURE [dbo].[Backup_Emails]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @to AS date
SET @to=convert(date, '2015.01.01')

select * into Icc_Backup.dbo.Message from iCC.dbo.Message WHERE TimeUTC <  @to
select * into Icc_Backup.dbo.Attachment from iCC.dbo.Attachment WHERE MessageId IN (SELECT MessageId from Icc.dbo.Message where TimeUTC < @to AND MessageType<>'TmpEmail')
select * into Icc_Backup.dbo.MessageEvent from iCC.dbo.Attachment WHERE MessageId IN (SELECT MessageId from Icc.dbo.Message where TimeUTC < @to AND MessageType<>'TmpEmail')
END

GO

