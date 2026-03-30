USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[isOutboundImpComplete]    Script Date: 17.2.2020 15:03:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
-- =============================================
-- Author:          <Zbyněk Homolka>
-- Create date: <17.2.2020>
-- Description:     <zjištuje, zda je celý import odchozí kampaně zpracován>
-- =============================================
CREATE FUNCTION [dbo].[isOutboundImpComplete]
(
       -- Add the parameters for the function here
       @OutboundListImportId as UniqueIdentifier
)
RETURNS integer
AS
BEGIN
 
RETURN ISNULL((SELECT TOP 1 0 FROM [iCC].[dbo].[OutboundCall]
  WHERE 1=1  AND OutboundListImportId =@OutboundListImportId AND CallResult='Scheduled'),1)
END
 

GO

