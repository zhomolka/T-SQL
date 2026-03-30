USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_AllAgents]    Script Date: 25. 1. 2016 15:36:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Jiří Stejskal>
-- Create date: <13.10.2015>
-- Description:	<Agentský report>
-- 9.12.2015 ZbH přidal sloupeček Odchozí hovory
-- 17.12.2015 ZbH Nahradil výraz QueueDuration výrazem RingDuration při výpočtu PrumernaDelkaCekani
-- 25.1.2016 ZbH přidal do výpočtupočtu Emailů podmínku: and MessageType='Email'
-- =============================================
CREATE FUNCTION [dbo].[rep_AllAgents]
(	
@from datetime,
@to datetime,
@Interval as char(1) -- Možné hodnoty jsou Y,M,W,D,h,t,q,f
)
RETURNS TABLE 
AS
RETURN 
(
select 
b.s
,b.E
,a.AgentId
,a.DisplayName
,a.TeamName
,(SELECT fs_custom.dbo.GetFirstLogonTime(A.AgentId, b.S)) AS FirstLogonTime
,(SELECT fs_custom.dbo.GetLastLogonTime(A.AgentId, b.S)) AS LastLogoffTime
,(select count(*) from icc.dbo.inboundcall with (nolock) where agentid=a.AgentId and Pilottime>=b.s and pilottime <=b.e) as PocetPrichozichHovoru
,(select count(*) from icc.dbo.inboundcall with (nolock) where agentid=a.AgentId and Pilottime>=b.s and pilottime <=b.e and AnswerTime is not null) as PocetVyzvednutychHovoru
,(select count(*) from icc.dbo.inboundcall with (nolock) where agentid=a.AgentId and Pilottime>=b.s and pilottime <=b.e and TransferredTo is not null) as PocetPrepojenychHovoru
,(select count(*) from icc.dbo.inboundcall with (nolock) where agentid=a.AgentId and Pilottime>=b.s and pilottime <=b.e and AnswerTime is  null) as PocetZtracenychHovoru
,(select avg(CallDuration) from icc.dbo.inboundcall with (nolock) where agentid=a.AgentId and Pilottime>=b.s and pilottime <=b.e and AnswerTime is not null) as PrumernaDobaHovoruPrichozi
,(select avg(duration) from icc.dbo.AgentEvent with (nolock) where agentid=a.AgentId and TimeLocal>=b.s and timelocal <=b.e and ReferenceData='PostCall') as PrumernaDelkaZabalu
,(select avg(RingDuration) from icc.dbo.inboundcall with (nolock) where agentid=a.AgentId and Pilottime>=b.s and pilottime <=b.e and AnswerTime is not null) as PrumernaDelkaCekani
,(select FS_custom.dbo.GetStateLength_2('60FBA1E2-08F0-4129-97B3-3041E9EE27B8',a.AgentId,b.s,b.e)) as AvailabilityTime
,(select sum(callduration) from icc.dbo.InboundCall i with (nolock) where i.AnswerTime >=b.s and i.AnswerTime<=b.e and agentid=a.AgentId) as Occupancy
,(select sum(duration) from icc.dbo.AgentEvent with (nolock) where agentid=a.AgentId and TimeLocal>=b.s and timelocal <=b.e and ReferenceData='Pause') as DelkaPauzy
,(select sum(duration) from icc.dbo.AgentEvent with (nolock) where agentid=a.AgentId and TimeLocal>=b.s and timelocal <=b.e and ReferenceData='Pause' and ReferenceId='E6A8E80D-2300-4699-91E7-0FB3533063DF') as Vypomoc
,(select sum(duration) from icc.dbo.AgentEvent with (nolock) where agentid=a.AgentId and TimeLocal>=b.s and timelocal <=b.e and ReferenceData='Pause' and ReferenceId='3961305B-DEE5-44FD-B8C5-3A82FF125159') as OsobniRozvoj
,(select sum(duration) from icc.dbo.AgentEvent with (nolock) where agentid=a.AgentId and TimeLocal>=b.s and timelocal <=b.e and ReferenceData='Pause' and ReferenceId='0CCC24A1-669E-4ECE-BA12-3B1FCA7448BB') as Administrativni
,(select sum(duration) from icc.dbo.AgentEvent with (nolock) where agentid=a.AgentId and TimeLocal>=b.s and timelocal <=b.e and ReferenceData='Pause' and ReferenceId='78028459-CA9E-45DE-A574-5005F96774BC') as Osobni
,(select sum(duration) from icc.dbo.AgentEvent with (nolock) where agentid=a.AgentId and TimeLocal>=b.s and timelocal <=b.e and ReferenceData='Pause' and ReferenceId='C13FFB8D-79CC-4AFA-BE7C-5BCAFC6FA155') as Maily
,(select sum(duration) from icc.dbo.AgentEvent with (nolock) where agentid=a.AgentId and TimeLocal>=b.s and timelocal <=b.e and ReferenceData='Pause' and ReferenceId='E4176740-4963-49CF-B41C-995E4F82C9D5') as Obed
,(select sum(duration) from icc.dbo.AgentEvent with (nolock) where agentid=a.AgentId and TimeLocal>=b.s and timelocal <=b.e and ReferenceData='Pause' and ReferenceId='CDDEA56D-AAB4-4756-8B50-AC5BEC7FFA96') as RadimSe
,(select sum(duration) from icc.dbo.AgentEvent with (nolock) where agentid=a.AgentId and TimeLocal>=b.s and timelocal <=b.e and ReferenceData='Pause' and ReferenceId='50823a9f-2a07-4542-adbc-d96c97e6e431') as OdchoziHovory
,(select count(*) from icc.dbo.OutboundCall with (nolock) where AgentId=a.AgentId and TimeUtc>=b.s and TimeUtc <=b.e) PocetOdchozich	
,(select count(*) from icc.dbo.OutboundCall with (nolock) where AgentId=a.AgentId and TimeUtc>=b.s and timeutc <=b.e and CallDuration is not null) PocetOdchozichUskutecnenych		
,(select avg(CallDuration) from icc.dbo.OutboundCall with (nolock) where AgentId=a.AgentId and TimeUtc>=b.s and timeutc <=b.e and CallDuration is not null) PrumernaDelkaHovoruOdchozi	
,(select count(*) from icc.dbo.Message m with (nolock) where AgentId=a.AgentId and DraftTime>=b.s and DraftTime <=b.e and MessageType='Email') as PocetEmailu
,(select count(*) from icc.dbo.Message m with (nolock) where AgentId=a.AgentId and DraftTime>=b.s and DraftTime <=b.e and MessagePhase='Closed' and MessageResult='Answered') as EmailyOdpovedi
,(select count(*) from icc.dbo.Message m with (nolock) where AgentId=a.AgentId and DraftTime>=b.s and DraftTime <=b.e and  (messagephase='closed' or messageresult='closed') and MessageResult<>'Answered' and MessageType='Email' ) as EmailyZavrene
,(select count(*) from icc.dbo.Message m with (nolock) where AgentId=a.AgentId and DraftTime>=b.s and DraftTime <=b.e and exists (select * from icc.dbo.messageevent me with (nolock) where EventType='Forwarding' and me.AgentId=a.AgentId and m.MessageId=me.messageid)) as EmailyPreposlane
,(select FS_custom.dbo.GetStateLengthRevers('E8AD6B58-B5CC-478F-9BAE-D6C8D8DC1AAE',a.AgentId,b.s,b.e)) as LogOnTime
from
icc.dbo.Rep_DateTime(@from,@to,@Interval) b cross join icc.dbo.Agent a with (nolock)
where a.Deleted=0
)


GO

