USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[WB_InCalls2]    Script Date: 21. 2. 2023 15:04:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2020-03-18
-- Description:	Řádek do Wallboardu o Příchozích hovorech
-- =============================================
CREATE FUNCTION [dbo].[WB_InCalls2] (@today datetime)
RETURNS TABLE
AS
RETURN
     (
 select
IIF(Column1='ServedCalls',1,IIF(Column1='LostCalls',2,IIF(Column1='InCalls',3,IIF(Column1='ServedThreshold',4,IIF(Column1='ServedCallsAfterThreshold',5,6))))) as Rank,
IIF(Column1='ServedCalls','Přijaté hovory',IIF(Column1='LostCalls','Ztracené hovory',IIF(Column1='InCalls','Hovory celkem',IIF(Column1='ServedThreshold','Hovory do 20 sec. / nad 20 sec.',IIF(Column1='ServedCallsAfterThreshold','Hovory do 20 sec. / nad 20 sec.','-----'))))) AS Text
,convert(nvarchar(10),Number) as Number
,'#ccff99' as BackColor
,'#000000' as FrontColor
,IIF(Column1='LostCalls','fa fa-trash','fa fa-phone') as Glyph

 FROM (
select  [Column1], [Number]
from 
    (   -- select relevant columns from source 
        select  InCalls, ServedCalls,LostCalls,ServedThreshold
        from (
		SELECT convert(nvarchar(10),ServedCalls+LostCalls) AS InCalls, 
		convert(nvarchar(10),ServedCalls) AS ServedCalls,convert(nvarchar(10),LostCalls) AS LostCalls
		,convert(nvarchar(4),ServedCallsInThreshold)+'/ '+convert(nvarchar(4),ServedCallsAfterThreshold) AS ServedThreshold
		from (
		SELECT
	'Inbound' AS Label
	/*,ISNULL(SUM(CASE WHEN ((AnswerTime is not null AND TeamName='CC' AND FS_Custom.dbo.IsLekarna(TeamName,C.ProjectId)=0)
       OR
   (CallResult='Lost' AND DATEDIFF(SECOND, EnqueueingTime, EndTime) > 3 and FS_custom.dbo.IsWhiteList2(C.InboundCallId)=0 AND FS_Custom.dbo.IsWorkTime3(C.InboundCallId,C.PilotTime)=1)) 
    THEN 1 ELSE 0 END), 0) AS InCalls	*/
	,ISNULL(SUM(CASE WHEN AnswerTime is not null AND AnswerTime > @today  AND TeamName='CC' AND FS_Custom.dbo.IsLekarna(TeamName,C.ProjectId)=0 THEN 1 ELSE 0 END), 0) AS ServedCalls	
	,ISNULL(SUM(CASE WHEN FS_custom.dbo.IsWhiteList2(C.InboundCallId)=0
	    -- AND DATEDIFF(SECOND, EnqueueingTime, EndTime) > 3 AND C.CallResult = 'Lost'
		 AND FS_Custom.[dbo].[IsLost](@Today,CONVERT(Datetime,'2099.01.01'),C.pilottime,C.EnqueueingTime,C.EndTime,C.CallResult)=1
	     AND FS_Custom.dbo.IsWorkTime3(C.InboundCallId,C.PilotTime)=1
		 AND FS_Custom.dbo.IsCCCall2(ProjectGroupName)=1
		  THEN 1 ELSE 0 END), 0) AS LostCalls
	,ISNULL(SUM(CASE WHEN AnswerTime is not null AND FS_Custom.dbo.IsLekarna(TeamName,C.ProjectId)=0 AND TeamName='CC' AND 
	   (isnull(QueueDuration,0)+isnull(RingDuration,0)) <= 20 THEN 1 ELSE 0 END), 0) AS ServedCallsInThreshold
	,ISNULL(SUM(CASE WHEN  AnswerTime is not null AND FS_Custom.dbo.IsLekarna(TeamName,C.ProjectId)=0 AND TeamName='CC' AND 
	   (isnull(QueueDuration,0)+isnull(RingDuration,0)) > 20  THEN 1 ELSE 0 END), 0) AS ServedCallsAfterThreshold
FROM ICC.dbo.InboundCall AS C WITH (NOLOCK)
	left join icc.dbo.Project as P with(nolock) on C.ProjectId = P.ProjectId	
WHERE PilotTime >= @Today 
	    ) AS Phase1 
		) AS Corn
    ) as piv
UNPIVOT (
        [Number] 
        for [Column1] in (inCalls, ServedCalls,LostCalls,ServedThreshold) 
    ) as unpiv
	) AS Phase2



)


GO

