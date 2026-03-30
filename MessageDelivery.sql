USE [iCC]
GO

SELECT 
      ME.[TimeLocal] AS MessageEventTime
	  , M.[ReceivedSentTime] AS MessageReceiveTime
      ,[EventType]
      ,M.[MessageId]
      ,M.[AgentId]
      ,[ReferenceData]
      ,[ReferenceId]
      ,[Duration]
      ,[ResultData]
  FROM [dbo].[MessageEvent] AS ME
  LEFT OUTER JOIN Message AS M WITH(NOLOCK) ON ME.MessageId=M.MessageId
  WHERE ME.[TimeLocal]>M.[ReceivedSentTime]+0.04 AND M.Direction='I' AND ME.EventType='Received' AND ME.[TimeLocal] > GETDATE()-20
GO


