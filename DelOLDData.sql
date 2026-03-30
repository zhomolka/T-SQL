USE [FS_CUSTOM]
GO
/****** Object:  StoredProcedure [dbo].[DelOLDData]    Script Date: 6. 9. 2017 17:17:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <16.8.2017>
-- Description:	<Mazání dat podle data>
-- =============================================
ALTER PROCEDURE [dbo].[DelOLDData]
AS
BEGIN
DECLARE @Datum AS date=CONVERT(date,CONVERT(NVARCHAR(20),YEAR(GETDATE()))) -- 1.1. tohoto roku
--SET @Datum = convert(datetime, '2015.09.01') -- Pro testování
IF OBJECT_ID (N'#TEMP', N'U') IS NOT NULL DROP TABLE #TEMP
IF OBJECT_ID (N'#TEMP2', N'U') IS NOT NULL DROP TABLE #TEMP2
IF OBJECT_ID (N'#TEMP3', N'U') IS NOT NULL DROP TABLE #TEMP3
IF OBJECT_ID (N'#TEMP4', N'U') IS NOT NULL DROP TABLE #TEMP4

-- Nejsem si jist, zda je toto nutné (vazba do ScenarioResult):
  update icc.dbo.Issue set formdataid = null where TimeUtc<@Datum



-- 'Message' ----------------------------------------- 1
select MessageId into #TEMP from Icc.dbo.Message WHERE TimeUTC < @Datum AND MessageType<>'TmpEmail'

BEGIN TRANSACTION
delete from Icc.dbo.Attachment where MessageId IN (SELECT * FROM #TEMP) -- 2
delete from Icc.dbo.MessageEvent where MessageId IN (SELECT * FROM #TEMP) -- 3
delete from icc.dbo.ScenarioResultValue where scenarioresultid in(
  select ScenarioResultid from icc.dbo.ScenarioResult where MessageId IN (SELECT * FROM #TEMP)) -- 4
delete from icc.dbo.ScenarioResult where MessageId IN (SELECT * FROM #TEMP)   -- 5

update Icc.dbo.Message set RelatedMessageId = NULL where RelatedMessageId in (SELECT * FROM #TEMP) -- 6
delete from Icc.dbo.Message where TimeUTC < @Datum AND MessageType<>'TmpEmail'  -- 7
--ROLLBACK TRANSACTION
COMMIT TRANSACTION
DROP TABLE #TEMP
------------------------------------------------------
-- 'InboundCall' -------------------------------------
select InboundCallId into #TEMP2 from Icc.dbo.InboundCall WHERE TimeUTC < @Datum -- 8

BEGIN TRANSACTION
delete from Icc.dbo.CallEvent where InboundCallId IN (SELECT * FROM #TEMP2) -- 9
delete from icc.dbo.ScenarioResultValue where scenarioresultid in(
  select ScenarioResultid from icc.dbo.ScenarioResult where InboundCallId IN (SELECT * FROM #TEMP2)) --10
update  icc.dbo.Issue set FormDataid = NULL where FormDataid in(
  select ScenarioResultid from icc.dbo.ScenarioResult where InboundCallId IN (SELECT * FROM #TEMP2)) --11

delete from icc.dbo.ScenarioResult where InboundCallId IN (SELECT * FROM #TEMP2) -- 12
update Icc.dbo.InboundCall set ChainingId = NULL where ChainingId in (SELECT * FROM #TEMP2) -- 13
delete from icc.dbo.InboundCall where TimeUtc< @Datum
--ROLLBACK TRANSACTION
COMMIT TRANSACTION
DROP TABLE #TEMP2
------------------------------------------------------
-- 'OutboundCall' ------------------------------------
select OutboundCallId into #TEMP4 from Icc.dbo.OutboundCall WHERE TimeUTC < @Datum 

BEGIN TRANSACTION
delete from Icc.dbo.CallEvent where OutboundCallId IN (SELECT * FROM #TEMP4)
delete from icc.dbo.ScenarioResultValue where scenarioresultid in(
  select ScenarioResultid from icc.dbo.ScenarioResult where OutboundCallId IN (SELECT * FROM #TEMP4))
delete from icc.dbo.ScenarioResult where OutboundCallId IN (SELECT * FROM #TEMP4)
update Icc.dbo.OutboundCall set ChainingId = NULL where ChainingId in (SELECT * FROM #TEMP4)
delete from icc.dbo.OutboundCall where TimeUtc< @Datum
--ROLLBACK TRANSACTION
COMMIT TRANSACTION
DROP TABLE #TEMP4
------------------------------------------------------
-- Nejsem si úplně jistý, zda jsou již všechny starší výsledky zrušeny pomocí vazeb na Message, In/Out/boundCall


-- 'Issue' ------------------------------------
BEGIN TRANSACTION
SELECT IssueId  INTO #TEMP3 from icc.dbo.Issue where Timeutc <@Datum
delete from icc.dbo.ScenarioResultValue where ScenarioResultId in (select ScenarioResultId from icc.dbo.ScenarioResult where IssueId in (SELECT * FROM #TEMP3))
delete from icc.dbo.ScenarioResult where IssueId in (SELECT * FROM #TEMP3)
DELETE FROM icc.dbo.IssueEvent  where IssueId in (SELECT * FROM #TEMP3)
IF OBJECT_ID (N'icc.dbo.IssueExtra', N'U') IS NOT NULL
  DELETE FROM icc.dbo.IssueExtra  where IssueId in (SELECT * FROM #TEMP3)
update icc.dbo.OutboundCall 
set Issueid = null where IssueId in (SELECT * FROM #TEMP3)
update icc.dbo.InboundCall  
set Issueid = null where IssueId in (SELECT * FROM #TEMP3)
update icc.dbo.Message  
set Issueid = null where IssueId in (SELECT * FROM #TEMP3)

delete from icc.dbo.Issue where (TimeUtc  < @Datum)
--ROLLBACK TRANSACTION
COMMIT TRANSACTION
DROP TABLE #TEMP3
-- 'AgentEvent' ------------------------------------
delete from icc.dbo.AgentEvent where TimeUtc< @Datum

END


