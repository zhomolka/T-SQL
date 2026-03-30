BEGIN TRANSACTION
UPDATE DataQueryColumn
SET TargetFormat='{0:dd.MM.yyyy HH:mm}', Width=85
WHERE Model LIKE 'Date%'
  AND TargetFormat='{0:dd.MM HH.mm}'
 COMMIT TRANSACTION

 --ROLLBACK TRANSACTION
