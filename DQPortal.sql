DECLARE @Id AS UNIQUEIDENTIFIER='22669630-84AA-49FC-9868-96DEE92E5B55'
 BEGIN TRANSACTION

UPDATE iCC.dbo.DataQueryColumn
SET  CSS = 'warning', Model='Color'
WHERE  Model='bold' AND EXISTS(SELECT Deleted FROM iCC.dbo.DataQuery DQ WHERE  DQ.DataQueryId=DataQueryColumn.DataQueryId AND DisplayName LIKE '%Portal%')

UPDATE iCC.dbo.DataQueryColumn
SET  CSS = 'danger'
WHERE  Model='color' AND TargetColumn='IsLate' AND EXISTS(SELECT Deleted FROM iCC.dbo.DataQuery DQ WHERE  DQ.DataQueryId=DataQueryColumn.DataQueryId AND DisplayName LIKE '%Portal%')

UPDATE iCC.dbo.DataQueryColumn
SET  UrlFormat = '/ReactClient/Pages/InCallEditor.html?Id={0}'
WHERE  UrlFormat='~/Pages/Calls/DispFormPlusIn.aspx?Id={0}' AND EXISTS(SELECT Deleted FROM iCC.dbo.DataQuery DQ WHERE  DQ.DataQueryId=DataQueryColumn.DataQueryId AND DisplayName LIKE '%Portal%')


DELETE FROM iCC.dbo.DataQueryColumn
WHERE Width=1 AND EXISTS(SELECT Deleted FROM iCC.dbo.DataQuery DQ WHERE  DQ.DataQueryId=DataQueryColumn.DataQueryId AND DisplayName LIKE '%Portal%') AND Deleted=0



COMMIT TRANSACTION

--ROLLBACK TRANSACTION
