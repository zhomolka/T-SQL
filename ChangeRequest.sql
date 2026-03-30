USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[ChangeRequest]    Script Date: 27.3.2019 8:27:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <27.03.2019>
-- Description:	<Posílá do tabulky [ChangeRequest] požadavek na změnu subjektu>
-- =============================================
CREATE PROCEDURE [dbo].[ChangeRequest]
@Command nvarchar(50)           -- 'AgentStatus', 'AgentLogin','CloseIssue'
,@Text nvarchar(MAX)            -- Patrně libovolný popis akce
,@ReferenceId uniqueidentifier  -- Např. požadovaný stav agenta
,@SubjectId uniqueidentifier    -- Např. AgentIdnebo IssueId, jehož stav se má změnit
,@DataId  uniqueidentifier      -- Při Commandu 'AgentLogin' zde je WorkplaceId, na které má být agent přihlášen 

AS
BEGIN

	INSERT INTO [iCC].[dbo].[ChangeRequest]
			   ([ChangeRequestTimeUtc], [Command] ,[Text] ,[Number] ,[ReferenceId] ,[SubjectId] ,[DataId] ,[Done])
		 VALUES
			   (GETUTCDATE(), @Command, @Text, 0, @ReferenceId, @SubjectId ,@DataId ,  0)

END


GO

