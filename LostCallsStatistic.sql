USE iCC
GO
SET DATEFORMAT ymd
DECLARE @from AS datetime=convert(datetime, '2020.01.01')
DECLARE @to AS datetime=convert(datetime, '2017.06.27')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER=(SELECT TOP 1 AgentId FROM Agent AG LEFT JOIN icc.dbo.Workplace AS W WITH(NOLOCK)  ON AG.WorkplaceId = W.WorkplaceId
WHERE Activity='Ready' AND w.State <> 'Free')
DECLARE @MainIVRId AS UniqueIdentifier= '00000000-0000-0000-0000-000000000000'
DECLARE @VIPIVRId AS UniqueIdentifier= '00000000-0000-0000-0000-000000000000'
DECLARE @PilotId AS UniqueIdentifier= '00000000-0000-0000-0000-000000000000'
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1
DECLARE @Number AS integer
DECLARE @GroupInterval AS integer=1440
DECLARE @RoundInterval AS integer=@GroupInterval
DECLARE @HolidayGroupName AS NVARCHAR(10)='XX'
DECLARE @ProjectGroupName AS NVARCHAR(10)='SK'-- 'CZ' -- 
DECLARE @Version  AS integer=1
DECLARE @LastTime AS bit=1

IF @ProjectGroupName ='CZ'
 BEGIN
  SET @MainIVRId='e02e8a2a-925e-47c4-8560-25a9a5f814ef'  
  SET @VIPIVRId='7dae005c-ad01-44dc-b82f-9e4bbd1e047c'  
  SET @PilotId='B83B9393-57CE-4DCA-AE66-B86213EBCB62'
  SET @HolidayGroupName='CZ_PROVOZ'
 END
ELSE
 BEGIN
  SET @MainIVRId='d3f906d1-afb4-416a-9588-dd665a3fa0f7'
  SET @VIPIVRId='59E51B5D-58C3-4F1E-853D-C40AE76302D0'  
  SET @PilotId='918FFCE3-7E43-40AC-9959-2F07AF90B652'
  SET @HolidayGroupName='SK_PROVOZ'
 END

IF @LastTime=1
 BEGIN
    --SET @from=DATEADD(DAY,-20,GETDATE())
    SET @to=GETDATE()
  END
/**/
SELECT 
  @from AS FromTime
, @to AS ToTime
, @ProjectGroupName AS Team
, SUM(DoUvodniHlasky) AS DoUvodniHlasky
, SUM(ZaUvodniHlaskou) AS ZaUvodniHlaskou
, SUM(Nabidky) AS Nabidky
, SUM(DoCislaZasilky) AS DoCislaZasilky
, SUM(InvalidNum1)  AS InvalidNum1
, SUM(InvalidNum2) AS InvalidNum2
, SUM(CteStavZasilky) AS CteStavZasilky
, SUM(PredVIP) AS PredVIP
, SUM(ZaVIP) AS ZaVIP
, SUM(CekaciFronta) AS CekaciFronta

FROM (
SELECT 
  InboundCallId
  ,IvrScriptId
  , Rank
  ,DisplayName
  , IIF(IvrScriptId=@MainIVRId AND Rank<=1000 OR IvrScriptId IS NULL,1,0)  AS DoUvodniHlasky
  , IIF(IvrScriptId=@MainIVRId AND Rank>1000 AND Rank<1050,1,0) AS ZaUvodniHlaskou
  , IIF(IvrScriptId=@MainIVRId AND Rank>1000 AND Rank=1050,1,0) AS Nabidky
  , IIF(IvrScriptId=@MainIVRId AND ((Rank>1050 AND Rank<=1720) OR (Rank>=2300 AND Rank<=2440)),1,0) AS DoCislaZasilky
  , IIF(IvrScriptId=@MainIVRId AND ((Rank>=1780 AND Rank<=1860) OR (Rank>=2100 AND Rank<=2240) /*OR IvrScriptId='F71A4C1F-4E00-4C92-99C5-E04A4ABAAFC1'*/) ,1,0) AS InvalidNum1
  , IIF(IvrScriptId=@MainIVRId AND Rank>=1880 AND Rank<=1960,1,0) AS InvalidNum2
  , IIF(IvrScriptId=@MainIVRId AND Rank=2250 ,1,0) AS CteStavZasilky
  , IIF(IvrScriptId=@VIPIVRId AND Rank<=120,1,0) AS PredVIP
  , IIF(IvrScriptId=@VIPIVRId AND Rank>120,1,0) AS ZaVIP
  , IIF(CallPhase='IVRScriptW',1,0) AS CekaciFronta
FROM (
SELECT 
      IC.InboundCallId
	  ,IC.CallPhase
	  , FS_Custom.dbo.ReturnMaxIVRRank(IC.InboundCallId)  AS IVRStepId
   FROM icc.dbo.InboundCall AS IC
   WHERE 1=1
    AND [PilotTime]>@from
    AND IC.CallResult <>'Served'
	AND IC.PilotId=@PilotId
	AND IC.CallResult <> 'Active'
	AND FS_Custom.dbo.IsWorkTime(PilotTime,@HolidayGroupName)=1
	--GROUP BY IC.InboundCallId
  ) AS Phase1
	 LEFT JOIN IvrStep AS IVRST ON IVRST.IvrStepId=Phase1.IvrStepId
  ) AS Phase2

  /*SELECT *
FROM (
SELECT 
      IC.InboundCallId
      --,[TimeLocal]
	  , MAX(ISNULL(IVRST.Rank,0)+IIF(IVRST.IvrScriptId<>@MainIVRId,10000,0)) AS Rank
      --,[EventType]
   FROM [iCC].[dbo].[CallEvent] CAE
  	 LEFT JOIN icc.dbo.InboundCall AS IC ON IC.InboundCallId = CAE.InboundCallId
	 LEFT JOIN IvrStep AS IVRST ON IVRST.IvrStepId=CAE.ReferenceId
  WHERE 1=1
    AND [TimeLocal]>@from
    AND CAE.InboundCallId IS NOT NULL
    AND IC.AnswerTime IS NULL
	AND IC.PilotId=@PilotId
	AND IC.CallResult <> 'Active'
	GROUP BY IC.InboundCallId
  ) AS Phase1  */