--Kdyby se nekomu hodilo…v puvodni  „GetStateLength_2“ od Michala Pajgrta byla nejaka drobna chybka, ze mi to nepocitalo aktualni trvani stavu (pro nejakou situaci v CEZ…) a nepocitala s --24/7 provozem – kdyby byl nìkdo ready pøes pulnoc, vùbec by se to nezapoèítalo…



USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[GetTotalLogonTime_3]    Script Date: 08.01.2019 13:25:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:   Václav Kubát   
-- Create date: 8.1.2019
-- Description: Celkova doba, jak dlouho byl agent zalogovan. Zohlednuje aktualni zalogovani a i pokud byl agent s den startu pocitani online pres pulnoc
-- =============================================
CREATE FUNCTION [dbo].[GetTotalLogonTime_3]
(
      @AgentId uniqueidentifier,
      @Day datetime,
      @Now datetime
)
RETURNS int
AS
BEGIN
      DECLARE @Duration AS int
      
--declare @agentid as uniqueidentifier = '2AF80FEE-A5C5-41D0-9CAF-DC0646F340EA' --Dzurik

declare @Today_LastAgentEventTime as datetime = (SELECT MAX(TimeLocal) FROM icc.dbo.AgentEvent WITH (NOLOCK) WHERE  AgentId = @AgentId)
declare @Today_FirstAgentStatusTime as datetime = (SELECT MIN(TimeLocal) FROM icc.dbo.AgentEvent WITH (NOLOCK) WHERE  AgentId = @AgentId and CAST(TimeLocal AS DATE) = @Day)
declare @Day_LastAgentStatusTime as datetime
declare @Day_LastAgentStatus as nvarchar (30) 

       SELECT top 1 --zjisteni posledni statove aktivity agenta pred pulnoci od nastaveneho dne @Day
              @Day_LastAgentStatusTime = TimeLocal
              ,@Day_LastAgentStatus = ReferenceData 
       FROM icc.dbo.AgentEvent WITH (NOLOCK) 
       WHERE  AgentId = @AgentId and CAST(TimeLocal AS DATE) = dateadd(day,-1,@Day) and EventType = 'AgentStatus' 
       order by TimeUtc desc

declare @Duration_Actual as int = (SELECT ISNULL((DATEDIFF(SECOND, MAX(Timelocal), @Now)), 0) --trvani aktualniho stavu
                                                                FROM icc.dbo.AgentEvent WITH (NOLOCK) 
                                                                WHERE TimeLocal >= @Day AND AgentId = @AgentId AND Duration IS NULL AND EventType = 'AgentStatus' AND ReferenceData <> 'LogOff' AND TimeLocal = @Today_LastAgentEventTime)

declare @Duration_Other as int = (SELECT SUM(ISNULL(Duration,0)) --trvani stavu ode dne @Day po dnesek
                                                                FROM icc.dbo.AgentEvent WITH (NOLOCK) 
                                                                WHERE TimeLocal >= @Day AND AgentId = @AgentId AND EventType = 'AgentStatus' AND ReferenceData <> 'LogOff')

set @Duration = @Duration_Actual + @Duration_Other

if @Day_LastAgentStatus = 'Logoff' RETURN @Duration --pokud agent nebyl online pres pulnoc, hotovo
declare @Midnight as datetime = cast (@day as datetime)
declare @Duration_OverMidnight as int  = (select datediff(second,@Midnight,@Today_FirstAgentStatusTime)) --trvani aktivniho stavu od pulnoci do prvniho prvniho zapocitaneho stavu dne @Day

set @Duration = @Duration + @Duration_OverMidnight

      RETURN @Duration

END

GO



