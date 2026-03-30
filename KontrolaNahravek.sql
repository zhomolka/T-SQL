USE [Frontstage_Custom]
GO

/****** Object:  StoredProcedure [dbo].[CheckRecAndEmlActivity]    Script Date: 9. 7. 2018 12:41:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- 19.3.2018 Byly tyto dvì adresy vypuštìny ze seznamu RemoteAddress a ToField: moncolova@jtbanka.sk a petrovova@jtbank.cz
CREATE PROCEDURE [dbo].[CheckRecAndEmlActivity] 
AS
BEGIN
       declare @Today as datetime = GETDATE()
	   declare @Pred15min as datetime = DATEADD(MINUTE, -15, @Today )	-- Pøed 15 min

-- Pokud je DNES nadefinovaný svátek procedura se ukonèí
       IF(EXISTS(SELECT * FROM frontstage_icc.dbo.Holiday as H where H.HolidayGroupName LIKE 'Svatky%' AND H.TimeMode='SingleDay' AND CAST(H.TimeFrom as DATE)=CAST(@Today AS DATE))) RETURN
       IF(EXISTS(SELECT * FROM frontstage_icc.dbo.Holiday as H where H.HolidayGroupName LIKE 'Svatky%' AND H.TimeMode='DayInYear' AND DATEPART(DAY,H.TimeFrom)=DATEPART(DAY,@Today) AND DATEPART(MONTH,H.TimeFrom)=DATEPART(MONTH,@Today))) RETURN
	   IF(EXISTS(SELECT * FROM frontstage_icc.dbo.Holiday as H where H.HolidayGroupName LIKE '%TECH' AND H.TimeMode='SingleDay' AND CAST(H.TimeFrom as DATE)=CAST(@Today AS DATE))) RETURN

 	declare @Interval as int

	IF DATEPART(HOUR,GETDATE()) BETWEEN 8 AND 17
		SET @Interval = 15	 
	ELSE
		SET @Interval = 35


	declare @Now as datetime = GETUTCDATE()
	declare @Last as datetime = DATEADD(MINUTE, -@Interval, @Now )
	declare @WeekAgo as datetime = DATEADD(DAY, -7, @Now )
	declare @LastWeekAgo as datetime = DATEADD(DAY, -7, @Last )

	declare @T as nvarchar(120) = CONVERT(nvarchar(20), DATEADD(MINUTE, -@Interval, @Today), 20) + ' - ' + CONVERT(nvarchar(20), @Today, 8)

       declare @RecNow as int = (select count(*) from Frontstage_Srec.dbo.VoiceRecord as R WITH(NOLOCK) where DATEDIFF(ss,R.StartTimeUtc,R.EndTimeUtc)>1 AND R.StartTimeUtc<=@Now AND R.StartTimeUtc>=@Last)
       declare @RecWeekAgo as int = (select count(*) from Frontstage_Srec.dbo.VoiceRecord as R WITH(NOLOCK) where DATEDIFF(ss,R.StartTimeUtc,R.EndTimeUtc)>1 AND R.StartTimeUtc<=@WeekAgo AND R.StartTimeUtc>=@LastWeekAgo)
 	   

	   declare @InCalls as int = (SELECT Count(*) FROM Frontstage_iCC.dbo.InboundCall as I WITH(NOLOCK) WHERE I.TimeUtc>=@Last AND I.TimeUtc<=@Now AND I.CallDuration>1 AND CallResult='Served')
	   declare @OutCalls as int = (SELECT Count(*) FROM Frontstage_iCC.dbo.OutboundCall as O WITH(NOLOCK) WHERE O.ScheduleTime>=@Pred15min AND O.ScheduleTime<=@Today AND O.CallDuration>1 AND CallResult<>'Active')

	   declare @RecMsg as nvarchar(400) = 'T=' + @T + ' R-now='+ CONVERT(nvarchar(10),@RecNow) + ' R-weekago=' + CONVERT(nvarchar(10),@RecWeekAgo) + ' InCalls=' + CONVERT(nvarchar(10),@InCalls) + ' OutCalls=' + CONVERT(nvarchar(10),@OutCalls)

	 


       IF( (@RecNow<@RecWeekAgo/5 OR @RecNow=0) AND @RecWeekAgo>0 ) AND (@InCalls+@OutCalls>0) AND ((@InCalls+@OutCalls)>@RecNow)
       BEGIN
			INSERT INTO Frontstage_Custom.dbo.CheckRecording (Action, State, TimeUtc, RecNow, RecWeekAgo, InCalls, OutCalls)
			VALUES ('False', 'Varování - Poèet hovorù vìtší než poèet nahrávek.', GETUTCDATE(), @RecNow, @RecWeekAgo, @InCalls, @OutCalls)
	
			 insert into frontstage_icc.dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText)
             values(@Now,'Email','Scheduled','Active', 'smtp-pa@jtfg.com', 'ITPAL2@jtfg.com,error@atlantis.cz','ITPAL2@jtfg.com,error@atlantis.cz','1e518945-c421-4e70-aff1-c571cc68d5d1',99,'O',
             'J&T Banka-Varování: nízký poèet nahrávek ' + CONVERT(nvarchar(10),@RecNow), @RecMsg, @RecMsg )
		
       END
	   ELSE IF (@InCalls+@OutCalls>0) AND ((@InCalls+@OutCalls)>@RecNow)
       BEGIN
			INSERT INTO Frontstage_Custom.dbo.CheckRecording (Action, State, TimeUtc, RecNow, RecWeekAgo, InCalls, OutCalls)
			VALUES ('False', 'Varování - Poèet hovorù vìtší než poèet nahrávek.', GETUTCDATE(), @RecNow, @RecWeekAgo, @InCalls, @OutCalls)
	
			 insert into frontstage_icc.dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText)
             values(@Now,'Email','Scheduled','Active', 'smtp-pa@jtfg.com', 'simonik@jtbank.cz,hnasova@jtbank.cz','simonik@jtbank.cz,hnasova@jtbank.cz','1e518945-c421-4e70-aff1-c571cc68d5d1',99,'O',
             'J&T Banka-Varování: nízký poèet nahrávek ' + CONVERT(nvarchar(10),@RecNow), @RecMsg, @RecMsg )

			RETURN		
       END
	   ELSE
	   BEGIN
			INSERT INTO Frontstage_Custom.dbo.CheckRecording (Action, State, TimeUtc, RecNow, RecWeekAgo, InCalls, OutCalls)
			VALUES ('True', 'Modul nahrávání v poøádku.', GETUTCDATE(), @RecNow, @RecWeekAgo, @InCalls, @OutCalls)
	   END

	
END

GO

