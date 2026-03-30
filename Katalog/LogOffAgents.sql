USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[LogOffAgents]    Script Date: 19.08.2022 11:53:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:        <Zbyněk Homolka / JaT>
-- Create date: <15.11.2018>
-- Description:   <Odhlašuje vsechny agenty>
-- =============================================
CREATE PROCEDURE [dbo].[LogOffAgents]
--@AgentId UniqueIdentifier
AS
BEGIN
 DECLARE @AgentId UniqueIdentifier 
 DECLARE My_cursor CURSOR FOR   
 SELECT AgentId FROM iCC.dbo.Agent WHERE Activity<>'Logoff'
   OPEN my_cursor 
  FETCH NEXT FROM My_cursor INTO @AgentId   
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @AgentId IS NOT NULL 
		BEGIN
		  EXEC [dbo].[LogOffAgent] @AgentId
		END
		FETCH NEXT FROM My_cursor INTO @AgentId  
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;
/*
IF EXISTS(SELECT 1 FROM iCC.dbo.Agent WHERE Activity<>'Logoff')
  BEGIN
    DECLARE @LogoffId UniqueIdentifier = (SELECT TOP 1 [StatusId] FROM [iCC].[dbo].[Status] WHERE Activity='Logoff')
    INSERT iCC.dbo.ChangeRequest( ChangeRequestTimeUtc , Command , SubjectId, ReferenceId)
    select GETUTCDATE(), N'AgentStatus', agentid, @LogoffId from iCC.dbo.Agent WHERE Activity<>'Logoff'
  END
*/
 END


GO

