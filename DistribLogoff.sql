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

IF @LastTime=1
 BEGIN
    SET @from=DATEADD(Day,-6,GETDATE())
    SET @to=DATEADD(Day,1,GETDATE())
  END
  SELECT
 W.DisplayName as WorkplaceName, Phase2.* FROM (
SELECT   A.DisplayName as AgentName,  
 S.DisplayName as StatusName, 
 
(SELECT TOP 1 WorkplaceId FROM CallEvent CE WITH(NOLOCK) WHERE CE.Timelocal>DATEADD(ss,-40,ISNULL(AE.Timelocal,@Now)) AND 
      CE.Timelocal<AE.Timelocal AND CE.EventType='Distributing' AND AE.Agentid=CE.Agentid) AS WorkplaceId


,AE.TimeLocal, 'Agent' as Kind, AE.EventType AS EventAgent,
AE.AgentId, /*CE.WorkplaceId,*/ AE.ReferenceId,
	dbo.ConcatName(AE.ResultData,Actor,AE.ReferenceData) AS Detail, AE.Duration

	
FROM AgentEvent AE WITH(NOLOCK) 
LEFT JOIN Agent AS A with(nolock) ON AE.AgentId=A.AgentId

LEFT JOIN Status AS S with(nolock) ON AE.ReferenceId=S.StatusId
--LEFT JOIN InboundCall AS IC with(nolock) ON DTA.InboundCallId=IC.InboundCallId
--LEFT JOIN OutboundCall AS OC with(nolock) ON DTA.OutboundCallId=OC.OutboundCallId
--LEFT JOIN Project AS P with(nolock) ON DTA.ProjectId=P.ProjectId
WHERE 1=1

AND TimeLocal>@from AND TimeLocal<@To
AND S.Activity='Logoff'
AND dbo.ConcatName(AE.ResultData,Actor,AE.ReferenceData)='Phone Distribution , Logoff'

) AS  Phase2
LEFT JOIN Workplace AS W with(nolock) ON Phase2.WorkplaceId=W.WorkplaceId
ORDER BY TimeLocal DESC