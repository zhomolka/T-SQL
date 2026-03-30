DECLARE @Id AS UNIQUEIDENTIFIER='22669630-84AA-49FC-9868-96DEE92E5B55'
 BEGIN TRANSACTION
UPDATE iCC.dbo.DataQuery
SET  QueryText = REPLACE(QueryText,'SELECT * From Attachment','SELECT TOP 1 ''X'' AS Nic From Attachment')
WHERE  QueryText LIKE '%SELECT * From Attachment%'
 -- AND DataQueryId='f2e2995f-40ad-4fdc-a3ee-27716a48a96b '

UPDATE iCC.dbo.DataQuery
SET  QueryText = REPLACE(QueryText,'ISNULL(M.BodyText, M.BodyHtml) as BodyField,','LEFT(ISNULL(M.BodyText, M.BodyHtml),100) as BodyField,')
WHERE  QueryText LIKE '%ISNULL(M.BodyText, M.BodyHtml) as BodyField,%'


COMMIT TRANSACTION

--ROLLBACK TRANSACTION
