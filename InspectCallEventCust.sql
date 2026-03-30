USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[InspectCallEventCust]    Script Date: 10/25/2023 2:07:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <25.11.2021>
-- Description:	<Kontrola chyb v CallEvent>
-- =============================================
CREATE FUNCTION [dbo].[InspectCallEventCust]
(
@MyIndex AS NVARCHAR(100)
)
RETURNS nvarchar(200)
AS
BEGIN
DECLARE @from AS datetime=DATEADD(Minute,-55,GETUTCDATE())
declare @EmlMsg as nvarchar(300)=''
--IF @MyIndex='CX_Type_Agent_Time'
--SELECT TOP (1) @EmlMsg=RTRIM([ResultData])+EventType 
--  FROM $(ICC).[dbo].[CallEvent] WITH (INDEX(CX_Type_Agent_Time)) 
--  WHERE TimeUTC>@from AND EventType='IvrScriptA' AND ReferenceData='Error' 
--  AND Timelocal>@from
--  AND ResultData not like '%SetTarget:invalid target%'
IF @MyIndex=''
 SELECT TOP (1) @EmlMsg=RTRIM([ResultData])+EventType 
  FROM ICC.[dbo].[CallEvent] WITH (INDEX(CX_TimeLocal_AgentId))
  WHERE Timelocal>@from AND EventType='IvrScriptA' AND ReferenceData='Error'  
  AND ResultData not like '%SetTarget:invalid target%'
ELSE
 BEGIN
   SET @EmlMsg='' -- Tady musím zavolat proceduru, která vrátí výsledek
 END
	  
  RETURN @EmlMsg


END
GO

