USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[LogTime]    Script Date: 02/13/2018 08:36:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <6.2.2017>
-- Description:	<Délka zalogování agenta v zadaném časovém úseku>
-- =============================================

CREATE FUNCTION [dbo].[LogTime](@AgentId as UNIQUEIdentifier, @From as Datetime, @To as Datetime)
RETURNS Integer
AS
BEGIN	 
    -- Posbírám všechny Duration v mém rozsahu - musím však oseknout čas, který přesahuje mimo zadaný interval
	DECLARE @LogTimeAg as int = ISNULL((SELECT SUM(Duration-(CASE WHEN DATEADD(second,Duration,TimeLocal)>@To THEN DATEDIFF(second,@to,DATEADD(second,Duration,TimeLocal)) ELSE 0 END )) 
	/*(SELECT Duration-(CASE WHEN DATEADD(second,Duration,TimeLocal)>@To THEN DATEDIFF(second,@to,DATEADD(second,Duration,TimeLocal)) ELSE 0 END ) AS Duration1*/
	 FROM iCC.dbo.AgentEvent AE WITH (NOLOCK) 
	  WHERE AE.TimeLocal >= @From AND AE.TimeLocal < @To  AND AgentId=@AgentId
	 	   AND EventType='AgentStatus' AND ReferenceData <> 'Logoff' and Actor <> 'Reset'
	 	   AND ReferenceId NOT IN ('BD64797A-EA0F-4E42-93D5-568FBF9F4909','AE91D094-BF7C-4872-93C4-980032AE72BC','92947E64-4AA4-4BBD-8622-E237CDAF3210')),0)
	   /*) AS Durations)*/
	-- Ještě se musím podívat, zda nepřesáhla nějaká aktivita operátora do zadaného časového intervalu
	DECLARE @Today AS Date = GETDATE()
	DECLARE @Duration as Int = (SELECT TOP 1 Duration-DATEDIFF(second,TimeLocal,@From) FROM iCC.dbo.AgentEvent AE WITH (NOLOCK) 
	  WHERE AE.TimeLocal >= @Today AND AE.TimeLocal < @From  AND AgentId=@AgentId AND DATEADD(second,Duration,AE.TimeLocal)>@From
	 	   AND EventType='AgentStatus' AND ReferenceData <> 'Logoff' and Actor <> 'Reset'
	 	   AND ReferenceId NOT IN ('BD64797A-EA0F-4E42-93D5-568FBF9F4909','AE91D094-BF7C-4872-93C4-980032AE72BC','92947E64-4AA4-4BBD-8622-E237CDAF3210')
	 	   ORDER BY TimeLocal DESC)
	IF @Duration IS NOT NULL
	    SET @LogTimeAg = @LogTimeAg+@Duration
   /*
	DECLARE  @AEiD as UniqueIdentifier = (SELECT TOP 1 AgentEventId FROM iCC.dbo.AgentEvent AE WITH (NOLOCK) 
	  WHERE AE.TimeLocal >= @Today AND AE.TimeLocal < @From  AND AgentId=@AgentId AND DATEADD(second,Duration,AE.TimeLocal)>@From
	 	   AND EventType='AgentStatus' AND ReferenceData <> 'Logoff' and Actor <> 'Reset'
	 	   ORDER BY TimeLocal DESC)
	IF @AEiD IS NOT NULL
	  BEGIN
	  	DECLARE  @StartTime as Datetime = (SELECT TimeLocal FROM iCC.dbo.AgentEvent AE WITH (NOLOCK) WHERE AgentEventId=@AEiD)
	    --DECLARE  @Duration as Integer = (SELECT Duration FROM iCC.dbo.AgentEvent AE WITH (NOLOCK) WHERE AgentEventId=@AEiD)
	    SET @LogTimeAg = @LogTimeAg+/*@Duration-*/DATEDIFF(second,@StartTime,@From) 
	  END	 */  
	RETURN @LogTimeAg 
END


GO

