--USE Frontstage_Synlab
--GO
SELECT TOP 5 
  1 AS Akce, 
  C.InboundCallId, C.TimeUtc, C.CallPhase, C.CallResult, C.CallerNumber, C.IssueId,
  C.ProjectId, C.LanguageId, C.AgentId, C.WorkplaceId,
  C.CallDuration, C.PilotTime, PIL.DisplayName AS PilotName, C.ChainingId,
  P.DisplayName AS ProjectName, A.DisplayName AS AgentName, L.DisplayName AS LanguageName, W.DisplayName AS WorkplaceName,
  --CAST(CASE WHEN CallResult='Active' THEN 1 ELSE 0 END AS bit) AS IsActive,
  --CAST(CASE WHEN CallResult='Lost' THEN 1 ELSE 0 END AS bit) AS IsLost,
  S.DisplayName as Afterwork,
  --X.agreementid as Smlouva,
  --X.Notice as Poznamka,
  --CAST(CASE WHEN X.Souhlas='1' THEN 'YES' ELSE 'NO' END AS nvarchar(3)) as Souhlas,
  T.DisplayName as Téma, S.DisplayName as Podtéma
  ,Redirector
  ,CASE WHEN CR.InboundCallId IS NULL THEN 'NO' ELSE 'YES' END AS ExNahravka
  FROM InboundCall AS C  WITH (NOLOCK)
  LEFT JOIN Project AS P WITH (NOLOCK) ON C.ProjectId=P.ProjectId
  LEFT JOIN Agent AS A WITH (NOLOCK)ON C.AgentId=A.AgentId
  LEFT JOIN Language AS L WITH (NOLOCK) ON C.LanguageId=L.LanguageId
  LEFT JOIN Workplace AS W WITH (NOLOCK) ON C.WorkplaceId=W.WorkplaceId
  LEFT JOIN Issue AS I WITH (NOLOCK) ON C.IssueId=I.IssueId
  --LEFT JOIN IssueExtra AS X ON C.IssueId=X.IssueId
  LEFT JOIN Topic AS T WITH (NOLOCK) ON T.TopicId=I.TopicId
  LEFT JOIN SubTopic AS S WITH (NOLOCK) ON S.SubTopicId=I.SubTopicId
  LEFT JOIN Pilot AS PIL WITH (NOLOCK) ON PIL.PilotId=C.PilotId
  LEFT JOIN CallRecord AS CR WITH (NOLOCK) ON CR.InboundCallId=C.InboundCallId
  WHERE 1=1
  --AND Callernumber='0724610047'
  ORDER BY TIMEUTC DESC
--------------------
/**/
SELECT 
CAE.InboundCallId,
 TimeLocal
, EventType 
, IVRST.Rank AS Navesti
, IVRST.Action AS Akce
, IVRST.DisplayName AS Ivrkrok
, IVRST.FileName AS Hlaska
, IVRSC.DisplayName AS IvrSkript
, PR.DisplayName AS ProjectName 
, AG.DisplayName AS AgentName 
, WP.DisplayName AS WorkPlaceName 
, ReferenceData 
, Duration 
, ResultData
, IC.CallerNumber 
FROM .dbo.CallEvent AS CAE WITH (NOLOCK)
LEFT JOIN IvrStep AS IVRST  WITH (NOLOCK)ON IVRST.IvrStepId=CAE.ReferenceId
LEFT JOIN IvrScript AS IVRSC  WITH (NOLOCK) ON IVRST.IvrScriptId=IVRSC.IvrScriptId
LEFT JOIN InboundCall AS IC  WITH (NOLOCK) ON IC.InboundCallId=CAE.InboundCallId
LEFT JOIN Project AS PR  WITH (NOLOCK) ON PR.ProjectId=CAE.ProjectId
LEFT JOIN Agent AS AG  WITH (NOLOCK) ON AG.AgentId=CAE.AgentId
LEFT JOIN Workplace AS WP  WITH (NOLOCK) ON WP.WorkPlaceId=CAE.WorkPlaceId
WHERE  /*CAE.TimeUTC>DATEADD(Month,-1,@today) AND*/
 CAE.InboundCallId='ED2A23B7-009C-ED11-9D7A-000D3ABA80CB' 
  
