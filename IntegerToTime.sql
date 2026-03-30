USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[IntegerToTime]    Script Date: 9. 6. 2017 15:26:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Václav Kubát>
-- Create date: <18.5.2017>
-- Description:	<prevadi integer (trvani nejake udalosti) na time>
-- =============================================

CREATE FUNCTION [dbo].[IntegerToTime](@DurationAsInt as int)
RETURNS nvarchar(17)
AS
BEGIN
	--declare @DurationAsInt as int = '1122351'
	declare @HoursDuration as int = (select @DurationAsInt / 3600)
	declare @MinutesDuration as int = (select (@DurationAsInt-(@HoursDuration*3600)) / 60)
	declare @SecondsDuration as int = (select (@DurationAsInt-(@HoursDuration*60)) % 60)
	declare @DurationAsTime as nvarchar(17) = (select cast (@HoursDuration as nvarchar (5)) + ':' + cast (@MinutesDuration as nvarchar (5)) + ':' +cast (@SecondsDuration as nvarchar (5)) )
	--select convert(nvarchar(17),@DurationAsTime,108)
	RETURN convert(nvarchar(17),@DurationAsTime,108)
END
--
GO

