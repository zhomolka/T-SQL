:r C:\\Atlantis\\Scripts\\setvar.txt
USE $(iCC)
GO
DECLARE @Workplace AS VARCHAR(24) = '4218'
DECLARE @RepeatCount AS Integer=3

DECLARE @WPState AS NVARCHAR(20)
DECLARE @WorkplaceId AS UniqueIdentifier 

SELECT TOP 1 @WorkplaceId=WorkplaceId,@WPState=State FROM .dbo.Workplace WHERE Number = @Workplace AND Deleted=0


--SELECT @WorkplaceId

-- Naètení od obsluhy
--accept l_dept number format '99' prompt 'Department #: '
IF @WorkplaceId IS NULL
  BEGIN
    SELECT 'Workplace '+@Workplace+' does not exist' AS Report
    RETURN
  END

IF @WPState='Free'
 SELECT 'Workplace has status= '+@WPState AS Report

WHILE @WPState<>'Free' AND @RepeatCount>0
  BEGIN

    SET @RepeatCount=@RepeatCount-1
	SELECT 'I am repairing Workplace '+@Workplace+' - I am waiting 50 seconds' AS Report
	--PRINT 'Provádím nápravu pracovištì '+@Workplace+' - èekám 30sekund.'
	WAITFOR DELAY '00:00:01'
	RAISERROR('',10,1) WITH NOWAIT

	BEGIN Transaction
	UPDATE [dbo].[Workplace] SET Deleted=1 WHERE WorkplaceId=@WorkplaceId
	COMMIT TRANSACTION

	WAITFOR DELAY '00:00:50'
	BEGIN Transaction
	UPDATE [dbo].[Workplace] SET Deleted=0 WHERE WorkplaceId=@WorkplaceId
	COMMIT TRANSACTION
	SELECT 'I am waiting 30 seconds for ServiceSync' AS Report
	WAITFOR DELAY '00:00:30'
	SET @WPState =(SELECT State FROM Workplace WHERE WorkplaceId=@WorkplaceId)
	IF @WPState<>'Free' UPDATE [dbo].[Agent] SET WorkplaceId=NULL WHERE WorkplaceId =  @WorkplaceId

	SELECT 'Workplace has status= '+@WPState AS Report

  END
GO
