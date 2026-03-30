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
    SET @from=DATEADD(Hour,-8,GETDATE())
    SET @to=GETDATE()
  END

SELECT ISE.IssueId,NewTime,AG.DisplayName AS AgentName, ISE.TeamName, ContractNumber,Notice
FROM IssueExtended ISE 
LEFT JOIN ScenarioResult SCR ON FormDataId=SCR.ScenarioResultId
LEFT JOIN Agent AG ON AG.AgentId=ISE.AgentId
WHERE 1=1
--AND Notice LIKE '%Cíger%'
  AND ISNULL(ContractNumber,'') = ''
  AND NewTime>@from AND NewTime<@To
  AND SCR.InboundCallId IS NOT NULL
  AND ISE.TeamName='SK'
  ORDER BY NewTime

