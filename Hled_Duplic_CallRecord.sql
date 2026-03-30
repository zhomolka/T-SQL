/*
SELECT Inboundcallid, Count(1) AS RecordCount FROM iCC.dbo.CallRecord
WHERE Inboundcallid IS NOT NULL
GROUP BY Inboundcallid
HAVING Count(1)>1
ORDER BY Count(1) DESC
*/

SELECT CR.Outboundcallid, Count(1) AS RecordCount, DistributionTime
 FROM iCC_LE.dbo.CallRecord CR
  INNER JOIN iCC_LE.dbo.OutboundCall OC ON OC.OutboundCallId=CR.OutboundCallId
WHERE 1=1
 --CR.Outboundcallid ='72774F3E-E3C0-EE11-9689-A4BF019000D4' --IS NOT NULL --
  --AND Score = 100 --IS NULL
GROUP BY CR.Outboundcallid, DistributionTime
HAVING Count(1)>2
ORDER BY DistributionTime DESC
--Count(1) DESC
/**/