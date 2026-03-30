:r C:\\Atlantis\\Scripts\\setvar.txt
USE $(ICC)
declare @From as datetime = DATEADD(YEAR,-3,GETDATE()) --'2022-05-01'
SELECT Number,WP.DisplayName AS WPName,Voice,Message, Chat, LastUsed, WP.Workplaceid 
FROM Workplace WP
--select null as Id, '---- Použité linky od '+convert(nvarchar, @From, 103)+' ----' as Name, null as number,'' AS LastUsed
--union all
  LEFT JOIN (

select WorkplaceId --, w.DisplayName as Name, w.Number
--,IIF(EX.OnLineStatus=0,'OK',CONVERT(NVARCHAR(10),EX.OnLineStatus)) AS ProStatus
,MAX(TimeLocal) LastUsed
 from AgentEvent ae
--join Workplace w on ae.WorkplaceId = w.WorkplaceId
--LEFT JOIN Proserver.dbo.Extension EX ON EX.Number=W.Number

where ae.WorkplaceId  is not null --and TimeUtc > @From
and ae.EventType = 'AgentStatus' --and w.Deleted = 0
GROUP BY WorkplaceId --, w.DisplayName , w.Number
--IIF(EX.OnLineStatus=0,'OK',CONVERT(NVARCHAR(10),EX.OnLineStatus)) 
) AS Phase1
  ON WP.WorkplaceId=Phase1.WorkplaceId
  WHERE Deleted=0
ORDER by Number
