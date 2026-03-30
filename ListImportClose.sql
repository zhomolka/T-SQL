USE iCC
GO
SET DATEFORMAT ymd
DECLARE @from AS datetime=convert(datetime, '2017.06.26')
DECLARE @to AS datetime=convert(datetime, '2017.06.27')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER=(SELECT TOP 1 AgentId FROM Agent AG LEFT JOIN icc.dbo.Workplace AS W WITH(NOLOCK)  ON AG.WorkplaceId = W.WorkplaceId
WHERE Activity='Ready' AND w.State <> 'Free')
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

DECLARE @Id AS UNIQUEIDENTIFIER='8549248b-e1ff-e911-80c5-001e67e7740d'
 BEGIN TRANSACTION

 UPDATE [iCC].[dbo].[OutboundListImport]
  SET  Active=0 --AND Deleted=1
   WHERE 1=1
   -- AND OutboundListId='143FB2A3-61BB-4B66-A08C-4B2B9B8C08CC' 
   AND Deleted=0
    AND Active=1
	AND TimeUTC<convert(datetime, '2019.06.01')
	AND [FS_Custom].dbo.[isOutboundImpComplete](OutboundListImportId)=1


COMMIT TRANSACTION

--ROLLBACK TRANSACTION

/*

  UPDATE iCC.dbo.Message
SET  ProjectId='cd9eb963-8b71-4fcf-b547-d7a828338999' 
WHERE Direction='O' AND MessageType='Email' AND ProjectId IS NULL AND SpamLevel=0
-- MessagePhase='Scheduled' AND MessageResult='Closed'

UPDATE iCC.dbo.Gateway
SET Direction = 'I'
WHERE  Deleted=0

UPDATE iCC.dbo.Issue
SET Activity = 'Closed', CloseTime=GETDATE()
 WHERE 1=1
     AND Activity<>'Closed'
	 AND (AgentId='f798c2d9-ae35-43c8-90ca-7f23fb6e030b' OR AgentId='5691fb89-0fb1-4f5b-8450-73205a3b875e')
  AND TimeUTC<@From


*/