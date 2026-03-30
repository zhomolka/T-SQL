DECLARE @syncTreshold AS Datetime
SET  @syncTreshold=CONVERT(Date,'2016.01.20')
DECLARE @AdrID NVARCHAR(20)
DECLARE @SegmentCode NVARCHAR(200)
DECLARE @ScenarioResultId UniqueIdentifier
DROP TABLE #TMP

SELECT NAV.NO_ AS AdrID ,[Segmentation Code] AS SegCode INTO #TMP  FROM [172.30.50.131].[AVE_WEB2NAV].[dbo].[View - Client/Contact for ATL] AS NAV
 --    WHERE [Segmentation Code] IS NOT NULL AND [Segmentation Code]<>''
 --    WHERE [Last Change Date] >= @syncTreshold
	  
-- COLLATE DATABASE_DEFAULT 
--SELECT * FROM #TMP

/*
SELECT NAV.SegCode  AS ResultText,SCRV.ScenarioResultId, 'SegmentCode' AS TargetColumn FROM #TMP AS NAV
   INNER JOIN ScenarioResultValue AS SCRV ON SCRV.TargetColumn='companyNumber' AND  NAV.AdrID COLLATE DATABASE_DEFAULT=LEFT(SCRV.ResultText,10) COLLATE DATABASE_DEFAULT 
*/
BEGIN TRANSACTION
INSERT INTO icc.dbo.ScenarioResultValue SELECT 
  NEWID() AS ScenarioResultValueId
  , SCRV.ScenarioResultId
  , '0d39762a-9db8-4b8e-b499-f8828cab850d' AS ScreenControlId
  , NULL AS ResultNumber
  , NAV.SegCode  AS ResultText
  , NULL AS ResultNumeric
  , NULL AS ResultTime
  , 'SegmentCode' AS TargetColumn
   FROM ScenarioResultValue AS SCRV
   INNER JOIN #TMP AS NAV ON  NAV.AdrID COLLATE DATABASE_DEFAULT=LEFT(SCRV.ResultText,10) COLLATE DATABASE_DEFAULT 

COMMIT TRANSACTION
--ROLLBACK 
select ScenarioResult.* from ScenarioResultValue INNER JOIN ScenarioResult ON ScenarioResultValue.ScenarioResultId=ScenarioResult.ScenarioResultId where TargetColumn = 'SegmentCode' AND ResultText IS NOT NULL AND ResultText<>'' 

/*
SELECT NO_
 INTO CustomersBackup2013
 FROM Customers

SET @AdrID = NO_
SET @ScenarioResultId=(SELECT ResultText FROM ScenarioResultValue WHERE TargetColumn='companyNumber' AND ResultText=@AdrID)
exec CreateTargetColumnText @ScenarioResultId, 'SegmentCode', @SegmentCode


-- NO_ : Identifikátor záznamu v AVE_WEB2NAV
[Last Change Date] = Datetime
BEGIN TRANSACTION
   
ROLLBACK
*/