/*USE iCC
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
*/
DECLARE @Id AS UNIQUEIDENTIFIER='4e3f9079-dc02-ed11-83a2-a4bf016eaf17'
DECLARE @ProjectId AS UNIQUEIDENTIFIER=(SELECT TOP 1 Projectid FROM iCC.dbo.Chat WHERE ChatId=@Id)

 BEGIN TRANSACTION
------------------  Vrácení chatu do distribuce --------------------
-- Pokud není v Queue, je potøeba jej tam doplnit
IF (SELECT TOP (1) 1 FROM [iCC].[dbo].[Queue] WHERE CommId=@Id) IS NULL
INSERT INTO iCC.[dbo].[Queue]
           ([TimeUtc]
           ,[ChannelIndex]
           ,[CommId]
           ,[CommState]
           ,[Priority]
           ,[QueueTimeUtc]
           ,[Rank]
           ,[ProjectId]
           ,[Skill]
           ,[LanguageId]
           ,[Proficiency]
           ,[Suggestion]
           ,[SuggestedAgentId]
           ,[AgentId]
           ,[WaitingOffset]
           ,[EnqueueingTimeUtc])
     VALUES
           (GETUTCDATE()
           ,6
           ,@Id
           ,1
           ,0
           ,GETUTCDATE()
           ,0
           ,@ProjectId 
           ,1
           ,NULL
           ,0
           ,0
           ,NULL
           ,NULL
           ,0
           ,GETUTCDATE())
ELSE
   UPDATE iCC.dbo.Queue
SET  CommState=1,AgentId=NULL
WHERE CommId=@Id
 
   UPDATE iCC.dbo.Chat
SET  AgentId=NULL
WHERE ChatId=@Id
--------------------------------------------------------------------
 


COMMIT TRANSACTION

--ROLLBACK TRANSACTION

/*
   UPDATE iCC.dbo.Chat
SET  ProjectId='ff651ae6-1adb-4e18-9ef6-2bc42e5bd020'
WHERE ChatId=@Id


*/