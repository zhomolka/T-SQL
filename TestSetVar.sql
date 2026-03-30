/* Toto nefunguje:
DECLARE @CMD VARCHAR(100)=':setvar iCC "iCC"'
EXEC (@CMD)
SELECT '$(iCC)'
*/
/*
DECLARE @Nic VARCHAR(10)='XXX'
DECLARE @Switch Int=1
:setvar FS_Custom "FS_Custom"
--:setvar iCC "iCC"
IF @Switch=1
  BEGIN
   SET @Nic='1'
   :setvar iCC "iCC"
  END
ELSE IF @Switch=2
  BEGIN
     SET @Nic='2'
  :setvar iCC "iCC_LE"
  END
*/

--SELECT ConfigurationValue FROM $(iCC).[dbo].[CONFIGURATION]  WHERE ConfigurationName='TOCC'
--PRINT $(iCC)
SELECT '$(ICC)'
SELECT '$(FS_CUSTOM)'

