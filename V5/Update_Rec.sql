--USE Frontstage
--GO
SET DATEFORMAT ymd
DECLARE @from AS datetime=convert(datetime, '2017.06.26')
DECLARE @to AS datetime=convert(datetime, '2017.06.27')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
--DECLARE @MeAgentId AS UNIQUEIDENTIFIER=(SELECT TOP 1 AgentId FROM Agent AG LEFT JOIN icc.dbo.Workplace AS W WITH(NOLOCK)  ON AG.WorkplaceId = W.WorkplaceId
--WHERE Activity='Ready' AND w.State <> 'Free')
DECLARE @NullId AS UniqueIdentifier= '00000000-0000-0000-0000-000000000000'
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1
DECLARE @Number AS integer
DECLARE @GroupInterval AS integer=1440
DECLARE @RoundInterval AS integer=@GroupInterval
DECLARE @Version  AS integer=1
DECLARE @LastTime AS bit=1

IF @LastTime=1
 BEGIN
    SET @from=DATEADD(Day,-10,GETDATE())
    SET @to=GETDATE()
  END

DECLARE @Id AS UNIQUEIDENTIFIER='E09590CD-7A80-47FD-9E95-105BE0E937AD'
 BEGIN TRANSACTION

   UPDATE DQC
SET Convertor = NULL, LiteralGroup = NULL
FROM [DataQueryColumn] DQC
  LEFT JOIN [DataQuery] DQ ON DQ.DataQueryId=DQC.DataQueryId
  WHERE DQ.QueryGroup='ServiceAPP' AND DQ.Deleted=0
  AND Model = 'Image' 
  AND TargetColumn  = 'HasAttachment' 
  --AND GlyphColumn IS NULL
  AND Convertor='LiteralValue'


COMMIT TRANSACTION
--ROLLBACK TRANSACTION

/*

   UPDATE DQC
SET GlyphColumn = 'MessageType', TargetFormat = NULL, Convertor = 'LiteralValue', LiteralGroup = 50
FROM [DataQueryColumn] DQC
  LEFT JOIN [DataQuery] DQ ON DQ.DataQueryId=DQC.DataQueryId
  WHERE DQ.QueryGroup='ServiceAPP' AND DQ.Deleted=0
  AND Model = 'Image' 
  AND TargetColumn  = 'MessageType' 
  AND GlyphColumn IS NULL

  UPDATE DQC
SET URLFormat = IIF(URLFormat LIKE '~','','~')+LTRIM(REPLACE(URLFormat,'/RC',''))
FROM [DataQueryColumn] DQC
  LEFT JOIN [DataQuery] DQ ON DQ.DataQueryId=DQC.DataQueryId
  WHERE DQ.QueryGroup='ServiceAPP' AND DQ.Deleted=0
  AND URLFormat IS NOT NULL
  AND URLFormat LIKE '%/RC%'
  AND UrlColumn IN ('MessageId','InboundCallId','OutboundCallId')  

  UPDATE Attachment
SET  MessageId=@Id
WHERE MessageId='D05E1058-2042-EF11-86C3-000D3AB85366'

  UPDATE Message
SET  MessageResult=0,MessagePhase=3
WHERE MessageId=@Id
  

  UPDATE .[dbo].[OutboundCall] 
SET CallDuration=60

WHERE OutboundCallId='BD2C051E-331C-EF11-83A6-A4BF016EAF17'


  UPDATE [ProServer].[dbo].[Account] 
SET  [SystemName]=REPLACE([SystemName],'ALZ\SR-DC1-ATLAPP1\','SR-DC1-ATLAPP1\')

WHERE SystemName LIKE 'ALZ\s%' --AND TeamName='B2B'
  

    UPDATE [ProServer].[dbo].[Credentials] 
SET  [SystemName]=REPLACE([SystemName],'ALZ\SR-DC1-ATLAPP1\','SR-DC1-ATLAPP1\')

WHERE SystemName LIKE 'ALZ\sr%' --AND TeamName='B2B'


 UPDATE FS_custom.dbo.ErrorLog
  
SET  RepeatAfter=-1
 --WHERE MessageType Like 'Tmp%' AND MessageResult = 'Active'

  UPDATE iCC.dbo.Message
SET  BodyText=FS_custom.dbo.ReplaceSmilyes(BodyText) 
WHERE MessageId=@Id

UPDATE iCC.dbo.Gateway
SET Direction = 'I'
WHERE  Deleted=0

UPDATE iCC.dbo.Issue
SET Activity = 'Closed', CloseTime=GETDATE()
 WHERE 1=1
     AND Activity<>'Closed'
	 AND (AgentId='f798c2d9-ae35-43c8-90ca-7f23fb6e030b' OR AgentId='5691fb89-0fb1-4f5b-8450-73205a3b875e')
  AND TimeUTC<@From

  SET  BodyHtml=REPLACE(BodyHtml,'http://www.dpd.com/','www.baliky.cz') 
 WHERE MessageType Like 'Tmp%' AND MessageResult = 'Active'
   -- AND TeamName='CZ'
  --AND AgentId='22b7b5b2-fbbd-4577-a995-e5847ed7de1e'
  --RemoteAddress='import@bemeta.cz'
    --AND MessageId='833f3691-3eb6-e611-80f3-f8bc1253a1a4'
  --AND BodyText LIKE '%dpd.com%'
  AND BodyHtml LIKE '%dpd.com/%'
  AND SubjectField LIKE '%DPD%'


*/