USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[GetTotalLogonTime2]    Script Date: 24.01.2023 15:36:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:        Michal Pajgrt     
-- Create date: 2012-05-23    
-- Description:  Upravil ZbH 
-- =============================================
CREATE FUNCTION [dbo].[GetTotalLogonTime2]
(
      @AgentId uniqueidentifier,
      @Day datetime,
      @Now datetime
)
RETURNS int
AS
BEGIN
      DECLARE @Result AS int
      
		select 
			@Result = (Duration + IIF((SELECT TOP (1) [Activity] FROM [iCC].[dbo].[Agent]
			WHERE AgentId=@AgentId)='LogOff',0,
			(DATEDIFF(SECOND,StartActual, @Now)) ))
		from 
			(SELECT 
				SUM(case when Duration is not null then Duration else 0 end) as Duration
				,MAX(case when Duration is null then TimeLocal end) as StartActual
			FROM icc.dbo.AgentEvent WITH (NOLOCK) WHERE TimeLocal > @Day AND AgentId = @AgentId 
			AND EventType = 'AgentStatus' AND ReferenceData <> 'LogOff' 
			) as CTE

	RETURN @Result

END


GO

