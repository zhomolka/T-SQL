USE [FS_custom]
GO
/****** Object:  StoredProcedure [dbo].[HlavniFormular]    Script Date: 28. 4. 2022 14:46:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Jiøí Stejskal, uprava Hemerka>
-- Create date: <31.1.2017>
-- Description:	naplní tabulku IssueExtra
-- 28.4.2022 ZbH pøidal hlídání vymazávání poznámky NOTE
-- =============================================
ALTER PROCEDURE [dbo].[HlavniFormular] (@ScenarioResultId as uniqueidentifier)
 
AS
BEGIN

	SET NOCOUNT ON;
DECLARE @Loguj AS Bit=1
DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
DECLARE @Popis AS nvarchar(MAX)

declare @Predat as nvarchar(150)
declare @Note as nvarchar(150) 
declare @Ico as nvarchar(60) 
declare @Problem as bit 
declare @issueid as uniqueidentifier =(select IssueId from icc.dbo.scenarioresult with(nolock) where ScenarioResultId=@ScenarioResultId)

select @Predat = ResultText 
from iCC.dbo.ScenarioResultValue with(nolock)
where ScenarioResultId=@ScenarioResultId
AND TargetColumn = 'Predat' 
AND (ResultText IS NOT NULL) 

select @Note = ResultText 
from iCC.dbo.ScenarioResultValue with(nolock)
where ScenarioResultId=@ScenarioResultId
AND TargetColumn = 'NOTE' 
AND (ResultText IS NOT NULL) 

select @Ico = ResultText 
from iCC.dbo.ScenarioResultValue with(nolock)
where ScenarioResultId=@ScenarioResultId
AND TargetColumn = 'ICO' 
AND (ResultText IS NOT NULL)	

select @Problem = 
CASE
WHEN ResultText = 'N' THEN 0
WHEN ResultText = 'A' THEN 1
END
from iCC.dbo.ScenarioResultValue with(nolock)
where ScenarioResultId=@ScenarioResultId
AND TargetColumn = 'PROBLEM' 
AND (ResultText IS NOT NULL)

update  icc.dbo.IssueExtra 
set Predat =@Predat
where IssueId=@issueid

update  icc.dbo.IssueExtra 
set Ico =@Ico
where IssueId=@issueid

update  icc.dbo.IssueExtra 
set Problem =@Problem
where IssueId=@issueid

-- Musím zkontrolovat, zda nejde o nechtìné vymazání textu
IF @Note=''
  BEGIN
    -- Vytáhnu døíve uloženou hodnotu z IssueExtra
    SET @Note=(SELECT TOP 1 NOTE FROM iCC.[dbo].[IssueExtra] WHERE IssueId=@issueid)
	IF @Note IS NOT NULL
	  BEGIN
		-- A zapíši ji zpìt do ScenarioResultValue
		EXEC [iCC].[dbo].[SetTargetColumnText] @ScenarioResultId, 'NOTE', @NOTE
 	    SET @Popis = 'I return value NOTE back on @IssueId='+convert(nvarchar(MAX), @IssueId)
	    EXEC  [FS_custom].[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
	  END
  END
ELSE
	update  icc.dbo.IssueExtra 
	set Note =@Note
	where IssueId=@issueid


END



