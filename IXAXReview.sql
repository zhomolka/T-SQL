USE iCC
SELECT  OBJECT_NAME(ix.ID) AS TableName, ix.name AS IXName
        , ax.Name AS AXName
		,'AX_'+OBJECT_NAME(ix.ID)+'_'+SUBSTRING(ix.name,4,50) AS Test
       FROM  sysindexes ix
	   LEFT JOIN sysindexes ax ON ax.name= 'AX_'+OBJECT_NAME(ix.ID)+'_'+SUBSTRING(ix.name,4,50)
       WHERE   ix.Name IS NOT NULL AND SUBSTRING(ix.Name, 1, 3) = 'IX_'
	   AND ax.Name IS NOT NULL--
	   ORDER BY OBJECT_NAME(ix.ID)