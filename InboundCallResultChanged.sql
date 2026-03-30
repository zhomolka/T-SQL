USE [FS_custom]
GO
/****** Object:  StoredProcedure [dbo].[InboundCallResultChanged]    Script Date: 10. 5. 2019 8:24:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <13.9.2017>
-- Description:	<Oprava případu spojeného s příchozím hovorem>
-- 10.5.2019 Doplněno přebírání kontaktu z případu do hovoru
-- =============================================

--
ALTER PROCEDURE [dbo].[InboundCallResultChanged]
	@InboundCallId as uniqueidentifier
AS
BEGIN

    DECLARE @Loguj AS Bit=1
	DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
	DECLARE @Popis AS nvarchar(MAX)
 	DECLARE @IssueId AS uniqueidentifier=(SELECT IssueId FROM iCC.dbo.InboundCall WITH (NOLOCK) WHERE InboundCallId=@InboundCallId)
	DECLARE @AgentId AS uniqueidentifier=(SELECT AgentId FROM iCC.dbo.InboundCall WITH (NOLOCK) WHERE InboundCallId=@InboundCallId)
	DECLARE @ContactId AS uniqueidentifier=(SELECT ContactId FROM iCC.dbo.InboundCall WITH (NOLOCK) WHERE InboundCallId=@InboundCallId)
    DECLARE @IssueContactId AS uniqueidentifier=IIF(@IssueId IS NULL,NULL,(SELECT ContactId FROM iCC.dbo.Issue WITH (NOLOCK) WHERE IssueId=@IssueId))
	DECLARE @IssuePhaseId AS uniqueidentifier=(SELECT PhaseId FROM iCC.dbo.Issue WITH (NOLOCK) WHERE issueId=@IssueId)

	-- Ma byt vyvolano pri prechodu do stavu Served
	SET NOCOUNT ON;
	SET @Popis = 'Vstupní bod, InboundCallId='+convert(nvarchar(MAX), @InboundCallId)
	--EXEC  [FS_custom].[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
	IF (@IssueId IS NOT NULL) AND (@AgentId IS NOT NULL)-- Můj obsloužený hovor má založený případ
	 BEGIN
		 IF (@AgentId IS NOT NULL)-- Můj hovor má agenta
		  BEGIN
	   		DECLARE @IssueAgentId AS uniqueidentifier=(SELECT AgentId FROM iCC.dbo.Issue WITH (NOLOCK) WHERE IssueId=@IssueId)
			IF  @IssueAgentId IS NOT NULL AND @IssueAgentId<>@AgentId and @IssuePhaseId not in ('78B2953D-D870-4F78-AB52-3DE00CF59B40','BFC21976-8923-41E9-BAA7-43298621531E')
			  BEGIN
				-- V mém hovoru a případu je jiný agent	- nastavím agenta v případu podle agenta v hovoru		
				UPDATE iCC.dbo.Issue SET  AgentId = @AgentId WHERE (IssueId = @IssueId)
				SET @Popis = 'Změna agenta Id:'+convert(nvarchar(MAX), @IssueAgentId)+' na případu IssueId='+convert(nvarchar(MAX), @IssueId)
				EXEC  [FS_custom].[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
			  END
		  END
		 IF (@ContactId IS NOT NULL)-- Můj obsloužený hovor má nastavený kontakt
		  BEGIN
			IF  1=1 --@IssueContactId IS NULL 
			  BEGIN
				-- V mém případu chybí Contact	- nastavím  podle hovoru		
				UPDATE iCC.dbo.Issue SET  ContactId = @ContactId WHERE (IssueId = @IssueId)
				SET @Popis = 'Zápis kontaktu:'+convert(nvarchar(MAX), @ContactId)+' na případu IssueId='+convert(nvarchar(MAX), @IssueId)
				EXEC  [FS_custom].[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
			  END
		  END
		ELSE  -- kontakt u hovoru není vyplněn
		  BEGIN
		   IF (@IssueContactId IS NOT NULL)-- Můj případ má kontakt - tak jej přenesu do obslouženého hovoru
			  BEGIN
			  	UPDATE iCC.dbo.InboundCall SET  ContactId = @IssueContactId WHERE (InboundCallId=@InboundCallId)
				SET @Popis = 'Zápis kontaktu:'+convert(nvarchar(MAX), @IssueContactId)+' na hovoru InboundCallId='+convert(nvarchar(MAX), @InboundCallId)
				EXEC  [FS_custom].[dbo].[WriteEvent] @Loguj, @ProcName, @Popis	
			  END
		 END
     END
END

