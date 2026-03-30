USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[OldMails]    Script Date: 3.9.2018 16:31:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <03-09-2018>
-- Description:	<Počet mailů 
-- =============================================

CREATE function [dbo].[OldMails] (
	@From datetime
)
returns Integer
as begin
  return (SELECT 		-- Maily											
		COUNT(1) AS Starsi24hod											
	FROM icc.dbo.Message AS M WITH(NOLOCK)													
	WHERE Direction='I' AND MessageType='Email' AND ReceivedSentTime > DATEADD(Hour,-24,@From)
	 AND (EndTime IS  NULL)
)

end

GO

