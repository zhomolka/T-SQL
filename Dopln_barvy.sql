 BEGIN TRANSACTION
UPDATE iCC.dbo.DataQueryColumn
SET  CSS = 'info'
WHERE  Color IN ('#F3F3C8','#DED9DB','#FFB870','#ffc000','#c5b5fe','#C0C0FF','XX')-- žlutá
    AND ISNULL(CSS,'')=''

UPDATE iCC.dbo.DataQueryColumn
SET  CSS = 'warning'
WHERE  Color IN ('#FFE9D1','#fffc96','#ffa700','#FFC000','#FFE9D1','#C5B5FE','#70AD47','#ffcc99','#FFE0E0','#F3F3C8','#FFE0E0','XX')-- oranžová
   AND ISNULL(CSS,'')=''
UPDATE iCC.dbo.DataQueryColumn
SET  CSS = 'danger'
WHERE  Color IN ('#FFC080','#FFBFBF','#FF8080','#FB6767','#fff2cc','#00b0f0','#FFFFC9','XX')-- èervená
   AND ISNULL(CSS,'')=''

UPDATE iCC.dbo.DataQueryColumn
SET  CSS = 'active'
WHERE  Color IN ('#E1FCFC','#DED9DB','#CCFFFF','#C0C0FF','#00C8FF','#ff9999','#bbc56b','#FF0000','#E0F0FF','#ffff00','#E0FFFF','XX')-- modrá
   AND ISNULL(CSS,'')=''

UPDATE iCC.dbo.DataQueryColumn
SET  CSS = 'success'
WHERE  Color IN ('#CCFADF','#b3ffb3','#CCFADF','#FF0000','#ff8080','XX')-- zelená
   AND ISNULL(CSS,'')=''
--SET  Width = 80
--WHERE  Width<80 AND DisplayName LIKE 'Èas%'


COMMIT TRANSACTION

--ROLLBACK TRANSACTION
