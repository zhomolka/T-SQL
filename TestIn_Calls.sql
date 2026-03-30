	 DECLARE @to AS datetime=convert(datetime, '2023.09.25 14:04')
	 DECLARE @from AS datetime=DATEADD(minute,-30,@to)
	 DECLARE @MAXanswertime AS datetime
	 DECLARE @MAXPilotTime AS datetime
	 DECLARE @SecondsWithoutAnswer AS Integer
	 DECLARE @NewNotAnswered AS Integer

    SELECT 
	     
	   @MAXPilotTime=MAXPilotTime
	   ,@MAXanswertime=MAXanswertime
       ,@SecondsWithoutAnswer=DATEDIFF(ss,ISNULL(MAXanswertime,@from),MAXPilotTime) 
	   ,@NewNotAnswered=(SELECT COUNT(1) FROM ICC.[dbo].[InboundCall] 
	   WHERE PilotTime>ISNULL(MAXanswertime,@from) AND PilotTime<@To AND AnswerTime IS NULL AND CallResult<>'Served'
	   ) 
	   FROM
 (SELECT TOP 100 
	   MAX(PilotTime) AS MAXPilotTime
	   ,MAX(answertime) AS MAXanswertime
   FROM ICC.[dbo].[InboundCall] IC   
  WHERE 1=1
    AND PilotTime>@from AND PilotTime<@To) AS Phase1

	 IF @SecondsWithoutAnswer > 300 AND @NewNotAnswered>2
	   SELECT CONVERT(NVARCHAR(5),@NewNotAnswered)+' not handled inbound Calls - error '+CONVERT(NVARCHAR(5),@SecondsWithoutAnswer)+' seconds'

	   SELECT TOP 100 
	    PilotTime
	   ,answertime
   FROM ICC.[dbo].[InboundCall] IC   
  WHERE 1=1
    AND PilotTime>@from AND PilotTime<@To
	ORDER BY PilotTime

	SELECT
	   @MAXPilotTime AS MAXPilotTime
	   ,@MAXanswertime AS MAXanswertime


	SELECT PilotTime,AnswerTime FROM ICC.[dbo].[InboundCall] 
	   WHERE PilotTime>ISNULL(@MAXanswertime,@from) AND PilotTime<@To AND AnswerTime IS NULL AND CallResult<>'Served' 