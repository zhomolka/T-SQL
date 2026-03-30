
SET XACT_ABORT OFF
GO
--Showplan disables the actual execution, but forces t-sql to create execution-plans for every statement.
--This is the core of the whole thing!
--SET SHOWPLAN_ALL ON
GO
--You cannot use dynamic SQL in here, since sp_executesql will not be executed, but only show the string passed in in the execution-plan
EXEC fs_custom.dbo.UTL_ForceSPRecompilation NULL,'isHoliday',1

GO
SET SHOWPLAN_ALL OFF
GO
SET XACT_ABORT ON
GO