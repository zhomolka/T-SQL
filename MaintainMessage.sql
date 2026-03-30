USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[MaintainMessage]    Script Date: 20.8.2019 14:06:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[MaintainMessage]
@Messageid AS Uniqueidentifier
AS
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <14.12.2018>
-- Description:	<Provádí údržbu zpráv>
-- =============================================

BEGIN
  DECLARE @Loguj AS Bit=1
  DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
  DECLARE @Popis AS nvarchar(MAX)
  IF (SELECT TOP 1 Direction FROM iCC.dbo.Message WITH (NOLOCK) WHERE (MessageId = @MessageId))='O' AND
     (SELECT TOP 1 GatewayId FROM iCC.dbo.Message WITH (NOLOCK) WHERE (MessageId = @MessageId)) IS NULL
    BEGIN -- Pokud není u odesílané zprávy vyplněno GatewayId, nastav nejběžnější
	  UPDATE iCC.dbo.Message
	  SET GatewayId = '264C5A4B-5499-418A-8149-D4C13D5ACEB0'
	  WHERE  (MessageId = @MessageId)
	  SET @Popis = 'Doplnění GatewayId na zprávě MessageId='+CONVERT(NVARCHAR(50),@MessageId)
	  EXEC  [FS_Custom].[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
    END
 IF (SELECT TOP 1 MessageResult FROM iCC.dbo.Message WITH (NOLOCK) WHERE (MessageId = @MessageId))='Closed' -- Omylem poslaná uzavřená zpráva
    BEGIN -- nastav původní stav Sent
	  UPDATE iCC.dbo.Message
	  SET MessagePhase = 'Sent'
	  WHERE  (MessageId = @MessageId)
	  SET @Popis = 'Vrácení MessagePhase na Sent na zprávě MessageId='+CONVERT(NVARCHAR(50),@MessageId)
	  EXEC  [FS_Custom].[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
    END

END


GO

