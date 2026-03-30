/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [SeatingId]
      ,SEA.[AgentId]
	  ,IIF(A.AgentId IS NULL,'FREE','OCCUPIED') AS Status
	  , WP.DisplayName AS WPName
      ,WP.[WorkplaceId]
	  ,WP.Deleted
      ,[KnowledgeOffset]
      ,[LoginClientModels]
      ,[UseClientModels]
      ,[Preference]
  FROM [iCC].[dbo].[Seating] SEA
       LEFT JOIN [iCC].[dbo].Workplace WP ON WP.WorkplaceId=SEA.WorkplaceId
	   LEFT JOIN Agent A ON WP.WorkplaceId=A.WorkplaceId
	   LEFT JOIN Agent AG ON SEA.AgentId=AG.AgentId
  WHERE 1=1
  --AND SEA.agentId LIKE '1bbba420-2834-4c5c-bc4a-20d6a601891c'
  AND (WP.WorkplaceId IS NULL OR WP.Deleted=1 OR AG.AgentId IS NULL OR AG.Deleted=1)