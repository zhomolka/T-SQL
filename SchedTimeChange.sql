USE iCC_D
GO
 DECLARE @from AS datetime 
    SET @from=DATEADD(Day,-2,GETDATE())

    DECLARE @OutboundCallId UniqueIdentifier
    DECLARE @ScheduleTime Datetime = DATEADD(Minute,10,GETDATE())     

    DECLARE MyCursor CURSOR FOR
     SELECT  TOP 2000 OutboundCallId --,ScheduleTime
      FROM .[dbo].[OutboundCall]
  WHERE 1=1
   AND CallPhase='Enqueue'
   AND Projectid='5F73AF64-475A-479B-B381-EEF5412B093A'
   AND CallResult='Scheduled'

 AND TimeUTC>@from
    OPEN MyCursor

    FETCH NEXT FROM MyCursor INTO @OutboundCallId
    WHILE @@FETCH_STATUS = 0 
    BEGIN       
      FETCH NEXT FROM MyCursor INTO @OutboundCallId
	    SET @ScheduleTime=DATEADD(Minute,1,@ScheduleTime)
        UPDATE .[dbo].[OutboundCall]
          SET  ScheduleTime=@ScheduleTime
        WHERE OutboundCallid=@OutboundCallid

    END
    CLOSE MyCursor
    DEALLOCATE MyCursor  
