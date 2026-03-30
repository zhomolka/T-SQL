
use iCC
--declare @From as datetime = '2019-04-01'
declare @From as datetime = DATEADD(Month,-5,GETDATE())
create table #UsedWorkPlace (workplaceid uniqueidentifier, displayname nvarchar(50),number int)
create table #DefinedWorkPlace (workplaceid uniqueidentifier, displayname nvarchar(50),number int)


insert into #UsedWorkPlace
select distinct(w.WorkplaceId), w.DisplayName, w.Number  from AgentEvent ae
join Workplace w on ae.WorkplaceId = w.WorkplaceId
where ae.WorkplaceId  is not null and TimeUtc > @From
             and ae.EventType = 'AgentStatus' and w.Deleted = 0
order by DisplayName


insert into #DefinedWorkPlace
select WorkplaceId, DisplayName, Number from Workplace where Deleted = 0


select null as Id, '---- Nepoužité linky od '+convert(nvarchar, @From, 103)+' ----' as Name, null as number
union all
select workplaceid as Id, displayname as Name, number as number from #DefinedWorkPlace where workplaceid not in (select workplaceid from #UsedWorkPlace) order by number
/*
select null as Id, '---- Použité linky od '+convert(nvarchar, @From, 103)+' ----' as Name, null as number
union all
select workplaceid as Id, displayname as Name, number as number from #UsedWorkPlace
*/


drop table #UsedWorkPlace
drop table #DefinedWorkPlace

