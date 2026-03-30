USE iCC
GO
--ALTER INDEX ALL ON [dbo].[Message] REORGANIZE
-- Když je fragmentace vìtší než 30%, ta je dobré použít:
--ALTER INDEX ALL ON dbo.[Workplace] REBUILD WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON,STATISTICS_NORECOMPUTE = ON)

 SELECT
        QUOTENAME(t.name) AS TableName,
        QUOTENAME(i.name) AS IndexName,
        s.avg_fragmentation_in_percent AS Fragmentation
    FROM
        sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) AS s
        JOIN sys.indexes AS i ON s.[object_id] = i.[object_id] AND s.index_id = i.index_id
        JOIN sys.tables AS t ON i.[object_id] = t.[object_id]
    WHERE
        --s.database_id = DB_ID() AND
        s.avg_fragmentation_in_percent >= 5
        AND i.name IS NOT NULL
        --AND i.type_desc IN ('CLUSTERED', 'HEAP')
        AND i.is_disabled = 0
        AND i.is_hypothetical = 0
		--AND t.name='WorkPlace'
ORDER BY s.avg_fragmentation_in_percent DESC