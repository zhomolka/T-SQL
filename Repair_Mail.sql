DECLARE @Id AS UNIQUEIDENTIFIER='22669630-84AA-49FC-9868-96DEE92E5B55'
 BEGIN TRANSACTION
UPDATE iCC.dbo.Message
--SET  Emails = 'maeve.osullivan02@bbc.co.uk'
SET  RemoteAddress = 'petra@agenturamachackova.cz',Tofield = 'petra <petra@agenturamachackova.cz>',MessagePhase='Scheduled',
  ExtendedFields='{"ToField":[{"DisplayName":"petra","Email":"petra@agenturamachackova.cz"}],"ToCcField":[],"ToBccField":[],"ToNumbers":null}'
WHERE  1=1
-- AND (PhoneNumberId = '766557E2-FCA6-4E9F-9C70-E7BB401AAAA0'
AND  (messageId = '1d06fa97-c8c0-e811-90f1-005056925807')
--AND Deleted=1

COMMIT TRANSACTION

--ROLLBACK TRANSACTION
