DECLARE @MessageId AS UniqueIdentifier = '86D61385-B37E-E611-AAD5-E634C1BF26E3'
BEGIN TRANSACTION
delete from Icc.dbo.Attachment where MessageId = @MessageId
delete from Icc.dbo.MessageEvent where MessageId =@MessageId
update ScenarioResult set MessageId = NULL where MessageId =@MessageId
update Message set RelatedMessageId = NULL where RelatedMessageId =@MessageId
delete from Message where MessageId  =@MessageId
--COMMIT TRANSACTION
ROLLBACK TRANSACTION
