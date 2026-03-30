USE iCC
GO
SET DATEFORMAT ymd
DECLARE @from AS datetime=convert(datetime, '2021.01.01')
DECLARE @to AS datetime=convert(datetime, '2021.01.31')
DECLARE @MaxTime AS datetime
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
DECLARE @MaxPocet AS integer
DECLARE @GroupInterval AS integer=1440
DECLARE @RoundInterval AS integer=@GroupInterval
DECLARE @Version  AS integer=1
DECLARE @LastTime AS bit=1

IF @LastTime=1
 BEGIN
    SET @from=DATEADD(Minute,-200,GETDATE())
    SET @to=GETDATE()
  END

IF OBJECT_ID(N'tempdb..##TEMP', N'U') IS NOT NULL 
  DROP TABLE ##TEMP

--

select AA.*,WP.DisplayName AS WPName into ##TEMP from FS_CUSTOM.[dbo].[Agent_activity] (@From,@To) AS AA
      LEFT JOIN iCC.dbo.Workplace AS WP ON WP.WorkplaceId=AA.WorkplaceId  
WHERE AA.WorkplaceId IS NOT NULL ORDER BY GroupingDate

--select * FROM ##TEMP 

--select GroupingDate,COUNT(1) AS Pocet FROM ##TEMP GROUP BY GroupingDate
/*
SET @MaxPocet=(select MAX(Pocet) AS MaxPocet FROM (
select GroupingDate,COUNT(1) AS Pocet FROM ##TEMP 
GROUP BY GroupingDate) AS Phase1)

SET @MaxTime = (select TOP 1 GroupingDate FROM (
select GroupingDate,COUNT(1) AS Pocet FROM ##TEMP 
GROUP BY GroupingDate) AS Phase1 
WHERE Pocet=@MaxPocet)
*/
SET @MaxTime = (select TOP 1 GroupingDate FROM (
select GroupingDate,COUNT(1) AS Pocet FROM ##TEMP 
GROUP BY GroupingDate) AS Phase1 
ORDER BY Pocet DESC)


select * FROM ##TEMP WHERE GroupingDate=@MaxTime



IF OBJECT_ID(N'tempdb..##TEMP', N'U') IS NOT NULL 
  DROP TABLE ##TEMP

GO
