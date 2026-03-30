DECLARE @from AS datetime=convert(datetime, '2017.01.09')
DECLARE @to AS datetime=convert(datetime, '2017.30.09')
--SET @from=convert(datetime, '2015.11.01')
--SET @to=convert(datetime, '2015.11.30')

SET @from=GETDATE()-1
SET @to=GETDATE()

USE iCC
SELECT 
           OutboundCallId
          , TimeLocal
          , EventType 
          , IVRST.Rank AS Navesti
          , IVRST.Action AS Akce
          , IVRST.DisplayName AS Ivrkrok
          , IVRST.FileName AS Hlaska
          , IVRSC.DisplayName AS IvrSkript
          , ProjectId 
          , AgentId 
          , WorkplaceId 
          , ReferenceData 
          , Duration 
          , ResultData 
      FROM  iCC.dbo.CallEvent  AS CAE
       LEFT JOIN IvrStep AS IVRST ON IVRST.IvrStepId=CAE.ReferenceId
       LEFT JOIN IvrScript AS IVRSC ON IVRST.IvrScriptId=IVRSC.IvrScriptId
	     WHERE 1=1
  AND TimeUTC >= @From AND TimeUTC <= @To
  AND OutboundCallId IS NOT NULL
-- AND OutboundCallId='64169300-A6E0-E711-80D5-001E67EAD5C6'
ORDER BY OutboundCallId,Timelocal