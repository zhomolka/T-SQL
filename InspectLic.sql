USE Proserver
select PBX.DisplayName AS Ustredna,count(*) AS Pocet from .dbo.extension EX
  LEFT JOIN .dbo.Pbx ON PBX.PBXid=EX.PBXid
 where EX.Deleted=0 AND Suspended=0 -- Kontrola licencí na ProServeru
 GROUP BY  PBX.DisplayName
