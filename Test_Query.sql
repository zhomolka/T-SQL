SET STATISTICS TIME ON 
SET DATEFORMAT ymd
DECLARE @from AS datetime=convert(datetime, '2017.06.26')
DECLARE @to AS datetime=convert(datetime, '2017.06.27')
DECLARE @today AS Datetime=CONVERT(Date,GETDATE())
DECLARE @Now AS datetime=GETDATE()
SET @from=@today
SET @to=@Now

SELECT AgentId,
	(SELECT fs_custom.dbo.GetTotalLogonTime2(a.AgentId,@From,@To)) AS LogonTime,
	(SELECT COUNT(*) FROM icc.dbo.InboundCall WITH(NOLOCK) WHERE AgentId=a.AgentId AND AnswerTime IS NOT NULL AND DistributionTime>=@From AND DistributionTime<@To) AS InCalls,
	(SELECT COUNT(*) FROM icc.dbo.OutboundCall WITH(NOLOCK) WHERE AgentId=a.AgentId AND DialTime>=@From AND DialTime<@To) AS OutCalls, 
	(SELECT COUNT(*) FROM icc.dbo.CallEvent WITH(NOLOCK) WHERE EventType='AgentMissed' AND TimeLocal>=@From AND TimeLocal<@To AND AgentId=a.AgentId) as MissedCalls,
	(SELECT AVG(CallDuration) FROM 
		(SELECT CallDuration FROM icc.dbo.InboundCall WITH(NOLOCK) WHERE AgentId=a.AgentId AND DistributionTime>=@From AND DistributionTime<@To AND CallDuration IS NOT NULL
		UNION ALL
		SELECT CallDuration FROM icc.dbo.OutboundCall WITH(NOLOCK) WHERE AgentId=a.AgentId AND DistributionTime>=@From AND DistributionTime<@To AND CallDuration IS NOT NULL) 
		AS CTE1)  AS AvgCallTime,
	--(SELECT COUNT(*) FROM icc.dbo.Message WITH(NOLOCK) WHERE  AgentId=a.AgentId AND Direction='I' AND EndTime>=@From AND EndTime<@To AND (MessageResult='Answered' OR MessageResult='Closed') AND MessageType='Email') AS InEmails,
	--(SELECT COUNT(*) FROM icc.dbo.Message WITH(NOLOCK) WHERE  AgentId=a.AgentId AND Direction='O' AND EndTime>=@From AND EndTime<@To AND MessageResult='Sent' AND MessageType='Email') AS OutEmails,
	(SELECT COUNT(*) FROM icc.dbo.MessageEvent WITH(NOLOCK) WHERE AgentId=a.AgentId AND EventType='Returning' AND TimeLocal>=@From AND TimeLocal<@To) AS ReturnEmails,
	(select cast((isnull(SUM(case when (AnswerTime is not null and isnull(QueueDuration,0) <= 20) then 1 else 0 end),0) * 100) as float(1))
									/
									cast(FS_custom.dbo.IsZero ((isnull(SUM(case when EnqueueingTime is not null or AgentId is not null then 1 else 0 end),0)),1) as float (1))
									from iCC.dbo.InboundCall with (nolock)
									where EndTime>=@From AND EndTime<@To) as ServiceLevel
from iCC.dbo.Agent a with (nolock) where Deleted = 0 and Template = 0 AND LastCallUtc IS NOT NULL
  AND A.AgentId='cd65abc1-4dc5-46d8-8119-d83564ebbf88'