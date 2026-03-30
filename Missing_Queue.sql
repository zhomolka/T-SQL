/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @from AS datetime = convert(datetime, '2019.11.05 06:00')
DECLARE @to AS datetime = convert(datetime, '2019.11.16 11:00')
DECLARE @ScheduleTime AS date = convert(datetime, '2019.11.13')
DECLARE @AgentId AS UniqueIdentifier = 'ddbc22e5-af73-4387-a5f4-77cd11740afe' -- Paní Balážová
--SET @AgentId  = '063d1446-911a-4121-b8f6-3dfb82fa41c1' 
DECLARE @LastTime AS bit=1

IF @LastTime=1
 BEGIN
    SET @from=DATEADD(Day,-20,GETDATE())
    SET @to=GETDATE()
  END

SELECT TOP 10000 [OutboundCallId]
      ,ScheduleTime
	  ,Predistributed
	  --,FS_Custom.dbo.TimeUTC_Local(TimeUTC) AS TimeUTC_Loc
     -- ,[DisplayName]
	        ,[OutboundListImportId]
      ,[CallDuration] 
	  ,[AnswerTime]
	  ,[EndTime] 
      ,DateDiff(ss,AnswerTime,EndTime) AS TeorDuration
	        ,[ChainingId]
			,PredictorUsed
     ,[TimeFrom]
      ,[TimeTo]
      ,[EnqueueingTime]
      ,[ScheduleTime]      
      ,[DistributionTime]
  , DATEDIFF(MINUTE,ScheduleTime,ISNULL(DistributionTime,GETDATE())) AS Delay
        ,[CallerNumber]

      ,[RegionalTime]
      ,[RingDuration]    
      ,OC.[TimeUtc]
      ,[CallType]
      ,[CallPhase]
      ,[CallResult]
      ,[AppResult]
      ,[PbxCallId]

      --,[OutboundListId]

      ,[PhoneNumberId]
      ,[ContactId]
      --,[ProjectId]
      ,[PreferredAgentId]

      ,[GroupNumber]
      ,[TimeMode]
      ,[AppResultTime]
      ,[PostCallEndTime]
      ,[Trial]
      ,[TeamName]
      ,[Predistributed]
      ,[WorkplaceId]
      ,[Correlation]
 
      ,[HoldDuration]
      ,[PcpWrapDuration]
      ,[IssueId]
      ,[ConditionLevel]
      ,[Mark]
      ,[IvrScriptAId]
      ,[IvrScriptATime]
      ,[IvrResponseA]
      ,[TransferredTo]
      ,[DialTime]
      ,[CallResultDetailId]
      ,[ExtendedFields]
  FROM [iCC].[dbo].[OutboundCall] OC
   LEFT JOIN [iCC].[dbo].[OutboundList] OL ON OL.OutboundListid=OC.OutboundListid
   LEFT JOIN [iCC].[dbo].[Queue] QU ON QU.Commid=OC.OutboundCallid
  WHERE 1=1
    AND CallResult='Scheduled'
	and CallPhase<>'Active'
	AND QU.Commid IS NULL
	AND OC.PredictorUsed=0
	AND OL.PredictorId IS NULL
  --AND DateADD(SS,1,ScheduleTime)<FS_Custom.dbo.TimeUTC_Local(TimeUTC)
    --AND DateDiff(ss,AnswerTime,EndTime)>0 AND CallDuration=0
	--AND DistributionTime>@from
	--AND ProjectId='AC0E05A8-2B5F-4BE5-8D4A-0F2F755A5F49'
	--AND TimeUTC>@from
	--AND PbxCallId='000000000016909310021396'
  -- AND CallerNumber IS NOT NULL
  --AND CallerNumber LIKE '00905142149%'
   --AND RegionalTime>@from AND RegionalTime<@To
   --AND AgentId=@AgentId
	--AND Priority=100
	--AND Predistributed=1
	--AND CONVERT(Date,ScheduleTime)=@ScheduleTime
  --OR TimeUTC>GETDATE()-0.2
  --AND OutboundCallId IN ('6de8d594-97dc-ee11-b810-005056a0e001','482987b5-0ef8-ea11-b7f7-005056a0e001','3d2987b5-0ef8-ea11-b7f7-005056a0e001','322987b5-0ef8-ea11-b7f7-005056a0e001')
 --AND ChainingId ='01c9963f-b9ee-ea11-b7f7-005056a0e001'
  
  --AND TimeUTC>GETDATE()-5
    --AND DATEDIFF(MINUTE,ScheduleTime,ISNULL(DistributionTime,GETDATE()))>10
  
  ORDER BY TimeUTC