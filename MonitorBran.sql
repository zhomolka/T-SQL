/****** Script for SelectTopNRows command from SSMS  ******/
USE iCC
DECLARE @from AS datetime=convert(datetime, '2017.06.26')
DECLARE @to AS datetime=convert(datetime, '2017.06.27')

DECLARE @LastTime AS bit=1
IF @LastTime=1
 BEGIN
    DECLARE @TimeDif AS Integer= DATEDIFF(Hour,GETUTCDATE(),GETDATE())
    SET @from=DATEADD(Hour,-2,GETDATE())
	SET @from=DATEADD(Hour,-@TimeDif,@from)
    SET @to=GETDATE()
  END

SELECT * FROM (
SELECT TOP 1000 
      [DisplayName]
      ,[PilotAddress]
	  ,GatewayId
      ,(SELECT COUNT(1) FROM Message ME WITH (NOLOCK) WHERE ME.GateWayId=GW.GateWayId AND TimeUTC>@from AND Direction='I') AS PrijatychZprav
      ,(SELECT COUNT(1) FROM Message ME WITH (NOLOCK) WHERE ME.GateWayId=GW.GateWayId AND TimeUTC>@from AND Direction='O' AND MessagePhase='Sent') AS OdeslanychZprav
      ,[Channel]
      ,[Direction]
      , InDevice
      , OutDevice
  FROM .[dbo].[Gateway] GW
  WHERE 1=1
  AND [Deleted]=0
  AND Channel<>'SMS'
  AND Direction<>'O'
  /*AND GatewayId='12bb1f96-2b95-4799-b1f8-12c6ffe924de'
  OR GatewayId='f46ba81c-9a2d-48d8-9a39-c5013358238e'*/
  ) AS Phase1
  WHERE PrijatychZprav=0

  UNION
  SELECT TOP 1
      'BEZ BRÁNY' AS [DisplayName]
      ,'' AS [PilotAddress]
	  ,NULL AS GatewayId
      ,(SELECT COUNT(1) FROM Message ME WITH (NOLOCK) WHERE ME.GateWayId IS NULL AND TimeUTC>@from AND Direction='I') AS PrijatychZprav
      ,(SELECT COUNT(1) FROM Message ME WITH (NOLOCK) WHERE ME.GateWayId IS NULL  AND TimeUTC>@from AND Direction='O' AND MessagePhase='Sent') AS OdeslanychZprav
      ,'' AS [Channel]
      ,'' AS [Direction]
      ,'' AS  InDevice
      ,'' AS  OutDevice
  FROM .[dbo].[Gateway] GW
    ORDER BY DisplayName


  