USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[SendWarningSMS_Gener]    Script Date: 7. 6. 2019 10:58:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 6.6.2019
-- Description:	Zasílání SMS o prodlevách v řešení případů a zmeškaných hovorech
-- =============================================
CREATE PROCEDURE [dbo].[SendWarningSMS_Gener]	
AS
BEGIN
DECLARE @Loguj AS Bit=1
DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
DECLARE @TeamNameLen AS Integer=30
DECLARE @Zprava AS NVarchar(500)
DECLARE @GroupP AS Varchar(1)
DECLARE @TeamName AS NVarchar(30)
DECLARE @CallerNumber AS NVarchar(30)
DECLARE @Info AS NVarchar(200)
DECLARE @Id AS UNIQUEIdentifier
DECLARE @IssueId AS UNIQUEIdentifier
DECLARE @SubjectField AS NVarchar(30)
DECLARE @BodyText AS NVarchar(200)
DECLARE @i AS Integer=0
DECLARE @ManagTeamName AS NVarchar(30)='Management' -- Jméno týmu managerů

DECLARE @GatewayId AS UNIQUEIdentifier='b1eb7484-6358-45db-839f-b8407e53bcde'
 
DECLARE @Problems TABLE (GroupP VARCHAR(1), Id UniqueIdentifier, IssueId UniqueIdentifier, WarAgent bit, WarManag bit, Info NVARCHAR(30),TeamName NVARCHAR(30))
DECLARE @CallerNumbers TABLE (Manager Bit, TeamName NVARCHAR(30), CallerNumber VARCHAR(20), Processed bit)

	--EXEC  [FS_custom].[dbo].[WriteEvent] @Loguj, @ProcName, 'Vstupní bod'

-- Zjistí neřešené případy
INSERT INTO @Problems
SELECT 'I', IssueId, IssueId, IIF(Mark=0,1,0) AS WarAgent, IIF(Mark<2 AND DATEDIFF(minute,I.OpenTime,GETDATE())>60,1,0) AS WarManag,T.DisplayName,I.TeamName
FROM iCC.dbo.Issue as I
LEFT JOIN iCC.dbo.Topic as T ON I.TopicId=T.TopicId
--LEFT JOIN iCC.dbo.Agent as A ON I.AgentId=A.AgentId
--LEFT JOIN iCC.dbo.Project as P ON I.ProjectId=P.ProjectId
WHERE I.Activity='New' AND DATEDIFF(minute,I.OpenTime,GETDATE())>30 AND I.Mark<2

-- Zjistí neošetřené ztracené hovory
INSERT INTO @Problems
SELECT 'C', InboundCallId, IssueId, IIF(Mark=0,1,0) AS WarAgent, IIF(Mark<2 AND DATEDIFF(minute,I.DistributionTime,GETDATE())>60,1,0) AS WarManag,I.CallerNumber,I.TeamName
FROM iCC.dbo.InboundCall as I
--LEFT JOIN iCC.dbo.Topic as T ON I.TopicId=T.TopicId
--LEFT JOIN iCC.dbo.Agent as A ON I.AgentId=A.AgentId
--LEFT JOIN iCC.dbo.Project as P ON I.ProjectId=P.ProjectId
WHERE I.CallResult='Lost' AND (I.CallPhase='AgentRingF' OR I.CallPhase='AgentRingM') AND DATEDIFF(minute,I.PilotTime,GETDATE())>30
 AND DATEDIFF(minute,I.DistributionTime,GETDATE())>30
  AND DATEDIFF(Day,I.PilotTime,GETDATE())<7 AND I.Mark<2
  AND NOT EXISTS(SELECT 1 FROM iCC.dbo.OutboundCall as OC WHERE OC.CallerNumber=I.CallerNumber AND OC.DistributionTime>I.Pilottime) -- Nevolal již někdo zpátky?

-- Zjistí čísla, na něž má posílat SMS
INSERT INTO @CallerNumbers
SELECT IIF(TeamName=@ManagTeamName,1,0) AS Manager,TeamName,SUBSTRING(ExternalPhone,1,ISNULL(NULLIF(CHARINDEX(ExternalPhone,','),0),10)) AS Telefon,0
FROM iCC.dbo.Agent as A
WHERE ExternalPhone IS NOT NULL AND ExternalPhone<>'' AND Deleted=0


-- Nyní tabulku problémů zpracuji
-- Nejprve agenty
WHILE @i < 2
  BEGIN
	WHILE EXISTS(SELECT 1 FROM @Problems WHERE (@i=0 AND WarAgent=1) OR (@i=1 AND WarManag=1) )
	   BEGIN
		 SET @Id = (SELECT TOP 1 Id FROM @Problems WHERE (@i=0 AND WarAgent=1) OR (@i=1 AND WarManag=1))
		 SET @IssueId=(SELECT TOP 1 IssueId FROM @Problems WHERE Id=@Id)
		 SET @TeamName=IIF(@i=1,@ManagTeamName,(SELECT TOP 1 TeamName FROM @Problems WHERE Id=@Id))
		 SET @GroupP=(SELECT TOP 1 GroupP FROM @Problems WHERE Id=@Id)
		 SET @Info=(SELECT TOP 1 Info FROM @Problems WHERE Id=@Id)
		 -- Pošlu zprávu všem, jichž se to týká
		 UPDATE @CallerNumbers Set Processed=0 -- WHERE CallerNumber=@CallerNumber -- Povolení zasílat na všechna čísla
		 SET @Zprava='GroupP='+@GroupP+' Info= '+@Info+' @I= '+CONVERT(NVARCHAR(6),@I)
		 EXEC  [FS_custom].[dbo].[WriteEvent] @Loguj, @ProcName, @Zprava
		 WHILE EXISTS(SELECT 1 FROM @CallerNumbers WHERE TeamName=@TeamName AND Processed=0)
		   BEGIN
			 SET @CallerNumber = (SELECT TOP 1 CallerNumber FROM @CallerNumbers WHERE TeamName=@TeamName AND Processed=0)
			 SET @SubjectField=IIF(@GroupP='I','Nereseny pripad','Zmeskany hovor')
			 SET @BodyText=IIF(@GroupP='I','Pripad '+@Info+' je neresen dele nez '+
			  CONVERT(NVARCHAR(6),(SELECT DATEDIFF(minute,OpenTime,GETDATE()) FROM iCC.dbo.Issue WHERE IssueId=@Id))+
			 ' minut.','z cisla '+@Info)
			 EXEC [FS_custom].dbo.[PosliSMS] @IssueId, @CallerNumber, @GatewayId , @SubjectField , @BodyText
			 UPDATE @CallerNumbers Set Processed=1 WHERE CallerNumber=@CallerNumber -- Označení odeslání na příslušné číslo
		   END
		   IF @GroupP='I'
				UPDATE iCC.dbo.Issue Set Mark=Mark+1 WHERE IssueId=@Id
		   ELSE
				UPDATE iCC.dbo.InboundCall Set Mark=Mark+1 WHERE InboundCallId=@Id
           IF @i=0
		     UPDATE @Problems Set WarAgent=0 WHERE Id=@Id -- Vyřízení problému
           ELSE
			 UPDATE @Problems Set WarManag=0 WHERE Id=@Id -- Vyřízení problému
	   END
	   SET @i=@i+1
  END
 	--EXEC  [FS_custom].[dbo].[WriteEvent] @Loguj, @ProcName, 'Konec ========'
END
 


GO

