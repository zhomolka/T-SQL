USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[OutProjInsp]    Script Date: 13. 4. 2021 15:52:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		ZbH
-- Create date: 9.3.2021
-- Description:	Převádí neprojektové hovory na projektové
-- =============================================
CREATE PROCEDURE [dbo].[OutProjInsp] 
	@Id uniqueidentifier
AS
BEGIN
DECLARE @Loguj AS Bit=1
DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
DECLARE @Popis AS nvarchar(MAX)
-----------------------
IF (select ProjectId from icc.dbo.OutboundCall where OutboundCallId=@Id) IS NULL
 BEGIN
   SET @Popis = 'Nevyplněný projekt na OutboundCallId='+CONVERT(NVARCHAR(50),@Id)
   EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
   UPDATE iCC.dbo.OutboundCall SET 
     Projectid='27c9e01a-ec7c-4fb8-a503-9bf7522ba8ab' -- Ad Hoc hovor
	 ,Outboundlistid='dbed5018-1ed8-4d00-a26a-2cdd4ecf73f1'
	 ,RegionalTime=GETDATE()
	 ,DistributionTime=GETDATE()
	 ,CallType='DialOut' 
      --CallPhase='Manual' 
   WHERE OutboundCallId=@Id
	INSERT INTO icc.dbo.CallEvent (TimeUtc, TimeLocal, EventType, InboundCallId,  ResultData)
	VALUES (GETUTCDATE(), GETDATE(), 'OutProjInsp', @Id,  'Private Call change to Project Call')

 END
-----------------------

END

GO

