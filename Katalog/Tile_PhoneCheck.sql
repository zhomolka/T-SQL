USE [FS_Custom]
GO
/****** Object:  UserDefinedFunction [dbo].[Tile_PhoneCheck]    Script Date: 13.03.2023 13:53:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:           <Václav Kubát>
-- Create date: <19.4.2020>
-- Description:      <kontrola pripojeneho SW tel.>
-- =============================================
ALTER FUNCTION [dbo].[Tile_PhoneCheck] 
(
@MeAgentId uniqueidentifier
)
RETURNS 
@Tile TABLE 
(
       Rank int
       ,Text nvarchar (40)
       ,Number nvarchar (40)
       ,BackColor nvarchar (10)
       ,FrontColor nvarchar (10)
       ,Glyph nvarchar (30)
       ,Url nvarchar (200)

)
AS
BEGIN
/*
declare @MeAgentId as uniqueidentifier = (select  agentid from iCC.dbo.Agent with (nolock) where SystemName like '%atkubavpn%')
*/


--OnLineStatus
       --7 - ExtensionNotAlive 
       --0 - OK 
declare @AgentOnline as bit = (select case when Activity = 'Logoff' then 0 else 1 end from icc.dbo.Agent where AgentId = @MeAgentId)
declare @Workplace_OnLineStatus as int 
/*zakomentovat na Grafikovipoku neni ProServer*/
       = (select OnLineStatus from ProServer.dbo.Extension as e with (nolock)
       where Number = (select Number from iCC.dbo.Agent a with (nolock) 
                                                                                         inner join iCC.dbo.Workplace as w with (nolock) on w.WorkplaceId = a.workplaceid
                                                                                         where AgentId = @MeAgentId) and Deleted = 0)
       
insert into @Tile 
                     SELECT 1 as rank
                           ,case when @Workplace_OnLineStatus is null then 'check Function' else 'ProServer Exten. status' end as Text
                           ,case when @Workplace_OnLineStatus is null then 'ERROR' when @Workplace_OnLineStatus = 0 then 'OK' else '-' end AS Number
                           ,case when @Workplace_OnLineStatus is null then '#00f7ff' when @AgentOnline = 0 then '#f2f2f2' when @Workplace_OnLineStatus = 0 then '#b3ffb3'  else '#ff3300' end
                                  as BackColor
                           ,case when @Workplace_OnLineStatus is null then '#000000' when @Workplace_OnLineStatus = 0 then '#000000' else '#ffffff' end
                                  as FrontColor
                           ,case when @Workplace_OnLineStatus is null then 'fa fa-question' when @Workplace_OnLineStatus = 0 then 'fa fa-thumbs-o-up' else 'fa fa-thumbs-down' end
                                  as Glyph
                           ,'' as Url
       RETURN 
END



