/****** Script for SelectTopNRows command from SSMS  ******/
SELECT Phase1.*,LEFT(DQ.QueryText,60) AS QText FROM (
SELECT DataQueryId,COUNT(1) AS Pocet 

  FROM [iCC].[dbo].[DataQueryColumn] WHERE DisplayName IN ('Duration','Agent','Direction','State','Email','Number','Phase','Time','Project','Chat Nick')


  GROUP BY DataQueryId  ) AS Phase1
  LEFT JOIN DataQuery DQ ON DQ.DataQueryId=Phase1.DataQueryId
    WHERE DQ.Deleted=0 AND Pocet=9 -- >
  --ORDER BY DataQueryId