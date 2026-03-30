USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[OutCallMainten]    Script Date: 2. 7. 2020 16:58:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <2.7.2020>
-- Description:	<Při ukončení odchozího hovoru zkontroluje/napraví CallDuration>
-- =============================================
CREATE PROCEDURE [dbo].[OutCallMainten] 
@Id uniqueidentifier
AS
BEGIN
IF (SELECT TOP 1 CallDuration FROM [iCC].[dbo].[OutboundCall] WITH (NOLOCK) WHERE OutboundCallId = @Id)=0
  BEGIN
	UPDATE iCC.dbo.OutboundCall
	   SET  CallDuration=DateDiff(ss,AnswerTime,EndTime) 
	   WHERE OutboundCallId =@Id AND DateDiff(ss,AnswerTime,EndTime)>5

	DECLARE @Zprava NVARCHAR(200)= 'Oprava CallDuration na OutboundCallId='+CONVERT(NVARCHAR(38),@Id)
	EXEC  [FS_custom].[dbo].[WriteEvent] 1,'OutCallMai',@Zprava
  END
RETURN
END





GO

