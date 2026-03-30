USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_AgentiEmaily]    Script Date: 5.2.2018 9:40:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jakub Pospíchal
-- Create date: 21.4.2017
-- Upravil: Zbyněk Homolka 20.9.2017
-- Description:
--emaily, které někdo přepošle (předat dál) se nemají počítat ani do „zpracováno jako RE“, ani do „zpracováno jako nový“. 
-- =============================================
CREATE FUNCTION [dbo].[rep_AgentiEmaily]
(	
@from datetime,
@to datetime,
@interval char,
@Today datetime
)
RETURNS TABLE 
AS
RETURN 
(
/*
declare @from date ='2017-04-01'
declare @to date ='2017-05-01'
declare @interval char ='D'
declare @Today datetime =getdate()
*/
select 
d.s,
d.e
,a.AgentId
,a.DisplayName
,a.TeamName
,(select count(*) from icc.dbo.Message m where MessageType='Email' and Direction='I' and AcceptedTime>d.s and AcceptedTime <=d.e and m.AgentId=a.AgentId and (m.SpamLevel=0 or m.SpamLevel is null)) as Doruceno
,(select count(*) from icc.dbo.Message m where MessageType='Email' AND Direction='I' and /*AcceptedTime>d.s and*/
 AcceptedTime <=d.e and m.AgentId=a.AgentId AND (AnsweringTime IS NULL OR AnsweringTime>d.e) and (EndTime IS NULL OR EndTime>d.e)
 and (m.SpamLevel=0 or m.SpamLevel is null)) as Rozpracovano

,(select count(*) from icc.dbo.Message m where MessageType='Email' AND Direction='I' /*and AcceptedTime>d.s and AcceptedTime <=d.e*/ 
and m.AgentId=a.AgentId  and (m.SpamLevel=0 or m.SpamLevel is null) AND  AnsweringTime>d.s AND AnsweringTime <=d.e
 and NOT EXISTS(SELECT TOP 1 MessageiD FROM icc.dbo.Message ME2 WITH (NOLOCK) WHERE ME2.RelatedMessageId=M.MessageiD AND ME2.SubjectField LIKE 'FW%')) as ZpracovanoRe

,(select count(*) from icc.dbo.Message m where MessageType='Email' AND Direction='O' And RelatedMessageId IS NULL and ReceivedSentTime>d.s and ReceivedSentTime <=d.e
 and m.AgentId=a.AgentId AND (m.SpamLevel=0 or m.SpamLevel is null)) as ZpracovanoNew

,(select count(*) from icc.dbo.MessageEvent mev where mev.EventType='ProjectChange' AND mev.TimeLocal>@from and mev.TimeLocal <=d.e
  AND mev.AgentId=a.AgentId) as Predano -- Změna projektu
,(select count(*) from icc.dbo.MessageEvent mev where mev.EventType='ProjectChange' AND mev.TimeLocal>d.s and mev.TimeLocal <=d.e
  AND mev.AgentId=a.AgentId
  and mev.ProjectId='ec01b642-a8aa-44a1-aa0c-820e67f35ee3') as PredanoSP -- Změna projektu na speciální

,(select count(*) from icc.dbo.MessageEvent mev where mev.EventType='ProjectChange' AND mev.TimeLocal>d.s and mev.TimeLocal <=d.e
  AND mev.AgentId=a.AgentId
  AND FS_Custom.dbo.DepartChange(mev.MessageId,mev.TimeLocal,mev.ProjectId)=1) as PredanoJO -- na jiné oddělení

--,(select count(*) from icc.dbo.message x where x.Direction='I' and ReceivedSentTime>d.s and ReceivedSentTime <=d.e  and x.AgentId=a.AgentId and (x.SpamLevel=0 or x.SpamLevel is null) and exists (select * from icc.dbo.MessageEvent m where m.messageid = x.MessageId and m.EventType='ProjectChange')) as PredanoJO -- na jiné oddělení
--,(select count(*) from icc.dbo.message x where x.Direction='I' and ReceivedSentTime>d.s and ReceivedSentTime <=d.e  and x.AgentId=a.AgentId and (x.SpamLevel=0 or x.SpamLevel is null)  and exists (select * from icc.dbo.MessageEvent m where m.messageid = x.MessageId and m.EventType='ProjectChange' and m.ProjectId='ec01b642-a8aa-44a1-aa0c-820e67f35ee3')) as PredanoSP
--,(select count(*) from icc.dbo.MessageEvent m where TimeLocal>d.s and TimeLocal <=d.e and m.AgentId=a.AgentId and m.EventType='ProjectChange' and m.ProjectId='ec01b642-a8aa-44a1-aa0c-820e67f35ee3') as PredanoSP --hack JiS, přidána podmínka na Direction I
,(select count(*) from icc.dbo.MessageEvent m where TimeLocal>d.s and TimeLocal <=d.e and m.AgentId=a.AgentId and m.EventType='Returning') as VracenoDoFronty
,(select sum(Duration) from icc.dbo.AgentEvent m where TimeLocal>d.s and TimeLocal <=d.e and m.AgentId=a.AgentId and m.EventType='AgentStatus' AND ReferenceData='Ready') as ReadyTime
,(select sum(WorkDuration) from icc.dbo.Message m where ReceivedSentTime>d.s and ReceivedSentTime <=d.e and m.AgentId=a.AgentId) as WorkDuration


from icc.dbo.Rep_DateTime(@From,@to,@interval) d cross join icc.dbo.Agent a with (nolock) where a.Template=0

)

