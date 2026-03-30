-- Zálohuje èásti tabulek a potom je pøípadnì maže 
USE iCC
DECLARE @from AS datetime=convert(datetime, '2018.01.01')
DECLARE @to AS datetime=convert(datetime, '2018.09.26 12:30')
DECLARE @cfrom AS NVARCHAR(100)='convert(datetime, '''+CONVERT ( nvarchar(10), @from , 102 )+''')'
DECLARE @cto AS NVARCHAR(100)='convert(datetime, '''+CONVERT ( nvarchar(19), @To , 120 )+''')'
DECLARE @Condition AS NVARCHAR(4000)=''
DECLARE @CommonDel AS bit=1
DECLARE @ProjectId AS VARCHAR(36)='B2A76908-1A64-4A14-BA31-F9AE94DA00DE' -- YVES Rocher CZ
SET @ProjectId = 'CDD8A2D2-CE37-41D4-B2F0-7413133B551F' -- YVES Rocher SK
DECLARE @OutboundCallId AS VARCHAR(36)='680d9625-ed4a-e911-841f-000c29ebd3f9'
DECLARE @IVRScriptId AS VARCHAR(36)='fe1c2270-c161-45d9-8fe4-3ad0f9f41941'
DECLARE @ListId AS NVARCHAR(4000)='''cb34c524-56a3-eb11-b7fb-005056a0a12b'',''864b9957-5aa3-eb11-b7fb-005056a0a12b'',
''5ded9398-9bb4-eb11-b7fc-005056a0a12b'',''a68c4b0e-50ae-eb11-b7fb-005056a0a12b'',
''b27363dd-0ca8-eb11-b7fb-005056a0a12b'',''6519505f-bd66-eb11-b7fa-005056a0a12b'',
''7b81450c-be66-eb11-b7fa-005056a0a12b'',''96146baf-d7a1-eb11-b7fb-005056a0a12b'',
''91ea2bbf-179c-eb11-b7fb-005056a0a12b'',''cd3f9094-a29b-eb11-b7fb-005056a0a12b'',
''1fe3b678-aa85-eb11-b7fb-005056a0a12b'',''f2c6cfc3-3e65-eb11-b7fa-005056a0a12b'',
''0dc5506d-6256-eb11-b7fa-005056a0a12b'',''0bb7501b-9338-eb11-a826-005056a09234'',
''5c383d07-8f38-eb11-a826-005056a09234'',''7eeadace-46f3-ea11-a826-005056a09234''
'
-- do 26.9.2018 14:30

 --SELECT @cto
DECLARE @MyTable AS NVARCHAR(40)='Message' --'ScenarioResultValue'--'Chat'-- 'Attachment' --'ChangeRequest' --'IVRStep' --'IVRScript' --'Holiday' --'OutboundCall' --'Issue'--'InboundCall'--'WaitPostcondition' --'Issue' --'OutboundCall' -- --'DataQuery'----  
DECLARE @Command AS NVARCHAR(300)

/* ============================== Øídící èást ======================= */
-- POZOR MÁM VYPNUTOU TRANSAKCI
DECLARE @ShowResults AS bit = 0-- Nejprve ukaž data, na nichž bude operace provedena
DECLARE @PerformBackup AS bit = 0 -- Proveï zálohu modifikovaných dat
DECLARE @PerformDelete AS bit =1 -- Proveï zrušení/modifikaci dat
/* ============================== Øídící èást ======================= */
--DECLARE @Condition AS NVARCHAR(300)=' WHERE SubjectField LIKE '+'''Test Atlantis%'''+'AND TimeUtC> '+@cfrom+' AND TimeUtC< '+@cto

--SELECT @Condition
--RETURN
--AND TimeUtc BETWEEN @from AND @to - toto je pomalé
--SELECT 'select * into Icc_Backup.dbo.'+@MyTable+' from .dbo.'+@MyTable+@Condition
/*
*/
IF  NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'Icc_Backup')
    BEGIN
        CREATE DATABASE [Icc_Backup]
    END

IF OBJECT_ID(N'tempdb..##TEMP', N'U') IS NOT NULL 
  DROP TABLE ##TEMP

IF @MyTable='Chat'
  BEGIN
   SET @Condition =' WHERE BodyText IS NULL'
   EXEC('select ChatId into ##TEMP from dbo.Chat'+@Condition)
  END
