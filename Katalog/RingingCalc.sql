USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[RingingCalc]    Script Date: 10/22/2020 1:01:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <22.10.2020>
-- Description:	<Počítá údaje o zvonění u agenta>
-- =============================================

CREATE FUNCTION [dbo].[RingingCalc] 
(	
	@From as datetime,
	@To as datetime,
	@AgentId as uniqueidentifier,
	@Request as VARCHAR(1)
	)
RETURNS REAL
AS
BEGIN
	DECLARE @Time as Datetime
    DECLARE @TimeRing as Datetime
	DECLARE @EventType as NVARCHAR(20)
	DECLARE @RingDuration as REAL = 0
	DECLARE @RingingCount as REAL = 0
    DECLARE @Number AS varchar(16)

DECLARE My_cursor CURSOR FOR   
 SELECT [TimeLocal],EventType  FROM [iCC].[dbo].[CallEvent] CAE
  WHERE  [TimeLocal]>@from AND TimeLocal < @To
    AND  EventType<>'Distributing' AND  EventType<>'IssueChange' AND  EventType<>'End'
    AND OutboundCallId IS  NULL
	AND AgentId IS NOT NULL
    AND AgentId = @AgentId

   OPEN my_cursor 
  FETCH NEXT FROM My_cursor INTO @Time,@EventType   
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @Time IS NOT NULL 
		BEGIN
		  IF @EventType='AgentRing'
		    BEGIN
			  SET @TimeRing=@Time
			  SET @RingingCount=@RingingCount+1
			END
          ELSE
		    BEGIN
			  IF @TimeRing IS NOT NULL
			    SET @RingDuration=@RingDuration+DATEDIFF(ss,@TimeRing,@Time)
	          SET @TimeRing=NULL
			END
		END
		FETCH NEXT FROM My_cursor INTO @Time,@EventType   
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;
  IF @Request='A' -- Average
    RETURN IIF(@RingingCount=0,0,@RingDuration/@RingingCount)
  IF @Request='C' -- RingingCount
    RETURN @RingingCount

  	RETURN @RingDuration
END
GO

