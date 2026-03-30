USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[EmailSchedule]    Script Date: 15.06.2022 15:15:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <15.6.2022>
-- Description:	<Posun odeslání mailu o určený počet minut>
-- =============================================
CREATE PROCEDURE [dbo].[EmailSchedule]
@MessageId uniqueidentifier,
@Minutes AS Integer
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- posuň odeslání zprávy o x minut
  DECLARE @Loguj AS Bit=0
  DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
  DECLARE @Popis AS nvarchar(MAX) 
  SET @Popis = 'I setup ScheduledTime on mail MessageId='+convert(nvarchar(MAX), @MessageId)
  EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis

   update icc.dbo.Message
    set ScheduledTime=dateadd(MINUTE,@Minutes,getdate())
      where MessageId=@MessageId AND ScheduledTime IS NULL AND Agentid IS NOT NULL

 
END
GO

