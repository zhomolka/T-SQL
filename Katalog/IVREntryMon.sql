USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[IVREntryMon]    Script Date: 18. 2. 2021 9:49:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[IVREntryMon]
--@Messageid AS Uniqueidentifier
AS
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <14.12.2020>
-- Description:	<Monitoruje zatížení IVR vstupů
-- =============================================

BEGIN
  DECLARE @Loguj AS Bit=1
  DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
  DECLARE @Popis AS nvarchar(MAX)
  DECLARE @IVRCountUse AS Integer
   --EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, 'Start'
   SET @IVRCountUse = (SELECT COUNT(1) FROM iCC.dbo.InboundCall WHERE CallResult='Active' AND  CallPhase='IvrScriptA')
   IF @IVRCountUse > 10
    BEGIN
      SET @Popis = 'Count of used IVREntry ='+CONVERT(NVARCHAR(5),@IVRCountUse)
      EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
    END
END

GO

