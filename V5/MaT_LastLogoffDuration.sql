declare @SlotToUtc datetime = getdate() 
declare @LimTimeUtc datetime = DATEADD(Day,-40,getUTCdate())
SELECT ae.AgentId,ae.EventType,ae.ReferenceData,ae.Duration,ae.ReferenceId,ae.TimeUtc
  ,ISNULL(LastDuration,0) as LastLogoffTimeUtc
	--,((select top 1 ISNULL(Duration,0) FROM AgentEvent ae2 with (nolock) where ae.AgentId = ae2.AgentId and ae2.EventType = 0 and ae2.ReferenceData = 'Logoff' order by ae2.TimeUtc desc)) as LastLogoffTimeUtc
	--INTO #temp_AE
	FROM AgentEvent ae WITH (NOLOCK)
	 LEFT JOIN
	 (
	 select ISNULL(ae1.Duration,0) AS LastDuration, Phase1.AgentId FROM 
(SELECT MAX(TimeUtc) AS LastLogoff,ae0.AgentId FROM AgentEvent ae0 with (nolock) 
where ae0.TimeUTC>@LimTimeUtc AND ae0.EventType = 0 and ae0.ReferenceData = 'Logoff' --AND AgentId='CFCA02A8-29AF-4CA0-9E59-1006558A4A96'
GROUP BY ae0.AgentId) AS Phase1
LEFT JOIN AgentEvent ae1 with (nolock) ON ae1.AgentId=Phase1.AgentId AND ae1.TimeUTC=Phase1.LastLogoff AND ae1.TimeUTC>@LimTimeUtc
) AS Phase2 ON Phase2.Agentid=ae.Agentid
	WHERE ae.EventType IN (0, 9) /* StatusChange, ShiftStart */ AND
	((      ae.TimeUtc                         BETWEEN DATEADD(SECOND, -15, @SlotToUtc) AND @SlotToUtc) OR
	 (DATEADD(SECOND, ae.Duration, ae.TimeUtc) BETWEEN DATEADD(SECOND, -15, @SlotToUtc) AND @SlotToUtc) OR
	 ae.Duration IS NULL)

 