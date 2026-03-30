/****** Script for SelectTopNRows command from SSMS  ******/
USE iCC
GO
SELECT TOP (10000) [QueueId]
      ,QU.[TimeUtc]
      ,[ChannelIndex]
      ,[CommId]
      ,[CommState]
	  ,OC.Callresult AS OCCallresult
	  ,IC.Callresult AS ICCallresult
	  ,ME.Messageresult
	  ,CH.Chatresult
   FROM .[dbo].[Queue]  QU
    LEFT JOIN .[dbo].[InboundCall] IC ON QU.CommId=IC.InboundCallId
	LEFT JOIN .[dbo].[OutboundCall] OC ON QU.CommId=OC.OutboundCallId
	LEFT JOIN .[dbo].[Message] ME ON QU.CommId=ME.MessageId
	LEFT JOIN .[dbo].[Chat] CH ON QU.CommId=CH.ChatId
  WHERE 1=1
  --and CommState=20 -- Blocked
  AND ChannelIndex=9 /* Odchozí hovory*/ AND (OC.Callresult<>'Scheduled' OR OC.OutboundCallId IS NULL) OR
      ChannelIndex=0 /* Pøíchozí hovory*/ AND (IC.Callresult<>'Active'  OR IC.InboundCallId IS NULL) OR
      ChannelIndex IN (1,11) /* Emaily, Tasky*/ AND (ME.Messageresult<>'Active' OR ME.MessageId IS NULL) OR
      ChannelIndex IN (4,5,6,7,8) /* Chat*/ AND (CH.Chatresult<>'Active'  OR CH.ChatId IS NULL) --OR
  ORDER BY QU.Timeutc