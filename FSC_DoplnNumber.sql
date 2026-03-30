USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[FSC_DoplnNumber]    Script Date: 12.04.2023 11:11:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Tomáš Waněk
-- Create date:  2023-04-01
-- Description:	Doplnění RemoteNumber pro párování hovorů
-- =============================================
CREATE PROCEDURE [dbo].[FSC_DoplnNumber]

AS
BEGIN
DECLARE @dt_max date = GETDATE()+1  -- current date GETDATE()+1
DECLARE @dt_min date = GETDATE()-3
Update [SRec].[dbo].[VoiceRecord]
SET RemoteNumber = '099'
WHERE RemoteName = 'Anonymous' and RemoteNumber IS NULL and TimeUtc <= @dt_max and TimeUtc >= @dt_min

END

GO

