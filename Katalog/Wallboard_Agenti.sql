USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[WallboardAgenti_table]    Script Date: 28. 4. 2023 15:37:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Jiří Stejskal>
-- Create date: <10.5.2016>
-- Description:	<Wallboard agentů>
-- 11.8. Pintar David požadoval: nepočítejme pro wallboard e-maily, které byly odeslány z adresy zakaznicky.servis@hptronic.cz
-- 16.8. Pintar David požadoval: příchozí e-maily tam určitě nepočítejme
-- 14.10.2016 : jsou odpovědi na přijatý e-mail
-- 19.1.2017 Přidán do výpočtů výraz and (DATEDIFF(hh , @DateTime , GETDATE())<=1 OR AnswerTime <= @DateTime)
-- který zajišťuje možnost zadat do @LasHour konečný čas při volání funkce z reportu
-- 17.10.2017 Přidány Chaty
-- 11.3.2019 Dohodnuto s Davidem Pintarem, že se má u mailů posuzovat ReceivedSentTime a ne EndTime
-- 18.6. 2019 Pintar David požadoval: výměnu chatů za přepadlé hovory
-- 30.7. 2019 požadovali: přičítat přepadlé hovory k příchozím
-- 8.6. 2020 B.CH s pí Novákovou K. úprava jednotné barvy řádků tabulky
-- 8.12.2021 ZbH otestoval a nasadil VaK zrychlovák
-- =============================================
CREATE FUNCTION [dbo].[WallboardAgenti_table]
(	
@Today datetime
,@DateTime datetime
)
RETURNS TABLE 
AS
RETURN 
(

/*
declare @Now as datetime = GETDATE()
declare @Today as datetime = CAST(@Now as date)
declare @DateTime as datetime = DATEADD(hour,-1,@Now)
declare @LastWeek as datetime = DATEADD(day,-7,@Now)
declare @LastMonth as datetime = DATEADD(month,-1,@Now)
declare @ThisMonth as datetime = DATEADD(day,1-DAY(@Today),@Today)
declare @FilterTimeTo as datetime = DATEADD(minute,-30,@Now)
*/
select 
	rank() over (order by celkemhodinazpet desc) as Poradi 
	, convert(bit,1) as Barva1
	--,convert(bit,(case when rank() over (order by celkemhodinazpet desc) <=3 then 1 else 0 end )) Barva1
	--,convert(bit,(case when rank() over (order by celkemhodinazpet desc) >3 then 1 else 0 end )) Barva2
	,*
	, PocetOdchodu+PocetPrichodu+PocetZprav+PocetChatu as Celkem 
from (
		 --======VaK zrychlovak (20201121):

			 select 
					a.DisplayName
					,A.GroupName
					,ISNULL(PocetPrichodu_WOLastHour,0) as PocetPrichodu
					,ISNULL(PocetOdchodu_WOLastHour,0) as PocetOdchodu
					,ISNULL(PocetZprav_WOLastHour,0) as PocetZprav
					,ISNULL(PocetChatu,0) as PocetChatu
					,ISNULL(Diverted,0) as Diverted
					,(ISNULL(PocetPrichodu_LastHour,0)	+ ISNULL(PocetOdchodu_LastHour,0)
					    + ISNULL(PocetZprav_LastHour,0)) as CelkemHodinaZpet
				from icc.dbo.Agent as a with (nolock)
				left join (
					select 
						i.AgentId
						,sum(case when (I.AnswerTime <= @DateTime) then 1 else 0 end) as PocetPrichodu_WOLastHour
						,sum(case when (AnswerTime >=@DateTime) then 1 else 0 end) as PocetPrichodu_LastHour
					from icc.dbo.InboundCall i with (nolock) where i.AnswerTime >=@Today  --and DATEDIFF(hh , @DateTime , GETDATE())<=1 OR i.AnswerTime <= @DateTime)
					group by i.AgentId) as i on a.AgentId = i.AgentId
				left join (
					select 
						o.AgentId
						,sum(case when (o.AnswerTime <= @DateTime) then 1 else 0 end) as PocetOdchodu_WOLastHour
						,sum(case when (o.AnswerTime >=@DateTime) then 1 else 0 end) as PocetOdchodu_LastHour
					from icc.dbo.OutboundCall o where o.AnswerTime >=@Today --and (DATEDIFF(hh , @DateTime , GETDATE())<=1 OR o.AnswerTime <= @DateTime)
					group by o.AgentId) as o on a.AgentId = o.AgentId
				left join (
					select 
						m.AgentId
						,sum(case when (m.ReceivedSentTime <= @DateTime) then 1 else 0 end) as PocetZprav_WOLastHour
						,sum(case when (m.ReceivedSentTime >=@DateTime) then 1 else 0 end) as PocetZprav_LastHour
					from icc.dbo.Message m with (nolock) where ReceivedSentTime>=@Today and MessageType='Email' AND m.GatewayId<>'A78D7F31-AF94-46A3-A059-300C17EF72C3'
						AND M.Direction = 'O' AND M.RelatedMessageId IS NOT NULL --and (DATEDIFF(hh , @DateTime , GETDATE())<=1 OR ReceivedSentTime <= @DateTime)
					group by m.AgentId) as m on a.AgentId = m.AgentId
				left join (
					select 
						ch.AgentId
						,sum(case when ch.ChatId is not null then 1 else 0 end) as PocetChatu
					from icc.dbo.Chat ch with (nolock) where ch.endtime >= @Today and ChatResult='Served' and LEN(ch.BodyText)>200
					group by ch.AgentId) as ch on a.AgentId = ch.AgentId
				left join (
					select 
						ce.AgentId
						,sum(case when ce.CallEventId is not null then 1 else 0 end) as Diverted
					from icc.dbo.CallEvent ce with (nolock) where timelocal>=@Today and EventType='AgentMissed'
					group by ce.AgentId) as ce on a.AgentId = ce.AgentId
				where Deleted=0 and a.Template=0 and a.GroupName ='Brno'
				) AS Phase1
				--order by a.DisplayName
)
GO

