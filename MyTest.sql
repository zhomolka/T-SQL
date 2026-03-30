USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[MyTest]    Script Date: 31.03.2023 14:14:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MyTest]

@MyIndex AS NVARCHAR(100)

AS
--BEGIN
DECLARE @from AS datetime=DATEADD(Minute,-55,GETUTCDATE())
declare @EmlMsg as nvarchar(300)
DECLARE @Command AS NVARCHAR(500)='SET @EmlMsg=(SELECT TOP (1) RTRIM([ResultData])+'' ''+EventType 
  FROM ICC.[dbo].[CallEvent] WITH (INDEX('+@MyIndex+')) 
  WHERE TimeUTC>CONVERT(Datetime,'''+CONVERT(NVARCHAR(20),@from,120)+''') AND EventType=''IvrScriptA'' AND ReferenceData=''Error'' AND Timelocal>CONVERT(Datetime,'''+CONVERT(NVARCHAR(20),@from,120)+''')
  AND ResultData not like ''%SetTarget:invalid target%'')'
SELECT @Command
  EXEC SP_EXECUTESQL @Command, N'@EmlMsg NVARCHAR(300) OUTPUT', @EmlMsg OUTPUT
  -- Only functions and some extended stored procedures can be executed from within a function.
  --SET @Command='SET @EmlMsg=.[dbo].'+LTRIM(@Command)
   --EXEC SP_EXECUTESQL @Command, N'@EmlMsg NVARCHAR(300) OUTPUT', @EmlMsg OUTPUT
 RETURN 1  
 -- RETURN @EmlMsg


--END
GO

