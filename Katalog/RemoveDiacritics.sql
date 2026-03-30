USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[ChangeCallPhase]    Script Date: 10. 9. 2018 14:46:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[RemoveDiacritics]
(
    @input VARCHAR(1024)
)
RETURNS VARCHAR(1024)
    AS
        BEGIN
            RETURN (SELECT @input COLLATE SQL_Latin1_General_CP1251_CI_AS)
        END



GO

