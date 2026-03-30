
USE iCC
DECLARE @maxRepDate datetime = (SELECT TOP 1(D) FROM Rep_Date ORDER BY D DESC)
IF(@maxRepDate is null) SET @maxRepDate = '2012-01-01 00:00:00'
ELSE SET @maxRepDate = DATEADD(DAY, 1, @maxRepDate)
IF @maxRepDate <= '2020-01-01 00:00:00' 
BEGIN
       declare @d as datetime = @maxRepDate
       while @d<'2030-01-01 00:00:00'
       begin
             insert into Rep_Date(D) VALUES(@d)
             set @d = DATEADD(DD,1,@d)
       end
END
IF (SELECT COUNT(*) FROM Rep_Time)=0 
BEGIN
       declare @t as time = '00:00:00'
       declare @q as char(1)
       while @t<'23:59:00'
       begin
             if DATEPART(minute,@t)=00 set @q='h'
             else if DATEPART(minute,@t) % 30 = 0 set @q='m'
             else if DATEPART(minute,@t) % 15 = 0 set @q='q'
             else if DATEPART(minute,@t) % 5 = 0 set @q='f'
             else set @q = ' '
             insert into Rep_Time(H,Q) VALUES(@t,@q)
             set @t =CAST( DATEADD(minute,1,@t) as time)
       end
END
