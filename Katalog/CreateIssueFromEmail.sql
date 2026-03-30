USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[CreateIssueFromEmail]    Script Date: 14.07.2021 9:47:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Jiří Stejskal>
-- Create date: <27.1.2017>
-- Description:	<Skript, který zakládá automaticky případy z mailů>
-- 23.7.2020 ZbH na radu Jiz změnil pořadí založení Issue
-- 30.3.2021 ZbH upravil pro potřeby ČT
-- =============================================
CREATE PROCEDURE [dbo].[CreateIssueFromEmail]
@MessageId uniqueidentifier
AS
BEGIN
--declare @MessageId uniqueidentifier='b5c4eaf1-c336-e911-90ff-005056011652'
declare @Condition nvarchar(5)=0
declare @ConditionId uniqueidentifier
declare @Subject nvarchar (max) = (select SubjectField from iCC.dbo.Message where MessageId=@MessageId)
declare @Adress nvarchar (max) = (select pilotaddress from iCC.dbo.Gateway where GatewayId=(select GatewayId from iCC.dbo.Message where MessageId=@MessageId))
set @Subject= replace(@Subject,'[','')
set @Subject= replace(@Subject,']','')
--rozhodni jaká varianta podmínek je správná
/*
if exists (select * from FS_custom.dbo.AutomaticTicket a where a.Gateway=@Adress and @Subject like '%' + a.Subject + '%') 
begin
		set @Condition=1
		set @ConditionId = (select top 1 Id from FS_custom.dbo.AutomaticTicket x where x.Gateway=@Adress and @Subject like '%' + x.Subject + '%')

end 


if @Condition=0 and exists (select * from FS_custom.dbo.AutomaticTicket a where isnull(a.Gateway,'qwertzuio')<>@Adress and @Subject like '%' + a.Subject + '%')
begin
		set @Condition=2 
		set @ConditionId = (select top 1 Id from FS_custom.dbo.AutomaticTicket x where x.Gateway is null and @Subject like '%' + x.Subject + '%')
end


if @Condition=0 and exists (select * from FS_custom.dbo.AutomaticTicket a where a.Gateway=@Adress and @Subject  not like '%' + isnull(a.Subject,'qwertzuio') + '%')
begin
		set @Condition=3 
		set @ConditionId = (select top 1 Id from FS_custom.dbo.AutomaticTicket x where x.Gateway=@Adress and x.Subject is null)
end



if @Condition=0 or @conditionId is null RETURN
*/
DECLARE @Decko AS bit=0

IF (select top 1 1 from iCC.dbo.Message ME with (nolock) 
INNER JOIN [iCC].[dbo].[Gateway] GW with (nolock) ON ME.GatewayId=GW.GatewayId
  where MessageId=@MessageId AND GW.PilotAddress='prazdniny@ceskatelevize.cz') IS NULL
     SET @Decko=1
/*IF (select top 1 1 from iCC.dbo.Message ME with (nolock) 
INNER JOIN [iCC].[dbo].[Gateway] GW with (nolock) ON ME.GatewayId=GW.GatewayId
  where MessageId=@MessageId AND GW.Description='Déčko') IS NOT NULL
     SET @Decko=1*/

declare @ProjectId as uniqueidentifier = (select projectid from iCC.dbo.Message where MessageId=@MessageId)
--declare @ContactId as uniqueidentifier = (select ContactId from iCC.dbo.Message where MessageId=@MessageId)
declare @TopicId as Uniqueidentifier= IIF(@Decko=1,(SELECT TOP (1) [NormalTopicId]
  FROM [iCC].[dbo].[IssueCondition] WHERE ProjectId=@ProjectId),'48cd174f-21fe-4c87-8ecc-115f9b5af650') -- Projekty 
declare @SubTopicId as Uniqueidentifier=IIF(@Decko=1,(select TOP 1 subtopicId from iCC.dbo.SubTopic 
   where Deleted =0 and TopicId=@TopicId AND DefaultItem=1),'6af85c5a-f7ec-4836-bb41-f81488eb8318') -- Advent2020 
