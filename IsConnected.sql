USE [FS_custom]
GO
/****** Object:  UserDefinedFunction [dbo].[IsHoliday]    Script Date: 21. 2. 2018 17:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <18.10.2019>
-- Description:	<Zjišťuje, zda se jedná o spojený hovor >
-- =============================================
CREATE FUNCTION [dbo].[IsConnected]
(
	 @From AS Datetime
	,@To AS Datetime
	,@AnswerTime AS Datetime
	,@TeamName AS NVARCHAR(50)
)
RETURNS Integer
AS
BEGIN  
   
	RETURN IIF(@AnswerTime > @From AND @AnswerTime <= @To AND @TeamName='CC',1,0)
END


