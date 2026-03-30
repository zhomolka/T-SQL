USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[TestContiConv]    Script Date: 17.08.2023 13:21:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <17.8.2023>
-- Description:	<je volán z IMR skriptu - kontroluje, zda nejde o pokračující konverzaci>
-- =============================================
CREATE FUNCTION [dbo].[FSC_TestContiConv]
(
	@MessageId AS UniqueIdentifier
)
RETURNS integer
AS
BEGIN
  DECLARE @LimTime AS Date = GETDATE()
  DECLARE @RelatedMessageId AS UniqueIdentifier=(SELECT RelatedMessageId FROM .dbo.Message WITH (NOLOCK) WHERE MessageId=@MessageId)
  -- Pojistka proti odesílání odpovědí na staré zprávy
  IF @RelatedMessageId IS NULL AND (SELECT ReceivedSentTime FROM .dbo.Message WITH (NOLOCK) WHERE MessageId=@MessageId)<@LimTime
    SET @RelatedMessageId=CONVERT(UniqueIdentifier,'93CB98DD-75EB-4A47-815C-0014221321C3') -- Aby se neposlala odpověď
  RETURN IIF(@RelatedMessageId IS NULL,0,1)
END



GO

