DECLARE @from AS datetime=convert(datetime, '2024.01.01')
DECLARE @to AS date=convert(datetime, '2023.01.01')
DECLARE @cfrom AS NVARCHAR(100)='convert(datetime, '''+CONVERT ( nvarchar(10), @from , 102 )+''')'
DECLARE @cto AS NVARCHAR(100)='convert(datetime, '''+CONVERT ( nvarchar(19), @To , 120 )+''')'
DECLARE @Condition AS NVARCHAR(300)=''
DECLARE @CommonDel AS bit=1
DECLARE @ProjectId AS VARCHAR(36)='B2A76908-1A64-4A14-BA31-F9AE94DA00DE' -- YVES Rocher CZ
DECLARE @OutboundCallId AS VARCHAR(36)='680d9625-ed4a-e911-841f-000c29ebd3f9'
DECLARE @Hour AS Integer=(SELECT DATEPART(HOUR,GETDATE()))

DECLARE @WTCount AS Integer=5--80--120000--2:48min--200000 --5:33-300000 --je asi moc -- count of records in one cycle
DECLARE @RecCount AS Integer
DECLARE @Count AS Integer=1800 -- Count of cycles
DECLARE @LastTime AS bit=1

IF @LastTime=1
 BEGIN
    SET @from=DATEADD(DAY,-2,GETDATE())
    SET @to=GETDATE()
  END

  WHILE @Count>0 --AND (@Hour<7 OR @Hour>16)
    BEGIN
	SET @RecCount=IIF(@Hour<7 OR @Hour>17,10000,@WTCount)
   PRINT ('Maži tabulku IDs:')
DELETE FROM FS_Custom.dbo.IDs

    PRINT ('Vkládám nová ID:')
 INSERT INTO FS_Custom.dbo.IDs (Id)
 select top (@RecCount) MessageId from Icc.dbo.Message 
 WHERE 1=1
  AND TimeUtc<@from 
  AND MessageType<>'TmpEmail' 
  AND MessageResult<>'Active'
  AND ( SpamLevel>=1
   OR (Direction='O' AND AgentId IS NULL AND SubjectField LIKE '%automatická odpovìï')
   OR (Direction='I' AND SubjectField LIKE 'Nedoruèitelná:%')
   OR (MessagePhase = 'Canceled' AND TimeUTC<@To)
   )
IF NOT EXISTS(SELECT TOP 1 1 FROM FS_Custom.dbo.IDs)
  BEGIN
    SELECT 'Není co mazat - konèím' AS Informace
	BREAK
  END
IF 1=2 -- Jen informuj
  BEGIN
	 SELECT * FROM FS_Custom.dbo.IDs
	 RETURN
  END
/* */
    PRINT ('Maži Attachment:')
	--DELETE FROM iCC.dbo.Attachment WHERE MessageId IN (SELECT * FROM ##TEMP)
	DELETE TOP (@RecCount*10) ATC FROM iCC.dbo.Attachment ATC
     INNER JOIN FS_Custom.dbo.IDs ID ON ATC.MessageId=ID.Id


	    PRINT ('Maži MessageEvent:')
	DELETE TOP (@RecCount*20) ME FROM iCC.dbo.MessageEvent ME
     INNER JOIN FS_Custom.dbo.IDs ID ON ME.MessageId=ID.Id

	    PRINT ('Maži MessageId FROM ScenarioResult:')
	update TOP (@RecCount*3) SCR 
	set MessageId = NULL 
	FROM iCC.dbo.ScenarioResult SCR
     INNER JOIN FS_Custom.dbo.IDs ID ON SCR.MessageId=ID.Id

	   PRINT ('Maži RelatedMessageId FROM Message:')
	update TOP (@RecCount*3) ME 
	set RelatedMessageId = NULL 
	FROM iCC.dbo.Message ME
     INNER JOIN FS_Custom.dbo.IDs ID ON ME.RelatedMessageId=ID.Id

	    PRINT ('Maži Message:')
	DELETE TOP (@RecCount) M FROM iCC.dbo.Message M
     INNER JOIN FS_Custom.dbo.IDs ID ON M.MessageId=ID.Id
	 SET @Count=@Count-1
	 PRINT ('============================================================')
	 WAITFOR DELAY '00:00:10'
	 SET @Hour =(SELECT DATEPART(HOUR,GETDATE()))
   END


/**/