declare @PhaseId as Uniqueidentifier = 'FB0B4C2C-9B57-49F4-BA50-0C053E4901DD' -- fáze Rozpracováno
declare @FormDataId as Uniqueidentifier=newid()
declare @IssueId as uniqueidentifier =newid()
declare @ScenarioId as uniqueidentifier = '2fbd0f27-0928-4955-8f5e-bd15f6f90f47' --ID formuláře případu
--declare @Predat nvarchar(max)= (select queue from FS_custom.dbo.AutomaticTicket where ID=@ConditionId)
--declare @ResultNumber int = (select top 1 ResultNumber from iCC.dbo.ScreenControlParameter where ResultText = @Predat and ScreenControlId='d8e0d4e3-9b02-405e-9407-10ca6ec2b94e' )
declare @AgentId uniqueidentifier --='0b369100-251d-4ac5-b51f-2a91a3babddd'



--select @Condition,@ConditionId,@TopicId,@SubTopicId



--vložení do tabulky scenarioResult
insert into icc.dbo.ScenarioResult
(ScenarioResultId,ScenarioId,TimeUtc,Activity)
values
(@FormDataId,@ScenarioId,getutcdate(),'Active')

--založení případu
insert into icc.dbo.Issue
(issueid,timeutc,DisplayName, activity, Priority,topicid, SubTopicId, AgentId, TeamName,OriginalProjectId,ProjectId,NewTime,OpenTime,NewClosed,Reactivated,Escalated,OpenDuration,mark,
PhaseId,ExpireAfter,ObliviateAfter,GdprSensitivity,FormDataId)
values
(@issueid,GETUTCDATE(),'Automat','Open',0,@TopicId,@SubTopicId,null,null,@ProjectId,@Projectid,getdate(),getdate(),0,0,0,0,0,@PhaseId,dateadd(yy,4,getdate()),dateadd(yy,4,getdate()),4,@FormDataId)

update icc.dbo.ScenarioResult
set issueid=@issueid
where ScenarioResultId=@FormDataId


/*update icc.dbo.IssueExtra
set --Predat=@Predat,
AutorId=@AgentId
where issueid=@IssueId*/


update icc.dbo.message
set IssueId=@IssueId
--,AgentId=@AgentId
--,MessagePhase='Accepted'
--,AcceptedTime=GETDATE()
where MessageId=@MessageId
/**/

--exec icc.dbo.SetTargetColumnText @FormDataId,'Predat',@Predat
exec icc.dbo.SetTargetColumnText @FormDataId,'Detail',''
exec icc.dbo.SetTargetColumnText @FormDataId,'Nazev',''
exec icc.dbo.SetTargetColumnText @FormDataId,'MarketingUsage',''
exec icc.dbo.SetTargetColumnText @FormDataId,'Note',' '
exec icc.dbo.SetTargetColumnText @FormDataId,'Priority',NULL
exec icc.dbo.SetTargetColumnText @FormDataId,'PrijetiPozadavku',''
exec icc.dbo.SetTargetColumnText @FormDataId,'PrideleniOperatorovi',''
exec icc.dbo.SetTargetColumnText @FormDataId,'PrvniReakce',''
exec icc.dbo.SetTargetColumnText @FormDataId,'ZadostKonzultace',NULL
exec icc.dbo.SetTargetColumnText @FormDataId,'OdpovedKonzultace',''
exec icc.dbo.SetTargetColumnText @FormDataId,'PrvniVyreseni',''

/*
update icc.dbo.ScenarioResultValue 
set ResultNumber=@ResultNumber
where ScenarioResultId=@FormDataId and TargetColumn='Predat'
*/
insert into icc.dbo.IssueEvent (IssueEventId,TimeUtc,TimeLocal,EventType,IssueId,AgentId,ReferenceData,ReferenceId)
select newid(),GETUTCDATE(),getdate(),'DataSaved',@IssueId,@AgentId,'save',@FormDataId

insert into icc.dbo.MessageEvent (MessageEventId,TimeUtc,TimeLocal,EventType,MessageId,ProjectId,AgentId,ReferenceData,ReferenceId,Duration,ResultData)
select newid(),GETUTCDATE(),getdate(),'IssueChange',@MessageId,@ProjectId,@AgentId,'MessageController_newissue',@IssueId,null,'Auto'

END


GO

