USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[RepairMessage]    Script Date: 10. 10. 2017 8:17:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <9.10.2017>
-- Description:	<Při odeslání zprávy napraví pole BodyText>
-- =============================================
CREATE PROCEDURE [dbo].[RepairMessage]
@Id uniqueidentifier
AS
BEGIN
-- Náprava kódování textu
UPDATE iCC.dbo.Message
SET  BodyText =  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(BodyText,'&aacute;','á'),'&yacute;','ý'),'&uacute;','ú'),'&iacute;','í'),'&#225;','á'),'&#237;','í'),'&scaron;','š')
WHERE MessageId=@Id
DECLARE @Zprava NVARCHAR(200)= 'Oprava BodyText na Messageid='+CONVERT(NVARCHAR(38),@Id)
EXEC  [FS_custom].[dbo].[WriteEvent] 1,'RepairMessage',@Zprava

RETURN
END





GO