IF @MyTable='Message'
  BEGIN
   SET @Condition =' WHERE 
        MessageType=''Task''
     AND MessagePhase  IN (''New'',''Receiving'')
	 AND RemoteAddress=''dso02.sap@cezdistribuce.cz''
     AND Direction=''I'''

   --SET @Condition =' WHERE MessageId=''A04DDFA1-14C7-E811-90F1-005056925807'''
   --SET @Condition =' WHERE ProjectId='''+@ProjectId+''' AND ReceivedSentTime <= '+@cTO
   EXEC('select MessageId into ##TEMP from dbo.Message'+@Condition)
  END
IF @MyTable='Attachment'
  BEGIN
   SET @Condition =' WHERE MessageId IN ('+@ListId+') AND 
   (DisplayName LIKE ''%Manažeøi+CC_Certifikáty_úvìr.xlsx'' OR DisplayName LIKE ''%KS_úvìr manažeøi.xlsx'' OR DisplayName LIKE ''%KS_úvìr+poj.xlsx'')
   ' -- '''
   --SET @Condition =' WHERE MessageId=''A04DDFA1-14C7-E811-90F1-005056925807'''
   --SET @Condition =' WHERE ProjectId='''+@ProjectId+''' AND ReceivedSentTime <= '+@cTO
   EXEC('select AttachmentId into ##TEMP from dbo.Attachment'+@Condition)
  END

IF @MyTable='Issue'
  BEGIN
   SET @Condition =' WHERE ProjectId = '''+@ProjectId+''' AND NewTime<'+@cto
   EXEC('select IssueId into ##TEMP from .dbo.Issue'+@Condition)
  END


IF @MyTable='InboundCall'
  BEGIN
   SET @Condition =' WHERE ProjectId = '''+@ProjectId+''' AND Timeutc<'+@cto
   EXEC('select InboundCallId into ##TEMP from .dbo.InboundCall'+@Condition)
  END

IF @MyTable='OutboundCall'
  BEGIN
   SET @Condition =' WHERE ProjectId = '''+@ProjectId+''' AND Timeutc<'+@cto
   SET @Condition =' WHERE OutboundCallId = '''+@OutboundCallId+''''
   EXEC('select OutboundCallId into ##TEMP from .dbo.OutboundCall'+@Condition)
  END

IF @MyTable='IVRScript' 
  BEGIN
   SET @Condition =' WHERE IvrScriptId = '''+@IVRScriptId+'''' 
   --SET @Condition =' WHERE OutboundCallId = '''+@OutboundCallId+''''
   EXEC('select IvrScriptId into ##TEMP from .dbo.IVRScript'+@Condition)
  END

IF @MyTable='IVRStep'
  BEGIN
   SET @Condition =' WHERE IvrScriptId = '''+@IVRScriptId+'''' 
   --SET @Condition =' WHERE OutboundCallId = '''+@OutboundCallId+''''
   EXEC('select IvrScriptId into ##TEMP from .dbo.IVRStep'+@Condition)
  END
IF @MyTable='ScenarioResultValue'
  BEGIN
   --SET @Condition =' WHERE IvrScriptId = '''+@IVRScriptId+'''' 
   SET @Condition =' WHERE TargetColumn LIKE ''%Emerg_2%'''
   EXEC('select ScenarioResultValueId into ##TEMP from .dbo.ScenarioResultValue'+@Condition  )
  END

IF @ShowResults=1
  BEGIN
   EXEC('select * FROM ##TEMP')
  END


