USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[Cor_SMS]    Script Date: 7/26/2021 3:30:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <26.07.2021>
-- Description:	<Korekce čísla v SMS>
-- =============================================

CREATE PROCEDURE [dbo].[Cor_SMS] (
@MessageId as uniqueidentifier
)
AS
BEGIN
  -- Materna netoleruje levostrann0 nuly v čísle
  DECLARE @Loguj AS Bit=1
  DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
  DECLARE @Popis AS nvarchar(MAX)

  DECLARE @ChangeAddr as bit=ISNULL((SELECT TOP 1 1 FROM ICC.[dbo].Message WHERE [MessageId]=@MessageId AND MessageType='SMS'
    AND RemoteAddress LIKE '0%' ),0)
  SET @Popis = 'Correction of SMS MessageId='+CONVERT(NVARCHAR(50),@MessageId)+' @ChangeAddr='+IIF(@ChangeAddr=1,'1','0')
  EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
  IF @ChangeAddr=1
    UPDATE iCC.dbo.Message
      SET RemoteAddress=SUBSTRING(RemoteAddress,2,10)
         WHERE MessageId=@MessageId

 /**/

END


GO

