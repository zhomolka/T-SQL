USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[SeatingsMaint]    Script Date: 2. 4. 2020 15:15:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <2.4.2020>
-- Description:	<Přidání pracovišť agentům podle jiného agenta>
-- =============================================
CREATE PROCEDURE [dbo].[SeatingsMaint]
 @AgentIdexm UniqueIdentifier -- Id agenta, podle nějž mají být umístění nastavena
 ,@TeamName NVARCHAR(100)     -- Jméno týmu, jehož agentům umístění nastavit
AS
BEGIN
IF @TeamName IS NULL SET @TeamName=(SELECT TOP 1 TeamName FROM [iCC].[dbo].[Agent] WITH (NOLOCK) WHERE AgentId=@AgentIdexm)

DECLARE @WorkplaceId UniqueIdentifier
DECLARE @UseClientModels NVARCHAR(512)
DECLARE @LoginClientModels NVARCHAR(512)
DECLARE SE_cursor CURSOR SCROLL FOR 
  SELECT [WorkplaceId]
      ,[LoginClientModels]
      ,[UseClientModels]
  FROM [iCC].[dbo].[Seating] WHERE Agentid=@AgentIdexm 

DECLARE @AgentId UniqueIdentifier
DECLARE My_cursor CURSOR FOR   
 SELECT  AgentId  FROM [iCC].[dbo].[Agent] WITH (NOLOCK)
  WHERE TeamName=@TeamName AND AgentId<>@AgentIdexm AND Deleted=0
   OPEN SE_cursor 
   OPEN My_cursor

  FETCH NEXT FROM My_cursor INTO @AgentId   
  WHILE @@FETCH_STATUS = 0 -- Proběhnu všechny agenty
    BEGIN
 	  IF @AgentId IS NOT NULL 
		BEGIN
		   FETCH FIRST FROM SE_cursor INTO @WorkplaceId, @UseClientModels, @LoginClientModels
           WHILE @@FETCH_STATUS = 0 -- Proběhnu všechna umístění
			BEGIN
 			  IF @WorkplaceId IS NOT NULL 
				BEGIN
		          IF NOT EXISTS((SELECT TOP 1 1 FROM [iCC].[dbo].[Seating] WHERE Agentid=@AgentId AND WorkplaceId=@WorkplaceId))
				    INSERT INTO iCC.[dbo].[Seating]
					   (
					    [AgentId]
					   ,[WorkplaceId]
					   ,[LoginClientModels]
					   ,[UseClientModels]
                        )
				 VALUES
					   (
					    @AgentId
					   ,@WorkplaceId
					   ,@LoginClientModels
					   ,@UseClientModels
	                   )
				END
				FETCH NEXT FROM SE_cursor INTO @WorkplaceId, @UseClientModels, @LoginClientModels 
		    END	
		END 
		FETCH NEXT FROM My_cursor INTO @AgentId    	 
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;
  CLOSE SE_cursor;  
  DEALLOCATE SE_cursor;

END

GO