IF @PerformBackup=1
 BEGIN
	EXEC('select * into Icc_Backup.dbo.'+@MyTable+' from .dbo.'+@MyTable+@Condition)

	 IF @MyTable='Chat'
	  BEGIN
		select * into Icc_Backup.dbo.ChatEvent from .dbo.ChatEvent WHERE ChatId IN (SELECT * FROM ##TEMP)
	  END
	-- Pro maily:
	IF @MyTable='Message'
	  BEGIN
		EXEC('select * into Icc_Backup.dbo.Attachment from .dbo.Attachment WHERE MessageId IN (SELECT MessageId from .dbo.Message'+@Condition+')')
		EXEC('select * into Icc_Backup.dbo.MessageEvent from .dbo.MessageEvent WHERE MessageId IN (SELECT MessageId from .dbo.Message'+@Condition+')')
		EXEC('select * into Icc_Backup.dbo.Queue from .dbo.Queue WHERE CommId IN (SELECT MessageId from .dbo.Message'+@Condition+')')
	  END
	IF @MyTable='Attachment'
	  BEGIN
		EXEC('select * into Icc_Backup.dbo.Attachment from .dbo.Attachment WHERE AttachmentId IN (SELECT AttachmentId from .dbo.Message'+@Condition+')')
	  END

	IF @MyTable='Issue'
	  BEGIN
	  	select * into Icc_Backup.dbo.IssueEvent from .dbo.IssueEvent WHERE IssueId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.ScenarioResult from .dbo.ScenarioResult WHERE IssueId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.ScenarioResultValue from .dbo.ScenarioResultValue WHERE scenarioresultid IN (SELECT scenarioresultid from .dbo.ScenarioResult
		WHERE IssueId IN (SELECT * FROM ##TEMP))
	    IF OBJECT_ID (N'.dbo.IssueExtra', N'U') IS NOT NULL
		   select * into Icc_Backup.dbo.IssueExtra from .dbo.IssueExtra WHERE IssueId IN (SELECT * FROM ##TEMP)           
	 	select * into Icc_Backup.dbo.InboundCall from .dbo.InboundCall WHERE IssueId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.OutboundCall from .dbo.OutboundCall WHERE IssueId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.Message from .dbo.Message WHERE IssueId IN (SELECT * FROM ##TEMP)
	  END

	IF @MyTable='InboundCall'
	  BEGIN
		select * into Icc_Backup.dbo.CallEvent from .dbo.CallEvent WHERE InboundCallId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.ScenarioResult from .dbo.ScenarioResult WHERE InboundCallId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.ScenarioResultValue from .dbo.ScenarioResultValue WHERE scenarioresultid IN (SELECT scenarioresultid from .dbo.ScenarioResult
		WHERE InboundCallId IN (SELECT * FROM ##TEMP))
		select * into Icc_Backup.dbo.Issue from .dbo.Issue WHERE FormDataid IN (SELECT scenarioresultid from .dbo.ScenarioResult
		WHERE InboundCallId IN (SELECT * FROM ##TEMP))

	  END
	 IF @MyTable='OutboundCall'
	  BEGIN
		select * into Icc_Backup.dbo.CallEvent from .dbo.CallEvent WHERE OutboundCallId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.ScenarioResult from .dbo.ScenarioResult WHERE OutboundCallId IN (SELECT * FROM ##TEMP)
		select * into Icc_Backup.dbo.ScenarioResultValue from .dbo.ScenarioResultValue WHERE scenarioresultid IN (SELECT scenarioresultid from .dbo.ScenarioResult
		WHERE OutboundCallId IN (SELECT * FROM ##TEMP))
		select * into Icc_Backup.dbo.Issue from .dbo.Issue WHERE FormDataid IN (SELECT scenarioresultid from .dbo.ScenarioResult
		WHERE OutboundCallId IN (SELECT * FROM ##TEMP))
		-- InboundCall nebudu již kvùli ChainingId zálohovat
	  END
	IF @MyTable='ScenarioResult'
	  BEGIN
	    select * into Icc_Backup.dbo.ScenarioResultValueConf from .dbo.ScenarioResultValue WHERE ScenarioResultId IN (SELECT * FROM ##TEMP)
	  END

 END
 --SELECT * FROM #TEMP
IF @PerformDelete=1
 BEGIN
	BEGIN TRANSACTION
	IF @MyTable='Chat'
	  BEGIN
	    PRINT ('Maži ChatEvent:')
		DELETE FROM .dbo.ChatEvent WHERE ChatId IN (SELECT * FROM ##TEMP)
	  END

	IF @MyTable='Message'
	  BEGIN
	    PRINT ('Maži Attachment:')
		DELETE FROM .dbo.Attachment WHERE MessageId IN (SELECT * FROM ##TEMP)
	    PRINT ('Maži MessageEvent:')
		DELETE FROM .dbo.MessageEvent WHERE MessageId IN (SELECT * FROM ##TEMP)
            PRINT ('Maži Queue:')
		DELETE  FROM [iCC].[dbo].[Queue]  WHERE CommId IN (SELECT * FROM ##TEMP)

		update .dbo.ScenarioResult set MessageId = NULL WHERE MessageId IN (SELECT * FROM ##TEMP)
		update .dbo.Message set RelatedMessageId = NULL where RelatedMessageId in (SELECT * FROM ##TEMP)
	  END

	IF @MyTable='Issue'
	  BEGIN  	
		DELETE from .dbo.ScenarioResultValue WHERE scenarioresultid IN (SELECT scenarioresultid from .dbo.ScenarioResult
		WHERE IssueId IN (SELECT * FROM ##TEMP))
                UPDATE iCC.dbo.Issue SET FormdataId=NULL WHERE IssueId IN (SELECT * FROM ##TEMP)
		DELETE from .dbo.ScenarioResult WHERE IssueId IN (SELECT * FROM ##TEMP)
	  	DELETE from .dbo.IssueEvent WHERE IssueId IN (SELECT * FROM ##TEMP)
	    update .dbo.Issue set formdataid = null WHERE FormDataid IN (SELECT scenarioresultid from .dbo.ScenarioResult
		WHERE IssueId IN (SELECT * FROM ##TEMP))
	    IF OBJECT_ID (N'.dbo.IssueExtra', N'U') IS NOT NULL
		   DELETE from .dbo.IssueExtra WHERE IssueId IN (SELECT * FROM ##TEMP)           
	 	update .dbo.InboundCall set Issueid = null where IssueId in (SELECT * FROM ##TEMP)
		update .dbo.OutboundCall set Issueid = null where IssueId in (SELECT * FROM ##TEMP)
		update .dbo.Message set Issueid = null where IssueId in (SELECT * FROM ##TEMP)
	  END

	IF @MyTable='InboundCall'
	  BEGIN
		update .dbo.Issue set formdataid = null WHERE FormDataid IN (SELECT scenarioresultid from .dbo.ScenarioResult
		WHERE InboundCallId IN (SELECT * FROM ##TEMP))
		DELETE FROM .dbo.ScenarioResultValue WHERE scenarioresultid IN (SELECT scenarioresultid from .dbo.ScenarioResult
		WHERE InboundCallId IN (SELECT * FROM ##TEMP))
		update .dbo.CallEvent set InboundCallId = null where InboundCallId IN (SELECT * FROM ##TEMP)
		DELETE FROM .dbo.ScenarioResult WHERE InboundCallId IN (SELECT * FROM ##TEMP)
		update .dbo.InboundCall set ChainingId = null where ChainingId IN (SELECT * FROM ##TEMP)
		update .dbo.CallRecord set InboundCallId = null where InboundCallId IN (SELECT * FROM ##TEMP)
	  END
	IF @MyTable='OutboundCall'
	  BEGIN
		update .dbo.Issue set formdataid = null WHERE FormDataid IN (SELECT scenarioresultid from .dbo.ScenarioResult
		WHERE OutboundCallId IN (SELECT * FROM ##TEMP))
		DELETE FROM .dbo.WorkflowEvent WHERE Workflowinstanceid IN (SELECT Workflowinstanceid FROM WorkflowInstance
		WHERE scenarioresultid IN (SELECT scenarioresultid from .dbo.ScenarioResult
		WHERE OutboundCallId IN (SELECT * FROM ##TEMP)))

		DELETE FROM .dbo.WorkflowInstance WHERE scenarioresultid IN (SELECT scenarioresultid from .dbo.ScenarioResult
		WHERE OutboundCallId IN (SELECT * FROM ##TEMP))

		DELETE FROM .dbo.ScenarioResultValue WHERE scenarioresultid IN (SELECT scenarioresultid from .dbo.ScenarioResult
		WHERE OutboundCallId IN (SELECT * FROM ##TEMP))
		update .dbo.CallEvent set OutboundCallId = null where OutboundCallId IN (SELECT * FROM ##TEMP)
		DELETE FROM .dbo.ScenarioResult WHERE OutboundCallId IN (SELECT * FROM ##TEMP)
		update .dbo.OutboundCall set ChainingId = null where ChainingId IN (SELECT * FROM ##TEMP)
		update .dbo.CallRecord set OutboundCallId = null where OutboundCallId IN (SELECT * FROM ##TEMP)
		DELETE FROM .dbo.OutboundCall WHERE OutboundCallId IN (SELECT * FROM ##TEMP) -- Pouze vybraných TOP 1000

	  END
    IF @CommonDel=1
	  BEGIN
		PRINT ('Maži záznamy urèené tabulky:'+@MyTable)
		EXEC('DELETE FROM .dbo.'+@MyTable+@Condition)
	  END

	COMMIT TRANSACTION
	--ROLLBACK TRANSACTION
 END
IF OBJECT_ID (N'##TEMP', N'U') IS NOT NULL 
 DROP TABLE ##TEMP
/*
*/




