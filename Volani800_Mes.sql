SELECT 
   COUNT(*) AS PocetZaMesic

      , MONTH(RegionalTime)*100+YEAR(RegionalTime)-2000 AS Mesic
         --, PR.DisplayName AS ProjectName 
  FROM  iCC.dbo.InboundCall  AS IC
   --LEFT JOIN IvrStep AS IVRST ON IVRST.IvrStepId=CAE.ReferenceId
   --LEFT JOIN IvrScript AS IVRSC ON IVRST.IvrScriptId=IVRSC.IvrScriptId
--LEFT JOIN Project AS PR ON PR.ProjectId=CAE.ProjectId
WHERE PilotId='180CDF2A-678A-48B2-B16A-00AE7AC85163'
AND RegionalTime>=convert(datetime, '2018.01.01')
AND RegionalTime<=convert(datetime, '2018.31.03')
GROUP BY MONTH(RegionalTime)*100+YEAR(RegionalTime)
ORDER BY MONTH(RegionalTime)*100+YEAR(RegionalTime)
