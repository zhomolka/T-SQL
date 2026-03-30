USE iCC
GO
SET DATEFORMAT ymd
DECLARE @from AS datetime=convert(datetime, '2017.06.26')
DECLARE @to AS datetime=convert(datetime, '2017.06.27')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER=(SELECT TOP 1 AgentId FROM Agent AG LEFT JOIN icc.dbo.Workplace AS W WITH(NOLOCK)  ON AG.WorkplaceId = W.WorkplaceId
WHERE Activity='Ready' AND w.State <> 'Free')
DECLARE @NullId AS UniqueIdentifier= '00000000-0000-0000-0000-000000000000'
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1
DECLARE @Number AS integer
DECLARE @GroupInterval AS integer=1440
DECLARE @RoundInterval AS integer=@GroupInterval
DECLARE @Version  AS integer=1
DECLARE @LastTime AS bit=1

SELECT AG.AgentId,ST.StatusId
	,W.Number AS Extension
	,AG.DisplayName AS AgentName, AG.GroupName,AG.TeamName
	,(SELECT fs_custom.dbo.GetFirstLogonTime(AG.AgentId, @Today)) AS FirstLogonTime
		,(SELECT fs_custom.dbo.GetLastLogonTime(AG.AgentId, @Today)) AS LastLogonTime
	,(SELECT fs_custom.dbo.GetTotalLogonTime2(AG.AgentId, @Today, @Now)) AS LogonTotal
	,fs_custom.dbo.GetCurrentStateLength2(AG.AgentId, @Now) AS StateLength
	,ST.DisplayName AS StatusName
	,W.State AS WorkplaceStatus

	,CASE 
	 WHEN W.State = 'Free' 
		THEN (SELECT Top 1 DATEDIFF(SECOND, DATEADD(HOUR, DATEDIFF(HH, GETUTCDATE(), GETDATE()), AG.LastCallUtc), @Now)) 
 	 WHEN AG.Activity<>'Logoff' AND EXISTS (SELECT Top 1 AnswerTime FROM InboundCall WITH(NOLOCK) WHERE AgentId = AG.AgentId AND CallResult = 'Active') 
		THEN (SELECT Top 1 DATEDIFF(SECOND, AnswerTime, @Now) FROM InboundCall WITH(NOLOCK)  WHERE AgentId = AG.AgentId AND CallResult = 'Active') 
 	 WHEN AG.Activity<>'Logoff' AND EXISTS (SELECT Top 1 DistributionTime FROM OutboundCall WITH(NOLOCK)  WHERE AgentId = AG.AgentId AND CallResult = 'Active') 
		THEN (SELECT Top 1 DATEDIFF(SECOND, DistributionTime, @Now) FROM OutboundCall WITH(NOLOCK)  WHERE AgentId = AG.AgentId AND CallResult = 'Active') 
   	 END AS WorkplaceStatusDuration

	,CAST(CASE WHEN AG.Activity = 'Ready' AND w.State = 'Free' THEN 1 ELSE 0 END AS bit) AS IsFree	
	,CAST(CASE WHEN AG.Activity = 'Pause' THEN 1 ELSE 0 END AS bit) AS IsPause
	,CAST(CASE WHEN w.State = 'Ring' THEN 1 ELSE 0 END AS bit) AS IsRinging
	,CAST(CASE WHEN w.State = 'Busy' THEN 1 ELSE 0 END AS bit) AS IsBusy
	,CAST(CASE WHEN AG.Activity = 'PostCall' THEN 1 ELSE 0 END AS bit) AS IsPCP
	,(select top 1 displayName as Crew from crew cr with (nolock) left join CrewMember cm with (nolock) on cr.CrewId=cm.CrewId where cm.AgentId=ag.agentid) as Crew
	,(SELECT MAX(DistributionTime) FROM 
		(SELECT DistributionTime FROM icc.dbo.InboundCall WITH(NOLOCK)  WHERE TimeUtc>@LastWeek AND AgentId = AG.AgentId AND (CallResult = 'Served' OR CallResult = 'Active') UNION 
		 SELECT DistributionTime FROM icc.dbo.OutboundCall WITH(NOLOCK)  WHERE TimeUtc>@LastWeek AND AgentId = AG.AgentId AND (EndTime IS NOT NULL)) AS CTE1) AS LastCallTime
	--,(select count(*) from icc.dbo.Issue with (nolock) where agentid=ag.AgentId and activity ='open') as OpenIssue
	--,(select count(*) from icc.dbo.Issue with (nolock) where agentid=ag.AgentId and CloseTime>=@Today ) as CloseIssue
	--,(select avg(callduration) from icc.dbo.InboundCall with (NOLOCK) where agentid=ag.agentid and timeutc>=@today) as CallDuration
	--,(select avg(RingDuration) from icc.dbo.InboundCall with (NOLOCK) where agentid=ag.agentid and timeutc>=@today) as RingDuration
	--,(SELECT COUNT(*) FROM icc.dbo.InboundCall AS IC WITH(NOLOCK)  WHERE IC.AgentId=AG.AgentId AND IC.DistributionTime>=@Today AND IC.CallResult='Served') AS InboundTotal
--,(SELECT COUNT(*) FROM icc.dbo.Message AS M  WITH(NOLOCK) WHERE M.AgentId=AG.AgentId AND M.Direction='I' AND (M.MessageResult='Closed' OR M.MessageResult='Answered') AND M.EndTime>=@Today) AS MsgTotal
		,(SELECT COUNT(*) FROM icc.dbo.CallEvent AS CE WHERE CE.AgentId=AG.AgentId AND CE.EventType='AgentMissed' AND CE.TimeLocal>=@Today) AS Missed
/*,(SELECT SUM(Duration) FROM icc.dbo.AgentEvent as AE WHERE AE.AgentId=AG.AgentId AND AE.EventType='AgentStatus' AND 
		(AE.ReferenceData='E4176740-4963-49CF-B41C-995E4F82C9D5' /* Oběd */ 
		OR AE.ReferenceData='E4176740-4963-49CF-B41C-995E4F82C9D5' /* Nepřipraven */ 

		) )AS PausesTotal
	*/

--	,fs_custom.dbo.TalkTime(@Today, @Now,AG.AgentId) as TalkTime

FROM icc.dbo.Agent AS AG  WITH(NOLOCK) 
LEFT JOIN icc.dbo.Workplace AS W WITH(NOLOCK)  ON AG.WorkplaceId = W.WorkplaceId
LEFT JOIN icc.dbo.Status AS ST WITH(NOLOCK)  ON AG.StatusId=ST.StatusId
WHERE AG.Deleted = 0 AND AG.Template=0 

