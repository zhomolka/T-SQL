DECLARE @from AS datetime=convert(datetime, '2023.01.01')
DECLARE @to AS datetime=convert(datetime, '2023.05.30')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER=(SELECT TOP 1 AgentId FROM Agent AG LEFT JOIN icc.dbo.Workplace AS W WITH(NOLOCK)  ON AG.WorkplaceId = W.WorkplaceId
WHERE Activity='Ready' AND w.State <> 'Free')
DECLARE @NullId AS UniqueIdentifier= '00000000-0000-0000-0000-000000000000'
DECLARE @Now AS datetime=GETDATE()
DECLARE @NowUTC AS datetime=GETUTCDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1
DECLARE @Number AS integer
DECLARE @GroupInterval AS integer=1440
DECLARE @RoundInterval AS integer=@GroupInterval
DECLARE @Version  AS integer=1
DECLARE @LastTime AS bit=1

IF @LastTime=1
 BEGIN
    SET @from=DATEADD(year,-1,GETDATE())
    SET @to=GETDATE()
  END
  SELECT PR.Displayname AS ProjectName,LastEndCall FROM (
	SELECT Projectid,MAX(CE.Timelocal) AS LastEndCall	FROM dbo.CallEvent ce WITH (NOLOCK) 
	WHERE Timelocal>@from
	GROUP BY Projectid) AS Phase1
	LEFT JOIN Project AS PR ON PR.ProjectId=Phase1.ProjectId
