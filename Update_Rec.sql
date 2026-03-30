USE iCC_D
GO
SET DATEFORMAT ymd
DECLARE @from AS datetime = convert(datetime, '2023-12-13 11:46:00.250')
DECLARE @to AS datetime = convert(datetime, '2020.03.03 11:00')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @NullId AS UniqueIdentifier= '00000000-0000-0000-0000-000000000000'
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1
DECLARE @Number AS integer
DECLARE @GroupInterval AS integer=1440
DECLARE @RoundInterval AS integer=@GroupInterval
DECLARE @Version  AS integer=1
DECLARE @LastTime AS bit=0

IF @LastTime=1
 BEGIN
    SET @from=DATEADD(Day,-10,GETDATE())
    SET @to=GETDATE()
  END

DECLARE @Id AS UNIQUEIDENTIFIER='2bd46080-ce8d-4c10-8b4d-3772417f57d8'
 BEGIN TRANSACTION

 
   UPDATE WP
SET Deleted = 1
FROM  .[dbo].Workplace WP
    LEFT JOIN FS_Custom.dbo.WPStatistics WPS ON WP.WorkplaceId=WPS.WorkplaceId

 WHERE Action='smazat'


-- MessagePhase='Scheduled' AND MessageResult='Closed'


COMMIT TRANSACTION

--ROLLBACK TRANSACTION

/*

   UPDATE VR
SET Remotename = 'EXP '+ISNULL(Remotename,'')
FROM [SRec].[dbo].[VoiceRecord] VR
    LEFT JOIN .[dbo].[CallRecord] CR ON CR.RecordFileId=VR.VoicerecordId
    LEFT JOIN .[dbo].[INboundCall] IC ON CR.InboundCallId=IC.InboundCallId
	LEFT JOIN .[dbo].[Issue] ISU  ON IC.IssueId=ISU.IssueId
    LEFT JOIN .[dbo].[OutboundCall] OC ON CR.OutboundCallId=OC.OutboundCallId
	LEFT JOIN .[dbo].[Issue] ISUO  ON OC.IssueId=ISUO.IssueId
   WHERE 1=1
     AND ISNULL(Remotename,'') NOT LIKE 'EXP%'
     AND (IC.InboundCallId IS NOT NULL OR OC.OutboundCallId IS NOT NULL)
	 AND (ISU.TopicId='B7197C2D-7F66-42F2-8DE6-B1BF6E13ACA1'
	 AND ISU.SubTopicId='1D57BAD3-AA0C-4561-BCFE-EC1B9BAAAA5D'
	 OR
	 ISUO.TopicId='B7197C2D-7F66-42F2-8DE6-B1BF6E13ACA1'
	 AND ISUO.SubTopicId='1D57BAD3-AA0C-4561-BCFE-EC1B9BAAAA5D'
	 )


   UPDATE [FS_custom_LE].[dbo].[ErrorLog]
SET  Message='' --Message+' - Test funguje' --
WHERE Timelocal=@from


   UPDATE [iCC_LE].[dbo].[Scenario]
SET  [OnSaveSqlCmd]=REPLACE(OnSaveSqlCmd,'SV] @ScenarioResultId','SV] @ScenarioResultId, @AgentId')
WHERE Deleted=0 


   UPDATE [iCC_LE].[dbo].[Holiday]
SET  [HolidayGroupName]='LAMA_ENERGY_Svatky'
WHERE Deleted=0 AND [HolidayGroupName]='LAMA_ENERGY' AND HolidayId<>'ac76f72b-43b2-495e-8217-641ca0d55c2d'

  UPDATE [iCC_LE].[dbo].[Agent]
SET  EmailConsumption=101
WHERE Deleted=0

   UPDATE [iCC].[dbo].[DataQuery]
SET  Deleted=0
WHERE DataqueryId =@Id


  UPDATE [iCC].[dbo].[InboundCall]
SET  QueueDuration=1200, EndTime=DATEADD(ss,1200,EnqueueingTime)
WHERE QueueDuration>1200
	AND TimeUTC>@from AND TimeUTC<=@To


UPDATE iCC.dbo.Gateway
SET Direction = 'I'
WHERE  Deleted=0

UPDATE iCC.dbo.Issue
SET Activity = 'Closed', CloseTime=GETDATE()
 WHERE 1=1
     AND Activity<>'Closed'
	 AND (AgentId='f798c2d9-ae35-43c8-90ca-7f23fb6e030b' OR AgentId='5691fb89-0fb1-4f5b-8450-73205a3b875e')
  AND TimeUTC<@From

    UPDATE iCC.dbo.Message
SET  BodyText=FS_custom.dbo.ReplaceSmilyes(BodyText) 
WHERE MessageId=@Id
-- MessagePhase='Scheduled' AND MessageResult='Closed'

  UPDATE [iCC].[dbo].[OutboundCall]
SET  CallPhase='New', CallResult='Prepared'
WHERE OutboundCallId =@Id
-- MessagePhase='Scheduled' AND MessageResult='Closed'



*/