Declare @Operator as varchar(30)
set @Operator = 'EPlus'

-- MO,MT Session ID-s
IF OBJECT_ID ('tempdb..#MO_Sessions' ) IS NOT NULL
		DROP TABLE #MO_Sessions
SELECT CASE b.[callDir]
			WHEN 'A->B' THEN a.[SessionId]
			WHEN 'B->A' THEN a.[SessionIdB]
	   END AS MOSessID
	   ,CASE b.[callDir]
			WHEN 'A->B' THEN a.[SessionIdB]
			WHEN 'B->A' THEN a.[SessionId]
	   END AS MTSessID
  INTO #MO_Sessions
  FROM [o2_Voice_2016_Q3].[dbo].[NC_Calls_Distinct] a
  LEFT OUTER JOIN [o2_Voice_2016_Q3].[dbo].[CallAnalysis] b 
     ON a.[SessionId] like b.[SessionId]
  WHERE a.[Operator] like @Operator and a.[Call_Status] like 'Completed'
  ORDER BY MOSessID

-- Merge Technology, band and codec data to table worth analyzing for MO Sessions
IF OBJECT_ID ('tempdb..#CodecTableMO' ) IS NOT NULL
		DROP TABLE #CodecTableMO
SELECT 
       a.[MsgId]
      ,a.[SessionId]
      ,a.[TestId]
      ,a.[PosId]
      ,a.[MsgTime]
      ,a.[NetworkId]
      ,a.[Direction]
      ,a.[Codec]
      ,a.[CodecRate]
      ,a.[Duration]
	  ,CASE
		WHEN [CodecRate] in (12.2, 10.2, 7.95, 7.4, 6.7, 5.9, 5.15, 4.75, 1.8) THEN 'NarrowBand'
		WHEN [CodecRate] in (23.85, 23.05, 19.85, 18.25, 15.85, 14.25, 12.65, 8.85, 6.6) THEN 'WideBand'
		END AS CodecBAND
	  ,b.[type]
	  ,c.[MCC]
      ,c.[HOMCC]
      ,c.[MNC]
      ,c.[HOMNC]
      ,c.[Operator]
      ,c.[HomeOperator]
      ,c.[technology]
  INTO #CodecTableMO
  FROM [o2_Voice_2016_Q3].[dbo].[VoiceCodecTest] a
  LEFT OUTER JOIN [o2_Voice_2016_Q3].[dbo].[NetworkIdRelation] b
     ON b.[NetworkId] = a.[NetworkId] and b.[SessionId] = a.[SessionId] and b.[TestId] = a.[TestId]  and b.[PosId] = a.[PosId]
  LEFT OUTER JOIN [o2_Voice_2016_Q3].[dbo].[NetworkInfo] c
     ON a.[NetworkId] = c.[NetworkId]
  WHERE a.[Duration] != 0 and a.[SessionId] in (SELECT MOSessID FROM #MO_Sessions)

-- Merge Technology, band and codec data to table worth analyzing for MO Sessions
IF OBJECT_ID ('tempdb..#CodecTableMT' ) IS NOT NULL
		DROP TABLE #CodecTableMT
SELECT 
       a.[MsgId]
      ,a.[SessionId]
      ,a.[TestId]
      ,a.[PosId]
      ,a.[MsgTime]
      ,a.[NetworkId]
      ,a.[Direction]
      ,a.[Codec]
      ,a.[CodecRate]
      ,a.[Duration]
	  ,CASE
		WHEN [CodecRate] in (12.2, 10.2, 7.95, 7.4, 6.7, 5.9, 5.15, 4.75, 1.8) THEN 'NarrowBand'
		WHEN [CodecRate] in (23.85, 23.05, 19.85, 18.25, 15.85, 14.25, 12.65, 8.85, 6.6) THEN 'WideBand'
		END AS CodecBAND
	  ,b.[type]
	  ,c.[MCC]
      ,c.[HOMCC]
      ,c.[MNC]
      ,c.[HOMNC]
      ,c.[Operator]
      ,c.[HomeOperator]
      ,c.[technology]
  INTO #CodecTableMT
  FROM [o2_Voice_2016_Q3].[dbo].[VoiceCodecTest] a
  LEFT OUTER JOIN [o2_Voice_2016_Q3].[dbo].[NetworkIdRelation] b
     ON b.[NetworkId] = a.[NetworkId] and b.[SessionId] = a.[SessionId] and b.[TestId] = a.[TestId]  and b.[PosId] = a.[PosId]
  LEFT OUTER JOIN [o2_Voice_2016_Q3].[dbo].[NetworkInfo] c
     ON a.[NetworkId] = c.[NetworkId]
  WHERE a.[Duration] != 0 and a.[SessionId] in (SELECT MTSessID FROM #MO_Sessions)

-- Michael_Part of script
IF OBJECT_ID ('tempdb..#CodecMO' ) IS NOT NULL
		DROP TABLE #CodecMO
SELECT DISTINCT
       [SessionId]
      ,[TestId]
      ,[Operator]
      ,[HomeOperator]
      ,[technology]
      ,[MsgTime] as StartTime
	  ,DATEADD(ms,Duration,MsgTime) AS EndTime
	  ,[Duration]
	  ,[CodecBAND]
  INTO #CodecMO
  FROM #CodecTableMO
  ORDER BY [SessionId],[TestId],[MsgTime]

IF OBJECT_ID ('tempdb..#CodecMT' ) IS NOT NULL
		DROP TABLE #CodecMT
SELECT DISTINCT
       [SessionId]
      ,[TestId]
      ,[Operator]
      ,[HomeOperator]
      ,[technology]
      ,[MsgTime] as StartTime
	  ,DATEADD(ms,Duration,MsgTime) AS EndTime
	  ,[Duration]
	  ,[CodecBAND]
  INTO #CodecMT
  FROM #CodecTableMT
  ORDER BY [SessionId],[TestId],[MsgTime]

IF OBJECT_ID ('tempdb..#CodecMOMT' ) IS NOT NULL
		DROP TABLE #CodecMOMT
SELECT 
	 a.[MOSessID]
    ,b.[TestId]			 AS MO_TestId
    ,b.[Operator]		 AS MO_Operator
    ,b.[HomeOperator]	 AS MO_HomeOperator
    ,b.[technology]		 AS MO_technology
    ,b.StartTime		 AS MO_StartTime
	,b.EndTime			 AS MO_EndTime
	,b.[Duration]		 AS MO_Duration
	,b.[CodecBAND]		 AS MO_CodecBAND
	,a.[MTSessID]
    ,c.[TestId]			 AS MT_TestId
    ,c.[Operator]		 AS MT_Operator
    ,c.[HomeOperator]	 AS MT_HomeOperator
    ,c.[technology]		 AS MT_technology
    ,c.StartTime		 AS MT_StartTime
	,c.EndTime			 AS MT_EndTime
	,c.[Duration]		 AS MT_Duration
	,c.[CodecBAND]		 AS MT_CodecBAND
   INTO #CodecMOMT
   FROM #MO_Sessions a
   LEFT OUTER JOIN #CodecMO b
     ON b.[SessionId] = a.[MOSessID]
   LEFT OUTER JOIN #CodecMT c
     ON c.[SessionId] = a.[MTSessID] and c.[TestId] = b.[TestId] and b.StartTime < c.EndTime and c.StartTime < b.EndTime 
   ORDER BY a.[MOSessID],b.StartTime 

IF OBJECT_ID ('tempdb..#DistCodecMOMT' ) IS NOT NULL
		DROP TABLE #DistCodecMOMT
SELECT DISTINCT
		 MOSessID
		,MO_TestId
		,MO_Operator
		,MO_HomeOperator
		,MO_technology
		,MO_CodecBAND
		,MTSessID
		,MT_TestId
		,MT_Operator
		,MT_HomeOperator
		,MT_technology
		,MT_CodecBAND
   INTO #DistCodecMOMT
   FROM #CodecMOMT 
   WHERE MT_CodecBAND is not null and MO_CodecBAND is not null
   ORDER BY [MOSessID],MO_TestId

SELECT  @Operator as Home_Operator
		,MO_Operator
		,MO_technology
		,MO_CodecBAND
		,MT_Operator
		,MT_technology
		,MT_CodecBAND
		,COUNT(MO_TestId) as Count
  FROM #DistCodecMOMT
  GROUP BY MO_Operator,MO_CodecBAND ,MT_Operator,MT_CodecBAND,MO_technology,MT_technology
  ORDER BY MO_Operator,MT_Operator,MO_technology,MT_technology,MO_CodecBAND,MT_CodecBAND
 -- CREATE STATISTICS TEMP TABLE
IF OBJECT_ID ('tempdb..#TempStatistics' ) IS NOT NULL
DROP TABLE #TempStatistics
 CREATE TABLE #TempStatistics(
						Extracted varchar(120),
						Value int)
-- STATISTICS


-- TOTAL NUMBER OF SAMPLES
Declare @TotalCodecTests as int
set @TotalCodecTests = ( SELECT  COUNT(*) from (SELECT DISTINCT MO_TestId FROM #DistCodecMOMT ) x)

 INSERT INTO #TempStatistics (Extracted, Value)
(SELECT 'Number of samples', @TotalCodecTests)

SELECT * FROM #TempStatistics