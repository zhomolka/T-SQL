USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[EmailSchedule]    Script Date: 01.11.2023 13:28:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <15.6.2022>
-- Description:	<Posun odeslání mailu o určený počet minut>
-- Ve fázi Draft volám funkci s @Minutes=60, aby mi FS zprávu neodeslal ihned
-- =============================================
CREATE PROCEDURE [dbo].[EmailSchedule]
@MessageId uniqueidentifier,
@Minutes AS Integer
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--declare @messageid uniqueidentifier ='4219ec10-3030-ed11-b809-005056a0a12b' declare @Minutes AS Integer=1
-- posuň odeslání zprávy o x minut
  DECLARE @GDPRSensitivity int =(select GdprSensitivity from iCC.dbo.Message where MessageId=@MessageId)
  DECLARE @RemoteAddress nvarchar(max) =(select RemoteAddress from iCC.dbo.Message where MessageId=@MessageId)
  DECLARE @Loguj AS Bit=0
  DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
  DECLARE @Popis AS nvarchar(MAX)
  DECLARE @ScheduledTime AS Datetime=dateadd(MINUTE,@Minutes,getdate())
  SET @Popis = 'I setup ScheduledTime on mail MessageId='+convert(nvarchar(MAX), @MessageId)+' '+convert(nvarchar(5), @Minutes)+' Minutes - '+convert(nvarchar(40), @ScheduledTime,13)
  EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
  --IF @Minutes<0
  IF @GDPRSensitivity =16 and @RemoteAddress  not like '%homecredit%'
  begin 

update iCC.dbo.Message 
		set MessagePhase='Canceled'
		where MessageId=@MessageId
		
		insert into icc.dbo.messageevent(timeutc, timelocal, EventType,MessageId,ReferenceData)
select GETUTCDATE(),GETDATE(),'Zpráva zrušena',@MessageId,'Odeslání mimo HC zamítnuto'

  end

   update icc.dbo.Message
    set ScheduledTime=@ScheduledTime
      where MessageId=@MessageId AND ScheduledTime IS NULL AND Agentid IS NOT NULL
  EXEC FS_custom.[dbo].[MaintainMessage] @MessageId
 
END
GO

