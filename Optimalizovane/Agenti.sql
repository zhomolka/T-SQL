USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[AgentsFirstLogonTime]    Script Date: 7/3/2024 3:05:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Václav Kubát>
-- Create date: <07.09.2022>
-- Description:	<za zvolene obdobi vraci seznam agentu a jejich prvni Ready v TimeLocal>
-- =============================================
create FUNCTION [dbo].[AgentsFirstReadyTime]
(	
	@From as datetime
	,@To as datetime
)
RETURNS TABLE 
AS
RETURN 
(
		SELECT 
		AgentId 
		,MIN(TimeLocal) as FirstReadyTime
	FROM icc.dbo.AgentEvent ae WITH (NOLOCK) 
	WHERE ReferenceData = 'Ready' AND EventType = 'AgentStatus'  AND ae.TimeLocal >= @From and Dateadd(second,isnull(ae.duration,0),ae.TimeLocal) <= @To
	group by AgentId
)
GO









-- =============================================
-- Author:		<Václav Kubát>
-- Create date: <07.09.2022>
-- Description:	<za zvolene obdobi vraci seznam agentu a jejich prvni prihlaseni v TimeLocal>
-- =============================================
CREATE FUNCTION [dbo].[AgentsFirstLogonTime]
(	
	@From as datetime
	,@To as datetime
)
RETURNS TABLE 
AS
RETURN 
(
		SELECT 
		AgentId 
		,MIN(TimeLocal) as FirstLogonTime
	FROM icc.dbo.AgentEvent ae WITH (NOLOCK) 
	WHERE Actor <> 'Reset' AND ReferenceData <> 'LogOff' AND EventType = 'AgentStatus'  AND ae.TimeLocal >= @From and Dateadd(second,isnull(ae.duration,0),ae.TimeLocal) <= @To
	group by AgentId
)
GO


