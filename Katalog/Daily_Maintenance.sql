USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[Daily_Maintenance]    Script Date: 4. 12. 2020 16:43:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <12.12.2019>
-- Description:	<Denní údržba nastavení Frontstage>
-- =============================================
-- ALTER
CREATE
 PROCEDURE [dbo].[Daily_Maintenance]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Vypnuto AS NVARCHAR(5)='false'
	DECLARE @DoplnVelikonoce AS NVARCHAR(5) = @Vypnuto
	EXEC .dbo.GiveParam2 'DoplnVelikonoce', @DoplnVelikonoce OUTPUT,'Automatické doplňování velikonočních svátků'
	DECLARE @DoplnMimoPrac AS NVARCHAR(5) = @Vypnuto
	EXEC .dbo.GiveParam2 'DoplnMimoPrac',@DoplnMimoPrac OUTPUT,'Doplňování indikace mimopracovní doby'
    DECLARE @PracDobaChatu  AS NVARCHAR(5) = @Vypnuto
	EXEC .dbo.GiveParam2 'PracDobaChatu',@PracDobaChatu OUTPUT,'Provádění úprav pracovních dob chatů'
	DECLARE @DoplnproServer  AS NVARCHAR(5) = @Vypnuto
	EXEC .dbo.GiveParam2 'DoplnproServer',@DoplnproServer OUTPUT,'Doplňování nastavení ProServeru (Toaster)'
	
	DECLARE @Zprava NVARCHAR(200)= 'Vstupní bod'
   EXEC  .[dbo].[WriteEvent] 1,'Daily_Maint',@Zprava

   -- Uzavření neuzavřených SPAMů:
   UPDATE  .[dbo].[Message]
  --SET MessagePhase='Scheduled',MessageResult='Active'
  SET MessagePhase='Closed',MessageResult='Closed',Mark=77
  WHERE 1=1
    AND ISNULL(SpamLevel,0) > 0
	AND MessagePhase<>'Closed' AND MessageResult<>'Closed'

-- Doplnění velikonoc:
   declare @Holiday as nvarchar(40) =.dbo.GiveParam('Holiday')
   IF @DoplnVelikonoce='true' AND DATEPART(MONTH,GETDATE()) <=4 AND @Holiday IS NOT NULL
     BEGIN
		 DECLARE @ROK AS Int = DATEPART(YEAR,GETDATE())
		 DECLARE @m AS Int = 24
		 DECLARE @n AS Int = 5
		 DECLARE @a AS Int = @ROK % 19
		 DECLARE @b AS Int = @ROK % 4
		 DECLARE @c AS Int = @ROK % 7
		 DECLARE @d AS Int = (19 * @a + @m) % 30
		 DECLARE @e AS Int = (@n + 2 * @b + 4 * @c + 6 * @d) % 7
		 DECLARE @POBREZEN AS Int = (22 + @d + @e)  + 1
		 --DECLARE @PABREZEN AS Int = (22 + @d + @e)  - 2
		 DECLARE @DUBEN AS Int = (@d + @e - 9) + 1
		 DECLARE @DEN AS Int 
		 DECLARE @Datum AS DateTime
		 DECLARE @MESIC AS Int 
		 DECLARE @I AS Int = 0
		 IF @DUBEN>0
		   BEGIN
			 SET @DEN=@DUBEN
			 SET @MESIC=4
		   END
		 ELSE
			BEGIN
			 SET @DEN=@POBREZEN
			 SET @MESIC=3
		   END
		  --  Vytvořím datum a čas
		  SET @Datum=CONVERT(DateTime,convert(NVARCHAR(4),@Rok)+'.'+convert(NVARCHAR(2),@Mesic)+'.'+convert(NVARCHAR(2),@DEN))
		  --SELECT @POBREZEN AS PondBrezen,@DUBEN AS Duben, @Datum
		  WHILE @i<2
		   BEGIN
		  IF NOT EXISTS(SELECT * FROM ICC.dbo.Holiday WHERE TimeFrom=@Datum AND HolidayGroupName=@Holiday)
		   INSERT INTO ICC.[dbo].[Holiday]
				   ([DisplayName]
				   ,[HolidayGroupName]
				   ,[TimeMode]
				   ,[TimeFrom]
				   ,[TimeTo]
					)
			 VALUES
				   (
				   'Velikonoce'
				   ,@Holiday
				   ,'SingleDay'
				   , @Datum 
				   , CONVERT(DateTime,SUBSTRING(CONVERT(NVARCHAR(24),@Datum,126),1,10)+' 23:59')
				   )
			  SET @Datum=DATEADD(Day,-3,@Datum)
			  SET @i=@i+1
		   END
