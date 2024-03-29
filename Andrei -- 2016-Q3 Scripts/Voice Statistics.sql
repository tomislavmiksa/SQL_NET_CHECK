IF EXISTS ( SELECT * FROM sysobjects WHERE id = object_id(N'TechExtract') AND xtype IN (N'FN', N'IF', N'TF') )
    DROP FUNCTION TechExtract
GO
Create FUNCTION TechExtract
(
    @Input1 varchar(50),
	@Input2 varchar(50),
	@Input3 varchar(50)
)
RETURNS varchar(50) 
AS
BEGIN
			declare @output varchar(255) = ''
			SET @output = @output +
							CASE 
								WHEN @Input1 like '%GSM%' or @Input2 like '%GSM%' or @Input3 like '%GSM%' THEN '2G,'
								ELSE ''
								END
							+
							CASE 
								WHEN @Input1 like '%UMTS%' or @Input2 like '%UMTS%' or @Input3 like '%UMTS%' THEN '3G,'
								ELSE ''
								END
							+
							CASE 
								WHEN @Input1 like '%LTE%' or @Input2 like '%LTE%' or @Input3 like '%LTE%' THEN '4G,'
								ELSE ''
								END
			RETURN @output;	  
END
GO

-- Filter Section
DECLARE @Operator		varchar(20)		= 'o2'
DECLARE @MODUL			varchar(20)		= '%'
DECLARE @LOCATION		varchar(20)		= '%'
DECLARE @Data_Cluster	varchar(20)		= '%'
DECLARE @Data_Motion	varchar(20)		= '%'

declare @myWeeks						table (Id int)
insert into @myWeeks					values (36), (37)	

declare @PS_SUCCESS						int
declare @PS_FAILED						int
declare @CS_SUCCESS						int
declare @CS_FAILED						int
declare @CS_DROPPED						int
declare @CS_RELEASE						int
declare @DB_Name						varchar(50)

declare @MOS_COUNT						int
declare @MOS_Avg						int
declare @MOS_STDEV						int
declare @MOS_less_10					int
declare @MOS_10_15						int
declare @MOS_15_20						int
declare @MOS_20_25						int
declare @MOS_25_30						int
declare @MOS_30_35						int
declare @MOS_35_40						int
declare @MOS_40_45						int
declare @MOS_more_45					int

-- Create Results Tables
IF OBJECT_ID ('tempdb..#TempStatistics' ) IS NOT NULL
	DROP TABLE #TempStatistics
 CREATE TABLE #TempStatistics(
		Comment varchar(120),
		PS_Completed int,
		PS_Failed int,
		Voice_Completed int,
		Voice_Failed int,
		Voice_Dropeed int,
		Voice_SystemRelease int	)

IF OBJECT_ID ('tempdb..#MOSStatistics' ) IS NOT NULL
	DROP TABLE #MOSStatistics
 CREATE TABLE #MOSStatistics(
		MO_Tech			varchar(120),
		MT_Tech			varchar(120),
		MOS_COUNT		int,
		MOS_Avg			int,
		MOS_STDEV		int,
		MOS_less_1_0	int,
		MOS_1_0_1_5		int,
		MOS_1_5_2_0		int,
		MOS_2_0_2_5		int,
		MOS_2_5_3_0		int,
		MOS_3_0_3_5		int,
		MOS_3_5_4_0		int,
		MOS_4_0_4_5		int,
		MOS_more_4_5	int)

-- Voice Statistics (VoLTE), Call success Rate calculations
IF OBJECT_ID ('tempdb..#VoiceSessions2' ) IS NOT NULL
		DROP TABLE #VoiceSessions2
-- Add MO Side statistics
SELECT  Operator
		,[TEC_Detail_A]
		,CASE 
			WHEN TEC_Detail_A LIKE '%GSM%' THEN 1
			ELSE 0
			END AS GSM_Flag
		,CASE 
			WHEN TEC_Detail_A LIKE '%UMTS%' THEN 1
			ELSE 0
			END AS UMTS_Flag
		,CASE 
			WHEN TEC_Detail_A LIKE '%LTE%' THEN 1
			ELSE 0
			END AS LTE_Flag
		,Call_Status
		,COUNT([Operator])  as Counting
INTO #VoiceSessions2
FROM [NC_Calls_Distinct]  
WHERE [TEC_Detail_A] is not null and [Modul] like @MODUL and [Location] like @LOCATION and [Week] in (SELECT * FROM @myWeeks)
GROUP BY Operator,[TEC_Detail_A],Call_Status 

