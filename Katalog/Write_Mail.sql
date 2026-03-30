USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[Write_Mail]    Script Date: 13. 2. 2020 8:57:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <13.02.2020>
-- Description:	<Zápis mailu>
-- =============================================

CREATE PROCEDURE [dbo].[Write_Mail] (
@GW as uniqueidentifier,
@RemoteAddress as nvarchar(200),
@SubjectField as nvarchar(200),
@Message as nvarchar(500)
)
AS
BEGIN
  DECLARE @FromField as nvarchar(200)=(SELECT TOP 1 [DisplayName] FROM [iCC].[dbo].[Gateway] WHERE [GatewayId]=@GW)
  DECLARE @TimeLocalMess as DateTime
  insert into ICC.dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText)
		values(GETDATE(),'Email','Scheduled','Active', @FromField, @RemoteAddress,@RemoteAddress ,@GW,99,'O',@SubjectField, @Message , @Message )
/**/

END

GO

