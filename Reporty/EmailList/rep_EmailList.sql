USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_EmailList]    Script Date: 8. 2. 2019 16:56:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <16.11.2016>
-- Description:	<Počet e-mailů podle emailové adresy v e-mailové frontě>
-- =============================================
CREATE FUNCTION [dbo].[rep_EmailList]
(	
	@From datetime, 
	@To datetime
)
RETURNS TABLE 
AS
RETURN 
(
select ReceivedSentTime AS Cas, Direction ,P.DisplayName AS ProjectName,
 RemoteAddress, SubjectField,MessagePhase,MessageResult  from icc.dbo.Message M WITH (NOLOCK)
 LEFT JOIN iCC.dbo.Project AS P WITH (NOLOCK) ON P.ProjectId = M.ProjectId

 where ReceivedSentTime  BETWEEN @From AND @To
)



GO

