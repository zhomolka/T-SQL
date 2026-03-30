USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_UNIQA_Agents]    Script Date: 02/23/2018 10:10:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Jiří Stejskal
-- Create date: 205-03-19
-- Description:	UNIQA - Agents report
-- =============================================
CREATE FUNCTION [dbo].[rep_UNIQA_Agents]
(	
	@From AS DATETIME,
	@To AS DATETIME
)
RETURNS TABLE 
AS
RETURN 
(
/*
Declare @from as datetime = getdate()-3
Declare @to as datetime = getdate()-2
*/
	SELECT 
	CAST(AE.TimeLocal AS DATE) AS DATE
	,  iCC.dbo.RoundTime(CAST(AE.TimeLocal AS DATE), 10080) AS WeekDate
	,  iCC.dbo.RoundTime(CAST(AE.TimeLocal AS DATE), 44640) AS MonthDate
	, A.TeamName
	,A.Description
	, AE.AgentId
	, A.DisplayName AS AgentName
	,  iCC.dbo.GetFirstLogonTime(AE.AgentId, CAST(AE.TimeLocal AS DATE)) AS FirstLoginTime
	, (SELECT MAX(TimeLocal) FROM iCC.dbo.AgentEvent WITH (NOLOCK) WHERE CAST(TimeLocal AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId AND EventType = 'AgentStatus' AND ReferenceData = 'Logoff' AND Actor <> 'Reset') AS LastLogoffTime
	, (SELECT SUM(ISNULL(Duration, 0)) FROM iCC.dbo.AgentEvent WITH (NOLOCK) WHERE CAST(TimeLocal AS DATE) = CAST(AE.TimeLocal AS DATE) AND EventType='AgentStatus' AND AgentId = AE.AgentId AND ReferenceData <> 'Logoff' and Actor <> 'Reset') AS LoggedDuration
	, (SELECT SUM(ISNULL(Duration, 0)) FROM iCC.dbo.AgentEvent WITH (NOLOCK) WHERE CAST(TimeLocal AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId AND ReferenceData = 'Ready' and Actor <> 'Reset') AS ReadyDuration
	
	--NR kody
	,  iCC.dbo.GetStateLength_1('C70B72C1-D381-4849-AEB2-18CC512AE1EF', AE.AgentId, CAST(AE.TimeLocal AS DATE), DATEADD(DD, 1, CAST(AE.TimeLocal AS DATE))) AS NRStatus_Porada 
	,  iCC.dbo.GetStateLength_1('2506D0DC-8DF8-40FF-9AB2-20E68878E9EF', AE.AgentId, CAST(AE.TimeLocal AS DATE), DATEADD(DD, 1, CAST(AE.TimeLocal AS DATE))) AS NRStatus_Osobni 
	,  iCC.dbo.GetStateLength_1('BD64797A-EA0F-4E42-93D5-568FBF9F4909', AE.AgentId, CAST(AE.TimeLocal AS DATE), DATEADD(DD, 1, CAST(AE.TimeLocal AS DATE))) AS NRStatus_Skoleni 	
	,  iCC.dbo.GetStateLength_1('40B6E59B-FC0E-49A9-811A-8FBA855697C0', AE.AgentId, CAST(AE.TimeLocal AS DATE), DATEADD(DD, 1, CAST(AE.TimeLocal AS DATE))) AS NRStatus_Obed 
	,  iCC.dbo.GetStateLength_1('AE91D094-BF7C-4872-93C4-980032AE72BC', AE.AgentId, CAST(AE.TimeLocal AS DATE), DATEADD(DD, 1, CAST(AE.TimeLocal AS DATE))) AS NRStatus_Faxy 
	,  iCC.dbo.GetStateLength_1('EFE38BC7-F0DC-4AF7-AEEB-A9AA9E4D7869', AE.AgentId, CAST(AE.TimeLocal AS DATE), DATEADD(DD, 1, CAST(AE.TimeLocal AS DATE))) AS NRStatus_Prodleva 
	,  iCC.dbo.GetStateLength_1('92947E64-4AA4-4BBD-8622-E237CDAF3210', AE.AgentId, CAST(AE.TimeLocal AS DATE), DATEADD(DD, 1, CAST(AE.TimeLocal AS DATE))) AS NRStatus_Technicka 
	,  iCC.dbo.GetStateLength_1('1B921022-8342-4822-9A51-7F40875DBAEB', AE.AgentId, CAST(AE.TimeLocal AS DATE), DATEADD(DD, 1, CAST(AE.TimeLocal AS DATE))) AS NRStatus_AdministrativaProdeje
	,  iCC.dbo.GetStateLength_1('0B1095D2-7F85-4366-8A8E-1F7FC66A31A8', AE.AgentId, CAST(AE.TimeLocal AS DATE), DATEADD(DD, 1, CAST(AE.TimeLocal AS DATE))) AS NRStatus_Projekt

	, (SELECT avg(ISNULL(CallDuration, 0)) FROM iCC.dbo.InboundCall WITH (NOLOCK) WHERE CAST(DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId) AS AVGINCallDuration
	, (SELECT avg(ISNULL(CallDuration, 0)) FROM iCC.dbo.OutboundCall WITH (NOLOCK) WHERE CAST(DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId) AS AVGOUTCallDuration
	, (SELECT avg(ISNULL(RingDuration, 0)) FROM iCC.dbo.InboundCall WITH (NOLOCK) WHERE CAST(DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId) AS AVGINRingDuration
	, (SELECT avg(ISNULL(RingDuration, 0)) FROM iCC.dbo.OutboundCall WITH (NOLOCK) WHERE CAST(DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId) AS AVGOUTRingDuration
	, (SELECT SUM(ISNULL(CallDuration, 0)) FROM iCC.dbo.InboundCall WITH (NOLOCK) WHERE CAST(DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId) AS INCallDuration
	, (SELECT SUM(ISNULL(CallDuration, 0)) FROM iCC.dbo.OutboundCall WITH (NOLOCK) WHERE CAST(DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId) AS OUTCallDuration
	, (SELECT SUM(ISNULL(RingDuration, 0)) FROM iCC.dbo.InboundCall WITH (NOLOCK) WHERE CAST(DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId) AS INRingDuration
	, (SELECT SUM(ISNULL(RingDuration, 0)) FROM iCC.dbo.OutboundCall WITH (NOLOCK) WHERE CAST(DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId) AS OUTRingDuration

	, (SELECT COUNT(*) FROM iCC.dbo.InboundCall WITH (NOLOCK) WHERE answertime is not null and CAST(DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId) AS INCallCount
	--, (SELECT COUNT(*) FROM iCC.dbo.InboundCall AS IC WITH (NOLOCK) LEFT JOIN Pilot AS P ON IC.PilotId = P.PilotId WHERE CAST(DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId ) AS INCallCountCB
	, (SELECT COUNT(*) FROM iCC.dbo.InboundCall WITH (NOLOCK) WHERE CAST(DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId AND (IvrResponseA = '2A' OR IvrResponseA = '2B' or IvrResponseA = 'P8')) AS INCallCountIVRResponse_2
	--, (SELECT COUNT(*) FROM iCC.dbo.CallEvent AS CE LEFT JOIN Project AS P ON P.ProjectId = CE.ProjectId WHERE CAST(CE.TimeLocal AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId AND ResultData = 'TransferedRelease' and EventType <> 'CallLost') AS TransferedCalls
	--, (SELECT COUNT(*) FROM iCC.dbo.CallEvent AS CE LEFT JOIN Project AS P ON P.ProjectId = CE.ProjectId WHERE CAST(CE.TimeLocal AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId AND EventType = 'ChangeMeta' and InboundCallId is not null) AS TransferedINCalls
	--, (SELECT COUNT(*) FROM iCC.dbo.CallEvent AS CE LEFT JOIN Project AS P ON P.ProjectId = CE.ProjectId WHERE CAST(CE.TimeLocal AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId AND EventType = 'ChangeMeta' and OutboundCallId is not null) AS TransferedOUTCalls
	
	, (select  COUNT(*) FROM iCC.dbo.inboundcall i with (nolock) left join iCC.dbo.Agent a with (nolock) on a.AgentId=i.AgentId 
       where a.TeamName=(select c.teamname FROM iCC.dbo.InboundCall x with (nolock) left join iCC.dbo.Agent c with (nolock)on c.AgentId=x.AgentId where x.InboundCallId=i.ChainingId)
        AND i.AgentId = AE.AgentId and CAST(i.DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE)) as TransferedINCalls
	, (select  COUNT(*) FROM iCC.dbo.inboundcall i with (nolock) left join iCC.dbo.Agent a with (nolock) on a.AgentId=i.AgentId 
       where a.TeamName<>(select c.teamname FROM iCC.dbo.InboundCall x with (nolock) left join iCC.dbo.Agent c with (nolock)on c.AgentId=x.AgentId where x.InboundCallId=i.ChainingId)
        AND i.AgentId = AE.AgentId and CAST(i.DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE)) as TransferedOUTCalls
        	
	, (SELECT COUNT(*) FROM iCC.dbo.OutboundCall WITH (NOLOCK) WHERE CAST(DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId) AS OUTCallCount
	, (SELECT COUNT(*) FROM iCC.dbo.OutboundCall WITH (NOLOCK) WHERE CAST(DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId AND AnswerTime IS NOT NULL AND CallDuration >= 8) AS OUTConnectedCallCount
	
	, (SELECT SUM(ISNULL(PcpWrapDuration, 0)) FROM iCC.dbo.OutboundCall WITH (NOLOCK) WHERE CAST(DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId) AS OUTPCPWrapTime
	, (SELECT SUM(ISNULL(PcpWrapDuration, 0)) FROM iCC.dbo.InboundCall WITH (NOLOCK)  WHERE CAST(DistributionTime AS DATE) = CAST(AE.TimeLocal AS DATE) AND AgentId = AE.AgentId) AS INPCPWrapTime
	
FROM iCC.dbo.AgentEvent AS AE WITH (NOLOCK) 
LEFT JOIN iCC.dbo.Agent AS A WITH (NOLOCK) ON A.AgentId = AE.AgentId
WHERE AE.TimeLocal >= @From AND AE.TimeLocal <= @To+1 AND Actor <> 'Reset' AND AE.AgentId is not null-- AND A.TeamName LIKE '##%'
GROUP BY CAST(AE.TimeLocal AS DATE), AE.AgentId, A.DisplayName,a.TeamName,A.Description
-- AE.TimeLocal <= @To+1 Změněno 14.10.2016 na přání pana Burdy
)



GO

