USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[GetTotalLogonTime3]    Script Date: 06.06.2022 9:22:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:        Václav Kubát
-- Create date: 20191107
-- Description: Doba zalogování agenta od zvoleného dne @Day do @Now (včetně aktuálního stavu)
-- =============================================
CREATE FUNCTION [dbo].[GetTotalLogonTime3]
(
      @AgentId uniqueidentifier,
      @Day datetime,
      @Now datetime
)
RETURNS int
AS
BEGIN
      DECLARE @Result AS int
	  DECLARE @isLogon AS int = ISNULL((SELECT TOP (1) 0 [AgentId] FROM [iCC].[dbo].[Agent]
	                           WHERE Activity='LOGOFF' AND Agentid=@AgentId),1)
      -- ZbH 6.6.2022: Když je agent odhlášený, logon Time se mu nemá navyšovat
              select 
                      @Result = (Duration + IIF(@isLogon=1,DATEDIFF(SECOND,StartActual, @Now),0) )
              from 
                      (SELECT 
                             SUM(case when Duration is not null then Duration else 0 end) as Duration
                             ,MAX(case when Duration is null then TimeLocal end) as StartActual
                      FROM icc.dbo.AgentEvent WITH (NOLOCK) WHERE TimeLocal > @Day 
					  AND AgentId = @AgentId AND EventType = 'AgentStatus' AND ReferenceData <> 'LogOff' 
                      ) as CTE

       RETURN @Result

END
GO

