 DECLARE @SystemNameOld AS NVARCHAR(100) = 'martina.janockova'
 DECLARE @SystemNameNew AS NVARCHAR(100) = 'martina.simeckova'
 DECLARE @DisplayNameNew AS NVARCHAR(100) = 'martina.simeckova'

 BEGIN TRANSACTION

    UPDATE iCC.dbo.Agent
SET  DisplayName=@DisplayNameNew,SystemName=REPLACE(SystemName,@SystemNameOld,@SystemNameNew)
where SystemName like '%'+@SystemNameOld+'%'

   UPDATE SREC.dbo.Account
SET  DisplayName=@DisplayNameNew,SystemName=REPLACE(SystemName,@SystemNameOld,@SystemNameNew)
where SystemName like '%'+@SystemNameOld+'%'


   UPDATE ProServer.dbo.Agent
SET  DisplayName=@DisplayNameNew,SystemName=REPLACE(SystemName,@SystemNameOld,@SystemNameNew)
where SystemName like '%'+@SystemNameOld+'%'
 
   UPDATE ProServer.dbo.Credentials
SET   SystemName=REPLACE(SystemName,@SystemNameOld,@SystemNameNew)
where SystemName like '%'+@SystemNameOld+'%'

   UPDATE ProServer.dbo.DataItem
SET   DataValue=REPLACE(DataValue,@SystemNameOld,@SystemNameNew)
where DataValue like '%'+@SystemNameOld+'%'

--------------------------------------------------------------------
 


COMMIT TRANSACTION
--ROLLBACK TRANSACTION
 