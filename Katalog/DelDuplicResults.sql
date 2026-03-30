USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[DelDuplicResults]    Script Date: 28. 11. 2022 10:48:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



 CREATE PROCEDURE [dbo].[DelDuplicResults]
 @ScenarioResultId UniqueIdentifier
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 28.11.2022
-- Description:	Ruší duplicitní výsledky Predat
-- =============================================

BEGIN
 DECLARE @Loguj AS Bit=1
 DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
 DECLARE @Popis AS nvarchar(MAX)
 

IF ISNULL((SELECT TOP 1 1  FROM [iCC].[dbo].ScenarioResultValue SCRV
    INNER JOIN [iCC].[dbo].ScenarioResult SCR ON SCRV.Scenarioresultid=SCR.Scenarioresultid
	INNER JOIN [iCC].[dbo].IssueExtra IE ON IE.Issueid=SCR.Issueid
WHERE SCRV.ScenarioResultId=@ScenarioResultId AND (SCRV.TargetColumn='Predat')
   AND IE.Predat<>SCRV.ResultText),0)=1

 BEGIN 
	 DELETE SCRV FROM [iCC].[dbo].ScenarioResultValue SCRV
		INNER JOIN [iCC].[dbo].ScenarioResult SCR ON SCRV.Scenarioresultid=SCR.Scenarioresultid
		INNER JOIN [iCC].[dbo].IssueExtra IE ON IE.Issueid=SCR.Issueid
	WHERE SCRV.ScenarioResultId=@ScenarioResultId AND (SCRV.TargetColumn='Predat')
	   AND IE.Predat<>SCRV.ResultText
		SET @Popis = 'I delete duplicate Predat results on ScenarioResultId='+convert(nvarchar(40), @ScenarioResultId)
		EXEC  [FS_custom].[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
 END

END

GO