END
-- Údržba pracovní doby Chatů
IF @PracDobaChatu='true' AND EXISTS(SELECT * FROM ICC.dbo.ChatGateCondition WHERE Signal='Closed') AND OBJECT_ID(N'FS_CUSTOM..HolidayPlan', N'U') IS NOT NULL
  BEGIN
    DECLARE @today AS Date=GETDATE()
    DECLARE @ChatWorkTime AS NVARCHAR(50)='CHATWT'
	DECLARE @ChatFrom AS DateTime
	DECLARE @ChatTo AS DateTime
	DECLARE @CharDateFrom AS NVARCHAR(24) 
	DECLARE @CharDateTo AS NVARCHAR(24)

	DECLARE @HolidayGroupName AS VARCHAR(50)
    DECLARE @RelId AS UniqueIdentifier
    DECLARE @PerformChange AS bit = 0
    DECLARE Hol_cursor CURSOR FOR SELECT  *  FROM dbo.HolidayPlan WHERE HolidayGroupName=@Holiday
	DECLARE Hol_cursor2 CURSOR FOR  SELECT  HP.HolidayGroupName,HP.RelId  FROM dbo.HolidayPlan HP
              LEFT JOIN dbo.HolidayPlan HP2 ON HP.RelId=HP2.RelId AND HP2.HolidayGroupName=@Holiday
              LEFT JOIN ICC.dbo.Holiday HO ON HP2.HolidayGroupName=HO.HolidayGroupName AND TimeMode='DayInYear' 
	             AND DATEPART(Month,@today)=DATEPART(Month,TimeFrom) AND DATEPART(Day,@today)=DATEPART(Day,TimeFrom)
				  WHERE HP.HolidayGroupName<>@Holiday AND HO.HolidayId IS NULL

    OPEN Hol_cursor 
	OPEN Hol_cursor2

  FETCH NEXT FROM Hol_cursor INTO @HolidayGroupName, @RelId   
  WHILE @@FETCH_STATUS = 0  
   BEGIN
    SET @CharDateFrom  = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeFrom FROM ICC.dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @CharDateTo = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeTo FROM ICC.dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	-- Zkontroluji, zda dnes není svátek:
	SELECT TOP 1 @ChatFrom=TimeFrom,@ChatTo=TimeTo FROM ICC.dbo.Holiday WHERE [HolidayGroupName]=@Holiday AND TimeMode='DayInYear' 
	  AND DATEPART(Month,@today)=DATEPART(Month,TimeFrom) AND DATEPART(Day,@today)=DATEPART(Day,TimeFrom)
	IF @ChatFrom IS NOT NULL
	  BEGIN
	    SET @ChatFrom = CONVERT(Datetime,@today) -- Vyrobím čas 0:00
		SET @ChatTo   = @ChatFrom
		SET @PerformChange=1
		--DELETE FROM Hol_cursor2 WHERE @RefId=RefId
		-- Teď musím do @Start a @End dosadit datumy z ChatGateCondition
		SET @ChatFrom = CONVERT(DateTime,@CharDateFrom+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatFrom,126),12,8))
		SET @ChatTo   = CONVERT(DateTime,@CharDateTo+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatTo,126),12,8))
		UPDATE ICC.[dbo].ChatGateCondition
			SET TimeFrom=@ChatFrom,
				TimeTo  =@ChatTo 
			WHERE ChatGateConditionId=@RelId
	  END
    FETCH NEXT FROM Hol_cursor INTO @HolidayGroupName, @RelId  
  END
  -- Teď zkontroluji pracovní doby (ne svátky)
  FETCH NEXT FROM Hol_cursor2 INTO @HolidayGroupName, @RelId   
  WHILE @@FETCH_STATUS = 0  
   BEGIN
    SET @CharDateFrom  = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeFrom FROM ICC.dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @CharDateTo   = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeTo FROM ICC.dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @PerformChange  = 0
	-- v Holiday najdu pracovní dobu dnešního dne
		SELECT @ChatFrom=TimeFrom,@ChatTo=TimeTo FROM ICC.dbo.Holiday WHERE [HolidayGroupName]=@HolidayGroupName AND @today>=CONVERT(Date,TimeFrom) AND @today<=CONVERT(Date,TimeTo)
		IF @ChatFrom IS NOT NULL
		  BEGIN	   
		   -- Teď musím do @Start a @End dosadit datumy z ChatGateCondition
		   SET @ChatFrom = CONVERT(DateTime,@CharDateFrom+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatFrom,126),12,8))
		   SET @ChatTo   = CONVERT(DateTime,@CharDateTo+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatTo,126),12,8))
			UPDATE ICC.[dbo].ChatGateCondition
			   SET TimeFrom=@ChatFrom,
				   TimeTo  =@ChatTo 
			 WHERE ChatGateConditionId=@RelId
		  END
     FETCH NEXT FROM Hol_cursor2 INTO @HolidayGroupName, @RelId  
   END
  CLOSE Hol_cursor;  
  DEALLOCATE Hol_cursor;
  CLOSE Hol_cursor2;  
  DEALLOCATE Hol_cursor2;
  END
  --------------------------------- úklid splněných importů kampaní ------------------------
  IF 1=1
    BEGIN
	  DECLARE @from1 AS datetime=DATEADD(Month,-3,GETDATE())
	  DECLARE @from2 AS datetime=DATEADD(Month,-4,GETDATE())
	    -- Nastavím importy jako neaktivní
		UPDATE ICC.[dbo].[OutboundListImport]
		  SET  Active=0 
		WHERE Deleted=0
		AND Active=1
		AND TimeUTC<@from1
		AND FS_CUSTOM.dbo.[isOutboundImpComplete](OutboundListImportId)=1
	    -- Zruším  neaktivní importy
		UPDATE  ICC.[dbo].[OutboundListImport]
			SET Deleted=1
		   WHERE Deleted=0
			AND Active=0
			AND TimeUTC<@from2
            AND FS_CUSTOM.dbo.[isOutboundImpComplete](OutboundListImportId)=1
	END

