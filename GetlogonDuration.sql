USE [FS_CUSTOM]
GO

/****** Object:  UserDefinedFunction [dbo].[GetLogonDuration]    Script Date: 5.10.2017 11:45:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- 5.10.2017 Opravil ZbH
ALTER FUNCTION [dbo].[GetLogonDuration]
(
      @AgentId uniqueidentifier,
      @From datetime, -- POZOR ! Pracuje jen pro hranice dnů !
      @To datetime
)
RETURNS int
AS
BEGIN
    DECLARE @Result1 AS int
	DECLARE @Result2 AS int = 0
	DECLARE @MaxTimeON AS DateTime
	DECLARE @MaxTimeOFF AS DateTime
	SET @Result1 = 
	  ISNULL( (SELECT SUM(Duration) FROM iCC.dbo.AgentEvent WITH (NOLOCK)
	   WHERE @From<=TimeLocal
	    AND TimeLocal<@To
		 AND AgentId = @AgentId
		  AND EventType = 'AgentStatus'
		   AND ReferenceData <> 'LogOff'), 0) 
  -- Ještě si zjistím, zda nemám připočítat aktuální stav, kde není Duration ještě vypočítáno
    SET @MaxTimeON = (SELECT MAX(TimeLocal) FROM icc.dbo.AgentEvent WITH (NOLOCK) WHERE  AgentId = @AgentId AND EventType = 'AgentStatus'
		   AND ReferenceData <> 'LogOff' AND Duration IS NULL)
    IF @MaxTimeON IS NOT NULL
	  BEGIN
		SET @MaxTimeOFF = (SELECT MAX(TimeLocal) FROM icc.dbo.AgentEvent WITH (NOLOCK) WHERE  AgentId = @AgentId AND EventType = 'AgentStatus'
			   AND ReferenceData = 'LogOff' )
		IF @MaxTimeON>@MaxTimeOFF AND @MaxTimeON<@To-- Agent je přihlášen a konec intervalu je vyšší než aktuální stav
		   SET @Result2 = ISNULL(DATEDIFF(SECOND,@MaxTimeON, IIF(GETDATE()>@To,@To,GETDATE())),0)
	  END
    RETURN @Result1+@Result2

/* Původní chybná verze:
    DECLARE @Result AS int
	SET @Result = 
	  ISNULL( (SELECT SUM(Duration) FROM iCC.dbo.AgentEvent WITH (NOLOCK) WHERE @From<=TimeLocal AND TimeLocal<@To AND AgentId = @AgentId AND EventType = 'AgentStatus' AND ReferenceData <> 'LogOff'), 0) +
	  ISNULL( (SELECT TOP 1 DATEDIFF(SECOND, Timelocal, @To) FROM iCC.dbo.AgentEvent WITH (NOLOCK) WHERE @From<=TimeLocal AND TimeLocal<@To  AND AgentId = @AgentId AND Duration IS NULL AND EventType = 'AgentStatus' AND ReferenceData <> 'LogOff' ORDER BY TimeLocal DESC), 0)
    RETURN @Result
	*/
END