/* Původní verze:
select 
d.s,
d.e
,a.AgentId
,a.DisplayName
,a.TeamName
,(select count(*) from icc.dbo.Message m where MessageType='Email' and Direction='I' and ReceivedSentTime>d.s and ReceivedSentTime <=d.e and m.AgentId=a.AgentId and (m.SpamLevel=0 or m.SpamLevel is null)) as Doruceno
,(select count(*) from icc.dbo.Message m where MessageType='Email' and ReceivedSentTime>d.s and ReceivedSentTime <=d.e and m.AgentId=a.AgentId AND MessageResult not in ('Closed','Answered') and (m.SpamLevel=0 or m.SpamLevel is null)) as Rozpracovano
,(select count(*) from icc.dbo.Message m where MessageType='Email' and ReceivedSentTime>d.s and ReceivedSentTime <=d.e and m.AgentId=a.AgentId AND MessageResult='Closed' and (m.SpamLevel=0 or m.SpamLevel is null)) as Zpracovano
,(select count(*) from icc.dbo.message x where x.Direction='I' and ReceivedSentTime>d.s and ReceivedSentTime <=d.e  and x.AgentId=a.AgentId and (x.SpamLevel=0 or x.SpamLevel is null) and exists (select * from icc.dbo.MessageEvent m where m.messageid = x.MessageId and m.EventType='ProjectChange')) as Predano
,(select count(*) from icc.dbo.message x where x.Direction='I' and ReceivedSentTime>d.s and ReceivedSentTime <=d.e  and x.AgentId=a.AgentId and (x.SpamLevel=0 or x.SpamLevel is null)  and exists (select * from icc.dbo.MessageEvent m where m.messageid = x.MessageId and m.EventType='ProjectChange' and m.ProjectId='ec01b642-a8aa-44a1-aa0c-820e67f35ee3')) as PredanoSP
--,(select count(*) from icc.dbo.MessageEvent m where TimeLocal>d.s and TimeLocal <=d.e and m.AgentId=a.AgentId and m.EventType='ProjectChange' and m.ProjectId='ec01b642-a8aa-44a1-aa0c-820e67f35ee3') as PredanoSP --hack JiS, přidána podmínka na Direction I
,(select count(*) from icc.dbo.MessageEvent m where TimeLocal>d.s and TimeLocal <=d.e and m.AgentId=a.AgentId and m.EventType='Returning') as VracenoDoFronty
,(select sum(Duration) from icc.dbo.AgentEvent m where TimeLocal>d.s and TimeLocal <=d.e and m.AgentId=a.AgentId and m.EventType='AgentStatus' AND ReferenceData='Ready') as ReadyTime
,(select sum(WorkDuration) from icc.dbo.Message m where ReceivedSentTime>d.s and ReceivedSentTime <=d.e and m.AgentId=a.AgentId) as WorkDuration


from icc.dbo.Rep_DateTime(@from,@to,@interval) d cross join icc.dbo.Agent a with (nolock) where a.Template=0

*/

GO

