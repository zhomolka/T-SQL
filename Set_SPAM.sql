DECLARE @Id AS UNIQUEIDENTIFIER='22669630-84AA-49FC-9868-96DEE92E5B55'
 BEGIN TRANSACTION

  UPDATE iCC.dbo.Message
SET  MessagePhase='Closed', MessageResult='Closed', EndTime='2019-07-12 15:54:41.930', SpamLevel=1
WHERE  MessagePhase='Received' AND MessageResult='Active' AND RemoteAddress='obchod@campdavidshop.cz'

COMMIT TRANSACTION

--ROLLBACK TRANSACTION

/*
 UPDATE iCC.dbo.Message
SET  MessagePhase='Canceled' 
WHERE  MessagePhase='Scheduled' AND MessageResult='Closed'

UPDATE iCC.dbo.Gateway
SET Direction = 'I'
WHERE  Deleted=0


*/