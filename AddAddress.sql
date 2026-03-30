USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[AddAddress]    Script Date: 30. 10. 2017 16:52:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <30-10-2017>
-- Description:	Přidává do tabulky FS_custom.dbo.Addresses novou RemoteAddress
-- ======================================================

CREATE function [dbo].[AddAddress] (
    @RemoteAddress NVARCHAR(250)
)
returns char(1)
as begin
   IF @RemoteAddress IS NOT NULL
     BEGIN
	    -- Prověřím existenci položky
		IF NOT EXISTS(SELECT TOP 1 'X' AS Nic FROM FS_custom.dbo.Addresses WHERE RemoteAddress=@RemoteAddress)
		 BEGIN
		   DECLARE @sql varchar(4000), @cmd varchar(4000)
           SELECT @sql = 'INSERT INTO Addresses (RemoteAddress) VALUES (''' + @RemoteAddress + ''') '
           SELECT @cmd = 'sqlcmd -S ' + @@servername +' -d ' + db_name() + ' -Q "' + @sql + '"'
           EXEC master..xp_cmdshell @cmd, 'no_output'

		   --INSERT FS_custom.dbo.Addresses (RemoteAddress) VALUES (@RemoteAddress)
		 END
	 END
return 'X'
END
GO

