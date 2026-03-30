/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) *
  FROM [Agent] WHERE 1=1
   --AND Agentid='f6ad8d16-0d4e-4003-86c5-dc438e76dc83'
   AND DisplayName LIKE '%hurban%'
  ORDER BY DisplayName