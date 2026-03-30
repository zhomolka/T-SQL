SELECT SUM(Logon) AS Logon, SUM(NotReady) AS NotReady, SUM(IsBusy) AS IsBusy, SUM(PostCall) AS PostCall, SUM(Ready) AS Ready, SUM(IVR) AS IVR, SUM(Waiting) AS Waiting, 
	CAST(CASE WHEN SUM(Waiting) > 0 THEN 1 ELSE 0 END AS BIT) AS QueueNotEmpty,
	(CASE WHEN SUM(Waiting) > 0 THEN 'dqWB1Red' ELSE 'dqWB1Normal' END)  AS QueueNotEmptyStyle

 FROM
	(SELECT  
		ISNULL(SUM( CASE WHEN AG.Activity<> 'Logoff'  THEN 1 ELSE 0 END),0) AS Logon,
		ISNULL(SUM( CASE WHEN AG.Activity= 'Pause'  THEN 1 ELSE 0 END),0) AS NotReady,
		ISNULL(SUM( CASE WHEN W.State = 'Busy' THEN 1 ELSE 0 END),0) AS IsBusy,
		ISNULL(SUM( CASE WHEN AG.Activity='PostCall' THEN 1 ELSE 0 END),0) AS PostCall,
		--ISNULL(SUM( CASE WHEN AG.Activity<> 'Logoff'  THEN 1 ELSE 0 END) 
			--- SUM( CASE WHEN W.State = 'Busy' THEN 1 ELSE 0 END) 
			--- SUM( CASE WHEN AG.Activity<> 'Logoff' AND AG.StatusId = '2506d0dc-8df8-40ff-9ab2-20e68878e9ef' THEN 1 ELSE 0 END) --prestavka
			--- SUM( CASE WHEN AG.Activity<> 'Logoff' AND AG.StatusId = '40b6e59b-fc0e-49a9-811a-8fba855697c0' THEN 1 ELSE 0 END) --obed
			--- SUM( CASE WHEN AG.Activity<> 'Logoff' AND AG.StatusId = 'bd64797a-ea0f-4e42-93d5-568fbf9f4909' THEN 1 ELSE 0 END) --skoleni
			--- SUM( CASE WHEN AG.Activity<> 'Logoff' AND AG.StatusId = 'ae91d094-bf7c-4872-93c4-980032ae72bc' THEN 1 ELSE 0 END) --email
		ISNULL(SUM( CASE WHEN AG.Activity='Ready' AND W.State='Free' AND W.Offer = 'None' THEN 1 ELSE 0 END)
			,0) AS Ready,
		0 AS IVR,
		0 AS Waiting
	FROM Agent as AG WITH (NOLOCK) 
		LEFT JOIN Workplace AS W WITH (NOLOCK) ON AG.WorkplaceId = W.WorkplaceId
	where AG.Deleted = 0 AND AG.Template=0 
UNION
	Select  
		0,
		0,
		0,
        0,
		0,
		ISNULL(SUM( CASE WHEN C.CallPhase='Pilot' OR C.CallPhase='IvrScriptA' THEN 1 ELSE 0 END),0) AS IVR,
		ISNULL(SUM( CASE WHEN C.CallPhase='Enqueued' OR C.CallPhase='WaitingQueue' THEN 1 ELSE 0 END),0) AS Waiting	
	FROM InboundCall as C WITH (NOLOCK) 
		LEFT JOIN Project AS P WITH (NOLOCK)  ON C.ProjectId=P.ProjectId 
	WHERE C.CallResult='Active'	) AS A