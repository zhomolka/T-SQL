USE iCC
GO
DECLARE @from AS date=convert(datetime, '2018.11.21')
DECLARE @to AS date=convert(datetime, '2018.11.22')
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
DECLARE @LastTime AS bit=0

IF @LastTime=1
 BEGIN
    SET @from=DATEADD(Day,-10,GETDATE())
    SET @to=GETDATE()
  END
USE iCC
select * from icc.dbo.scenarioresult with(nolock) 
where 1=1
  AND AgentId='ec14f695-50b3-4f74-b38f-c50b3a940d95'
    AND TimeUTC>@from AND TimeUTC<@To
--AND ScenarioResultId='1E37B4DB-5BED-E811-80D3-00505600003C'




--Start, @ScenarioResultId=1E37B4DB-5BED-E811-80D3-00505600003C