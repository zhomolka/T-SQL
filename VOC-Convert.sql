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

DECLARE @VOCId AS UNIQUEIDENTIFIER='426f6742-a008-4615-afd2-4aa1ca53e257'
DECLARE @VOC2Id AS UNIQUEIDENTIFIER='21fc0cbe-dd7c-4912-8fe2-f9feaa92171d'
DECLARE @ScrTestId AS UNIQUEIDENTIFIER='06551968-4611-4482-9424-eff28b4a1900'
DECLARE @ScrVOCTimesId AS UNIQUEIDENTIFIER='7bd4c04b-cc7c-4056-838f-a8f7eeb2fe24'

 BEGIN TRANSACTION
/*
--Pøesun obrazovky do jiného scénáøe VOC ASC2:
  UPDATE iCC.dbo.Screen 
SET  Scenarioid=@VOCId
 WHERE 1=1
  AND scenarioId=@VOC2Id
  AND DisplayName='VOC ASC2'--
  */

-------------------------------------------------------------------------------------
 


--Pøesun prvkù obrazovky VOC Times 2  na VOC Times:
  UPDATE iCC.dbo.ScreenControl -- 
SET  Screenid=@ScrVOCTimesId
 WHERE 1=1
  AND Screenid='b3822198-d84a-4b90-84bb-d2ba2fba06fc' -- Z VOC Times 2
  AND Rank>40
  AND ExportField=1
  AND Deleted=0  
  /* Zkontrolovat poøadí U tìchto položek má být */ 
COMMIT TRANSACTION

--ROLLBACK TRANSACTION

/*
 -------------------------------------------------------------------------------------
  --Pøesun obrazovky do jiného scénáøe VOC Proposed Solution:
  UPDATE iCC.dbo.Screen 
SET  Scenarioid=@VOCId
 WHERE 1=1
  AND scenarioId=@VOC2Id
  AND DisplayName='VOC Proposed Solution'--



--Pøesun prvkù obrazovky na jinou obrazovku:
  UPDATE iCC.dbo.ScreenControl 
SET  Screenid=@ScrTestId -- Odsun stávajících prvkù na Test
 WHERE 1=1
  AND Screenid='aac4f9a4-69e8-4417-a3c8-6aa5345c3eda' -- VOC proposed Solution
  AND ExportField=1
  AND Deleted=0 

  UPDATE iCC.dbo.ScreenControl -- 
SET  Screenid='aac4f9a4-69e8-4417-a3c8-6aa5345c3eda' --
 WHERE 1=1
  AND Screenid=@ScrVOCTimesId -- Z VOC Times
  AND Rank>91
  AND ExportField=1
  AND Deleted=0  
--------------------------
 --Pøesun obrazovky do jiného scénáøe VOC SECZ:
  UPDATE iCC.dbo.Screen 
SET  Scenarioid=@VOCId
 WHERE 1=1
  AND scenarioId=@VOC2Id
  AND DisplayName='VOC SECZ'--



--Pøesun prvkù obrazovky na jinou obrazovku:
  UPDATE iCC.dbo.ScreenControl 
SET  Screenid=@ScrTestId -- Odsun stávajících prvkù na Test
 WHERE 1=1
  AND Screenid='da765c0c-3ea8-463e-9372-672e19af73c9' -- VOC SECZ
  AND Rank<100
  AND ExportField=1
  AND Deleted=0 

  UPDATE iCC.dbo.ScreenControl -- 
SET  Screenid='da765c0c-3ea8-463e-9372-672e19af73c9' --
 WHERE 1=1
  AND Screenid=@ScrVOCTimesId -- Z VOC Times
  AND Rank>60
  AND ExportField=1
  AND Deleted=0  

   --Pøesun obrazovky do jiného scénáøe VOC ASC:
  UPDATE iCC.dbo.Screen 
SET  Scenarioid=@VOCId
 WHERE 1=1
  AND scenarioId=@VOC2Id
  AND DisplayName='VOC ASC'--



--Pøesun prvkù obrazovky na jinou obrazovku:
  UPDATE iCC.dbo.ScreenControl 
SET  Screenid=@ScrTestId -- Odsun stávajících prvkù na Test
 WHERE 1=1
  AND Screenid='07670021-f26c-431d-933d-f9e0d1575dca' -- VOC ASC 
  AND (Rank<30 OR Rank>40)
  AND ExportField=1
  AND Deleted=0 

  UPDATE iCC.dbo.ScreenControl -- 
SET  Screenid='07670021-f26c-431d-933d-f9e0d1575dca',DisplayName='1st '+DisplayName
 WHERE 1=1
  AND Screenid=@ScrVOCTimesId -- Z VOC Times
  AND Rank>40
  AND ExportField=1
  AND Deleted=0  
  /* Zkontrolovat poøadí U tìchto položek má být */ 


*/