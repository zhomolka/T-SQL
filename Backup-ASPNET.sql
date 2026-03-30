-- Zálohuje èásti tabulek a potom je pøípadnì maže 
DECLARE @from AS datetime=convert(datetime, '2017.01.05')
DECLARE @to AS datetime=convert(datetime, '2017.01.06')
DECLARE @cfrom AS NVARCHAR(100)='convert(datetime, '''+CONVERT ( nvarchar(10), @from , 102 )+''')'
DECLARE @cto AS NVARCHAR(100)='convert(datetime, '''+CONVERT ( nvarchar(10), @To , 102 )+''')'

DECLARE @MyTable AS NVARCHAR(40)='aspnet_Users' --'Message'
DECLARE @Command AS NVARCHAR(300)

--DECLARE @Condition AS NVARCHAR(300)=' WHERE SubjectField LIKE '+'''Test Atlantis%'''+'AND TimeUtC> '+@cfrom+' AND TimeUtC< '+@cto
DECLARE @Condition AS NVARCHAR(300)=''

--SELECT @Condition
--RETURN
--AND TimeUtc BETWEEN @from AND @to - toto je pomalé
--SELECT 'select * into Icc_Backup.dbo.'+@MyTable+' from iCC.dbo.'+@MyTable+@Condition
/*
*/
select * into ASPNET_iCC_Backup.dbo.aspnet_PersonalizationAllUsers from ASPNET_iCC.dbo.aspnet_PersonalizationAllUsers
select * into ASPNET_iCC_Backup.dbo.aspnet_PersonalizationPerUser from ASPNET_iCC.dbo.aspnet_PersonalizationPerUser
select * into ASPNET_iCC_Backup.dbo.aspnet_Users from ASPNET_iCC.dbo.aspnet_Users




