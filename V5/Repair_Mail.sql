
/*UPDATE iCC.dbo.Message
--SET  Emails = 'maeve.osullivan02@bbc.co.uk'
SET  RemoteAddress = 'petra@agenturamachackova.cz',Tofield = 'petra <petra@agenturamachackova.cz>',MessagePhase='Scheduled',
  ExtendedFields='{"ToField":[{"DisplayName":"petra","Email":"petra@agenturamachackova.cz"}],"ToCcField":[],"ToBccField":[],"ToNumbers":null}'
WHERE  1=1
-- AND (PhoneNumberId = '766557E2-FCA6-4E9F-9C70-E7BB401AAAA0'
AND  (messageId = '1d06fa97-c8c0-e811-90f1-005056925807')
--AND Deleted=1
*/
DECLARE @Id AS UNIQUEIDENTIFIER='58E7BF92-2F79-EF11-83C7-005056013ADB'
DECLARE @ProjectId AS UNIQUEIDENTIFIER=(SELECT TOP 1 Projectid FROM Message WHERE MessageId=@Id)

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
           ,1
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

--COMMIT TRANSACTION

ROLLBACK TRANSACTION
