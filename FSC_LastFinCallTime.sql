USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[FSC_LastFinCallTime]    Script Date: 29.07.2024 14:32:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Zbynek Homolka>
-- Create date: <29.07.2024>
-- Description:	<za zvolene obdobi vraci seznam agentu a jejich casy ukonceni poslednich hovoru v ramci kazdeho dne>
-- =============================================
CREATE FUNCTION [dbo].[FSC_LastFinCallTime]
(	
	@From as datetime
	,@To as datetime
	,@RoundInterval AS INT
)
RETURNS TABLE 
AS
RETURN 
(
		SELECT 
		AgentId 
		,dbo.RoundTime(CE.Timelocal, @RoundInterval) AS GroupingDate	
		,MAX(TimeLocal) as LastFinCallTime
	FROM icc.dbo.CallEvent ce WITH (NOLOCK) 
	WHERE ce.TimeLocal >= @From AND ce.TimeLocal < @To AND EventType = 'End' and Agentid IS NOT NULL   --AND  Dateadd(second,isnull(ae.duration,0),ae.TimeLocal) <= @To
	group by AgentId,dbo.RoundTime(cE.Timelocal, @RoundInterval)
)
GO

