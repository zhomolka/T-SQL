USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_InboundCallsAgents]    Script Date: 13. 11. 2018 9:00:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <6.11.2018>
-- Description:	<Informace o příchozích hovorech agentů>
-- =============================================

CREATE FUNCTION [dbo].[rep_InboundCallsAgents]
(	
	@From datetime,
	@To datetime
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
	    CONVERT(VARCHAR(13), IC.PilotTime, 120) As DatumaCas
		,DATEPART(HOUR,  IC.PilotTime) AS Hour
	   	,AG.DisplayName AS AgentName
		,SUM(1) AS InCalls
		      FROM
       iCC.dbo.InboundCall IC WITH (NOLOCK)
	   LEFT JOIN iCC.dbo.Agent AG WITH (NOLOCK) ON AG.AgentId=IC.AgentId 
  	       WHERE IC.PilotTime >= @From AND IC.PilotTime < @To  AND AnswerTime IS NOT NULL
		     AND GroupName='Externí'
  GROUP BY AG.DisplayName,CONVERT(VARCHAR(13), IC.PilotTime, 120),DATEPART(HOUR,  IC.PilotTime)
		UNION
	SELECT 
	 CONVERT(VARCHAR(13), Cas.S, 120) As DatumaCas
		,DATEPART(HOUR,  Cas.S) AS Hour
	   	,'CasRastr' AS AgentName
		,0 AS OutCalls
		      FROM iCC.dbo.Rep_DateTime(@From,@To,'h') AS Cas WHERE FS_Custom.[dbo].[IsWorkTime](S,'PRAC_6')=1

	

)



GO

