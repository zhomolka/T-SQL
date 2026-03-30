USE [FS_reporting]
GO

/****** Object:  UserDefinedFunction [dbo].[StatusDuration_WOInteraction]    Script Date: 21.01.2019 9:26:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Václav Kubát>
-- Create date: <18. 1. 2019>
-- Description:	<vraci cistou dobu stravenou agentem v nejakem stavu - tedy doba stravena ve stavu po odecteni prace na interakcich (message,in/out calls a chat)>
-- =============================================
CREATE FUNCTION [dbo].[StatusDuration_WOInteraction]
(
	@StatusId as uniqueidentifier
	,@AgentId as uniqueidentifier
	,@From as datetime
	,@To as datetime
	
)
RETURNS int
AS
BEGIN
	
	--========================================================================================================================
--set @StatusId = '60fba1e2-08f0-4129-97b3-3041e9ee27b8'--Připraven
--set @AgentId = '368a95de-2293-493c-8602-c3d90fb110ee'--Dzurik Ondřej
--set @From = '2018-12-13 12:00:00.000'
--set @To = '2018-12-13 12:30:00.000'
--========================================================================================================================

declare @ResultDuration as int

--existuje-li udalost interakce, ktera zacala drive jak interval a pozdeji, vratim nulu, nebo cisty cas stavu je nula...
if exists (select top 1 1 from iCC.dbo.MessageEvent with (nolock) where AgentId = @AgentId and ReferenceData = 'Open' and (TimeLocal <= @From and DATEADD (second,Duration,TimeLocal) >= @To)) 
	begin 
		set @ResultDuration = 0 
		RETURN @ResultDuration
	end
if exists (select top 1 1 from iCC.dbo.InboundCall with (nolock) where AgentId = @AgentId and (AnswerTime <= @From and EndTime >= @To)) 
	begin 
		set @ResultDuration = 0 
		RETURN @ResultDuration
	end
if exists (select top 1 1 from iCC.dbo.OutboundCall with (nolock) where AgentId = @AgentId and CallDuration is not null and (DialTime <= @From and EndTime >= @To)) 
	begin 
		set @ResultDuration = 0 
		RETURN @ResultDuration
	end
if exists (select top 1 1 from iCC.dbo.Chat with (nolock) where AgentId = @AgentId and ChatDuration is not null and (AnswerTime <= @From and EndTime >= @To)) 
	begin 
		set @ResultDuration = 0 
		RETURN @ResultDuration
	end

--nactu si useky, kdy byl agent ve zvolenem stavu
declare @StatusSections as table (AgentEventId uniqueidentifier, [FromTime] datetime, [ToTime] datetime, Duration int, DiscartInteractionId uniqueidentifier, DefaultAgentEventId uniqueidentifier)
insert into @StatusSections
select AgentEventId, TimeLocal as [FromTime], DATEADD (second,Duration,TimeLocal) as [ToTime], Duration, NULL as DiscartInteractionId, NULL as DefaultAgentEventId from iCC.dbo.AgentEvent with (nolock) where AgentId = @AgentId and TimeLocal >= @From and TimeLocal <= @To and EventType = 'AgentStatus' and ReferenceId = @StatusId

	--plus okrajove stavy - tedy na prelomu @From a na prelomu @To (nebo aktuani stav, pokud je @To jako @Now)
	declare @LastAgentEventTime as datetime --= (SELECT MAX(TimeLocal) FROM icc.dbo.AgentEvent WITH (NOLOCK) WHERE  AgentId = @AgentId and TimeLocal > @From and TimeLocal < @To)
	declare @LastAgentEventId as uniqueidentifier = (SELECT top 1 AgentEventId FROM icc.dbo.AgentEvent WITH (NOLOCK) WHERE  AgentId = @AgentId and TimeLocal > @From and TimeLocal < @To order by timelocal desc)
	declare @FirstAgentStatusTime as datetime --= (SELECT MIN(TimeLocal) FROM icc.dbo.AgentEvent WITH (NOLOCK) WHERE  AgentId = @AgentId and TimeLocal > @From and TimeLocal < @To)
	declare @BeforeFrom_LastAgentStatusTime as datetime
	declare @BeforeFrom_LastAgentStatus as nvarchar (30) 
	declare @BeforeFrom_LastAgentStatusId as uniqueidentifier
		SELECT @LastAgentEventTime = MAX(TimeLocal),@FirstAgentStatusTime = MIN(TimeLocal) FROM icc.dbo.AgentEvent WITH (NOLOCK) WHERE  AgentId = @AgentId and TimeLocal > @From and TimeLocal < @To
		--nejprve na prelomu @to nebo pro @Now
		update @StatusSections set Duration = isnull(DATEDIFF(second,FromTime,@To),0) where AgentEventId = @LastAgentEventId

		--pak pro trvani stavu na prelomu parametru @From
		SELECT top 1 --zjisteni posledni stavove aktivity agenta pred pulnoci od nastaveneho @From
			@BeforeFrom_LastAgentStatusTime = TimeLocal
			,@BeforeFrom_LastAgentStatus = ReferenceData 
			,@BeforeFrom_LastAgentStatusId = AgentEventId
		FROM icc.dbo.AgentEvent WITH (NOLOCK) 
		WHERE  AgentId = @AgentId and TimeLocal > dateadd(day,-1,@From) and TimeLocal <= @From and EventType = 'AgentStatus' 
		order by TimeUtc desc

		if (@BeforeFrom_LastAgentStatus <> 'Logoff') --pokud agent nebyl online pres @From, hotovo
			begin
				insert into @StatusSections--trvani aktivniho stavu od pulnoci do prvniho prvniho zapocitaneho stavu dne @From
				select @BeforeFrom_LastAgentStatusId as AgentEventId, @From as [FromTime], @FirstAgentStatusTime as [ToTime], datediff(second,@From,@FirstAgentStatusTime) as Duration, NULL as DiscartInteractionId, NULL as DefaultAgentEventId
			end

--nactu si useky interakci, na kterych agent delal
declare @InteractionSections as table (Id uniqueidentifier, Origin nvarchar(20),[FromTime] datetime, [ToTime] datetime, Duration int)
	--Message
	insert into @InteractionSections
	select MessageEventId as Id, 'MessageEvent' as Origin, TimeLocal as [FromTime], DATEADD (second,Duration,TimeLocal) as [ToTime], Duration from iCC.dbo.MessageEvent with (nolock) 
		where AgentId = @AgentId and ReferenceData = 'Open' and Duration is not null and Duration <> 0
		and ((TimeLocal >= @From and TimeLocal <= @To) --udalost interakce zacala v zadanem intervalu
			or (DATEADD (second,Duration,TimeLocal) >= @From and DATEADD (second,Duration,TimeLocal) <= @To)) --udalost interakce skoncila v zadanem intervalu
	--IN--PROZATIM POCITAM JEN SE SPOJENYMI HOVORY, NEZAHRNUJU POKUSY O DOVOLANI
	insert into @InteractionSections
	select InboundCallId as Id, 'Inboundcall' as Origin, AnswerTime as [FromTime], EndTime as [ToTime], CallDuration from iCC.dbo.InboundCall with (nolock) 
		where AgentId = @AgentId and CallDuration is not null--PROZATIM POCITAM JEN SE SPOJENYMI HOVORY, NEZAHRNUJU POKUSY O DOVOLANI
		and ((AnswerTime >= @From and AnswerTime <= @To) --udalost interakce zacala v zadanem intervalu
			or (EndTime>= @From and EndTime <= @To)) --udalost interakce skoncila v zadanem intervalu
	--OUT--PROZATIM POCITAM JEN SE SPOJENYMI HOVORY, NEZAHRNUJU POKUSY O DOVOLANI
	insert into @InteractionSections
	select OutboundCallId as Id, 'OutboundCall' as Origin, DialTime as [FromTime], EndTime as [ToTime], CallDuration from iCC.dbo.OutboundCall with (nolock) 
		where AgentId = @AgentId and CallDuration is not null--PROZATIM POCITAM JEN SE SPOJENYMI HOVORY, NEZAHRNUJU POKUSY O DOVOLANI
		and ((DialTime >= @From and DialTime <= @To) --udalost interakce zacala v zadanem intervalu
			or (EndTime>= @From and EndTime <= @To)) --udalost interakce skoncila v zadanem intervalu
	--Chat
	insert into @InteractionSections
	select ChatId as Id, 'Chat' as Origin, AnswerTime as [FromTime], EndTime as [ToTime], ChatDuration from iCC.dbo.Chat with (nolock) 
		where AgentId = @AgentId and ChatDuration is not null
		and ((AnswerTime >= @From and AnswerTime <= @To) --udalost interakce zacala v zadanem intervalu
			or (EndTime>= @From and EndTime <= @To)) --udalost interakce skoncila v zadanem intervalu




declare @ActualInterId as uniqueidentifier
declare @Cursor as cursor
declare @InterFrom as datetime
declare @InterTo as datetime

	set @Cursor = cursor for
	select Id from @InteractionSections where Duration is not null order by Duration desc

	--upravy casu stavu, aby jejich cas byl cisty bez interakci
	open @Cursor;
    FETCH NEXT FROM @Cursor INTO @ActualInterId;
    WHILE @@FETCH_STATUS = 0
        BEGIN

			--nejprve pro interakce, ktere trvaji pres cele stavy - tedy se stav uplne vypusti/smaze
			select @InterFrom = FromTime, @InterTo = ToTime  from @InteractionSections where @ActualInterId = Id
			update @StatusSections set Duration = 0, DiscartInteractionId = @ActualInterId where FromTime >= @InterFrom and ToTime <= @InterTo

			--dale pro interakce, ktere maji zacatek i konec v prubehu stavu (v prubehu trvani stavu)
			--druhou cast stavu, ktery pokracuje za interkaci, si vlozim do tabulky znovu a zkracene (od konce interakce do konce stavu)
			insert into @StatusSections
			select concat(left(@ActualInterId,8),right(AgentEventId,28)) as AgentEventId, @InterTo as [FromTime], ToTime as [ToTime], datediff(second,@InterTo,ToTime) as Duration, NULL as DiscartInteractionId, AgentEventId as DefaultAgentEventId from @StatusSections where @InterFrom >= FromTime and @InterTo <= ToTime
			--a zkratim prvni cast stavu o trvani interakce (jeji zacatek)
			update @StatusSections set ToTime = @InterFrom, Duration = datediff(second,FromTime,@InterFrom) where @InterFrom >= FromTime and @InterTo <= ToTime

			--dale pro interakce, ktere maji zacatek v prubehu stavu a konec mimo stav (po skonceni stavu)
			update @StatusSections set ToTime = @InterFrom, Duration = datediff(second,FromTime,@InterFrom) where @InterFrom >= FromTime and @InterFrom <= ToTime and @InterTo > ToTime
			
			--dale pro interakce, ktere maji zacatek pred stavem a konec v prubehu stavu (v prubehu trvani stavu)
			update @StatusSections set FromTime = @InterTo, Duration = datediff(second,@InterTo,ToTime) where @InterFrom < FromTime and @InterTo >= FromTime and @InterTo <= ToTime

		   FETCH NEXT FROM @Cursor INTO @ActualInterId; 
	     END

--spocitam vyslednou cistou dobu ve stavu
select @ResultDuration = sum(Duration) from @StatusSections where DiscartInteractionId is null

return @ResultDuration

END
GO

