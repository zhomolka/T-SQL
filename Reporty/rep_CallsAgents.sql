USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_CallsAgents]    Script Date: 02/02/2018 11:35:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <1.2.2018>
-- Description:	<Informace o příchozích a odchozích hovorech agentů>
-- =============================================

CREATE FUNCTION [dbo].[rep_CallsAgents]
(	
	@From datetime,
	@To datetime
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
	    R.S As DatumaCas
	    ,CONVERT(Date,R.S) AS Datum
	    ,convert(varchar(10), R.S, 108) AS CAS
		,A.DisplayName AS AgentName
		, FS_Custom.[dbo].[CallTime](AgentId,R.S,R.E)AS CallDuration
		, FS_Custom.[dbo].[LogTime](AgentId,R.S,R.E)AS LogDuration
		, (SELECT COUNT(1) FROM iCC.dbo.InboundCall IC WITH (NOLOCK) WHERE IC.DistributionTime >= R.S AND IC.DistributionTime < R.E AND IC.AgentId=A.AgentId) AS InboundCallCount
		, (SELECT COUNT(1) FROM iCC.dbo.OutboundCall OC WITH (NOLOCK) WHERE OC.AnswerTime >= R.S AND OC.AnswerTime < R.E  AND OC.AgentId=A.AgentId) AS OutboundCallCount
      FROM
       iCC.dbo.Rep_DateTime(@From,@To,'h') AS R
       CROSS JOIN [iCC].[dbo].[Agent] A  WITH (NOLOCK) WHERE Deleted=0 AND Template=0
       AND (SELECT TOP 1 1 FROM iCC.dbo.AgentEvent AE WITH (NOLOCK) 
	       WHERE AE.TimeLocal >= @From AND AE.TimeLocal < @To  AND AgentId=A.AgentId
	 	   AND EventType='AgentStatus' AND ReferenceData <> 'Logoff' and Actor <> 'Reset') IS NOT NULL
	 	   AND A.TeamName='## Praha'
	

)


GO

