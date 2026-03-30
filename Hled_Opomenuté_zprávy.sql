SELECT TOP 100 ReceivedSentTime,MessageId, MessageResult , MessagePhase FROM  [iCC].[dbo].[Message] WITH (NOLOCK)
    WHERE 1=1
   --AND ReceivedSentTime >= @FROM 
   --AND ReceivedSentTime <= @TO
   AND MessageType ='Email' AND MessageResult='Active'
   AND DIRECTION ='I' AND MessagePhase <> 'Canceled' and (spamlevel is null or spamlevel = 0)
   AND DATEDIFF(Hour,ReceivedSentTime,GETDATE()) > 30 -- Zpráva je 30hodin nepøijata
   AND AcceptedTime IS NULL
   and GatewayId<>'656bb249-7e33-48d9-ad41-cca8bdacfefc'
  ORDER BY ReceivedSentTime DESC