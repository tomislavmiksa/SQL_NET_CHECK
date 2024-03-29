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

-- Create Results Table
IF OBJECT_ID ('tempdb..#TempStatistics' ) IS NOT NULL
	DROP TABLE #TempStatistics
 CREATE TABLE #TempStatistics(
		Comment varchar(120),
		DatabaseName varchar(120),
		PS_Completed int,
		PS_Failed int,
		CS_Completed int,
		Voice_Failed int,
		Voice_Dropeed int,
		Voice_SystemRelease int	)

-- Display DB Data statistics (2G/3G Locked)
SET @DB_Name = 'o2_Data_2016_Q3_3G'
IF OBJECT_ID ('tempdb..#DataSessions1' ) IS NOT NULL
		DROP TABLE #DataSessions1
SELECT  OPERATOR
		,SQ_Technology = REPLACE(SQ_Technology,'Unknown/', '')
		,CASE 
			WHEN SQ_Technology LIKE '%GSM%' THEN 1
			ELSE 0
			END AS GSM_Flag
		,CASE 
			WHEN SQ_Technology LIKE '%UMTS%' THEN 1
			ELSE 0
			END AS UMTS_Flag
		,CASE 
			WHEN SQ_Technology LIKE '%LTE%' THEN 1
			ELSE 0
			END AS LTE_Flag
		,ResultC
		,COUNT([OPERATOR]) as Counting
INTO #DataSessions1
FROM [NC_ROUTES] 
WHERE SQ_Technology is not null and SQ_Technology not like 'Unknown' and ResultC is not null and [Modul] like @MODUL and [CLUSTER] like @Data_Cluster and [MOTION] like @Data_Motion and [WEEK] in (SELECT * FROM @myWeeks)
GROUP BY OPERATOR, SQ_Technology, ResultC
ORDER BY OPERATOR, SQ_Technology, ResultC

-- GSM ONLY
SET @PS_SUCCESS = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'successful' and OPERATOR = @Operator and GSM_Flag = 1 and UMTS_Flag = 0 and LTE_Flag = 0 )
SET @PS_FAILED  = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'failed'     and OPERATOR = @Operator and GSM_Flag = 1 and UMTS_Flag = 0 and LTE_Flag = 0 )
INSERT INTO #TempStatistics (Comment,DatabaseName,PS_Completed,PS_Failed,CS_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT '2G ONLY',@DB_Name, @PS_SUCCESS, @PS_FAILED, 0, 0, 0, 0 
-- UMTS ONLY
SET @PS_SUCCESS = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'successful' and OPERATOR = @Operator and GSM_Flag = 0 and UMTS_Flag = 1 and LTE_Flag = 0 )
SET @PS_FAILED  = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'failed'     and OPERATOR = @Operator and GSM_Flag = 0 and UMTS_Flag = 1 and LTE_Flag = 0 )
INSERT INTO #TempStatistics (Comment,DatabaseName,PS_Completed,PS_Failed,CS_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT '3G ONLY',@DB_Name, @PS_SUCCESS, @PS_FAILED, 0, 0, 0, 0 
-- LTE ONLY
SET @PS_SUCCESS = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'successful' and OPERATOR = @Operator and GSM_Flag = 0 and UMTS_Flag = 0 and LTE_Flag = 1 )
SET @PS_FAILED  = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'failed'     and OPERATOR = @Operator and GSM_Flag = 0 and UMTS_Flag = 0 and LTE_Flag = 1 )
INSERT INTO #TempStatistics (Comment,DatabaseName,PS_Completed,PS_Failed,CS_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT '4G ONLY',@DB_Name, @PS_SUCCESS, @PS_FAILED, 0, 0, 0, 0 
-- GSM MIXED
SET @PS_SUCCESS = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'successful' and OPERATOR = @Operator and GSM_Flag = 1 and (UMTS_Flag = 1 or  LTE_Flag = 1) )
SET @PS_FAILED  = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'failed'     and OPERATOR = @Operator and GSM_Flag = 1 and (UMTS_Flag = 1 or  LTE_Flag = 1) )
INSERT INTO #TempStatistics (Comment,DatabaseName,PS_Completed,PS_Failed,CS_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT '2G MIXED',@DB_Name, @PS_SUCCESS, @PS_FAILED, 0, 0, 0, 0 
-- UMTS MIXED
SET @PS_SUCCESS = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'successful' and OPERATOR = @Operator and UMTS_Flag = 1 and (GSM_Flag = 1 or  LTE_Flag = 1) )
SET @PS_FAILED  = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'failed'     and OPERATOR = @Operator and UMTS_Flag = 1 and (GSM_Flag = 1 or  LTE_Flag = 1) )
INSERT INTO #TempStatistics (Comment,DatabaseName,PS_Completed,PS_Failed,CS_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT '3G MIXED',@DB_Name, @PS_SUCCESS, @PS_FAILED, 0, 0, 0, 0 
-- LTE MIXED
SET @PS_SUCCESS = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'successful' and OPERATOR = @Operator and LTE_Flag = 1 and (GSM_Flag = 1 or  UMTS_Flag = 1) )
SET @PS_FAILED  = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'failed'     and OPERATOR = @Operator and LTE_Flag = 1 and (GSM_Flag = 1 or  UMTS_Flag = 1) )
INSERT INTO #TempStatistics (Comment,DatabaseName,PS_Completed,PS_Failed,CS_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT '4G MIXED',@DB_Name, @PS_SUCCESS, @PS_FAILED, 0, 0, 0, 0 
-- TOTAL MIXED
SET @PS_SUCCESS = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'successful' and OPERATOR = @Operator and (LTE_Flag + GSM_Flag + UMTS_Flag > 1) )
SET @PS_FAILED  = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'failed'     and OPERATOR = @Operator and (LTE_Flag + GSM_Flag + UMTS_Flag > 1) )
INSERT INTO #TempStatistics (Comment,DatabaseName,PS_Completed,PS_Failed,CS_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT 'TOTAL MIXED',@DB_Name, @PS_SUCCESS, @PS_FAILED, 0, 0, 0, 0
-- TOTAL ATTEMPTS
SET @PS_SUCCESS = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'successful' and OPERATOR = @Operator )
SET @PS_FAILED  = ( SELECT SUM(Counting) from #DataSessions1 WHERE ResultC = 'failed'     and OPERATOR = @Operator )
INSERT INTO #TempStatistics (Comment,DatabaseName,PS_Completed,PS_Failed,CS_Completed,Voice_Failed,Voice_Dropeed,Voice_SystemRelease)
SELECT 'TOTAL ATTEMPTS',@DB_Name, @PS_SUCCESS, @PS_FAILED, 0, 0, 0, 0 



SELECT * FROM #TempStatistics