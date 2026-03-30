USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[ChangeCallPhase]    Script Date: 10. 9. 2018 14:46:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <07.09.2018>
-- Description:	<Napravuje CallPhase z 'Enqueue' na 'Manual' při přeplánování hovoru, který je v kampani s příznakem manuálního plánování>
-- Toto způsobuje nevytáčení okamžitých volání
-- =============================================
CREATE PROCEDURE [dbo].[ChangeCallPhase]
@OutboundCallId UniqueIdentifier
AS
BEGIN
  DECLARE @Manual AS bit = IIF(EXISTS(SELECT TOP 1 OC.Mark FROM iCC.dbo.OutboundCall OC WITH (NOLOCK) INNER JOIN iCC.dbo.OutboundList OL WITH (NOLOCK) 
     ON OC.OutboundListId=OC.OutboundListId
   WHERE OutboundCallId=@OutboundCallId AND ManualDistribution>0 AND Mark=0 AND CallPhase = 'Enqueue' AND Trial>1
   AND OC.OutboundlistId='0791057F-3A66-4655-BB51-1B58A085709C'),1,0) 
  IF @Manual=1
    BEGIN
     UPDATE iCC.dbo.OutboundCall SET CallPhase = 'Manual' WHERE OutboundCallId=@OutboundCallId AND Mark=0 AND CallPhase = 'Enqueue'
	 DECLARE @Popis AS nvarchar(500) = 'Nastavení Callphase=Manual na hovoru OutboundCallId= '+convert(nvarchar(MAX), @OutboundCallId)
	 EXEC  [FS_custom].[dbo].[WriteEvent] 1, 'ChangeCallPhase', @Popis
    END

 END



GO

