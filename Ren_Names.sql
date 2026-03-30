	DECLARE @OrigName AS NCHAR(120)
    DECLARE @NewName AS NCHAR(120)
    DECLARE @Renameid AS UniqueIdentifier
    DECLARE Ren_cursor CURSOR FOR SELECT OrigName, NewName , Renameid  FROM FS_Custom.dbo.Rename WHERE Result<>'OK'
    OPEN Ren_cursor 

  FETCH NEXT FROM Ren_cursor INTO @OrigName, @NewName , @Renameid 
  WHILE @@FETCH_STATUS = 0  
   BEGIN
	IF @OrigName IS NOT NULL
	  BEGIN
	    IF EXISTS(SELECT TOP 1 1 FROM iCC.dbo.Agent WHERE DisplayName=@OrigName)
		  BEGIN
			UPDATE iCC.[dbo].Agent
			SET DisplayName=@NewName
			WHERE DisplayName=@OrigName
			UPDATE FS_Custom.dbo.Rename
			SET Result='OK'
			WHERE Renameid =@Renameid 
	      END
      END
    FETCH NEXT FROM Ren_cursor INTO @OrigName, @NewName , @Renameid  
   END
  CLOSE Ren_cursor;  
  DEALLOCATE Ren_cursor;
  