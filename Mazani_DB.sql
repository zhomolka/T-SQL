USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[MazaniDB]    Script Date: 22.6.2016 8:25:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Jiří Stejskal>
-- Create date: <12.8.2015>
-- Description:	<Mazání dat podle data>
-- =============================================
CREATE PROCEDURE [dbo].[MazaniDB]
@Datum datetime
AS
BEGIN
SELECT MessageId INTO #TEMP from Icc.dbo.Message where TimeUTC < @Datum AND MessageType<>'TmpEmail'

BEGIN TRANSACTION
delete from Icc.dbo.Attachment where MessageId IN (SELECT * FROM #TEMP)
delete from Icc.dbo.MessageEvent where MessageId IN (SELECT * FROM #TEMP)
update Icc.dbo.ScenarioResult set MessageId = NULL where MessageId in (SELECT * FROM #TEMP)
update Icc.dbo.Message set RelatedMessageId = NULL where RelatedMessageId in (SELECT * FROM #TEMP)

delete from Icc.dbo.Message where TimeUTC < @Datum AND MessageType<>'TmpEmail'
COMMIT TRANSACTION
DROP TABLE #TEMP
--ROLLBACK TRANSACTION

--declare @Datum date ='2015-05-01'
delete from icc.dbo.CallEvent where TimeLocal < @Datum
-- 'deleted callevent'

delete from icc.dbo.IssueEvent where TimeLocal < @Datum
-- 'deleted issueevent'


delete from icc.dbo.ScenarioResultValue where scenarioresultid in(
select ScenarioResultid from icc.dbo.ScenarioResult where timeutc <@Datum)
-- 'deleted scenarioresultvalue'
update icc.dbo.Issue 
set formdataid = null where TimeUtc<@Datum
-- 'update FormDataId v Issue'

delete from icc.dbo.ScenarioResult where TimeUtc <@Datum
-- 'deleted scenarioresult'
------------------
update icc.dbo.CallEvent  
set InboundCallId = null where InboundCallId in (SELECT InboundCallId FROM icc.dbo.InboundCall where TimeUtc< @Datum)

delete from icc.dbo.InboundCall where TimeUtc< @Datum
-- 'deleted inboundcall'

---------------
SELECT IssueId  INTO #TEMP2 from icc.dbo.Issue where Timeutc <@Datum

update icc.dbo.OutboundCall 
set Issueid = null where IssueId in (SELECT * FROM #TEMP2)
update icc.dbo.IssueEvent  
set Issueid = null where IssueId in (SELECT * FROM #TEMP2)
update icc.dbo.InboundCall  
set Issueid = null where IssueId in (SELECT * FROM #TEMP2)

DROP TABLE #TEMP2
delete from icc.dbo.Issue where (TimeUtc  < @Datum)
-- 'deleted issue'
---------------

update icc.dbo.ScenarioResult  
set OutboundCallId = null where OutboundCallId in (SELECT OutboundCallId FROM icc.dbo.OutboundCall where TimeUtc <@Datum)
update icc.dbo.CallEvent 
set OutboundCallId = null where OutboundCallId in (SELECT OutboundCallId FROM icc.dbo.OutboundCall where TimeUtc <@Datum)

delete from icc.dbo.OutboundCall where TimeUtc <@Datum 
-- 'deleted outboundcall'

END

GO

