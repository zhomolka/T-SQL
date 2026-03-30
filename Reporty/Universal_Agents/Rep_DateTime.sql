USE [iCC]
GO

/****** Object:  UserDefinedFunction [dbo].[Rep_DateTime]    Script Date: 4. 1. 2019 16:18:13 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE FUNCTION [dbo].[Rep_DateTime]
(
	@From smalldatetime,
	@To smalldatetime,
	@Interval char(1) -- Y (rok),M (měsíc),W(týden),D(den),h(hodina),t(půlhodina),q(čtvrthodina),f(pětiminutovka), 1(minuta) - intervaly pro generování
)
RETURNS
@Result TABLE
(
	S smalldatetime,
	E smalldatetime
)
AS
BEGIN
	declare @FromEnd as smalldatetime
	IF @Interval='Y'
	BEGIN
		SET @FromEnd = (SELECT D FROM Rep_Date WITH (NOLOCK) WHERE D>@From AND D<=DATEADD(year,1,@From) AND DAY(D)=1 AND MONTH(D)=1)
		INSERT INTO @Result(S,E) VALUES(@From,@FromEnd)
		INSERT INTO @Result(S,E) SELECT D, DATEADD(year,1,D) FROM Rep_Date WHERE D>@From AND D<@To AND DAY(D)=1 AND MONTH(D)=1
		UPDATE @Result SET E = @To WHERE E>@To
	END
	ELSE IF @Interval='M'
	BEGIN
		SET @FromEnd = (SELECT D FROM Rep_Date WITH (NOLOCK) WHERE D>@From AND D<=DATEADD(month,1,@From) AND DAY(D)=1)
		INSERT INTO @Result(S,E) VALUES(@From,@FromEnd)
		INSERT INTO @Result(S,E) SELECT D, DATEADD(month,1,D) FROM Rep_Date WHERE D>@From AND D<@To AND DAY(D)=1
		UPDATE @Result SET E = @To WHERE E>@To
	END
	ELSE IF @Interval='W'
	BEGIN
		SET @FromEnd = (SELECT D FROM Rep_Date WITH (NOLOCK) WHERE D>@From AND D<=DATEADD(WEEK,1,@From) AND DATEPART(w,D)=DATEPART(w,'2016-07-18'))
		INSERT INTO @Result(S,E) VALUES(@From,@FromEnd)
		INSERT INTO @Result(S,E) SELECT D, DATEADD(week,1,D) FROM Rep_Date WHERE D>@From AND D<@To AND DATEPART(w,D)=DATEPART(w,'2016-07-18')
		UPDATE @Result SET E = @To WHERE E>@To
	END
	ELSE IF @Interval='D'
	BEGIN
		SET @FromEnd = (SELECT D FROM Rep_Date WITH (NOLOCK) WHERE D>@From AND D<=DATEADD(DAY,1,@From))
		INSERT INTO @Result(S,E) VALUES(@From,@FromEnd)
		INSERT INTO @Result(S,E) SELECT D, DATEADD(day,1,D) FROM Rep_Date WHERE D>@From AND D<@To
		UPDATE @Result SET E = @To WHERE E>@To
	END
	ELSE IF @Interval='h'
	BEGIN
		SET @FromEnd = (SELECT D+CAST(H as datetime) FROM Rep_Date WITH (NOLOCK), Rep_Time WITH (NOLOCK) WHERE D+CAST(H as datetime)>@From AND D+CAST(H as datetime)<=DATEADD(HOUR,1,@From) and Q='h')
		INSERT INTO @Result(S,E) VALUES(@From,@FromEnd)
		INSERT INTO @Result(S,E) SELECT D+CAST(H as datetime), DATEADD(HOUR,1,D+CAST(H as datetime)) FROM Rep_Date,Rep_Time WHERE D+CAST(H as datetime)>@From AND D+CAST(H as datetime)<@To and Q='h'
		UPDATE @Result SET E = @To WHERE E>@To
	END
	ELSE IF @Interval='t'
	BEGIN
		SET @FromEnd = (SELECT D+CAST(H as datetime) FROM Rep_Date WITH (NOLOCK), Rep_Time WITH (NOLOCK) WHERE D+CAST(H as datetime)>@From AND D+CAST(H as datetime)<=DATEADD(MINUTE,30,@From) and (Q='m' OR Q='h'))
		INSERT INTO @Result(S,E) VALUES(@From,@FromEnd)
		INSERT INTO @Result(S,E) SELECT D+CAST(H as datetime), DATEADD(MINUTE,30,D+CAST(H as datetime)) FROM Rep_Date,Rep_Time WHERE D+CAST(H as datetime)>@From AND D+CAST(H as datetime)<@To and (Q='m' OR Q='h')
		UPDATE @Result SET E = @To WHERE E>@To
	END
	ELSE IF @Interval='q'
	BEGIN
		SET @FromEnd = (SELECT D+CAST(H as datetime) FROM Rep_Date WITH (NOLOCK), Rep_Time WITH (NOLOCK) WHERE D+CAST(H as datetime)>@From AND D+CAST(H as datetime)<=DATEADD(MINUTE,15,@From) and (Q='m' OR Q='h' OR Q='q'))
		INSERT INTO @Result(S,E) VALUES(@From,@FromEnd)
		INSERT INTO @Result(S,E) SELECT D+CAST(H as datetime), DATEADD(MINUTE,15,D+CAST(H as datetime)) FROM Rep_Date,Rep_Time WHERE D+CAST(H as datetime)>@From AND D+CAST(H as datetime)<@To and (Q='m' OR Q='h' OR Q='q')
		UPDATE @Result SET E = @To WHERE E>@To
	END
	ELSE IF @Interval='f'
	BEGIN
		SET @FromEnd = (SELECT D+CAST(H as datetime) FROM Rep_Date WITH (NOLOCK), Rep_Time WITH (NOLOCK) WHERE D+CAST(H as datetime)>@From AND D+CAST(H as datetime)<=DATEADD(MINUTE,5,@From) and (Q='m' OR Q='h' OR Q='q' OR Q='f'))
		INSERT INTO @Result(S,E) VALUES(@From,@FromEnd)
		INSERT INTO @Result(S,E) SELECT D+CAST(H as datetime), DATEADD(MINUTE,5,D+CAST(H as datetime)) FROM Rep_Date,Rep_Time WHERE D+CAST(H as datetime)>@From AND D+CAST(H as datetime)<@To and (Q='m' OR Q='h' OR Q='q' OR Q='f')
		UPDATE @Result SET E = @To WHERE E>@To
	END
	ELSE IF @Interval='1'
	BEGIN
		SET @FromEnd = (SELECT D+CAST(H as datetime) FROM Rep_Date WITH (NOLOCK), Rep_Time WITH (NOLOCK) WHERE D+CAST(H as datetime)>@From AND D+CAST(H as datetime)<=DATEADD(MINUTE,1,@From))
		INSERT INTO @Result(S,E) VALUES(@From,@FromEnd)
		INSERT INTO @Result(S,E) SELECT D+CAST(H as datetime), DATEADD(MINUTE,1,D+CAST(H as datetime)) FROM Rep_Date,Rep_Time WHERE D+CAST(H as datetime)>@From AND D+CAST(H as datetime)<@To
		UPDATE @Result SET E = @To WHERE E>@To
	END
	RETURN
END
GO

