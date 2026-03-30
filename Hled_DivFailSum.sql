DECLARE @from AS date=GETDATE()-30


 /*    
      (SELECT CONVERT(DATE,PilotTime) AS Datum,COUNT(1) 
	  FROM ICC.[dbo].[InboundCall] WITH (NOLOCK) GROUP BY CONVERT(DATE,PilotTime)  WHERE PilotTime>@from)

		RETURN CONVERT(NVARCHAR(5),@DivFailCount)+' Divert Failed. It is '+CONVERT(NVARCHAR(9),@DivFailCount*100/@InCallCount)+' %'
		*/

--SET @from =convert(datetime, '2022.04.01')
SELECT Phase1.Datum,InCall,COUNT(1) AS PocDivFailed,(CONVERT(REAL,COUNT(1))*100/CONVERT(REAL,InCall)) AS Day_Percent ,
IIF(DATEPART(w,Phase1.Datum) in (1,7),'WE','') AS WE FROM (
SELECT DISTINCT --TOP 10000 
	  CONVERT(DATE,CAE.[TimeLocal]) AS Datum
	  ,CAE.[TimeLocal]
	  ,CAE.InboundCallId
   FROM ICC.[dbo].[CallEvent] CAE
  LEFT JOIN ICC.[dbo].[CallEvent] CAE2 ON CAE.InboundCallId=CAE2.InboundCallId AND CAE2.EventType='Error'
  LEFT JOIN ICC.[dbo].[CallEvent] CAE3 ON CAE.InboundCallId=CAE3.InboundCallId 
    AND CAE.AgentId=CAE3.AgentId AND CAE3.EventType='AgentMissed'
  LEFT JOIN ICC.[dbo].[CallEvent] CAE4 ON CAE.InboundCallId=CAE4.InboundCallId 
    AND CAE4.ResultData='NormalRelease'
  LEFT JOIN ICC.[dbo].[InboundCall] IC ON CAE.InboundCallId=IC.InboundCallId

  WHERE 1=1
	AND CAE.EventType IN ('Distributing','Error') --and ResultData like 'Divert not arrived%'
    AND CAE.[TimeLocal]>@from
	AND (CAE2.InboundCallId IS NOT NULL OR CAE.WorkplaceId<>IC.WorkplaceId OR IC.WorkplaceId IS NULL)
	AND CAE3.InboundCallId IS NULL -- Nešlo o zmeškaný hovor
	AND CAE4.InboundCallId IS NULL -- Nešlo o hovor ukonèený zákazníkem
    AND CAE.InboundCallId IS NOT NULL -- Zatím jen pøíchozí hovory
	
) AS Phase1

LEFT JOIN (SELECT CONVERT(DATE,PilotTime) AS Datum,COUNT(1) AS InCall
	  FROM ICC.[dbo].[InboundCall] WITH (NOLOCK)  WHERE PilotTime>@from GROUP BY CONVERT(DATE,PilotTime)) AS InCalls
  ON Phase1.Datum=InCalls.Datum

GROUP BY Phase1.Datum,InCall
ORDER BY Phase1.Datum

