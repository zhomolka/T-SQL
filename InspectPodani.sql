USE iCC
GO
DECLARE @from AS date=convert(datetime, '2017.06.26')
DECLARE @to AS date=convert(datetime, '2017.06.27')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER=(SELECT TOP 1 AgentId FROM Agent WHERE Activity='Ready')
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
    SET @from=DATEADD(Day,-20,GETDATE())
    SET @to=GETDATE()
  END

SELECT 
--DISTINCT
TOP 1000
  ME.ReceivedSentTime
  ,WFI.StartTimeUtc AS WFIStartTimeUtc
  ,MessageType
  ,MessageResult
  ,MessagePhase
  ,[dbo].[GetTargetColumnText](ISU.FormDataId,'EvidencniCislo') as EvidencniCislo
  ,SubjectField
  ,ISU.Activity AS ISUActivity
  ,SCR.Activity AS SCRActivity -- má být 'Completed'
  ,ISU.FormDataId  AS ISUScenarioResultId
        ,ME.[MessageId]

	, ME.IssueId
  	,ToField
	RemoteAddress

 	  	  /* */
  FROM [iCC].[dbo].[Message] ME
    LEFT JOIN iCC.dbo.Issue AS ISU ON ME.IssueId=ISU.IssueId
    LEFT JOIN iCC.dbo.Agent AS A ON A.AgentId=ME.AgentId
	LEFT JOIN [iCC].[dbo].ScenarioResult SCR ON ISU.FormDataId=SCR.ScenarioResultId
    LEFT JOIN [iCC].[dbo].[WorkflowInstance] as WFI with (NOLOCK) on ISU.FormDataId=WFI.ScenarioResultId
   
  WHERE 1=1
    --AND DATEDIFF(DD,ReceivedSentTime,ME.TimeUtc)>2
	--AND ME.MessageId='5FEFE866-6075-ED11-BD42-005056B5E8B0'
   AND ME.TimeUtc>@from
   --AND [dbo].[GetTargetColumnText](ISU.FormDataId,'EvidencniCislo') IN ('1800750','1797825','1796757','1789693')
   AND ISU.Activity='Closed'
   AND MessageType='Task'
   AND SCR.Activity <> 'Completed'
   --AND ME.BodyText LIKE '%'+'7667FA7A-7369-ED11-BD42-005056B5E8B0%'
   --AND IssueId='5b7a60d9-c326-e811-8508-0050568e4c40'
   --AND BodyHtml LIKE '%Štìpánková%'
   --AND ME.ProjectId='005EBA6E-949A-4732-8492-D371DE0D8BCF' -- SPAM
 --   AND MessageType='Task'
	--AND ME.ProjectId IS  NULL
	--AND SpamLevel>=1 
	--AND A.DisplayName LIKE '%Fuks%'
  --AND RemoteAddress='radek@spravazeleznic.cz'
  --AND MessageType='Email' AND Direction='O'
  --AND ToField LIKE '%Sodkova@spra%' -- 'KlimaV@spravazeleznic.cz'
  --AND SubjectField LIKE 'Sablona_BodyHtml_PDF'
  --AND Direction='O'
  --AND ME.AgentId IS  NULL
  --AND RelatedMessageId IS NOT NULL
  --FromField='import@bemeta.cz'
  --AND ME.MessageId='dd52f00b-6558-ee11-bd4c-005056b5e8b0' 

   --AND ME.AgentId='6d3be5af-8397-4a08-93eb-e2fb9930e34d'  BEE69283-5EE2-E611-96AD-0050568E4C40
  --AND MessagePhase='Draft'
  ORDER BY ME.TimeUtc
   /*
  AND MessageId IN (
  '11B1DCD1-50B2-E611-BF8E-0050568E62E5',
  'C7249BFB-AB3D-E611-86FB-0050568E62E5',
  'BF249BFB-AB3D-E611-86FB-0050568E62E5',
  '784D77D1-AB3D-E611-86FB-0050568E62E5'

  ) */

