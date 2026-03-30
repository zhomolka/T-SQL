USE iCC
GO
DECLARE @from AS date=convert(datetime, '2017.06.26')
DECLARE @to AS date=convert(datetime, '2017.06.27')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER=(SELECT TOP 1 AgentId FROM Agent WHERE Activity='Ready')
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
    SET @from=DATEADD(Day,-2,GETDATE())
    SET @to=GETDATE()
  END
/* */
select
IIF(Column1='Queue',1,IIF(Column1='WaitingMax',2,IIF(Column1='ServedCallsCount',3,IIF(Column1='LostCallsCount',4,IIF(Column1='ServedCallsAfterThresholdCount',5,6))))) as Rank,
Column1 AS Text
,convert(nvarchar(10),Number)+'%' as Number
,'#4682B4' as BackColor
,'#F7f9f9' as FrontColor
,'fa fa-level-up' as Glyph
 FROM (
select  [Column1], [Number]
from 
    (   -- select relevant columns from source 
        select  Queue,  WaitingMax, ServedCallsCount,LostCallsCount,ServedCallsAfterThresholdCount,LostCallsAfterThresholdCount
        from (
		SELECT
	'Outbound' AS Label
	,ISNULL(SUM( CASE WHEN C.CallResult = 'Active' AND (C.CallPhase='Enqueued' OR C.CallPhase='WaitingQueue') THEN 1 ELSE 0 END),0) AS Queue
	,ISNULL(MAX(CASE WHEN C.CallResult = 'Active' AND (C.CallPhase='Enqueued' OR C.CallPhase='WaitingQueue') AND EnqueueingTime IS NOT NULL THEN DATEDIFF(SS, EnqueueingTime, @Now) END) ,0) AS WaitingMax
	,ISNULL(SUM(CASE WHEN C.CallResult = 'Served' THEN 1 ELSE 0 END), 0) AS ServedCallsCount	
	,ISNULL(SUM(CASE WHEN (C.CallPhase='Enqueued' OR C.CallPhase='WaitingQueue') AND C.CallResult = 'Lost' THEN 1 ELSE 0 END), 0) AS LostCallsCount
	,ISNULL(SUM(CASE WHEN C.CallResult = 'Served' AND QueueDuration > 30  THEN 1 ELSE 0 END), 0) AS ServedCallsAfterThresholdCount
	,ISNULL(SUM(CASE WHEN C.CallResult = 'Lost' AND QueueDuration IS NOT NULL AND QueueDuration > 30 THEN 1 ELSE 0 END), 0) AS LostCallsAfterThresholdCount
FROM InboundCall AS C WITH (NOLOCK)
LEFT JOIN Project AS P  WITH (NOLOCK) ON C.ProjectId=P.ProjectId 
left join Agent as A with (nolock) on a.AgentId=c.AgentId
WHERE PilotTime >= @Today  AND C.ProjectId IN (SELECT * FROM [FS_custom].dbo.[Return_Ids]('Outbound'))
		) AS Corn
    ) as piv
UNPIVOT
    (   -- define new result columns.  
        ----  [Value] is the detailed count/sum/whatever
        ----  [Column] get the old name of the column 

        [Number] 
        for [Column1] in (Queue,  WaitingMax, ServedCallsCount,LostCallsCount,ServedCallsAfterThresholdCount,LostCallsAfterThresholdCount) 
    ) as unpiv
	) AS Phase2
/*
SELECT
	'Outbound' AS Label
	,ISNULL(SUM( CASE WHEN C.CallResult = 'Active' AND (C.CallPhase='Enqueued' OR C.CallPhase='WaitingQueue') THEN 1 ELSE 0 END),0) AS Queue
	,ISNULL(MAX(CASE WHEN C.CallResult = 'Active' AND (C.CallPhase='Enqueued' OR C.CallPhase='WaitingQueue') AND EnqueueingTime IS NOT NULL THEN DATEDIFF(SS, EnqueueingTime, @Now) END) ,0) AS WaitingMax
	,ISNULL(SUM(CASE WHEN C.CallResult = 'Served' THEN 1 ELSE 0 END), 0) AS ServedCallsCount	
	,ISNULL(SUM(CASE WHEN (C.CallPhase='Enqueued' OR C.CallPhase='WaitingQueue') AND C.CallResult = 'Lost' THEN 1 ELSE 0 END), 0) AS LostCallsCount
	,ISNULL(SUM(CASE WHEN C.CallResult = 'Served' AND QueueDuration > 30  THEN 1 ELSE 0 END), 0) AS ServedCallsAfterThresholdCount
	,ISNULL(SUM(CASE WHEN C.CallResult = 'Lost' AND QueueDuration IS NOT NULL AND QueueDuration > 30 THEN 1 ELSE 0 END), 0) AS LostCallsAfterThresholdCount
FROM InboundCall AS C WITH (NOLOCK)
LEFT JOIN Project AS P  WITH (NOLOCK) ON C.ProjectId=P.ProjectId 
left join Agent as A with (nolock) on a.AgentId=c.AgentId
WHERE PilotTime >= @Today  AND C.ProjectId IN (SELECT * FROM [FS_custom].dbo.[Return_Ids]('Outbound'))
*/
