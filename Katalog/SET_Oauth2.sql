USE [FS_Custom]
GO
/****** Object:  StoredProcedure [dbo].[SET_Oauth2]    Script Date: 20.10.2022 11:54:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <18.10.2022>
-- Description:	<Nastavuje bránu EWS Oauth2>
-- =============================================
ALTER PROCEDURE [dbo].[SET_Oauth2]
(
	-- Add the parameters for the function here
	@GatewayId AS UNIQUEIDENTIFIER
   ,@TemplateGWiD AS UNIQUEIDENTIFIER
   ,@TemplateUsr AS NVARCHAR(50)
)

AS
BEGIN
--DECLARE @TemplateGWiD AS UNIQUEIDENTIFIER='cc3d860d-e804-451f-9dbc-3933f9b6e9f3'
DECLARE @PilotAddress AS NVARCHAR(512)=RTRIM((SELECT PilotAddress FROM iCC.dbo.Gateway WHERE GatewayId=@GatewayId))
DECLARE @Device AS NVARCHAR(MAX)=(SELECT InDevice FROM iCC.dbo.Gateway WHERE GatewayId=@TemplateGWiD)
SET @Device=REPLACE(@Device,@TemplateUsr,@PilotAddress)

UPDATE iCC.dbo.Gateway
SET Description = 'EWS/Oauth2',InDevice=@Device,OutDevice=@Device
WHERE  GatewayId=@GatewayId 

 	RETURN 
END

