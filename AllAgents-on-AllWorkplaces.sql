USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[MazaniDB]    Script Date: 22.6.2016 8:25:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
[‎01.‎07.‎2016 12:17] Roman Peterský: 
INSERT INTO Seating SELECT newid() SeatingId, 
AgentId, 
Workplace.WorkplaceId as WorkplaceId, 
0 as KnowlegeOffset, 
'Phone;CCStates;WebCaller;WebClient' as LoginClientModels, 
'Phone;CCStates;WebCaller;WebClient' as UseClientModels
from Agent cross join Workplace where 
Agent.Deleted = 0 and Workplace.Deleted = 0
Order by AgentId, Workplace.WorkplaceId  

END

GO

