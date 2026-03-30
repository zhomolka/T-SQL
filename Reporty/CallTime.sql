USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[CallTime]    Script Date: 02/13/2018 08:36:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <1.2.2018>
-- Description:	<Délka hovorů agenta v zadaném časovém úseku>
-- =============================================

CREATE FUNCTION [dbo].[CallTime](@AgentId as UNIQUEIdentifier, @From as Datetime, @To as Datetime)
RETURNS Integer
AS
BEGIN	
   DECLARE  @Duration as Integer 
   	--   Příchozí hovory   
    -- Posbírám všechny CallDuration v mém rozsahu - musím však oseknout čas, který přesahuje mimo zadaný interval
	DECLARE @CallTimeAg as int = ISNULL((SELECT SUM(CASE WHEN EndTime<@To THEN CallDuration ELSE DATEDIFF(second,AnswerTime,@to) END) FROM iCC.dbo.InboundCall IC WITH (NOLOCK) 
	  WHERE IC.DistributionTime >= DATEADD(Hour,-1,@From) AND IC.DistributionTime < @To  AND AgentId=@AgentId AND IC.AnswerTime >= @From AND IC.AnswerTime < @To),0)
	-- Ještě se musím podívat, zda nepřesáhl nějaký hovor operátora do zadaného časového intervalu
	DECLARE @Today AS Date = GETDATE()
	DECLARE  @CalliD as UniqueIdentifier = (SELECT TOP 1 InboundCallId FROM iCC.dbo.InboundCall  WITH (NOLOCK) 
	  WHERE DistributionTime >= @Today AND DistributionTime < @From  AND AgentId=@AgentId AND AnswerTime < @From AND EndTime>@From
	 	   ORDER BY Agentid,DistributionTime DESC)
	IF @CalliD IS NOT NULL
	  BEGIN
	  	SET @Duration  = (SELECT CallDuration-DATEDIFF(second,AnswerTime,@From) FROM iCC.dbo.InboundCall AE WITH (NOLOCK) WHERE InboundCallId=@CalliD)
	    SET @CallTimeAg = @CallTimeAg+@Duration 
	  END
	--   Odchozí hovory  
	--  	
	SET @CallTimeAg = @CallTimeAg+ISNULL((SELECT SUM(CASE WHEN EndTime<@To THEN CallDuration ELSE DATEDIFF(second,AnswerTime,@to) END) FROM iCC.dbo.OutboundCall IC WITH (NOLOCK) 
	  WHERE IC.AnswerTime >= @From AND IC.AnswerTime < @To  AND AgentId=@AgentId),0)
	SET  @CalliD  = (SELECT TOP 1 OutboundCallId FROM iCC.dbo.OutboundCall  WITH (NOLOCK) 
	  WHERE AgentId=@AgentId AND AnswerTime < @From AND EndTime>@From
	 	   ORDER BY Agentid,DistributionTime DESC)
	IF @CalliD IS NOT NULL
	  BEGIN
	  	SET @Duration  = (SELECT CallDuration-DATEDIFF(second,AnswerTime,@From) FROM iCC.dbo.OutboundCall AE WITH (NOLOCK) WHERE OutboundCallId=@CalliD)
	    SET @CallTimeAg = @CallTimeAg+@Duration 
	  END
	     
	RETURN @CallTimeAg 
END


GO

