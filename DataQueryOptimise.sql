 USE iCC_Test
 GO
 BEGIN TRANSACTION
UPDATE DQC
SET  Model = 'DateTimeUtc'
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Hovory' AND DQC.TargetColumn='TimeUtc'
COMMIT TRANSACTION

--ROLLBACK TRANSACTION