-- Add MT Side statistics
INSERT INTO #VoiceSessions2 (Operator,TEC_Detail_A,GSM_Flag,UMTS_Flag,LTE_Flag,Call_Status,Counting)
SELECT  Operator
		,[TEC_Detail_B]
		,CASE 
			WHEN TEC_Detail_B LIKE '%GSM%' THEN 1
			ELSE 0
			END AS GSM_Flag
		,CASE 
			WHEN TEC_Detail_B LIKE '%UMTS%' THEN 1
			ELSE 0
			END AS UMTS_Flag
		,CASE 
			WHEN TEC_Detail_B LIKE '%LTE%' THEN 1
			ELSE 0
			END AS LTE_Flag
		,Call_Status
		,COUNT([Operator])  as Counting
FROM [NC_Calls_Distinct]  
WHERE [TEC_Detail_B] is not null and [Modul] like @MODUL and [Location] like @LOCATION and [Week] in (SELECT * FROM @myWeeks)
GROUP BY Operator,[TEC_Detail_B],Call_Status 

-- Extract calls per technology distribution and KPI-s
-- GSM ONLY
SET @CS_SUCCESS	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Completed'  and OPERATOR = @Operator and GSM_Flag = 1 and UMTS_Flag = 0 and LTE_Flag = 0 )
SET @CS_FAILED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Failed'     and OPERATOR = @Operator and GSM_Flag = 1 and UMTS_Flag = 0 and LTE_Flag = 0 )
SET @CS_DROPPED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Dropped'    and OPERATOR = @Operator and GSM_Flag = 1 and UMTS_Flag = 0 and LTE_Flag = 0 )
SET @CS_RELEASE	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status like 'System%' and OPERATOR = @Operator and GSM_Flag = 1 and UMTS_Flag = 0 and LTE_Flag = 0 )
INSERT INTO #TempStatistics (Comment,PS_Completed,PS_Failed,Voice_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT '2G ONLY', 0, 0, @CS_SUCCESS, @CS_FAILED, @CS_DROPPED, @CS_RELEASE 
-- UMTS ONLY
SET @CS_SUCCESS	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Completed'  and OPERATOR = @Operator and GSM_Flag = 0 and UMTS_Flag = 1 and LTE_Flag = 0 )
SET @CS_FAILED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Failed'     and OPERATOR = @Operator and GSM_Flag = 0 and UMTS_Flag = 1 and LTE_Flag = 0 )
SET @CS_DROPPED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Dropped'    and OPERATOR = @Operator and GSM_Flag = 0 and UMTS_Flag = 1 and LTE_Flag = 0 )
SET @CS_RELEASE	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status like 'System%' and OPERATOR = @Operator and GSM_Flag = 0 and UMTS_Flag = 1 and LTE_Flag = 0 )
INSERT INTO #TempStatistics (Comment,PS_Completed,PS_Failed,Voice_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT '3G ONLY', 0, 0, @CS_SUCCESS, @CS_FAILED, @CS_DROPPED, @CS_RELEASE 
-- LTE ONLY
SET @CS_SUCCESS	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Completed'  and OPERATOR = @Operator and GSM_Flag = 0 and UMTS_Flag = 0 and LTE_Flag = 1 )
SET @CS_FAILED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Failed'     and OPERATOR = @Operator and GSM_Flag = 0 and UMTS_Flag = 0 and LTE_Flag = 1 )
SET @CS_DROPPED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Dropped'    and OPERATOR = @Operator and GSM_Flag = 0 and UMTS_Flag = 0 and LTE_Flag = 1 )
SET @CS_RELEASE	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status like 'System%' and OPERATOR = @Operator and GSM_Flag = 0 and UMTS_Flag = 0 and LTE_Flag = 1 )
INSERT INTO #TempStatistics (Comment,PS_Completed,PS_Failed,Voice_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT '4G ONLY', 0, 0, @CS_SUCCESS, @CS_FAILED, @CS_DROPPED, @CS_RELEASE 
-- GSM MIXED
SET @CS_SUCCESS	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Completed'  and OPERATOR = @Operator and GSM_Flag = 1 and (UMTS_Flag = 1 or LTE_Flag = 1) )
SET @CS_FAILED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Failed'     and OPERATOR = @Operator and GSM_Flag = 1 and (UMTS_Flag = 1 or LTE_Flag = 1) )
SET @CS_DROPPED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Dropped'    and OPERATOR = @Operator and GSM_Flag = 1 and (UMTS_Flag = 1 or LTE_Flag = 1) )
SET @CS_RELEASE	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status like 'System%' and OPERATOR = @Operator and GSM_Flag = 1 and (UMTS_Flag = 1 or LTE_Flag = 1) )
INSERT INTO #TempStatistics (Comment,PS_Completed,PS_Failed,Voice_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT '2G MIXED', 0, 0, @CS_SUCCESS, @CS_FAILED, @CS_DROPPED, @CS_RELEASE 
-- UMTS MIXED
SET @CS_SUCCESS	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Completed'  and OPERATOR = @Operator and UMTS_Flag = 1 and (GSM_Flag = 1 or LTE_Flag = 1) )
SET @CS_FAILED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Failed'     and OPERATOR = @Operator and UMTS_Flag = 1 and (GSM_Flag = 1 or LTE_Flag = 1) )
SET @CS_DROPPED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Dropped'    and OPERATOR = @Operator and UMTS_Flag = 1 and (GSM_Flag = 1 or LTE_Flag = 1) )
SET @CS_RELEASE	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status like 'System%' and OPERATOR = @Operator and UMTS_Flag = 1 and (GSM_Flag = 1 or LTE_Flag = 1) )
INSERT INTO #TempStatistics (Comment,PS_Completed,PS_Failed,Voice_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT '3G MIXED', 0, 0, @CS_SUCCESS, @CS_FAILED, @CS_DROPPED, @CS_RELEASE 
-- LTE MIXED
SET @CS_SUCCESS	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Completed'  and OPERATOR = @Operator and LTE_Flag = 1 and (UMTS_Flag = 1 or GSM_Flag = 1) )
SET @CS_FAILED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Failed'     and OPERATOR = @Operator and LTE_Flag = 1 and (UMTS_Flag = 1 or GSM_Flag = 1) )
SET @CS_DROPPED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Dropped'    and OPERATOR = @Operator and LTE_Flag = 1 and (UMTS_Flag = 1 or GSM_Flag = 1) )
SET @CS_RELEASE	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status like 'System%' and OPERATOR = @Operator and LTE_Flag = 1 and (UMTS_Flag = 1 or GSM_Flag = 1) )
INSERT INTO #TempStatistics (Comment,PS_Completed,PS_Failed,Voice_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT '4G MIXED', 0, 0, @CS_SUCCESS, @CS_FAILED, @CS_DROPPED, @CS_RELEASE 
-- MIXED
SET @CS_SUCCESS	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Completed'  and OPERATOR = @Operator and (LTE_Flag + UMTS_Flag + GSM_Flag > 1) )
SET @CS_FAILED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Failed'     and OPERATOR = @Operator and (LTE_Flag + UMTS_Flag + GSM_Flag > 1) )
SET @CS_DROPPED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Dropped'    and OPERATOR = @Operator and (LTE_Flag + UMTS_Flag + GSM_Flag > 1) )
SET @CS_RELEASE	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status like 'System%' and OPERATOR = @Operator and (LTE_Flag + UMTS_Flag + GSM_Flag > 1) )
INSERT INTO #TempStatistics (Comment,PS_Completed,PS_Failed,Voice_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT 'TOTAL MIXED', 0, 0, @CS_SUCCESS, @CS_FAILED, @CS_DROPPED, @CS_RELEASE 
-- TOTAL Attempts
SET @CS_SUCCESS	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Completed'  and OPERATOR = @Operator )
SET @CS_FAILED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Failed'     and OPERATOR = @Operator )
SET @CS_DROPPED	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status = 'Dropped'    and OPERATOR = @Operator )
SET @CS_RELEASE	 = ( SELECT SUM(Counting) from #VoiceSessions2 WHERE Call_Status like 'System%' and OPERATOR = @Operator )
INSERT INTO #TempStatistics (Comment,PS_Completed,PS_Failed,Voice_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT 'TOTAL ATTEMPTS', 0, 0, @CS_SUCCESS, @CS_FAILED, @CS_DROPPED, @CS_RELEASE 

SELECT * FROM #TempStatistics

-- POLQA STATISTICS per Technology
IF OBJECT_ID ('tempdb..#POLQARaw1' ) IS NOT NULL
		DROP TABLE #POLQARaw1
SELECT [Operator]
		,dbo.TechExtract([Sample_Technology_A_Rank1],[Sample_Technology_A_Rank2],[Sample_Technology_A_Rank3]) as MO_Tech
		,dbo.TechExtract([Sample_Technology_B_Rank1],[Sample_Technology_B_Rank2],[Sample_Technology_B_Rank3]) as MT_Tech
	    ,[LQ]
        ,[Narrowband_Sample]
        ,[Wideband_Sample]
  INTO #POLQARaw1
  FROM [NEW_Speech_Samples_RAW]
  WHERE Operator = @Operator

  SELECT Operator,MO_Tech,MT_Tech,
		 COUNT(LQ) as POLQA_Sample_Count,
		 AVG(LQ) as POLQA_Sample_Average,
		 STDEV(LQ) as POLQA_Sample_STDEV
	FROM #POLQARaw1
	GROUP BY Operator,MO_Tech,MT_Tech
	ORDER BY Operator,MO_Tech,MT_Tech