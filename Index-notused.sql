SELECT   DB_NAME() AS DATABASENAME, 
         OBJECT_NAME(B.OBJECT_ID) AS TABLENAME, 
         B.NAME AS INDEXNAME, 
         B.INDEX_ID 
FROM     SYS.OBJECTS A 
         INNER JOIN SYS.INDEXES B 
           ON A.OBJECT_ID = B.OBJECT_ID 
WHERE    NOT EXISTS (SELECT * 
                     FROM   SYS.DM_DB_INDEX_USAGE_STATS C 
                     WHERE  B.OBJECT_ID = C.OBJECT_ID 
                            AND B.INDEX_ID = C.INDEX_ID) 
         AND A.TYPE <> 'S' 
ORDER BY 1, 2, 3 