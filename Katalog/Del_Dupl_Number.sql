USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[Del_Dupl_Number]    Script Date: 14.04.2021 16:23:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[Del_Dupl_Number]
@PhoneNumberId AS UniqueIdentifier
,@ContactId AS UniqueIdentifier
,@Numbers AS NVARCHAR(80)
AS
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <14.4.2021>
-- Description:	<Odstranění záznamu z PhoneNumber>
-- =============================================

BEGIN
    DECLARE @Loguj AS Bit=1
	DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
	DECLARE @Popis AS nvarchar(MAX)

-- Jeden náhradní identifikátor:
--DECLARE @ContactId AS UniqueIdentifier = (SELECT Top 1 ContactId from Icc.dbo.PhoneNumber where PhoneNumberId=@PhoneNumberId)
--DECLARE @Numbers AS UniqueIdentifier = (SELECT Top 1 Numbers from Icc.dbo.PhoneNumber where PhoneNumberId=@PhoneNumberId)
IF NOT EXISTS(SELECT TOP 1 1 FROM iCC.dbo.PhoneNumber WHERE PhoneNumberId=@PhoneNumberId)
  RETURN --===================>>>>
DECLARE @PhoneReplId AS UniqueIdentifier = 
(SELECT Top 1 PhoneNumberId from Icc.dbo.PhoneNumber
where PhoneNumberId<>@PhoneNumberId
  AND (@ContactId IS NULL OR  ContactId=@ContactId)
  AND (@Numbers IS NULL OR  Numbers=@Numbers))
IF @PhoneReplId IS NOT NULL
 BEGIN
 --BEGIN TRANSACTION
   --IF EXISTS(SELECT PhoneNumberId FROM Icc.dbo.PhoneComposition WITH (NOLOCK)
   --   WHERE PhoneNumberId=@PhoneNumberId) AND 
    --DELETE FROM Icc.dbo.PhoneComposition -- Když už tam náhradní Id je, musím rušená Id smazat
    --  WHERE PhoneNumberId IN (SELECT * FROM #TEMP2)
 -- ELSE
PRINT 'Replace PhoneComposition:'
UPDATE Icc.dbo.PhoneComposition
     SET PhoneNumberId=@PhoneReplId WHERE PhoneNumberId=@PhoneNumberId
PRINT 'Replace InboundCall:'
UPDATE Icc.dbo.InboundCall
SET PhoneNumberId=@PhoneReplId WHERE PhoneNumberId=@PhoneNumberId
PRINT 'Replace OutboundCall:'
UPDATE Icc.dbo.OutboundCall
SET PhoneNumberId=@PhoneReplId WHERE PhoneNumberId=@PhoneNumberId
PRINT 'Replace Message:'
UPDATE Icc.dbo.Message
SET PhoneNumberId=@PhoneReplId WHERE PhoneNumberId=@PhoneNumberId
PRINT 'Replace Issue:'
UPDATE Icc.dbo.Issue
SET PhoneNumberId=@PhoneReplId WHERE PhoneNumberId=@PhoneNumberId
PRINT 'Replace Chat:'
UPDATE Icc.dbo.Chat
SET PhoneNumberId=@PhoneReplId WHERE PhoneNumberId=@PhoneNumberId

PRINT 'DELETE PhoneNumberId from PhoneNumber:'
DELETE FROM iCC.dbo.PhoneNumber WHERE PhoneNumberId=@PhoneNumberId
SET @Popis = FORMATMESSAGE('PhoneNumberid %s  byl nahrazen %s',convert(nvarchar(40), @PhoneNumberId),convert(nvarchar(40), @PhoneReplId))
EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis

--COMMIT TRANSACTION
 -- ROLLBACK TRANSACTION
END

END


GO

