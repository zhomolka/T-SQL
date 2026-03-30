USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[PosliSMS]    Script Date: 7. 6. 2019 10:57:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[PosliSMS]
  @IssueId AS UniqueIdentifier,
  @CallerNumber AS NVARCHAR(20),
  @GatewayId AS UniqueIdentifier,
  @SubjectField AS NVARCHAR(30),
  @BodyText AS NVARCHAR(500)
AS
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <6.6.2019>
-- Description:	<Posílá SMS>
-- =============================================

BEGIN
INSERT INTO iCC.dbo.Message(TimeUtc,MessageType,MessagePhase,MessageResult,Direction,IssueId,RemoteAddress,ToField,GatewayId,SubjectField,BodyText)
VALUES (GETUTCDATE(),'SMS','Scheduled','Active','O',@IssueId,@CallerNumber,'+42'+@CallerNumber,@GatewayId,@SubjectField,@BodyText)

END

GO

