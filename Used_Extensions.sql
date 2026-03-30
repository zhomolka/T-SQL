use iCC
declare @From as datetime = '2022-05-01'
SELECT * FROM (
select null as Id, '---- Použité linky od '+convert(nvarchar, @From, 103)+' ----' as Name, null as number,'' AS ProStatus
union all

select distinct(w.WorkplaceId), w.DisplayName as Name, w.Number,IIF(EX.OnLineStatus=0,'OK'
,CONVERT(NVARCHAR(10),EX.OnLineStatus)) AS ProStatus 
 from AgentEvent ae
join Workplace w on ae.WorkplaceId = w.WorkplaceId
LEFT JOIN Proserver.dbo.Extension EX ON EX.Number=W.Number
where ae.WorkplaceId  is not null and TimeUtc > @From
and ae.EventType = 'AgentStatus' and w.Deleted = 0
) AS Phase1
order by Name
