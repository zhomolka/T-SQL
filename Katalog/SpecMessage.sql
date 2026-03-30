USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[SpecMessage]    Script Date: 2/3/2021 7:27:02 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <28.1.2021>
-- Description:	<Posílá mail o nedostatku agentů>
-- =============================================
CREATE PROCEDURE [dbo].[SpecMessage]
(
	-- Add the parameters for the function here
	@InboundCallId as UniqueIdentifier
)
AS
BEGIN
	-- Pošli upozorňovací mail
	DECLARE @SubjectField as nvarchar(320)='Callback FS – '+CONVERT(NVARCHAR(30),GETDATE())+' '+(SELECT TOP 1 CallerNumber FROM [iCC].[dbo].[InboundCall] IC WITH (NOLOCK)
		 WHERE InboundCallId=@InboundCallId)
    EXEC .dbo.Write_Mail '8bdc17d3-e9a9-4711-a633-4eb9c55412a7','d.benesova@cra.cz',@SubjectField,'Neobsloužené volání'

END
GO

