USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[PharmMaintenance]    Script Date: 3. 10. 2022 9:23:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <30.08.2022>
-- Description:	<Údržba lékáren>
-- =============================================
CREATE PROCEDURE [dbo].[PharmMaintenance]
 @CommandId AS UniqueIdentifier
AS
BEGIN
  DECLARE @cLekarny AS NVARCHAR(3) 
  DECLARE @Redirector AS NVARCHAR(5) 

DECLARE @today AS Date=GETDATE()
DECLARE @Timelocal AS DateTime
DECLARE @ProfStatus AS nvarchar(16)
DECLARE @Status AS nvarchar(16)
DECLARE @Number AS nvarchar(16)
DECLARE @DisplayName AS nvarchar(120)
--DECLARE @CommandId AS UniqueIdentifier
DECLARE @Proficiency AS int
DECLARE My_cursor CURSOR FOR   
 SELECT  DisplayName,Proficiency,CommandId,Timelocal,ProfStatus,Status,Number FROM .[dbo].[Pharmacies] WITH (NOLOCK) 
  WHERE (CommandId =@CommandId OR @CommandId IS NULL) AND 
  (ProfStatus IN ('Scheduled','Completed') OR  Status IN ('Scheduled','ProServer','ProRestart','Ready'))

   OPEN my_cursor 
  FETCH NEXT FROM My_cursor INTO @DisplayName,@Proficiency,@CommandId,@Timelocal,@ProfStatus,@Status,@Number
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @DisplayName IS NOT NULL AND @DisplayName<>''
		BEGIN
		 IF CONVERT(Date,@Timelocal)=@today AND @ProfStatus='Scheduled'
		  -- Aktualizace Proficiency v Redirektorech:
		  BEGIN
			  SET @cLekarny   = SUBSTRING(@DisplayName,1,3)
			  SET @Redirector = '70'+@cLekarny

			  UPDATE iCC.dbo.Redirector
				 SET Proficiency = @Proficiency
			   WHERE Number = @Redirector
			  UPDATE .[dbo].[Pharmacies]
				 SET ProfStatus = 'Completed'
			   WHERE CommandId  = @CommandId 
           END
		 IF (@Status='Scheduled' /*AND @ProfStatus IS NULL*/) 
		  BEGIN
		    EXEC .dbo.NewAgent @DisplayName,@Number
			EXEC .dbo.PharmNewForm
			UPDATE .[dbo].[Pharmacies]
				 SET Status = 'Ready'
			   WHERE CommandId  = @CommandId 

		  END

		 --IF (@Status='Scheduled' AND @ProfStatus IS NULL) OR @ProfStatus ='Completed'
		 IF (@Status='Ready' AND @ProfStatus IS NULL) OR @ProfStatus ='Completed'
		  -- Nastavení příznaku otestování telefonie operátorem (Jirkou Machačkou)
		  BEGIN
		    --EXEC .dbo.NewAgent @DisplayName,@Number
			  UPDATE .[dbo].[Pharmacies]
				 SET Status = 'Tested'
			   WHERE CommandId  = @CommandId 

		  END
		END
		IF @Status='ProServer'
		  BEGIN
		    EXEC .dbo.NewNumber @Number
			  UPDATE .[dbo].[Pharmacies]
				 SET Status = 'ProRestart'
			   WHERE CommandId  = @CommandId 

		  END
		IF @Status='ProRestart' AND ISNULL((SELECT TOP 1 1 FROM ProServer.dbo.[Extension] WHERE Number=@Number AND Deleted=0 AND OnLineStatus=0),0)=1
		  BEGIN
			  UPDATE .[dbo].[Pharmacies]
				 SET Status = 'Scheduled'
			   WHERE CommandId  = @CommandId 

		  END


		FETCH NEXT FROM My_cursor INTO @DisplayName,@Proficiency,@CommandId,@Timelocal,@ProfStatus,@Status,@Number 
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;
END

GO

