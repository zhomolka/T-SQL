:r C:\\Atlantis\\Scripts\\setvar.txt
USE $(ICC)
/*
-- Pøepiš Perso problematického agenta Persem funkèního agenta:
	 DECLARE @Id AS UNIQUEIDENTIFIER='A047E56E-1560-4963-98C7-749F17A1282D' -- AgentId with functionally configuration
 BEGIN TRANSACTION

 UPDATE .[dbo].[Perso]
   SET JsonData=(SELECT TOP 1 JsonData FROM .[dbo].[Perso] WHERE AgentId=@Id AND RefName='ProCaller#RibbonDefinition')
WHERE AgentId='93B23421-8F17-4FC7-855E-FD6C38778C8D'
and RefName='ProCaller#RibbonDefinition'


COMMIT TRANSACTION
--ROLLBACK TRANSACTION
-----------------------------------------
-- Zapiš Perso problematickému agentovi podle Perso funkèního agenta:
USE iCC
DECLARE @Id AS UNIQUEIDENTIFIER='D3CE9A13-D161-4D5B-8740-7C33A0BBE3C9' -- AgentId with functionally configuration
DECLARE @ProblemId AS UNIQUEIDENTIFIER='fff158fd-2619-442b-9ccf-db7195d443a2' -- AgentId with missing configuration
 
INSERT INTO [dbo].[Perso]
           (--[PersoId],
           [AgentId],[Profile],[RefName],[RefId],[JsonData],[ContextId])
    SELECT TOP 1 @ProblemId AS [AgentId],[Profile],[RefName],[RefId],[JsonData],[ContextId] 
	FROM .[dbo].[Perso] 
	WHERE AgentId=@Id AND RefName='ProCaller#EventHandlingDefinition' --'ProCaller#RibbonDefinition'
*/
SELECT TOP (10000000) --[PersoId],
      AG.AgentId,
      AG.DisplayName AS AgentName,
	  (SELECT COUNT(1)  FROM $(ICC).[dbo].[Perso] PER2 WHERE PER.JsonData=PER2.JsonData ) AS ConfCount 
	  --,AG.Deleted
   --   ,[Profile]
      ,[RefName]
      ,[RefId]
      ,[JsonData]
      ,[ContextId]
  FROM $(ICC).[dbo].[Perso] PER
    LEFT JOIN $(ICC).[dbo].[Agent] AG  ON AG.AgentId=PER.AgentId
	WHERE 1=1
	 --AND AG.AgentId IS NULL OR AG.Deleted=1
	 AND AG.AgentId IS NOT NULL AND AG.Deleted=0
	 and RefName like 'Pro%'
	 and RefName='ProCaller#RibbonDefinition'
	 --and PersoId='5DC9169B-AB31-4FA6-99DB-C0F7341A3AB9'
	-- and JsonData='{"SchemaVersion":2,"UsedVersion":2,"Definitions":[{"DisplayName":"Default","Id":"ae77a00e-6bc7-444b-b4fa-bf11a1c4972c","Options":{"CommunicationInfo":{"VoiceDisplayTemplate":"{ProjectName};{ContactName};{SourceNumber}","ChatDisplayTemplate":"Chat {ContactName};{ProjectName};{RemotePartyName}","MessageDisplayTemplate":"Message {ContactName};{ProjectName}","TaskDisplayTemplate":"Task {ContactName};{ProjectName}"},"SplashHideTimeoutMilliseconds":2000,"ClientAlert":{"ShiftIntervalInSeconds":5,"AlertListMaxAgeThresholdSeconds":60},"AgentStatus":{"AllowChangeBetweenLogoffStatuses":true,"StatusChangeRequestTimeoutSeconds":20},"AgentWorkplace":{"WorkplaceChangeRequestTimeoutSeconds":20},"UiOptions":{"BootstrapColorMappings":{"success":"#13A10E","danger":"#E81123","primary":"#0078D4","info":"#EAEAEA","warning":"#d6d600","white":"#ffffff","default":"#000000"},"DqBootstrapColorMappings":null},"WebView":{"ChatWindowUrl":"https://cc.post.ee/ReactClient/pages/ChatEditor.html?id={chatId}"},"VoiceCommandThrottleMilliseconds":3000},"ComponentGroups":[{"Name":null,"Components":[{"Id":"45701d5f-b6e1-4f1b-8480-f43427934bf7","CodeName":"StatusDropdown","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":126.0}],"BlockWidth":4,"AppendSeparator":true,"Orientation":0,"Band":0,"BandIndex":0,"Id":"27251361-56ae-469d-a6c8-fad3b41ec68c","CodeName":null,"IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":45.0,"WidthPx":184.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Name":null,"Components":[{"Id":"884f6cae-a4b7-4980-8859-480e030350e7","CodeName":"BasicCallBar","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":270.0},{"Id":"7858bce0-68e5-4bf3-8237-2c37074e03d3","CodeName":"TransferCallBar","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":270.0}],"BlockWidth":9,"AppendSeparator":true,"Orientation":0,"Band":0,"BandIndex":1,"Id":"c4f06275-f4d0-4b6d-b8cc-42a58eaa46b1","CodeName":null,"IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":45.0,"WidthPx":414.0,"RightSeparator":true,"CompoWidthEstimate":32.0}]}],"SelectedDefinitionId":"ae77a00e-6bc7-444b-b4fa-bf11a1c4972c","RibbonResources":{"ResourceList":[{"Sha256Hash":"647703b726f27267036fad8eaf435fe1d321da7ebf14f8162d959a58732229c9","Id":"6e1d0baa-7a6b-4612-94b2-5b5dcc074f26","Data":"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","Origin":null}]}}  '
    --AND AgentId IN ('c8717f6e-8933-411a-9d27-ea0ebc3d7d1e','16c53508-86b4-4694-a779-1f5ed4b34b79')
 --   AND RefName NOT IN ('SelectQueryPage','DataQueryPortlet')
	--AND RefName = 'MessageEditorPersoCached'
	ORDER BY AG.DisplayName
/*
	SELECT 
      [RefName]
	  ,COUNT(1) AS Count
      ,[JsonData]

  FROM $(ICC).[dbo].[Perso] PER
    LEFT JOIN $(ICC).[dbo].[Agent] AG  ON AG.AgentId=PER.AgentId
	WHERE 1=1
	 --AND AG.AgentId IS NULL OR AG.Deleted=1
	 AND AG.AgentId IS NOT NULL AND AG.Deleted=0
	 and RefName like 'Pro%'
	 and RefName='ProCaller#RibbonDefinition'
	 GROUP BY RefName,[JsonData]
	 */
/*
-- Vymaž duplicitní/nesprávné Perso:
DELETE FROM $(ICC).[dbo].[Perso]
WHERE 1=1
and PersoId='641AEBAE-3170-46C3-BC87-FC6889935827'
--AND AgentId='e51f4c8e-e71d-4b94-b84f-9b0cab693a2c'
--and RefName='ProCaller#RibbonDefinition'

*/