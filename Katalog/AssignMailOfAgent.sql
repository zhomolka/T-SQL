USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[AssignMailOfAgent]    Script Date: 11.5.2020 14:25:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <5.02.2020>
-- Description:	<Přidělení mailů určenému agentovi>
-- Zpracováno na základě ticketu Homecredit -nacenění úpravy přiřazování mailů
-- Popis projektu musí obsahovat klíčovou slabiku 'PA', aby bylo přidělení uskutečněno
-- =============================================
CREATE PROCEDURE [dbo].[AssignMailOfAgent]
 @MessageId uniqueidentifier,
 @AgentId uniqueidentifier
AS
BEGIN
DECLARE @MessageId2 uniqueidentifier
DECLARE @ProjectId uniqueidentifier
DECLARE @IssueId uniqueidentifier
declare @TeamName nvarchar(30) =(select  TOP 1 TeamName from icc.dbo.Agent where agentid=@AgentId)
DECLARE @SubjectField AS nvarchar(320) = (SELECT TOP 1 SubjectField from iCC.dbo.message WITH (NOLOCK) where messageid =@MessageId)
DECLARE My_cursor CURSOR FOR   
 SELECT MessageId,ME.ProjectId,IssueId  FROM iCC.[dbo].[Message] ME WITH (NOLOCK) 
   INNER JOIN iCC.[dbo].[Project] PR WITH (NOLOCK)  ON ME.ProjectId=PR.ProjectId AND Description like '%PA%'
 WHERE SubjectField=@SubjectField AND MessagePhase='Received' AND MessageId<>@MessageId
  AND /*(agentid is null) and*/ MessageResult='Active' and Direction='I'

   OPEN my_cursor 
  FETCH NEXT FROM My_cursor INTO @MessageId2,@ProjectId,@IssueId   
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @MessageId2  IS NOT NULL
		BEGIN
			update icc.dbo.Message
				set AgentId = @AgentId
				,TeamName=@TeamName
				,MessagePhase='Accepted'
                ,AcceptedTime=getdate()
				--,ProjectId=@ProjectId
				,IssueId=@IssueId
				where /*agentid is null and MessageResult='Active' and Direction='I' and*/ MessageId=@MessageId2
	        insert into iCC.[dbo].[MessageEvent] (TimeUtc, TimeLocal, EventType, MessageId, AgentId, ReferenceData, ReferenceId)
		       values(GETUTCDATE(), GETDATE(), 'AgentChange', @MessageId2, @AgentId, 'AssignMailOfAgent', @AgentId)	
		END
		FETCH NEXT FROM My_cursor INTO @MessageId2,@ProjectId,@IssueId  
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;

END



GO

