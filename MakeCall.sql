USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[MakeCall]    Script Date: 27. 8. 2019 12:42:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <23.8.2019>
-- Description:	<Vytáčí hovor na základě PhoneNumberId>
-- =============================================

ALTER PROCEDURE [dbo].[MakeCall] (
@PhoneNumberId as UniqueIdentifier,
@AgentId as UniqueIdentifier
)
AS
BEGIN
 DECLARE @OutboundCallId as UniqueIdentifier = NewId()
 DECLARE @ProjectId as UniqueIdentifier = '27c9e01a-ec7c-4fb8-a503-9bf7522ba8ab' -- Ad-Hhoc hovor
 DECLARE @WorkplaceId as UniqueIdentifier = (SELECT TOP 1 WorkplaceId FROM iCC.[dbo].[Agent] WHERE AgentId=@AgentId )
 DECLARE @TeamName as NVARCHAR(50) = (SELECT TOP 1 TeamName FROM iCC.[dbo].[Agent] WHERE AgentId=@AgentId )
 DECLARE @CallerNumber as NVARCHAR(50) = (SELECT TOP 1 Numbers FROM iCC.[dbo].[PhoneNumber] WHERE PhoneNumberId=@PhoneNumberId )
 SET @CallerNumber=IIF(SUBSTRING(@CallerNumber,1,1)='0','','0')+@CallerNumber

-- Založení nového odchozího hovoru

INSERT INTO iCC.[dbo].[OutboundCall]
           (OutboundCallId
		   ,OutboundListId
           ,[TimeUtc]
           ,CallType
           ,[CallPhase]
           ,[CallResult]
		   ,CallerNumber
		   ,[DisplayName]
		   ,PhoneNumberId
           ,[ProjectId]
           ,[AgentId]
           --,[WorkplaceId]
           ,RegionalTime
		   ,ScheduleTime
		   ,[TeamName]
		   ,Predistributed
		   ,Skill
		   ,Priority
		   ,TimeMode,TimeFrom,TimeTo)
     VALUES
           (@OutboundCallId
		   ,'dbed5018-1ed8-4d00-a26a-2cdd4ecf73f1'
		   ,GETUTCDATE()
           ,'DialOut'
		   ,'Enqueue'
		   ,'Scheduled'
		   ,@CallerNumber
		   ,'Ad-Hoc hovor z kontaktu'
		   ,@PhoneNumberId
           ,@ProjectId
           ,@AgentId
           --,@WorkplaceId
		    ,GETDATE()
		    ,GETDATE()
			,@TeamName
			,1,0,100
			,'SingleDay',GETDATE(),DATEADD(Minute,20,GETDATE()))
/*
INSERT INTO iCC.[dbo].[CallEvent]
           (
           [TimeUtc]
           ,[TimeLocal]
           ,[EventType]
           ,[OutboundCallId]
           ,[ProjectId]
           ,[AgentId]
           --,[WorkplaceId]
           ,[ReferenceData]
           ,[ActorId])
     VALUES
           (GETUTCDATE()
           ,GETDATE()
           ,'NewCall'
           ,@OutboundCallId
           ,@ProjectId
           ,@AgentId
           --,@WorkplaceId
           ,'ParamCall'
           ,@AgentId)

*/
/*
INSERT FS_Custom.dbo.[IDs] (ID)
 VALUES(@AgentId)
*/
  
END

GO

