USE [FS_Custom]
GO
/****** Object:  StoredProcedure [dbo].[CallbackCheckNumber_AltiTEst]    Script Date: 8/31/2022 10:44:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Jiří Stejskal>
-- Create date: <15.12.2014>
-- Description:	<Kontrola nově zadaného čísla>
-- =============================================
ALTER PROCEDURE [dbo].[CallbackCheckNumber_AltiTEst]
(
@NEWCALLERNUMBER as NVARCHAR(50)
)
AS
BEGIN
declare @CHECK AS NVARCHAR(50)
exec @CHECK=[FS_Custom].[dbo].[CallbackCheck_AltiTest] 
   @NEWCALLERNUMBER


SELECT @CHECK AS 'IVR_CB_CHECK'

END




