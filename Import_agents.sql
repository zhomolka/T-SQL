USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[Import_agents]    Script Date: 22.10.2024 13:39:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 5.10.2022
-- Description:	Import agentů
-- =============================================


CREATE PROCEDURE [dbo].[Import_agents]
 --@csvFilePath nvarchar(500)
 --,@csvErrorFilePath nvarchar(500)
AS

BEGIN
 
    DECLARE @Loguj AS Bit=1
	DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
	DECLARE @Popis AS nvarchar(MAX)

DECLARE @row_terminator CHAR;
SET @row_terminator = CHAR(13) + CHAR(10) --'0x0A' -- '\n'; --char(13) -- or '\r\n' or char(10)
DECLARE @RowCount NVARCHAR(10)=
(SELECT * FROM OPENROWSET(
   BULK  '\\szdc000phant171.d01.uadf.cz\sap\ROZHRANI\HR\Frontstage\ZE_SAP\info.csv'
	  ,SINGLE_CLOB
   ,ERRORFILE = '\\szdc000phant171.d01.uadf.cz\sap\ROZHRANI\HR\Frontstage\ZE_SAP\errorInf.log'
  ) AS DataFile)

DECLARE @stmt NVARCHAR(2000);
IF OBJECT_ID(N'tempdb..##TMP', N'U') IS NOT NULL DROP TABLE ##TMP
    create table ##tmp (
	   [OsobniCislo] nvarchar(100)
      ,[Jmeno] nvarchar(100)
      ,[Pozice] nvarchar(100)
      ,[OrganizacniJednotka] nvarchar(100)
      ,[Email] nvarchar(100)
      ,[Login] nvarchar(100)
     );

	 DELETE FROM [FS_custom].[dbo].[InsertAgents]

SET @stmt = '
  BULK INSERT ##tmp
   FROM ''\\szdc000phant171.d01.uadf.cz\sap\ROZHRANI\HR\Frontstage\ZE_SAP\export.csv''
   WITH 
      (
	  KEEPIDENTITY,
        firstrow=2,
FIELDTERMINATOR = '';''  ,
CODEPAGE = ''65001'',
ROWS_PER_BATCH=1000
   ,ROWTERMINATOR='''+@row_terminator+'''
   ,Lastrow = '+@RowCount+'
   ,ERRORFILE = ''\\szdc000phant171.d01.uadf.cz\sap\ROZHRANI\HR\Frontstage\ZE_SAP\error.log''
   )'
exec sp_executesql @stmt;

-- Odstranění levostranných nul:
UPDATE ##tmp
SET OsobniCislo = CAST(CAST(OsobniCislo AS REAL) AS NVARCHAR(100))
UPDATE ##tmp
SET OrganizacniJednotka = 'Zpracovatel_Leader' WHERE Jmeno='Illiaš Marek'

INSERT INTO FS_Custom.dbo.InsertAgents (OsobniCislo, Jmeno, Pozice, OrganizacniJednotka, Email, Login)
SELECT DISTINCT OsobniCislo, Jmeno, Pozice , OrganizacniJednotka, Email, Login FROM ##tmp --WHERE Login LIKE '%\%'
/**/

IF OBJECT_ID(N'tempdb..##TMP', N'U') IS NOT NULL DROP TABLE ##TMP

--EXEC master.sys.sp_executesql @sql;


	   SET @Popis = 'Import new Agents was performed' -- +convert(nvarchar(MAX), @VoiceRecordId)
	   EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
 
 END 

GO

