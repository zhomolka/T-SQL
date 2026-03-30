USE iCC
GO
DECLARE @NowUTC AS datetime=GETUTCDATE()
DECLARE @MeAgentId AS UNIQUEIDENTIFIER='db25ad2c-89dc-41d9-889c-aa87621bd274'
SELECT 1 as rank
					,'' as Text
					,IIF(isRunningCall=1,
					concat('Dlouhý hovor: ',FS_custom.dbo.DurationToTime (LastCallDuration)),				
					'Máte vyvìšený telefon! ')
					AS Number
					,case 
						when IsBusy_5min > 0 then '#e53935'
						else '#ffad33'
					end	 as BackColor
					,case 
						when IsBusy_5min > 0 then '#ffffff'
						else '#000000'
					end	 as FrontColor
					,'' as BackgroundImage
					,case 
						when IsBusy_5min > 0 then 'fa fa-exclamation-triangle'
						else 'fa fa-exclamation'
					end	 as 
					Glyph
					,''
						as Url
from
(
	select 
	DATEDIFF (second,LastCallUtc,@NowUTC) as LastCallDuration
	,CAST(CASE WHEN w.State = 'Busy' and DATEDIFF (second,LastCallUtc,@NowUTC) >= 120 and DATEDIFF (second,LastCallUtc,@NowUTC) < 300THEN 1 ELSE 0 END AS bit) AS IsBusy_2min
	,CAST(CASE WHEN w.State = 'Busy' and DATEDIFF (second,LastCallUtc,@NowUTC) > 300 THEN 1 ELSE 0 END AS bit) AS IsBusy_5min
	,IIF(LastEndCall>LastStartCall,0,1) AS isRunningCall
	FROM dbo.Agent AS AG  WITH(NOLOCK) 
	LEFT JOIN dbo.Workplace AS W WITH(NOLOCK)  ON AG.WorkplaceId = W.WorkplaceId
	LEFT JOIN (SELECT Agentid, MAX(IIF(EventType IN ('End','HangupAgent'),CE.Timelocal,NULL)) AS LastEndCall,
       MAX(IIF(EventType IN ('AgentAccepted','AgentAnswer'),CE.Timelocal,NULL)) AS LastStartCall
FROM dbo.CallEvent ce WITH (NOLOCK) 
	WHERE Agentid = @MeAgentId
	GROUP BY Agentid) LCE ON LCE.Agentid=AG.Agentid

	where AG.AgentId = @MeAgentId and w.State = 'Busy' and DATEDIFF (second,LastCallUtc,@NowUTC) > 120
) as CTE

SELECT FS_Custom.dbo.TimeUTC_Local(LastCallUtc) AS LastCallTimeinAgent
	FROM dbo.Agent AS AG  WITH(NOLOCK) 
	WHERE Agentid = @MeAgentId

SELECT 
       MAX(IIF(EventType IN ('AgentAccepted','AgentAnswer'),CE.Timelocal,NULL)) AS LastStartCall,
	   MAX(IIF(EventType IN ('End','HangupAgent'),CE.Timelocal,NULL)) AS LastEndCall
FROM dbo.CallEvent ce WITH (NOLOCK) 
	WHERE Agentid = @MeAgentId

/*
	SELECT Agentid,MAX(CE.Timelocal) AS LastEndCall	FROM dbo.CallEvent ce WITH (NOLOCK) 
	WHERE EventType = 'End' and Agentid = @MeAgentId
	GROUP BY Agentid
*/