DECLARE @AgentId AS UniqueIdentifier
SET @AgentId='76d92e82-b0b9-4869-a673-6a6497564296'
DECLARE @from AS datetime
DECLARE @to AS datetime
SET @from=GETDATE()-60
SET @to=GETDATE()
--SET @from=convert(datetime, '2016.03.07')
--SET @to=convert(datetime, '2016.03.07 20:05')

SELECT SR.TimeUtc  
      ,SRV.ScenarioResultId  
      ,[ResultNumber]
      ,[ResultText]
	  ,IIF(ICA.DisplayName IS NULL,'Odchozí','Pøíchozí') AS Smer
 	  ,AG.DisplayName AS Hodnotitel
	  ,IIF(ICA.DisplayName IS NULL,OCA.DisplayName,ICA.DisplayName) AS Hodnoceny
      ,SRV.TargetColumn
	  ,SCC.DisplayName
	  ,sr.activity
  FROM [dbo].[ScenarioResultValue] AS SRV
     LEFT JOIN ScenarioResult AS SR ON SRV.ScenarioResultId=SR.ScenarioResultId
	 LEFT JOIN ScreenControl AS SCC ON SRV.ScreenControlId=SCC.ScreenControlId
	 LEFT JOIN Agent AS AG ON SR.AgentId=AG.AgentId
     LEFT JOIN InboundCall as IC on SR.InboundCallId=IC.InboundCallId
     LEFT JOIN Agent as ICA on IC.AgentId=ICA.AgentId
     LEFT JOIN OutboundCall as OC on SR.OutboundCallId=OC.OutboundCallId
     LEFT JOIN Agent as OCA on OC.AgentId=OCA.AgentId
	 LEFT JOIN ScenarioCondition as SC on SR.ScenarioId=SC.ScenarioId
  WHERE SC.Channel LIKE 'Rating%' ORDER BY Hodnoceny,TimeUTC
  -- AND SR.TimeUtc>=@from AND SR.TimeUtc<=@to
  -- AND  sr.activity ='Completed' 
  -- SRV.TargetColumn LIKE 'Otazka%' AND SR.TimeUtc>@from 
  -- WHERE ScenarioResultId='21d476de-d8f2-41b6-a9ac-c8ed90467198'
  -- WHERE ResultTime>@from


--SELECT GETDATE()-30
/*
select distinct SR.TimeUtc, SR.Activity, SR.ScenarioResultId as RecordId,
SR.AgentId, A.DisplayName as RatingAgentName, 
SR.InboundCallId, ICA.DisplayName AS IcAgentName, 
SR.OutboundCallId, OCA.DisplayName AS OcAgentName,
SR.MessageId, MA.DisplayName AS MsgAgentName,
COALESCE(IC.PilotTime, OC.DistributionTime, M.ReceivedSentTime) AS CommTime, 
COALESCE(IC.CallDuration, OC.CallDuration, M.OpenDuration) AS Duration, 
COALESCE(IC.CallerNumber, OC.CallerNumber, M.RemoteAddress) AS Contact,
dbo.GetTargetColumnNumber(SR.ScenarioResultId,'HodnoceniAgentuCelkem') as Result
from ScenarioResult AS SR
left join ScenarioCondition as SC on SR.ScenarioId=SC.ScenarioId
left join Agent as A on SR.AgentId=A.AgentId
left join InboundCall as IC on SR.InboundCallId=IC.InboundCallId
left join Agent as ICA on IC.AgentId=ICA.AgentId
left join OutboundCall as OC on SR.OutboundCallId=OC.OutboundCallId
left join Agent as OCA on OC.AgentId=OCA.AgentId
left join Message as M on SR.MessageId=M.MessageId
left join Agent as MA on M.AgentId=MA.AgentId
where SC.Channel LIKE 'Rating%' AND SR.Activity <> 'CANCELED' AND (IC.AgentId=@MeAgentId OR OC.AgentId=@MeAgentId OR M.AgentId=@MeAgentId) and sr.activity ='Completed'
*/