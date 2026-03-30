USE [FS_custom]
GO
/****** Object:  StoredProcedure [dbo].[Vrat_do_fronty_maily]    Script Date: 25. 9. 2019 15:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <25.09.2019>
-- Description:	<Vrací >
-- =============================================
ALTER PROCEDURE [dbo].[Vrat_do_fronty_maily]

AS
BEGIN
 DECLARE @LogoffId AS UNIQUEIDENTIFIER=(SELECT TOP 1 StatusId FROM [iCC].[dbo].Status WHERE Activity='Logoff')
 BEGIN TRANSACTION
UPDATE ME
SET  AgentId=NULL
FROM [iCC].[dbo].[Message] ME 
  INNER JOIN [iCC].[dbo].[Agent] AG  ON ME.AgentId=AG.AgentId
WHERE 1=1
  AND MessageType ='Email' AND MessageResult='Active' 
   AND DIRECTION ='I' AND MessagePhase <> 'Canceled' and (spamlevel is null or spamlevel = 0)
   AND DATEDIFF(Day,ReceivedSentTime,GETDATE()) < 20 -- Vracím zprávy za posledních 20 dnů
   AND AcceptedTime IS NULL
   and GatewayId<>'656bb249-7e33-48d9-ad41-cca8bdacfefc'
   AND AG.StatusId=@LogoffId --Agent není v práci
   AND AG.ReturnMessagesOnLogoff=1


COMMIT TRANSACTION
--ROLLBACK TRANSACTION
END


