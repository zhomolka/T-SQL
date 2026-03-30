USE [PCS]
GO

/****** Object:  StoredProcedure [dbo].[IssueEvaluate]    Script Date: 11.9.2017 16:05:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--
-- V PČS nechtějí mít případy vzniklé ze ztracených hovorů
--
CREATE PROCEDURE [dbo].[IssueEvaluate]
	@InboundCallId as uniqueidentifier
AS
BEGIN

    DECLARE @Loguj AS Bit=1
	DECLARE @ProcName AS Varchar(10) = SUBSTRING(object_name(@@PROCID),1,10)
	DECLARE @Popis AS nvarchar(MAX)
 	DECLARE @IssueId AS uniqueidentifier=(SELECT IssueId FROM iCC.dbo.InboundCall WITH (NOLOCK) WHERE InboundCallId=@InboundCallId)
--		DECLARE @IssueId AS uniqueidentifier=(SELECT IssueId FROM iCC.dbo.Issue WITH (NOLOCK) WHERE Inbou)

	-- Ma byt vyvolano pri prechodu do stavu Lost
	SET NOCOUNT ON;
	SET @Popis = 'Vstupní bod, InboundCallId='+convert(nvarchar(MAX), @InboundCallId)
	EXEC  [PCS].[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
	IF (@IssueId IS NOT NULL) -- Můj ztracený hovor má založený případ
	  BEGIN
	    IF NOT EXISTS(SELECT IssueId FROM iCC.dbo.InboundCall WITH (NOLOCK) WHERE IssueId=@IssueId AND InboundCallId<>@InboundCallId)
		  BEGIN
		    -- Je to jediný Příchozí hovor k tomuto případu
	        IF NOT EXISTS(SELECT IssueId FROM iCC.dbo.OutboundCall WITH (NOLOCK) WHERE IssueId=@IssueId)
		     BEGIN
		        -- k tomuto případu neexistuje odchozí hovor
			  	IF NOT EXISTS(SELECT IssueId FROM iCC.dbo.Message WITH (NOLOCK) WHERE IssueId=@IssueId)
		          BEGIN
		            -- k tomuto případu neexistuje zpráva - měl bych ten případ zrušit
					DECLARE @AgentId AS uniqueidentifier=(SELECT AgentId FROM iCC.dbo.Issue WITH (NOLOCK) WHERE IssueId=@IssueId)

					-- Zatím u něj pouze vymažu agenta
					UPDATE iCC.dbo.Issue SET  AgentId = NULL WHERE (IssueId = @IssueId)
				    SET @Popis = 'Vymazání agenta Id:'+convert(nvarchar(MAX), @AgentId)+' z případu IssueId='+convert(nvarchar(MAX), @IssueId)
				    EXEC  [PCS].[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
		          END
		     END
		  END
	  END
END
GO

