USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[FSC_CustMaintenance]    Script Date: 28.12.2023 13:03:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
 CREATE PROCEDURE [dbo].[FSC_CustMaintenance]
	 AS
	  BEGIN
	    DECLARE @SchedDay AS Date=convert(datetime, '2023.12.28')
		DECLARE @ToDay AS Date=GETDATE()
		IF @SchedDay=@ToDay
		  BEGIN
			CREATE NONCLUSTERED INDEX CX_TimeLocal
			ON iCC.[dbo].[CallEvent] ([TimeLocal])
			INCLUDE ([EventType],[InboundCallId],[ReferenceData],[ResultData])

		  END
	  END
GO

