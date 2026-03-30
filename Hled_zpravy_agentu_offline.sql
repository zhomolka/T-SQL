SELECT ReceivedSentTime,MessageId, MessageResult , MessagePhase, AcceptedTime, AG.DisplayName AS AgentName
FROM  [iCC].[dbo].[Message] ME WITH (NOLOCK) 
      INNER JOIN [iCC].[dbo].[Agent] AG  ON ME.AgentId=AG.AgentId
    WHERE 1=1
    AND MessageType ='Email' AND MessageResult='Active' 
   AND DIRECTION ='I' AND MessagePhase <> 'Canceled' and (spamlevel is null or spamlevel = 0)
   AND DATEDIFF(Day,ReceivedSentTime,GETDATE()) < 90 -- Zpráva je 30hodin nepøijata
   AND AcceptedTime IS NULL
   and GatewayId<>'656bb249-7e33-48d9-ad41-cca8bdacfefc'
   AND AG.StatusId='E8AD6B58-B5CC-478F-9BAE-D6C8D8DC1AAE'--Agent není v práci