USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[WB_Project]    Script Date: 6. 5. 2019 13:57:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2.5.2019
-- Description:	Vrací záznam do tabulky Wallboardu
-- =============================================
CREATE FUNCTION [dbo].[WB_Project] (@ProjectGroup as NVARCHAR(20),@Today AS DateTime,@Now AS DateTime)
RETURNS TABLE
AS
RETURN
(
select
IIF(Column1='Queue',1,IIF(Column1='WaitingMax',2,IIF(Column1='InCallCount',3,IIF(Column1='LostCallsCount',4,IIF(Column1='Processed',5,6))))) as Rank,
Column1 AS Text
,convert(nvarchar(10),Number)+IIF(Column1='SL','%','') as Number
,IIF((Column1='Queue' OR Column1='WaitingMax') AND Number>0 OR Column1='SL' AND Number<50 ,'#f29ba6',IIF(Column1='Queue' OR Column1='WaitingMax' OR Column1='SL','#4682B4','#f9f7f7')) as BackColor
,IIF(Column1='Queue' OR Column1='WaitingMax' OR Column1='SL','#F7f9f9','#070707') as FrontColor
,IIF(Column1='Queue','fa fa-shopping-cart',IIF(Column1='WaitingMax','fa fa-dashboard',IIF(Column1='InCallCount','fa fa-phone',IIF(Column1='LostCallsCount','fa fa-chain-broken',
     IIF(Column1='Processed','fa fa-phone','fa fa-bar-chart')))))  as Glyph
 FROM (
select  [Column1], [Number]
from 
    (   -- select relevant columns from source 
        select  Queue,  WaitingMax, InCallCount,LostCallsCount,Processed,SL
        from (
		SELECT *,
		  InCallCount-LostCallsCount AS Processed,
		  FS_Custom.dbo.Percents(ServedCallsInThresholdCount,InCallCount) AS SL
		 FROM(
		SELECT

	ISNULL(SUM( CASE WHEN C.CallResult = 'Active' AND (C.CallPhase='Enqueued' OR C.CallPhase='WaitingQueue') THEN 1 ELSE 0 END),0) AS Queue
	,ISNULL(MAX(CASE WHEN C.CallResult = 'Active' AND (C.CallPhase='Enqueued' OR C.CallPhase='WaitingQueue') AND EnqueueingTime IS NOT NULL THEN DATEDIFF(SS, EnqueueingTime, @Now) END) ,0) AS WaitingMax
	,ISNULL(SUM(1), 0) AS InCallCount
	--,ISNULL(SUM(CASE WHEN C.CallResult = 'Served' THEN 1 ELSE 0 END), 0) AS ServedCallsCount	
	,ISNULL(SUM(CASE WHEN (C.CallPhase='Enqueued' OR C.CallPhase='WaitingQueue') AND C.CallResult = 'Lost' THEN 1 ELSE 0 END), 0) AS LostCallsCount
	--,SUM(1-IIF((C.CallPhase='Enqueued' OR C.CallPhase='WaitingQueue') AND C.CallResult = 'Lost',1,0)) AS Processed
	--,ISNULL(SUM(CASE WHEN C.CallResult = 'Lost' AND QueueDuration IS NOT NULL AND QueueDuration > 30 THEN 1 ELSE 0 END), 0) AS LostCallsAfterThresholdCount
	,ISNULL(SUM(CASE WHEN C.CallResult = 'Served' AND QueueDuration <= 30  THEN 1 ELSE 0 END), 0) AS ServedCallsInThresholdCount
FROM iCC.dbo.InboundCall AS C WITH (NOLOCK)
LEFT JOIN iCC.dbo.Project AS P  WITH (NOLOCK) ON C.ProjectId=P.ProjectId 
left join iCC.dbo.Agent as A with (nolock) on a.AgentId=c.AgentId
WHERE PilotTime >= @Today  AND C.ProjectId IN (SELECT * FROM [FS_custom].dbo.[Return_Ids](@ProjectGroup))
  	 ) AS Phase1
		) AS Corn
    ) as piv
UNPIVOT
    (   -- define new result columns.  
        ----  [Value] is the detailed count/sum/whatever
        ----  [Column] get the old name of the column 

        [Number] 
        for [Column1] in (Queue,  WaitingMax, InCallCount,LostCallsCount,Processed,SL) 
    ) as unpiv
	) AS Phase2

--SL=	CAST(CAST((SUM(ServedCallsCount) - SUM(ServedCallsAfterThresholdCount))AS DECIMAL(4,1)) / (SUM(ServedCallsCount) + SUM(LostCallsCount))*100 AS DECIMAL(4,0)) 

/*
select
 1 as Rank
,'SLA '+(SELECT DisplayName FROM iCC.dbo.Project WITH (NOLOCK) WHERE ProjectId=@ProjectId) as Text, 
convert(nvarchar(10),FS_Custom.dbo.SLA_Calls(@ProjectId,20,@Today))+'%' as Number
,'#4682B4' as BackColor
,'#F7f9f9' as FrontColor
,'fa fa-level-up' as Glyph

UNION ALL
select
 2 as rank
,'Počet zvednutých hovorů dne' as Text, 
convert(nvarchar(10),count(*)) as Number
,'#4682B4' as BackColor
,'#F7f9f9' as FrontColor
,'fa fa-phone' as Glyph
 from icc.dbo.inboundcall with (nolock) 
	where PilotTime >= @Today AND AnswerTime IS NOT NULL AND ProjectId=@ProjectId

UNION ALL
select
 3 as rank
,'Počet ztracených hovorů dne' as Text, 
convert(nvarchar(10),count(*)) as Number
,'#4682B4' as BackColor
,'#F7f9f9' as FrontColor
,'fa fa-phone' as Glyph
 from icc.dbo.inboundcall with (nolock) 
	where  PilotTime>= @Today AND AnswerTime IS NOT NULL AND ProjectId=@ProjectId AND EnqueueingTime IS NOT NULL AND CallResult='Lost'

UNION ALL
select
 4 as rank
,'AST dne' as Text, 
convert(nvarchar(10),AVG(CallDuration)) as Number
,'#4682B4' as BackColor
,'#F7f9f9' as FrontColor
,'fa fa-phone' as Glyph
 from icc.dbo.inboundcall with (nolock) 
	where  PilotTime>= @Today AND AnswerTime IS NOT NULL AND ProjectId=@ProjectId AND ISNULL(CallDuration,0)>0

union all
select 
5 as Rank
,'Lidí v IVR' as Text
,CONVERT(NVARCHAR(10),ISNULL(sum(1),0)) as Number
,'#4682B4' as BackColor
,'#F7f9f9' as FrontColor
,'fa fa-phone' as Glyph
FROM iCC.dbo.InboundCall WITH (NOLOCK) WHERE pilottime >= @today AND ProjectId=@ProjectId AND CallResult='active' and callphase in ('IvrScriptA','ivrscriptw')

union all
select 
6 as Rank
,'Aktivních operátorů' as Text
,CONVERT(NVARCHAR(10),ISNULL(sum(1),0)) as Number
,'#4682B4' as BackColor
,'#F7f9f9' as FrontColor
,'fa fa-users' as Glyph
FROM iCC.dbo.Agent AG WITH (NOLOCK) 
  INNER JOIN iCC.dbo.Skill SK WITH (NOLOCK) ON SK.AgentId=AG.AgentId AND ProjectId=@ProjectId AND PbxInCount>0 AND PbxInEnabled=1 AND PbxInChannel=1
WHERE AG.Activity='Ready'

union all
select 
7 as Rank
,'Počet e-mailů k řešení' as Text
,CONVERT(NVARCHAR(10),ISNULL(sum(1),0)) as Number
,'#4682B4' as BackColor
,'#F7f9f9' as FrontColor
,'fa fa-envelope' as Glyph
FROM iCC.dbo.Message WITH (NOLOCK) WHERE ProjectId=@ProjectId
AND (MessagePhase='Accepted' OR MessagePhase='Answering' OR MessagePhase='Draft' OR MessagePhase='Read' OR MessagePhase='Received')

union all
select 
8 as Rank
,'Nejstarší e-mail: '+CONVERT(NVARCHAR(19),ISNULL(MIN(ReceivedSentTime),0),121) as Text
,':' as Number
,'#4682B4' as BackColor
,'#F7f9f9' as FrontColor
,'fa fa-envelope' as Glyph
FROM iCC.dbo.Message WITH (NOLOCK) WHERE ProjectId=@ProjectId
AND EndTime IS NULL
*/
);


GO

