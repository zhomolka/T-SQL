USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[FSC_FirstReadyTime]    Script Date: 29.07.2024 13:41:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Zbynek Homolka>
-- Create date: <29.07.2024>
-- Description:	<za zvolene obdobi vraci seznam agentu a jejich prvni Ready v TimeLocal v ramci kazdeho dne>
-- =============================================
CREATE FUNCTION [dbo].[FSC_FirstReadyTime]
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
		,dbo.RoundTime(AE.Timelocal, @RoundInterval) AS GroupingDate	
		,MIN(TimeLocal) as FirstReadyTime
	FROM icc.dbo.AgentEvent ae WITH (NOLOCK) 
	WHERE ae.TimeLocal >= @From AND ae.TimeLocal < @To AND EventType = 'AgentStatus' and ReferenceData = 'Ready'  --AND  Dateadd(second,isnull(ae.duration,0),ae.TimeLocal) <= @To
	group by AgentId,dbo.RoundTime(AE.Timelocal, @RoundInterval)
)
GO

