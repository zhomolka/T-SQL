USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[IsLogonAgent]    Script Date: 2/3/2021 7:28:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <16.12.2020>
-- Description:	<testuje příhlášení agentů v projektu Tele>
-- =============================================
CREATE FUNCTION [dbo].[IsLogonAgent]
(
	-- Add the parameters for the function here
	@InboundCallId as UniqueIdentifier
)
RETURNS integer
AS
BEGIN
	DECLARE @isLogon as integer = 0
	DECLARE @ProjectId as UniqueIdentifier='52817352-b2a0-45ac-886c-44aaf9cf7b68' -- Projekt, v němž mají být agenti přihlášení
	IF (SELECT TOP 1 1 FROM iCC.dbo.Agent A  WITH (NOLOCK)   
        LEFT OUTER JOIN iCC.dbo.Skill  WITH (NOLOCK) ON Skill.AgentId=A.AgentId AND Skill.PbxInKnowledge>0 AND Skill.PbxInEnabled=1 AND Skill.PbxInChannel=1
        WHERE A.AgentId=Skill.AgentId AND A.Activity='Ready' AND Skill.ProjectId=@ProjectId)=1
	  BEGIN
	    SET @isLogon = 1  -- Alespoň jeden agent je přihlášen
	  END
    ELSE
	  BEGIN
	   SET @isLogon = 0
	    -- Pošli upozorňovací mail -- Toto zde není možné
		/*DECLARE @SubjectField as nvarchar(320)='Callback FS – '+CONVERT(NVARCHAR(30),GETDATE())+' '+(SELECT TOP 1 CallerNumber FROM [iCC].[dbo].[InboundCall] IC WITH (NOLOCK)
		 WHERE InboundCallId=@InboundCallId)*/
	    --EXEC .dbo.Write_Mail '8bdc17d3-e9a9-4711-a633-4eb9c55412a7','d.benesova@cra.cz',@SubjectField,'Neobsloužené volání'
	  END

	RETURN @isLogon

END
GO

