USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[WallBoard_ZC_SL]    Script Date: 8. 12. 2016 14:34:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ZbH doplnil 13.4.2016 projekty e-shop 

CREATE FUNCTION [dbo].[WallBoard_ZC_SL]
(	
	@Now as datetime,
	@Today as datetime
)RETURNS 
@Result TABLE 
(
	Label nvarchar(120),
	Rank int,
	Value int,
	Red bit,
	Orange bit,
	Green bit
)
AS
BEGIN

--Service level celkem (%)... unq_Ratio_wallboard= 100*@U / (@D+@E+@F)
-- cewe mají: SL = 100*(dovolaných do 30 sec po IVR) / (všechny položené ve frontě + všechny přijaté)
   
   DECLARE @TimeLimit AS INT = 30 -- 2.6.2016 požadoval pan Stehlík změnu
   IF GETDATE()>CONVERT(datetime,'2016.12.31') SET @TimeLimit = 20


	DECLARE @SL as int = fs_custom.dbo.unq_Ratio_wallboard(
	(SELECT COUNT(*) FROM icc.dbo.InboundCall AS IC WITH(NOLOCK) WHERE IC.EnqueueingTime>=@Today AND IC.CallResult='Served' and (isnull(IC.RingDuration,0) + isnull(IC.QueueDuration,0))<=@TimeLimit AND ProjectId not in ('f2e47b25-1482-4c16-b6ba-1926e0b1f390','7ca1606f-9f9d-427f-ad4c-1e0d38544485','e289d410-b75f-4bc1-b3c7-b8f9ade26ee6')),
	(SELECT COUNT(*) FROM icc.dbo.InboundCall AS IC WITH(NOLOCK) WHERE IC.EnqueueingTime>=@Today AND IC.CallResult='Served' AND ProjectId not in ('f2e47b25-1482-4c16-b6ba-1926e0b1f390','7ca1606f-9f9d-427f-ad4c-1e0d38544485','e289d410-b75f-4bc1-b3c7-b8f9ade26ee6')   ),
	(SELECT COUNT(*) FROM icc.dbo.InboundCall AS IC WITH(NOLOCK) WHERE IC.EnqueueingTime>=@Today AND IC.CallResult='Lost'  AND IC.CallPhase NOT IN ('IvrScriptA','IvrScriptB', 'Pilot','Enqueue') AND ProjectId not in ('f2e47b25-1482-4c16-b6ba-1926e0b1f390','7ca1606f-9f9d-427f-ad4c-1e0d38544485','e289d410-b75f-4bc1-b3c7-b8f9ade26ee6')   ),
	(SELECT 0   )
	) 


	INSERT INTO @Result
	SELECT 'SL-'+CAST(@TimeLimit AS varchar(2))+'s' as Label, 10 as Rank, @SL AS Value, 
		CAST(CASE WHEN @SL<70 THEN 1 ELSE 0 END AS BIT) AS Red,
		CAST(CASE WHEN @SL>=70 AND @SL<80 THEN 1 ELSE 0 END AS BIT) AS Orange,
		CAST(CASE WHEN @SL>=80 THEN 1 ELSE 0 END AS BIT) AS Green

--Service level celkový (%)
-- cewe mají: SL = 100*(dovolaných po IVR) / (všechny položené ve frontě + všechny přijaté)	 
	DECLARE @SLall as int = fs_custom.dbo.unq_Ratio_wallboard(
	(SELECT COUNT(*) FROM icc.dbo.InboundCall AS IC WITH(NOLOCK) WHERE IC.EnqueueingTime>=@Today AND IC.CallResult='Served'  AND ProjectId not in ('f2e47b25-1482-4c16-b6ba-1926e0b1f390','7ca1606f-9f9d-427f-ad4c-1e0d38544485','e289d410-b75f-4bc1-b3c7-b8f9ade26ee6')),
	(SELECT COUNT(*) FROM icc.dbo.InboundCall AS IC WITH(NOLOCK) WHERE IC.EnqueueingTime>=@Today AND IC.CallResult='Served' AND ProjectId not in ('f2e47b25-1482-4c16-b6ba-1926e0b1f390','7ca1606f-9f9d-427f-ad4c-1e0d38544485','e289d410-b75f-4bc1-b3c7-b8f9ade26ee6')   ),
	(SELECT COUNT(*) FROM icc.dbo.InboundCall AS IC WITH(NOLOCK) WHERE IC.EnqueueingTime>=@Today AND IC.CallResult='Lost'  AND IC.CallPhase NOT IN ('IvrScriptA','IvrScriptB', 'Pilot','Enqueue') AND ProjectId not in ('f2e47b25-1482-4c16-b6ba-1926e0b1f390','7ca1606f-9f9d-427f-ad4c-1e0d38544485','e289d410-b75f-4bc1-b3c7-b8f9ade26ee6')   ),
	(SELECT 0   )
	) 
	INSERT INTO @Result
	SELECT 'SL-celk' as Label, 10 as Rank, @SLall AS Value, 
		CAST(CASE WHEN @SLall<70 THEN 1 ELSE 0 END AS BIT) AS Red,
		CAST(CASE WHEN @SLall>=70 AND @SL<80 THEN 1 ELSE 0 END AS BIT) AS Orange,
		CAST(CASE WHEN @SLall>=80 THEN 1 ELSE 0 END AS BIT) AS Green


	
	RETURN 
END


GO

