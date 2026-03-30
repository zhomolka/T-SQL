USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[RepairDuration]    Script Date: 30. 9. 2016 15:13:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 30.09.2016
-- Description:	Náprava Duration v AgentEvent
-- Pokud je Druration Null, GetStateLength počítá trvání od Timelocal až do GETDATE()
-- =============================================
CREATE PROCEDURE [dbo].[RepairDuration]
--(
	--@Status as NVARCHAR(10)
	--@CallerNumber as NVARCHAR(50)
--)
	
AS
BEGIN
--drop table #TEMP1
DECLARE @FROM AS DATE = GETDATE()-2
SELECT AgentEventId,DATEDIFF(SECOND, TimeLocal, NextEventTime) AS MyDuration INTO #TEMP1
 FROM
 (SELECT  
 (SELECT TOP 1 TimeLocal FROM iCC.dbo.AgentEvent AE2  WITH (NOLOCK) WHERE AE2.AgentId=AE.AgentId AND AE2.TimeLocal>AE.TimeLocal ORDER BY AE2.TimeLocal ASC) AS NextEventTime
 , AgentEventId,TimeLocal 
 FROM iCC.dbo.AgentEvent AE WITH (NOLOCK)
 WHERE EventType = 'AgentStatus'  AND Duration IS NULL AND TimeLocal >= @FROM -- AND ST.DisplayName LIKE 'Aktivní%'
 ) AS FirstTable

 --SELECT * FROM #TEMP1
 BEGIN TRANSACTION
UPDATE iCC.dbo.AgentEvent  SET Duration=(SELECT MyDuration FROM #TEMP1 WHERE iCC.dbo.AgentEvent.AgentEventId=#TEMP1.AgentEventId)
WHERE EventType = 'AgentStatus' AND Duration IS NULL AND TimeLocal >= @FROM
COMMIT TRANSACTION
--ROLLBACK TRANSACTION
drop table #TEMP1 
END

GO

