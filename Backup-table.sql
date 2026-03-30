-- Zálohuje èásti tabulek a potom je pøípadnì maže 
-- Pøedìlat podmínky na (SELECT * FROM ##TEMP)
DECLARE @from AS datetime=convert(datetime, '2018.01.01')
DECLARE @to AS datetime=convert(datetime, '2021.01.01 0:30')
DECLARE @cfrom AS NVARCHAR(100)='convert(datetime, '''+CONVERT ( nvarchar(10), @from , 102 )+''')'
DECLARE @cto AS NVARCHAR(100)='convert(datetime, '''+CONVERT ( nvarchar(19), @To , 120 )+''')'
DECLARE @Condition AS NVARCHAR(300)=''
DECLARE @CommonDel AS bit=1
DECLARE @ProjectId AS VARCHAR(36)='B2A76908-1A64-4A14-BA31-F9AE94DA00DE' -- YVES Rocher CZ
SET @ProjectId = 'CDD8A2D2-CE37-41D4-B2F0-7413133B551F' -- YVES Rocher SK
DECLARE @OutboundCallId AS VARCHAR(36)='680d9625-ed4a-e911-841f-000c29ebd3f9'
DECLARE @IVRScriptId AS VARCHAR(36)='fe1c2270-c161-45d9-8fe4-3ad0f9f41941'
-- do 26.9.2018 14:30

 --SELECT @cto
DECLARE @MyTable AS NVARCHAR(40)='Message' --'Seating'--'WfmSlot' --'InboundCall'--'OutboundCall' --'Issue'--'DataQueryColumn'-- 'IVRStep' --'IVRScript' --'Holiday' --'WaitPostcondition' --'Issue' --'OutboundCall' --'DataQuery'--  
DECLARE @Command AS NVARCHAR(300)

/* ============================== Øídící èást ======================= */
DECLARE @ShowResults AS bit = 0-- Nejprve ukaž data, na nichž bude operace provedena
DECLARE @PerformBackup AS bit = 0 -- Proveï zálohu modifikovaných dat
DECLARE @PerformDelete AS bit =1 -- Proveï zrušení/modifikaci dat
/* ============================== Øídící èást ======================= */
--DECLARE @Condition AS NVARCHAR(300)=' WHERE SubjectField LIKE '+'''Test Atlantis%'''+'AND TimeUtC> '+@cfrom+' AND TimeUtC< '+@cto

--SELECT @Condition
--RETURN
--AND TimeUtc BETWEEN @from AND @to - toto je pomalé
--SELECT 'select * into Icc_Backup.dbo.'+@MyTable+' from iCC.dbo.'+@MyTable+@Condition
/*
*/
IF  NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'Icc_Backup')
    BEGIN
        CREATE DATABASE [Icc_Backup]
    END

IF OBJECT_ID(N'tempdb..##TEMP', N'U') IS NOT NULL 
  DROP TABLE ##TEMP

IF @MyTable='WfmSlot'
  BEGIN
   SELECT WfmSlotId  into ##TEMP
   FROM [iCC].[dbo].[WfmSlot] WFS
	LEFT JOIN.[dbo].WfmPlan WFP ON  WFP.WfmPlanId=WFS.WfmPlanId
  WHERE 1=1
    AND (WFP.Status LIKE 'Week%' OR WFP.Status LIKE 'Template%')
	AND WFS.Deleted=0
  END


IF @MyTable='Message'
  BEGIN
   --SET @Condition =' WHERE MessageId=''7FE9EA7D-F322-ED11-80F1-A4BF01355AC2'''
   --SET @Condition =' WHERE MessageId=''A04DDFA1-14C7-E811-90F1-005056925807'''
   --SET @Condition =' WHERE ProjectId='''+@ProjectId+''' AND ReceivedSentTime <= '+@cTO
   SET @Condition =' WHERE ReceivedSentTime <= '+@cTO
   EXEC('select MessageId into ##TEMP from Icc.dbo.Message'+@Condition)
  END

IF @MyTable='Seating'
  BEGIN
   SET @Condition =' WHERE WP.Deleted=1'
   EXEC('select SeatingId into ##TEMP from [iCC].[dbo].[Seating] SEA
       LEFT JOIN [iCC].[dbo].Workplace WP ON WP.WorkplaceId=SEA.WorkplaceId'+@Condition)
  END
  
IF @MyTable='Issue'
  BEGIN
   SET @Condition =' WHERE ProjectId = '''+@ProjectId+''' AND NewTime<'+@cto
   SET @Condition =' WHERE IssueId = ''929d562a-ee22-ed11-80f1-a4bf01355ac2'''
   EXEC('select IssueId into ##TEMP from Icc.dbo.Issue'+@Condition)
  END


IF @MyTable='InboundCall'
  BEGIN
   SET @Condition =' WHERE InboundCallId IN (''0e9e0749-e0c0-ee11-80ff-a4bf01355ac2'',''ab8eaefc-312e-ee11-80fb-a4bf01355ac2'')'
   --SET @Condition =' WHERE ProjectId = '''+@ProjectId+''' AND Timeutc<'+@cto
   EXEC('select InboundCallId into ##TEMP from Icc.dbo.InboundCall'+@Condition)
  END

IF @MyTable='OutboundCall'
  BEGIN
   SET @Condition =' WHERE ProjectId = '''+@ProjectId+''' AND Timeutc<'+@cto
   SET @Condition =' WHERE OutboundCallId = '''+@OutboundCallId+''''
   SET @Condition =' WHERE OutboundCallId IN (''8357d991-ddc0-ee11-80ff-a4bf01355ac2'',''0e638d3d-e9c0-ee11-80ff-a4bf01355ac2'')'
   EXEC('select OutboundCallId into ##TEMP from Icc.dbo.OutboundCall'+@Condition)
  END

IF @MyTable='IVRScript' 
  BEGIN
   SET @Condition =' WHERE IvrScriptId = '''+@IVRScriptId+'''' 
   --SET @Condition =' WHERE OutboundCallId = '''+@OutboundCallId+''''
   EXEC('select IvrScriptId into ##TEMP from Icc.dbo.IVRScript'+@Condition)
  END

IF @MyTable='IVRStep'
  BEGIN
   SET @Condition =' WHERE IvrScriptId = '''+@IVRScriptId+'''' 
   --SET @Condition =' WHERE OutboundCallId = '''+@OutboundCallId+''''
   EXEC('select IvrScriptId into ##TEMP from Icc.dbo.IVRStep'+@Condition)
  END


IF @ShowResults=1
  BEGIN
   EXEC('select * FROM ##TEMP')
  END


IF @PerformBackup=1
 BEGIN
	IF @MyTable NOT IN ('WfmSlot','Seating')
	  EXEC('select * into Icc_Backup.dbo.'+@MyTable+' from .dbo.'+@MyTable+@Condition)

	IF @MyTable='WfmSlot'
	  BEGIN
	   SELECT WFS.*  into Icc_Backup.dbo.WfmSlot
	   FROM [iCC].[dbo].[WfmSlot] WFS
		LEFT JOIN.[dbo].WfmPlan WFP ON  WFP.WfmPlanId=WFS.WfmPlanId
	  WHERE 1=1
		AND (WFP.Status LIKE 'Week%' OR WFP.Status LIKE 'Template%')
		AND WFS.Deleted=0
	  END

	 IF @MyTable='Seating'
	   EXEC('select SEA.* into Icc_Backup.dbo.'+@MyTable+' from [iCC].[dbo].[Seating] SEA
		   LEFT JOIN [iCC].[dbo].Workplace WP ON WP.WorkplaceId=SEA.WorkplaceId'+@Condition)

	-- Pro maily:
	IF @MyTable='Message'
	  BEGIN
		EXEC('select * into Icc_Backup.dbo.Attachment from iCC.dbo.Attachment WHERE MessageId IN (SELECT MessageId from Icc.dbo.Message'+@Condition+')')
		EXEC('select * into Icc_Backup.dbo.MessageEvent from iCC.dbo.MessageEvent WHERE MessageId IN (SELECT MessageId from Icc.dbo.Message'+@Condition+')')
	  END
	IF @MyTable='Issue'
	  BEGIN
	  	select * into Icc_Backup.dbo.IssueEvent from iCC.dbo.IssueEvent WHERE IssueId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.ScenarioResult from iCC.dbo.ScenarioResult WHERE IssueId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.ScenarioResultValue from iCC.dbo.ScenarioResultValue WHERE scenarioresultid IN (SELECT scenarioresultid from Icc.dbo.ScenarioResult
		WHERE IssueId IN (SELECT * FROM ##TEMP))
	    IF OBJECT_ID (N'icc.dbo.IssueExtra', N'U') IS NOT NULL
		   select * into Icc_Backup.dbo.IssueExtra from iCC.dbo.IssueExtra WHERE IssueId IN (SELECT * FROM ##TEMP)           
	 	select * into Icc_Backup.dbo.InboundCall from iCC.dbo.InboundCall WHERE IssueId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.OutboundCall from iCC.dbo.OutboundCall WHERE IssueId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.Message from iCC.dbo.Message WHERE IssueId IN (SELECT * FROM ##TEMP)
	  END

	IF @MyTable='InboundCall'
	  BEGIN
		select * into Icc_Backup.dbo.CallEvent from iCC.dbo.CallEvent WHERE InboundCallId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.ScenarioResult from iCC.dbo.ScenarioResult WHERE InboundCallId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.ScenarioResultValue from iCC.dbo.ScenarioResultValue WHERE scenarioresultid IN (SELECT scenarioresultid from Icc.dbo.ScenarioResult
		WHERE InboundCallId IN (SELECT * FROM ##TEMP))
		select * into Icc_Backup.dbo.Issue from iCC.dbo.Issue WHERE FormDataid IN (SELECT scenarioresultid from Icc.dbo.ScenarioResult
		WHERE InboundCallId IN (SELECT * FROM ##TEMP))

	  END
	 IF @MyTable='OutboundCall'
	  BEGIN
		select * into Icc_Backup.dbo.CallEvent from iCC.dbo.CallEvent WHERE OutboundCallId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.ScenarioResult from iCC.dbo.ScenarioResult WHERE OutboundCallId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.ScenarioResultValue from iCC.dbo.ScenarioResultValue WHERE scenarioresultid IN (SELECT scenarioresultid from Icc.dbo.ScenarioResult
		WHERE OutboundCallId IN (SELECT * FROM ##TEMP))
		select * into Icc_Backup.dbo.Issue from iCC.dbo.Issue WHERE FormDataid IN (SELECT scenarioresultid from Icc.dbo.ScenarioResult
		WHERE OutboundCallId IN (SELECT * FROM ##TEMP))
		-- InboundCall nebudu již kvùli ChainingId zálohovat
	  END

 END
 --SELECT * FROM #TEMP
IF @PerformDelete=1
 BEGIN
	BEGIN TRANSACTION
	IF @MyTable='Message'
	  BEGIN
	    PRINT ('Maži Attachment:')
		DELETE FROM iCC.dbo.Attachment WHERE MessageId IN (SELECT * FROM ##TEMP)
	    PRINT ('Maži MessageEvent:')
		DELETE FROM iCC.dbo.MessageEvent WHERE MessageId IN (SELECT * FROM ##TEMP)
		update iCC.dbo.ScenarioResult set MessageId = NULL WHERE MessageId IN (SELECT * FROM ##TEMP)
		update Icc.dbo.Message set RelatedMessageId = NULL where RelatedMessageId in (SELECT * FROM ##TEMP)

	  END

	IF @MyTable='Issue'
	  BEGIN  	
		DELETE from iCC.dbo.ScenarioResultValue WHERE scenarioresultid IN (SELECT scenarioresultid from Icc.dbo.ScenarioResult
		WHERE IssueId IN (SELECT * FROM ##TEMP))
		UPDATE iCC.dbo.Issue SET FormdataId=NULL WHERE IssueId IN (SELECT * FROM ##TEMP)
		DELETE from iCC.dbo.ScenarioResult WHERE IssueId IN (SELECT * FROM ##TEMP)
	  	DELETE from iCC.dbo.IssueEvent WHERE IssueId IN (SELECT * FROM ##TEMP)
	    update iCC.dbo.Issue set formdataid = null WHERE FormDataid IN (SELECT scenarioresultid from Icc.dbo.ScenarioResult
		WHERE IssueId IN (SELECT * FROM ##TEMP))
	    IF OBJECT_ID (N'icc.dbo.IssueExtra', N'U') IS NOT NULL
		   DELETE from iCC.dbo.IssueExtra WHERE IssueId IN (SELECT * FROM ##TEMP)           
	 	update iCC.dbo.InboundCall set Issueid = null where IssueId in (SELECT * FROM ##TEMP)
		update iCC.dbo.OutboundCall set Issueid = null where IssueId in (SELECT * FROM ##TEMP)
		update iCC.dbo.Message set Issueid = null where IssueId in (SELECT * FROM ##TEMP)
	  END

	IF @MyTable='InboundCall'
	  BEGIN
		update iCC.dbo.Issue set formdataid = null WHERE FormDataid IN (SELECT scenarioresultid from Icc.dbo.ScenarioResult
		WHERE InboundCallId IN (SELECT * FROM ##TEMP))
		DELETE FROM iCC.dbo.ScenarioResultValue WHERE scenarioresultid IN (SELECT scenarioresultid from Icc.dbo.ScenarioResult
		WHERE InboundCallId IN (SELECT * FROM ##TEMP))
		update icc.dbo.CallEvent set InboundCallId = null where InboundCallId IN (SELECT * FROM ##TEMP)
		DELETE FROM iCC.dbo.ScenarioResult WHERE InboundCallId IN (SELECT * FROM ##TEMP)
		update icc.dbo.InboundCall set ChainingId = null where ChainingId IN (SELECT * FROM ##TEMP)
		update icc.dbo.CallRecord set InboundCallId = null where InboundCallId IN (SELECT * FROM ##TEMP)
	  END
	IF @MyTable='OutboundCall'
	  BEGIN
		update iCC.dbo.Issue set formdataid = null WHERE FormDataid IN (SELECT scenarioresultid from Icc.dbo.ScenarioResult
		WHERE OutboundCallId IN (SELECT * FROM ##TEMP))
		DELETE FROM iCC.dbo.ScenarioResultValue WHERE scenarioresultid IN (SELECT scenarioresultid from Icc.dbo.ScenarioResult
		WHERE OutboundCallId IN (SELECT * FROM ##TEMP))
		update icc.dbo.CallEvent set OutboundCallId = null where OutboundCallId IN (SELECT * FROM ##TEMP)
		DELETE FROM iCC.dbo.ScenarioResult WHERE OutboundCallId IN (SELECT * FROM ##TEMP)
		update icc.dbo.OutboundCall set ChainingId = null where ChainingId IN (SELECT * FROM ##TEMP)
		update icc.dbo.CallRecord set OutboundCallId = null where OutboundCallId IN (SELECT * FROM ##TEMP)
		DELETE FROM iCC.dbo.OutboundCall WHERE OutboundCallId IN (SELECT * FROM ##TEMP) -- Pouze vybraných TOP 1000

	  END
    IF @CommonDel=1
	  BEGIN
		PRINT ('Maži záznamy urèené tabulky:'+@MyTable)
		IF @MyTable='Seating'
		   EXEC('DELETE FROM iCC.dbo.'+@MyTable+' WHERE SeatingId IN (SELECT * FROM ##TEMP)')
		 ELSE
			EXEC('DELETE FROM iCC.dbo.'+@MyTable+@Condition)
	  END

	COMMIT TRANSACTION
	--ROLLBACK TRANSACTION
 END
IF OBJECT_ID (N'##TEMP', N'U') IS NOT NULL 
 DROP TABLE ##TEMP
/*
*/




