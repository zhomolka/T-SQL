USE [FS_Custom]
GO
/****** Object:  UserDefinedFunction [dbo].[CustomCheck]    Script Date: 31. 1. 2020 12:20:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <27.8.2019>
-- Description:	<Zakaznicky test>
-- =============================================

ALTER FUNCTION [dbo].[CustomCheck](@TestVer AS NVARCHAR(2), @Last as DateTime)
RETURNS int
AS
BEGIN
	DECLARE @Result as int = 0
	DECLARE @Now AS datetime=GETDATE()
	/*
	-- Kontrola přijatých mailů
	IF  @TestVer='MN' AND EXISTS(SELECT 1 FROM  [iCC].[dbo].[Message] WITH (NOLOCK)
    WHERE 1=1
    AND ReceivedSentTime >= @Last
   --AND ReceivedSentTime <= @TO
   AND MessageType ='Email' AND MessageResult='Active' 
   AND DIRECTION ='I' AND MessagePhase <> 'Canceled' and (spamlevel is null or spamlevel = 0)
   AND DATEDIFF(Hour,ReceivedSentTime,GETDATE()) > 30 -- Zpráva je 30hodin nepřijata
   AND AcceptedTime IS NULL
   and GatewayId<>'656bb249-7e33-48d9-ad41-cca8bdacfefc')
   	  SET @Result = 1
    ELSE
	  SET @Result = 0
	  */
	  	-- Kontrola mailů přidělených agentům, kteří nejsou v práci
		/*
   DECLARE @LogoffId AS UNIQUEIDENTIFIER=(SELECT TOP 1 StatusId FROM [iCC].[dbo].Status WHERE Activity='Logoff')
	IF  @TestVer='NV' AND EXISTS(SELECT 1 FROM  [iCC].[dbo].[Message] ME WITH (NOLOCK) 
      INNER JOIN [iCC].[dbo].[Agent] AG  ON ME.AgentId=AG.AgentId
    WHERE 1=1
    AND MessageType ='Email' AND MessageResult='Active' 
   AND DIRECTION ='I' AND MessagePhase <> 'Canceled' and (spamlevel is null or spamlevel = 0)
   AND DATEDIFF(Day,ReceivedSentTime,GETDATE()) < 90 -- Zpráva je 30hodin nepřijata
   AND AcceptedTime IS NULL
   and GatewayId<>'656bb249-7e33-48d9-ad41-cca8bdacfefc'
   AND AG.StatusId=@LogoffId) --Agent není v práci
   	  SET @Result = 1
    ELSE
	  SET @Result = 0 */


/*
	IF  @TestVer='IC' AND EXISTS(SELECT 1 FROM iCC.dbo.InboundCall as I WITH(NOLOCK) WHERE I.TimeUtc>=@Last AND I.TimeUtc<=@Now AND I.CallDuration>1 AND CallResult='Served' AND WorkplaceId<>'48418D3A-F438-412F-BDE0-A1E61594B243')
	  SET @Result = 1
    ELSE
	  SET @Result = 0
	IF  @TestVer='OC' AND EXISTS(SELECT 1 FROM iCC.dbo.OutboundCall as O WITH(NOLOCK) WHERE  O.CallDuration>1 AND CallResult<>'Active' AND O.AgentId IS NOT NULL AND WorkplaceId<>'48418D3A-F438-412F-BDE0-A1E61594B243')
	  SET @Result = 1
    ELSE
	  SET @Result = 0
*/
	RETURN @Result
END











