USE [FS_Custom]
GO

/****** Object:  Table [dbo].[Eventlog]    Script Date: 10.09.2021 8:34:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- CT = Create Table
-- II = Insert Ids
-- UD = Update Data
DECLARE @Control AS VARCHAR(2) = 'UD'

IF @Control='CT'
CREATE TABLE [dbo].[Ids](
	[Id] [UniqueIdentifier] NULL
) 


IF @Control='II'
 BEGIN  
	delete from FS_Custom.dbo.Ids
	BULK INSERT FS_Custom.dbo.Ids
	FROM 'c:\Ids.csv'
	WITH
	(
		FIRSTROW = 2,
		codepage=65001,
		FIELDTERMINATOR = ',',  --CSV field delimiter '","' - toto nefungovalo
	   ROWTERMINATOR ='0x0A',   --Use to shift the control to next row
		TABLOCK )
END

IF @Control='UD'
 BEGIN  
 DECLARE @Id AS UniqueIdentifier 
--SET @from=GETDATE()-2
 DECLARE My_cursor CURSOR FOR   
 SELECT TOP 1 /**/ Id  FROM .dbo.Ids IC WITH (NOLOCK)
 
   OPEN my_cursor 

  FETCH NEXT FROM My_cursor INTO @Id    
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @Id  IS NOT NULL
		BEGIN

			DELETE FROM SREC.dbo.VoiceRecord where VoiceRecordID = @Id 

			DELETE FROM SREC.dbo.DeviceEvent where VoiceRecordId = @Id

			DELETE FROM SREC.dbo.CustomNote where VoiceRecordId = @Id

			DELETE FROM SREC.dbo.Matching where VoiceRecordId = @Id 

			DELETE FROM SREC.dbo.Transcription where VoiceRecordId = @Id 

			DELETE FROM SREC.dbo.Statistic where VoiceRecordId = @Id 

			DELETE FROM SREC.dbo.Keyword where VoiceRecordId = @Id 

			DELETE FROM SREC.dbo.DeviceEvent where VoiceRecordId = @Id
			
			DELETE FROM iCC.dbo.Callrecord where RecordFileId = @Id
		END
		FETCH NEXT FROM My_cursor INTO @Id  
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;

 END

 
GO


