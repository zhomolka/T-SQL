RESTORE DATABASE MyTempCopy FROM DISK='C:\Atlantis-backup\DB\iCC20200219.bak'
WITH 
   MOVE 'iCC' TO 'D:\Temp\iCCRest.mdf',
   MOVE 'iCC_LOG' TO 'D:\Temp\iCCRest_log.ldf'