IF @DoplnproServer='true'
   BEGIN
	   EXEC PridejPravaPoslechu
	   EXEC ProServerSync_Toaster
   END

------------------------------------------------------------------------------------------------------
 IF @DoplnMimoPrac='true'
   BEGIN


-- Údržba značek MimoPracovní doby:
 --USE $(FS_CUSTOM)
 DECLARE @from AS datetime=DATEADD(Day,-6,GETDATE()) -- Jak daleko do minulosti se dívat
 DECLARE @PilotTime AS datetime
 DECLARE @InboundcallId AS UniqueIdentifier = '00000000-0000-0000-0000-000000000000'
 DECLARE My_cursor CURSOR FOR   
 SELECT /*TOP 10*/ PilotTime,IC.InboundCallId  FROM ICC.dbo.InboundCall IC WITH (NOLOCK)
   LEFT JOIN ICC.dbo.callevent ce WITH (NOLOCK) ON IC.InboundCallId=CE.InboundCallId AND CE.referencedata = 'NopOK' and CE.ResultData = 'MIMOPRAC'
   --LEFT JOIN ICC.dbo.callevent ce2 WITH (NOLOCK) ON IC.InboundCallId=CE2.InboundCallId AND CE2.referencedata = 'NopOK' and CE2.ResultData = 'WHITELIST'
   WHERE PilotTime>@from AND dbo.IsWorkTime4(PilotTime,'PracDoba')=0.
   AND CE.InboundCallId IS NULL --AND CE2.InboundCallId IS NULL
   OPEN my_cursor 

  FETCH NEXT FROM My_cursor INTO @PilotTime, @InboundcallId    
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @InboundcallId  IS NOT NULL
		BEGIN
		  -- Zapiš do $(ICC).dbo.callevent chybějící záznam
          INSERT INTO ICC.[dbo].[CallEvent]
           ( [TimeUTC]
           , [TimeLocal]
           ,[EventType]
           ,[InboundCallId]
           ,[ReferenceData]
           ,[ResultData]
           )
          VALUES
           (GETUTCDATE()
           ,@PilotTime
           ,'IvrScriptA'
           ,@InboundCallId
           ,'NopOK'
           ,'MIMOPRAC'
            )
		END
		FETCH NEXT FROM My_cursor INTO @PilotTime, @InboundcallId  
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;

  END

	   SET @Zprava = 'Konec procedury'
       EXEC  .[dbo].[WriteEvent] 1,'Daily_Maint',@Zprava

END

GO

