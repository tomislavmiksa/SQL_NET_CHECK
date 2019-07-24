-------------------------------
--  RADIO VALUES EXTRACTION  --
-------------------------------

-- GSM RF Strength and Quality
IF OBJECT_ID ('tempdb..#GSMRadioRF' ) IS NOT NULL
    DROP TABLE #GSMRadioRF
SELECT a.[MsgTime]
	  ,a.[SessionId]
	  ,a.[NetworkId]
      ,b.[Operator]
      ,b.[HomeOperator]
      ,b.[technology]
	  ,a.[RxLevFull]
	  ,a.[RxQualFull]
  INTO #GSMRadioRF
  FROM [GSMMeasReport] a
  LEFT OUTER JOIN [NetworkInfo] b
    ON a.[NetworkId] = b.[NetworkId]

-- UMTS RF Strength and Quality
IF OBJECT_ID ('tempdb..#UMTSRadioRF' ) IS NOT NULL
    DROP TABLE #UMTSRadioRF
SELECT a.[MsgTime]
      ,a.[SessionId]
      ,a.[NetworkId]
      ,b.[Operator]
      ,b.[HomeOperator]
      ,b.[technology]
	  ,a.[AggrRSCP]
      ,a.[AggrEcIo]
  INTO #UMTSRadioRF
  FROM [WCDMAActiveSet] a
  LEFT OUTER JOIN [NetworkInfo] b
    ON a.[NetworkId] = b.[NetworkId]

-- UMTS TxPwr
IF OBJECT_ID ('tempdb..#UMTSRadioTx' ) IS NOT NULL
    DROP TABLE #UMTSRadioTx
SELECT  a.[MsgTime]
       ,a.[SessionId]
	   ,a.[NetworkId]
       ,b.[Operator]
       ,b.[HomeOperator]
       ,b.[technology]
       ,a.[TxPwr]
  INTO #UMTSRadioTx
  FROM [WCDMAAGC] a
  LEFT JOIN [NetworkInfo] b
    ON a.[NetworkId] = b.[NetworkId]


-- LTE RF Strength and Quality
IF OBJECT_ID ('tempdb..#LTERadioRF' ) IS NOT NULL
    DROP TABLE #LTERadioRF
SELECT   a.[MsgTime]
		,a.[SessionId]
		,a.[NetworkId]
		,b.[Operator]
        ,b.[HomeOperator]
		,b.[technology]
		,a.[RSRP]
		,a.[RSRQ]
  INTO #LTERadioRF
  FROM [LTEMeasurementReport] a
  LEFT JOIN [NetworkInfo] b
    ON a .[NetworkId] = b.[NetworkId]

-- LTE TxPwr
IF OBJECT_ID ('tempdb..#LTERadioTx' ) IS NOT NULL
    DROP TABLE #LTERadioTx
SELECT a.[MsgTime]
	  ,a.[SessionId]
      ,a.[NetworkId]
	  ,b.[Operator]
      ,b.[HomeOperator]
	  ,b.[technology]
      ,a.[PuschTxPower]
  INTO #LTERadioTx
  FROM [LTEPUSCHStatisticsInfo] a
  LEFT JOIN [NetworkInfo] b
    ON a .[NetworkId] = b.[NetworkId]
	
--------------------------------
-- COLLECT ALL SESSIONS IN DB --
--------------------------------
	IF OBJECT_ID ('tempdb..#ConcernedSessions1' ) IS NOT NULL
			DROP TABLE #ConcernedSessions1
	-- Insert if data Sessions
	SELECT  
		   a.[SessionId]
		  ,a.[band] as technology
		  ,a.[FileId]
		  ,a.[NetworkId]
		  ,a.[Status]
		  ,a.[valid]
		  ,a.[Roaming]
		  ,a.[NetIds]
		  ,a.[Duration]
		  ,b.[ASideDevice]
		  ,CASE 
			WHEN [BSideDevice] like 'Answering Station' then '-'
			ELSE [BSideDevice]
			END AS BSideDevice
		  ,b.IMSI
	  INTO #ConcernedSessions1
	  FROM [DataCallAnalysis] a
	  LEFT OUTER JOIN [Q3_accept_stationary_pre_bad_data].[dbo].[FileList] b
		ON a.[FileId] = b.[FileId]

	-- Insert if Voice sessions
	INSERT INTO #ConcernedSessions1
	SELECT 
		   a.[SessionId] as [SessionId]
		  ,(SELECT TOP 1 [EndTechnology] FROM [CallAnalysis] WHERE [SessionId] like a.[SessionId]) as technology
		  ,a.[FileId] as [FileId]
		  ,a.[NetworkId] as [NetworkId]
		  ,a.[callStatus] as Status
		  ,a.[valid]
		  ,a.[Roaming]
		  ,a.[NetIds]
		  ,a.[callDuration] as Duration
		  ,b.[ASideDevice]
		  ,CASE 
			WHEN [BSideDevice] like 'Answering Station' then '-'
			ELSE [BSideDevice]
			END AS BSideDevice
		  ,b.IMSI
	  FROM [CallAnalysis] a
	  LEFT OUTER JOIN [FileList] b
		ON a.[FileId] = b.[FileId]

--------------------------------------
-- Data tests collect required data --
--------------------------------------
	IF OBJECT_ID ('tempdb..#DataTests1' ) IS NOT NULL
			DROP TABLE #DataTests1
	SELECT [TestId]
		  ,[SessionId]
		  ,[duration]
		  ,[TestName]
	  INTO #DataTests1
	  FROM [Q3_accept_stationary_pre_bad_data].[dbo].[TestInfo]
	  WHERE [TestName] in ('UL_TBKPI', 'DL_TBKPI')

	IF OBJECT_ID ('tempdb..#DataTests' ) IS NOT NULL
			DROP TABLE #DataTests
	SELECT a.[SessionId]
		  ,a.[technology]
		  ,a.[FileId]
		  ,a.[NetworkId]
		  ,a.[Status]
		  ,a.[valid]
		  ,a.[Roaming]
		  ,a.[NetIds]
		  ,a.[Duration]
		  ,a.[ASideDevice]
		  ,a.[BSideDevice]
		  ,a.IMSI
		  ,CASE 
			WHEN b.[TestName] like 'UL_TBKPI' THEN b.[TestId]
			END as Data_UL_TestID
		  ,CASE 
			WHEN b.[TestName] like 'DL_TBKPI' THEN b.[TestId]
			END as Data_DL_TestID
	  INTO #DataTests
	  FROM #ConcernedSessions1 a
	  LEFT OUTER JOIN #DataTests1 b
	   ON a.[SessionId] = b.[SessionId]

---------------------------------------
-- Voice tests collect required data --
---------------------------------------
IF OBJECT_ID ('tempdb..#Tests1' ) IS NOT NULL
			DROP TABLE #Tests1
SELECT 	 a.[SessionId]
		,a.[technology]
		,a.[FileId]
		,a.[NetworkId]
		,a.[Status]
		,a.[valid]
		,a.[Roaming]
		,a.[NetIds]
		,a.[Duration]
		,a.[ASideDevice]
		,a.[BSideDevice]
		,a.[IMSI]
		,a.[Data_UL_TestID]
		,a.[Data_DL_TestID]
		,CASE 
			WHEN a.[Data_UL_TestID] is null and a.[Data_DL_TestID] is null then [callDir]
			END AS Voice_Call_Direction
  INTO #Tests1
  FROM #DataTests a
  LEFT OUTER JOIN [CallAnalysis] b
    on a.[SessionId] = b.[SessionId]

-- THROUGHPUT Temp Tables
	IF OBJECT_ID ('tempdb..#ThroughputData' ) IS NOT NULL
			DROP TABLE #ThroughputData
	SELECT a.[SessionId]
		  ,a.[TestId]
		  ,a.[MsgTime]
		  ,a.[NetworkId]
		  ,b.[Operator]
		  ,b.[HomeOperator]
		  ,b.[technology]
		  ,a.[Throughput]
		  ,a.[Duration]
		  ,a.[BytesTransferred]
		  ,a.[LastBlock]
	  INTO #ThroughputData
	  FROM [ResultsHTTPTransferTest] a
	  LEFT OUTER JOIN [NetworkInfo] b
		ON a.[NetworkId] = b.[NetworkId]
	  WHERE a.[ErrorCode] = 0

IF OBJECT_ID ('tempdb..#Tests2' ) IS NOT NULL
			DROP TABLE #Tests2
SELECT 	 [SessionId]
		,[technology]
		,[FileId]
		,[NetworkId]
		,[Status]
		,[valid]
		,[Roaming]
		,[NetIds]
		,[Duration]
		,[ASideDevice]
		,[BSideDevice]
		,[IMSI]
		,[Data_UL_TestID]
		,( SELECT MIN ([MsgTime]) FROM #ThroughputData WHERE [SessionId] = a.[SessionId] and TestId = [Data_UL_TestID] ) as UL_Start
		,CASE 
			WHEN EXISTS ( SELECT MIN([MsgTime]) FROM #ThroughputData WHERE [SessionId] = a.[SessionId] and TestId = [Data_UL_TestID]  and [LastBlock] = 1 )
				THEN ( SELECT MIN([MsgTime]) FROM #ThroughputData WHERE [SessionId] = a.[SessionId] and TestId = [Data_UL_TestID]  and [LastBlock] = 1 )
			ELSE ( SELECT MAX([MsgTime]) FROM #ThroughputData WHERE [SessionId] = a.[SessionId] and TestId = [Data_UL_TestID] )
			END AS UL_End
		,( SELECT MAX ([BytesTransferred]) FROM #ThroughputData WHERE [SessionId] = a.[SessionId] and TestId = [Data_UL_TestID] ) as UL_Bytes
		,[Data_DL_TestID]
		,[Voice_Call_Direction]
		,( SELECT MIN ([MsgTime]) FROM #ThroughputData WHERE [SessionId] = a.[SessionId] and TestId = [Data_DL_TestID] ) as DL_Start
		,CASE 
			WHEN EXISTS ( SELECT MIN([MsgTime]) FROM #ThroughputData WHERE [SessionId] = a.[SessionId] and TestId = [Data_DL_TestID]  and [LastBlock] = 1 )
				THEN ( SELECT MIN([MsgTime]) FROM #ThroughputData WHERE [SessionId] = a.[SessionId] and TestId = [Data_DL_TestID]  and [LastBlock] = 1 )
			ELSE ( SELECT MAX([MsgTime]) FROM #ThroughputData WHERE [SessionId] = a.[SessionId] and TestId = [Data_DL_TestID] )
			END AS DL_End
		,( SELECT MAX ([BytesTransferred]) FROM #ThroughputData WHERE [SessionId] = a.[SessionId] and TestId = [Data_DL_TestID] ) as DL_Bytes
  INTO #Tests2
  FROM #Tests1 a

IF OBJECT_ID ('tempdb..#Tests' ) IS NOT NULL
			DROP TABLE #Tests
SELECT   [SessionId]
		,[technology]
		,[FileId]
		,[NetworkId]
		,[Status]
		,[valid]
		,[Roaming]
		,[NetIds]
		,[Duration]
		,[ASideDevice]
		,[BSideDevice]
		,[IMSI]
		,[Data_UL_TestID]
		,[UL_Start]
		,[UL_End]
		,[UL_Bytes]
		,CASE
			WHEN [UL_Start] is not null and [UL_End] is not null and [UL_Bytes] is not null and not [UL_Start] = [UL_End] and not DATEDIFF(SECOND,[UL_Start],[UL_End]) = 0 
				THEN [UL_Bytes]/DATEDIFF(SECOND,[UL_Start],[UL_End])
			END as UL_bytesSec
		,[Data_DL_TestID]
		,[Voice_Call_Direction]
		,[DL_Start]
		,[DL_End]
		,[DL_Bytes]
		,CASE
			WHEN [DL_Start] is not null and [DL_End] is not null and [DL_Bytes] is not null and not [DL_Start] = [DL_End] and not DATEDIFF(SECOND,[DL_Start],[DL_End]) = 0
				THEN [DL_Bytes]/DATEDIFF(SECOND,[DL_Start],[DL_End])
			END as DL_bytesSec
INTO #Tests
FROM #Tests2
--------------------------
-- Process IMSI BY IMSI --
--------------------------
-- Declare required variables

IF OBJECT_ID ('tempdb..#FinalResults' ) IS NOT NULL
		DROP TABLE #FinalResults
CREATE TABLE #FinalResults(
						IMSI														 varchar(20),
						"GSM 900 RxLev (Samples Count)                            "  int,
						"GSM 900 RxLev (Average)                                  "  float,
						"GSM 900 RxLev (Median)                                   "  float,
						"GSM 900 RxLev (Minimum)                                  "  float,
						"GSM 900 RxLev (Maximum)                                  "  float,
						"GSM 900 RxLev (Standard Deviation)                       "  float,
						"GSM 900 RxQual (Samples Count)                           "  int,
						"GSM 900 RxQual (Average)                                 "  float,
						"GSM 900 RxQual (Median)                                  "  float,
						"GSM 900 RxQual (Minimum)                                 "  float,
						"GSM 900 RxQual (Maximum)                                 "  float,
						"GSM 900 RxQual (Standard Deviation)                      "  float,
						"GSM 1800 RxLev (Samples Count)                           "  int,
						"GSM 1800 RxLev (Average)                                 "  float,
						"GSM 1800 RxLev (Median)                                  "  float,
						"GSM 1800 RxLev (Minimum)                                 "  float,
						"GSM 1800 RxLev (Maximum)                                 "  float,
						"GSM 1800 RxLev (Standard Deviation)                      "  float,
						"GSM 1800 RxQual (Samples Count)                          "  int,
						"GSM 1800 RxQual (Average)                                "  float,
						"GSM 1800 RxQual (Median)                                 "  float,
						"GSM 1800 RxQual (Minimum)                                "  float,
						"GSM 1800 RxQual (Maximum)                                "  float,
						"GSM 1800 RxQual (Standard Deviation)                     "  float,
						"UMTS 2100 RSCP (Samples Count)                           "  int,
						"UMTS 2100 RSCP (Average)                                 "  float,
						"UMTS 2100 RSCP (Median)                                  "  float,
						"UMTS 2100 RSCP (Minimum)                                 "  float,
						"UMTS 2100 RSCP (Maximum)                                 "  float,
						"UMTS 2100 RSCP (Standard Deviation)                      "  float,
						"UMTS 2100 EcNo (Samples Count)                           "  int,
						"UMTS 2100 EcNo (Average)                                 "  float,
						"UMTS 2100 EcNo (Median)                                  "  float,
						"UMTS 2100 EcNo (Minimum)                                 "  float,
						"UMTS 2100 EcNo (Maximum)                                 "  float,
						"UMTS 2100 EcNo (Standard Deviation)                      "  float,
						"UMTS 2100 TxPwr (Samples Count)                          "  int,
						"UMTS 2100 TxPwr (Average)                                "  float,
						"UMTS 2100 TxPwr (Median)                                 "  float,
						"UMTS 2100 TxPwr (Minimum)                                "  float,
						"UMTS 2100 TxPwr (Maximum)                                "  float,
						"UMTS 2100 TxPwr (Standard Deviation)                     "  float,
						"UMTS 2100 UL Throughput ALL Samples (Samples Count)      "  int,
						"UMTS 2100 UL Throughput ALL Samples (Average)            "  float,
						"UMTS 2100 UL Throughput ALL Samples (Median)             "  float,
						"UMTS 2100 UL Throughput ALL Samples (Minimum)            "  float,
						"UMTS 2100 UL Throughput ALL Samples (Maximum)            "  float,
						"UMTS 2100 UL Throughput Test Average (Samples Count)     "  int,
						"UMTS 2100 UL Throughput Test Average (Average)           "  float,
						"UMTS 2100 UL Throughput Test Average (Median)            "  float,
						"UMTS 2100 UL Throughput Test Average (Minimum)           "  float,
						"UMTS 2100 UL Throughput Test Average (Maximum)           "  float,
						"UMTS 2100 DL Throughput ALL Samples (Samples Count)      "  int,
						"UMTS 2100 DL Throughput ALL Samples (Average)            "  float,
						"UMTS 2100 DL Throughput ALL Samples (Median)             "  float,
						"UMTS 2100 DL Throughput ALL Samples (Minimum)            "  float,
						"UMTS 2100 DL Throughput ALL Samples (Maximum)            "  float,
						"UMTS 2100 DL Throughput Test Average (Samples Count)     "  int,
						"UMTS 2100 DL Throughput Test Average (Average)           "  float,
						"UMTS 2100 DL Throughput Test Average (Median)            "  float,
						"UMTS 2100 DL Throughput Test Average (Minimum)           "  float,
						"UMTS 2100 DL Throughput Test Average (Maximum)           "  float,
						"LTE 800 RSRP (Samples Count)                             "  int,
						"LTE 800 RSRP (Average)                                   "  float,
						"LTE 800 RSRP (Median)                                    "  float,
						"LTE 800 RSRP (Minimum)                                   "  float,
						"LTE 800 RSRP (Maximum)                                   "  float,
						"LTE 800 RSRP (Standard Deviation)                        "  float,
						"LTE 800 RSRQ (Samples Count)                             "  int,
						"LTE 800 RSRQ (Average)                                   "  float,
						"LTE 800 RSRQ (Median)                                    "  float,
						"LTE 800 RSRQ (Minimum)                                   "  float,
						"LTE 800 RSRQ (Maximum)                                   "  float,
						"LTE 800 RSRQ (Standard Deviation)                        "  float,
						"LTE 800 TxPwr (Samples Count)                            "  int,
						"LTE 800 TxPwr (Average)                                  "  float,
						"LTE 800 TxPwr (Median)                                   "  float,
						"LTE 800 TxPwr (Minimum)                                  "  float,
						"LTE 800 TxPwr (Maximum)                                  "  float,
						"LTE 800 TxPwr (Standard Deviation)                       "  float,
						"LTE 800 UL Throughput ALL Samples (Samples Count)        "  int,
						"LTE 800 UL Throughput ALL Samples (Average)              "  float,
						"LTE 800 UL Throughput ALL Samples (Median)               "  float,
						"LTE 800 UL Throughput ALL Samples (Minimum)              "  float,
						"LTE 800 UL Throughput ALL Samples (Maximum)              "  float,
						"LTE 800 UL Throughput Test Average (Samples Count)       "  int,
						"LTE 800 UL Throughput Test Average (Average)             "  float,
						"LTE 800 UL Throughput Test Average (Median)              "  float,
						"LTE 800 UL Throughput Test Average (Minimum)             "  float,
						"LTE 800 UL Throughput Test Average (Maximum)             "  float,
						"LTE 800 DL Throughput ALL Samples (Samples Count)        "  int,
						"LTE 800 DL Throughput ALL Samples (Average)              "  float,
						"LTE 800 DL Throughput ALL Samples (Median)               "  float,
						"LTE 800 DL Throughput ALL Samples (Minimum)              "  float,
						"LTE 800 DL Throughput ALL Samples (Maximum)              "  float,
						"LTE 800 DL Throughput Test Average (Samples Count)       "  int,
						"LTE 800 DL Throughput Test Average (Average)             "  float,
						"LTE 800 DL Throughput Test Average (Median)              "  float,
						"LTE 800 DL Throughput Test Average (Minimum)             "  float,
						"LTE 800 DL Throughput Test Average (Maximum)             "  float,
						"LTE 1800 RSRP (Samples Count)                            "  int,
						"LTE 1800 RSRP (Average)                                  "  float,
						"LTE 1800 RSRP (Median)                                   "  float,
						"LTE 1800 RSRP (Minimum)                                  "  float,
						"LTE 1800 RSRP (Maximum)                                  "  float,
						"LTE 1800 RSRP (Standard Deviation)                       "  float,
						"LTE 1800 RSRQ (Samples Count)                            "  int,
						"LTE 1800 RSRQ (Average)                                  "  float,
						"LTE 1800 RSRQ (Median)                                   "  float,
						"LTE 1800 RSRQ (Minimum)                                  "  float,
						"LTE 1800 RSRQ (Maximum)                                  "  float,
						"LTE 1800 RSRQ (Standard Deviation)                       "  float,
						"LTE 1800 TxPwr (Samples Count)                           "  int,
						"LTE 1800 TxPwr (Average)                                 "  float,
						"LTE 1800 TxPwr (Median)                                  "  float,
						"LTE 1800 TxPwr (Minimum)                                 "  float,
						"LTE 1800 TxPwr (Maximum)                                 "  float,
						"LTE 1800 TxPwr (Standard Deviation)                      "  float,
						"LTE 1800 UL Throughput ALL Samples (Samples Count)       "  int,
						"LTE 1800 UL Throughput ALL Samples (Average)             "  float,
						"LTE 1800 UL Throughput ALL Samples (Median)              "  float,
						"LTE 1800 UL Throughput ALL Samples (Minimum)             "  float,
						"LTE 1800 UL Throughput ALL Samples (Maximum)             "  float,
						"LTE 1800 UL Throughput Test Average (Samples Count)      "  int,
						"LTE 1800 UL Throughput Test Average (Average)            "  float,
						"LTE 1800 UL Throughput Test Average (Median)             "  float,
						"LTE 1800 UL Throughput Test Average (Minimum)            "  float,
						"LTE 1800 UL Throughput Test Average (Maximum)            "  float,
						"LTE 1800 DL Throughput ALL Samples (Samples Count)       "  int,
						"LTE 1800 DL Throughput ALL Samples (Average)             "  float,
						"LTE 1800 DL Throughput ALL Samples (Median)              "  float,
						"LTE 1800 DL Throughput ALL Samples (Minimum)             "  float,
						"LTE 1800 DL Throughput ALL Samples (Maximum)             "  float,
						"LTE 1800 DL Throughput Test Average (Samples Count)      "  int,
						"LTE 1800 DL Throughput Test Average (Average)            "  float,
						"LTE 1800 DL Throughput Test Average (Median)             "  float,
						"LTE 1800 DL Throughput Test Average (Minimum)            "  float,
						"LTE 1800 DL Throughput Test Average (Maximum)            "  float,
						"LTE 2600 RSRP (Samples Count)                            "  int,
						"LTE 2600 RSRP (Average)                                  "  float,
						"LTE 2600 RSRP (Median)                                   "  float,
						"LTE 2600 RSRP (Minimum)                                  "  float,
						"LTE 2600 RSRP (Maximum)                                  "  float,
						"LTE 2600 RSRP (Standard Deviation)                       "  float,
						"LTE 2600 RSRQ (Samples Count)                            "  int,
						"LTE 2600 RSRQ (Average)                                  "  float,
						"LTE 2600 RSRQ (Median)                                   "  float,
						"LTE 2600 RSRQ (Minimum)                                  "  float,
						"LTE 2600 RSRQ (Maximum)                                  "  float,
						"LTE 2600 RSRQ (Standard Deviation)                       "  float,
						"LTE 2600 TxPwr (Samples Count)                           "  int,
						"LTE 2600 TxPwr (Average)                                 "  float,
						"LTE 2600 TxPwr (Median)                                  "  float,
						"LTE 2600 TxPwr (Minimum)                                 "  float,
						"LTE 2600 TxPwr (Maximum)                                 "  float,
						"LTE 2600 TxPwr (Standard Deviation)                      "  float,
						"LTE 2600 UL Throughput ALL Samples (Samples Count)       "  int,
						"LTE 2600 UL Throughput ALL Samples (Average)             "  float,
						"LTE 2600 UL Throughput ALL Samples (Median)              "  float,
						"LTE 2600 UL Throughput ALL Samples (Minimum)             "  float,
						"LTE 2600 UL Throughput ALL Samples (Maximum)             "  float,
						"LTE 2600 UL Throughput Test Average (Samples Count)      "  int,
						"LTE 2600 UL Throughput Test Average (Average)            "  float,
						"LTE 2600 UL Throughput Test Average (Median)             "  float,
						"LTE 2600 UL Throughput Test Average (Minimum)            "  float,
						"LTE 2600 UL Throughput Test Average (Maximum)            "  float,
						"LTE 2600 DL Throughput ALL Samples (Samples Count)       "  int,
						"LTE 2600 DL Throughput ALL Samples (Average)             "  float,
						"LTE 2600 DL Throughput ALL Samples (Median)              "  float,
						"LTE 2600 DL Throughput ALL Samples (Minimum)             "  float,
						"LTE 2600 DL Throughput ALL Samples (Maximum)             "  float,
						"LTE 2600 DL Throughput Test Average (Samples Count)      "  int,
						"LTE 2600 DL Throughput Test Average (Average)            "  float,
						"LTE 2600 DL Throughput Test Average (Median)             "  float,
						"LTE 2600 DL Throughput Test Average (Minimum)            "  float,
						"LTE 2600 DL Throughput Test Average (Maximum)            "  float)

DECLARE @GSM900_RxLev_Samples_Count				int	;
DECLARE @GSM900_RxLev_Average					float;
DECLARE @GSM900_RxLev_Median					float;
DECLARE @GSM900_RxLev_Minimum					float;
DECLARE @GSM900_RxLev_Maximum					float;
DECLARE @GSM900_RxLev_StDev						float;
DECLARE @GSM900_RxQual_Samples_Count			int	 ;
DECLARE @GSM900_RxQual_Average					float;
DECLARE @GSM900_RxQual_Median					float;
DECLARE @GSM900_RxQual_Minimum					float;
DECLARE @GSM900_RxQual_Maximum					float;
DECLARE @GSM900_RxQual_StDev					float;
DECLARE @GSM1800_RxLev_Samples_Count			int	 ;
DECLARE @GSM1800_RxLev_Average					float;
DECLARE @GSM1800_RxLev_Median					float;
DECLARE @GSM1800_RxLev_Minimum					float;
DECLARE @GSM1800_RxLev_Maximum					float;
DECLARE @GSM1800_RxLev_StDev					float;
DECLARE @GSM1800_RxQual_Samples_Count			int	 ;
DECLARE @GSM1800_RxQual_Average					float;
DECLARE @GSM1800_RxQual_Median					float;
DECLARE @GSM1800_RxQual_Minimum					float;
DECLARE @GSM1800_RxQual_Maximum					float;
DECLARE @GSM1800_RxQual_StDev					float;
DECLARE @UMTS2100_RSCP_Samples_Count			int	 ;
DECLARE @UMTS2100_RSCP_Average					float;
DECLARE @UMTS2100_RSCP_Median					float;
DECLARE @UMTS2100_RSCP_Minimum					float;
DECLARE @UMTS2100_RSCP_Maximum					float;
DECLARE @UMTS2100_RSCP_StDev					float;
DECLARE @UMTS2100_EcNo_Samples_Count			int	 ;
DECLARE @UMTS2100_EcNo_Average					float;
DECLARE @UMTS2100_EcNo_Median					float;
DECLARE @UMTS2100_EcNo_Minimum					float;
DECLARE @UMTS2100_EcNo_Maximum					float;
DECLARE @UMTS2100_EcNo_StDev					float;
DECLARE @UMTS2100_TxPwr_Samples_Count			int	 ;
DECLARE @UMTS2100_TxPwr_Average					float;
DECLARE @UMTS2100_TxPwr_Median					float;
DECLARE @UMTS2100_TxPwr_Minimum					float;
DECLARE @UMTS2100_TxPwr_Maximum					float;
DECLARE @UMTS2100_TxPwr_StDev					float;
DECLARE @UMTS2100_UL_ALL_Samples_Count			int	 ;
DECLARE @UMTS2100_UL_ALL_Average				float;
DECLARE @UMTS2100_UL_ALL_Median					float;
DECLARE @UMTS2100_UL_ALL_Minimum				float;
DECLARE @UMTS2100_UL_ALL_Maximum				float;
DECLARE @UMTS2100_UL_ALL_StDev					float;
DECLARE @UMTS2100_UL_TestAvg_Samples_Count		int	 ;
DECLARE @UMTS2100_UL_TestAvg_Average			float;
DECLARE @UMTS2100_UL_TestAvg_Median				float;
DECLARE @UMTS2100_UL_TestAvg_Minimum			float;
DECLARE @UMTS2100_UL_TestAvg_Maximum			float;
DECLARE @UMTS2100_UL_TestAvg_StDev				float;
DECLARE @UMTS2100_DL_ALL_Samples_Count			int	 ;
DECLARE @UMTS2100_DL_ALL_Average				float;
DECLARE @UMTS2100_DL_ALL_Median					float;
DECLARE @UMTS2100_DL_ALL_Minimum				float;
DECLARE @UMTS2100_DL_ALL_Maximum				float;
DECLARE @UMTS2100_DL_ALL_StDev					float;
DECLARE @UMTS2100_DL_TestAvg_Samples_Count		int	 ;
DECLARE @UMTS2100_DL_TestAvg_Average			float;
DECLARE @UMTS2100_DL_TestAvg_Median				float;
DECLARE @UMTS2100_DL_TestAvg_Minimum			float;
DECLARE @UMTS2100_DL_TestAvg_Maximum			float;
DECLARE @UMTS2100_DL_TestAvg_StDev				float;
DECLARE @LTE800_RSRP_Samples_Count				int	 ;
DECLARE @LTE800_RSRP_Average					float;
DECLARE @LTE800_RSRP_Median						float;
DECLARE @LTE800_RSRP_Minimum					float;
DECLARE @LTE800_RSRP_Maximum					float;
DECLARE @LTE800_RSRP_StDev						float;
DECLARE @LTE800_RSRQ_Samples_Count				int	 ;
DECLARE @LTE800_RSRQ_Average					float;
DECLARE @LTE800_RSRQ_Median						float;
DECLARE @LTE800_RSRQ_Minimum					float;
DECLARE @LTE800_RSRQ_Maximum					float;
DECLARE @LTE800_RSRQ_StDev						float;
DECLARE @LTE800_TxPwr_Samples_Count				int	 ;
DECLARE @LTE800_TxPwr_Average					float;
DECLARE @LTE800_TxPwr_Median					float;
DECLARE @LTE800_TxPwr_Minimum					float;
DECLARE @LTE800_TxPwr_Maximum					float;
DECLARE @LTE800_TxPwr_StDev						float;
DECLARE @LTE800_UL_ALL_Samples_Count			int	 ;
DECLARE @LTE800_UL_ALL_Average					float;
DECLARE @LTE800_UL_ALL_Median					float;
DECLARE @LTE800_UL_ALL_Minimum					float;
DECLARE @LTE800_UL_ALL_Maximum					float;
DECLARE @LTE800_UL_ALL_StDev					float;
DECLARE @LTE800_UL_TestAvg_Samples_Count		int	 ;
DECLARE @LTE800_UL_TestAvg_Average				float;
DECLARE @LTE800_UL_TestAvg_Median				float;
DECLARE @LTE800_UL_TestAvg_Minimum				float;
DECLARE @LTE800_UL_TestAvg_Maximum				float;
DECLARE @LTE800_UL_TestAvg_StDev				float;
DECLARE @LTE800_DL_ALL_Samples_Count			int	 ;
DECLARE @LTE800_DL_ALL_Average					float;
DECLARE @LTE800_DL_ALL_Median					float;
DECLARE @LTE800_DL_ALL_Minimum					float;
DECLARE @LTE800_DL_ALL_Maximum					float;
DECLARE @LTE800_DL_ALL_StDev					float;
DECLARE @LTE800_DL_TestAvg_Samples_Count		int	 ;
DECLARE @LTE800_DL_TestAvg_Average				float;
DECLARE @LTE800_DL_TestAvg_Median				float;
DECLARE @LTE800_DL_TestAvg_Minimum				float;
DECLARE @LTE800_DL_TestAvg_Maximum				float;
DECLARE @LTE800_DL_TestAvg_StDev				float;
DECLARE @LTE1800_RSRP_Samples_Count				int	 ;
DECLARE @LTE1800_RSRP_Average					float;
DECLARE @LTE1800_RSRP_Median					float;
DECLARE @LTE1800_RSRP_Minimum					float;
DECLARE @LTE1800_RSRP_Maximum					float;
DECLARE @LTE1800_RSRP_StDev						float;
DECLARE @LTE1800_RSRQ_Samples_Count				int	 ;
DECLARE @LTE1800_RSRQ_Average					float;
DECLARE @LTE1800_RSRQ_Median					float;
DECLARE @LTE1800_RSRQ_Minimum					float;
DECLARE @LTE1800_RSRQ_Maximum					float;
DECLARE @LTE1800_RSRQ_StDev						float;
DECLARE @LTE1800_TxPwr_Samples_Count			int	 ;
DECLARE @LTE1800_TxPwr_Average					float;
DECLARE @LTE1800_TxPwr_Median					float;
DECLARE @LTE1800_TxPwr_Minimum					float;
DECLARE @LTE1800_TxPwr_Maximum					float;
DECLARE @LTE1800_TxPwr_StDev					float;
DECLARE @LTE1800_UL_ALL_Samples_Count			int	 ;
DECLARE @LTE1800_UL_ALL_Average					float;
DECLARE @LTE1800_UL_ALL_Median					float;
DECLARE @LTE1800_UL_ALL_Minimum					float;
DECLARE @LTE1800_UL_ALL_Maximum					float;
DECLARE @LTE1800_UL_ALL_StDev					float;
DECLARE @LTE1800_UL_TestAvg_Samples_Count		int	 ;
DECLARE @LTE1800_UL_TestAvg_Average				float;
DECLARE @LTE1800_UL_TestAvg_Median				float;
DECLARE @LTE1800_UL_TestAvg_Minimum				float;
DECLARE @LTE1800_UL_TestAvg_Maximum				float;
DECLARE @LTE1800_UL_TestAvg_StDev				float;
DECLARE @LTE1800_DL_ALL_Samples_Count			int	 ;
DECLARE @LTE1800_DL_ALL_Average					float;
DECLARE @LTE1800_DL_ALL_Median					float;
DECLARE @LTE1800_DL_ALL_Minimum					float;
DECLARE @LTE1800_DL_ALL_Maximum					float;
DECLARE @LTE1800_DL_ALL_StDev					float;
DECLARE @LTE1800_DL_TestAvg_Samples_Count		int	 ;
DECLARE @LTE1800_DL_TestAvg_Average				float;
DECLARE @LTE1800_DL_TestAvg_Median				float;
DECLARE @LTE1800_DL_TestAvg_Minimum				float;
DECLARE @LTE1800_DL_TestAvg_Maximum				float;
DECLARE @LTE1800_DL_TestAvg_StDev				float;
DECLARE @LTE2600_RSRP_Samples_Count				int	 ;
DECLARE @LTE2600_RSRP_Average					float;
DECLARE @LTE2600_RSRP_Median					float;
DECLARE @LTE2600_RSRP_Minimum					float;
DECLARE @LTE2600_RSRP_Maximum					float;
DECLARE @LTE2600_RSRP_StDev						float;
DECLARE @LTE2600_RSRQ_Samples_Count				int	 ;
DECLARE @LTE2600_RSRQ_Average					float;
DECLARE @LTE2600_RSRQ_Median					float;
DECLARE @LTE2600_RSRQ_Minimum					float;
DECLARE @LTE2600_RSRQ_Maximum					float;
DECLARE @LTE2600_RSRQ_StDev						float;
DECLARE @LTE2600_TxPwr_Samples_Count			int	 ;
DECLARE @LTE2600_TxPwr_Average					float;
DECLARE @LTE2600_TxPwr_Median					float;
DECLARE @LTE2600_TxPwr_Minimum					float;
DECLARE @LTE2600_TxPwr_Maximum					float;
DECLARE @LTE2600_TxPwr_StDev					float;
DECLARE @LTE2600_UL_ALL_Samples_Count			int	 ;
DECLARE @LTE2600_UL_ALL_Average					float;
DECLARE @LTE2600_UL_ALL_Median					float;
DECLARE @LTE2600_UL_ALL_Minimum					float;
DECLARE @LTE2600_UL_ALL_Maximum					float;
DECLARE @LTE2600_UL_ALL_StDev					float;
DECLARE @LTE2600_UL_TestAvg_Samples_Count		int	 ;
DECLARE @LTE2600_UL_TestAvg_Average				float;
DECLARE @LTE2600_UL_TestAvg_Median				float;
DECLARE @LTE2600_UL_TestAvg_Minimum				float;
DECLARE @LTE2600_UL_TestAvg_Maximum				float;
DECLARE @LTE2600_UL_TestAvg_StDev				float;
DECLARE @LTE2600_DL_ALL_Samples_Count			int	 ;
DECLARE @LTE2600_DL_ALL_Average					float;
DECLARE @LTE2600_DL_ALL_Median					float;
DECLARE @LTE2600_DL_ALL_Minimum					float;
DECLARE @LTE2600_DL_ALL_Maximum					float;
DECLARE @LTE2600_DL_ALL_StDev					float;
DECLARE @LTE2600_DL_TestAvg_Samples_Count		int	 ;
DECLARE @LTE2600_DL_TestAvg_Average				float;
DECLARE @LTE2600_DL_TestAvg_Median				float;
DECLARE @LTE2600_DL_TestAvg_Minimum				float;
DECLARE @LTE2600_DL_TestAvg_Maximum				float;
DECLARE @LTE2600_DL_TestAvg_StDev				float;
-- Extract all IMSI in measurement
IF OBJECT_ID ('tempdb..#IMSI_List1' ) IS NOT NULL
			DROP TABLE #IMSI_List1
SELECT DISTINCT [IMSI]
			    --,ROW_NUMBER() OVER(ORDER BY [IMSI]) AS Row   
  INTO #IMSI_List1
  FROM #Tests
  ORDER BY [IMSI] 
IF OBJECT_ID ('tempdb..#IMSI_List' ) IS NOT NULL
			DROP TABLE #IMSI_List
SELECT ROW_NUMBER() OVER(ORDER BY [IMSI]) AS Row
	   ,[IMSI]
  INTO #IMSI_List
  FROM #IMSI_List1

DECLARE @RowNumb int = 0 ;
DECLARE @CurrIMSI varchar(20);

-- Loop IMSI by IMSI
WHILE EXISTS ((SELECT DISTINCT [IMSI] FROM #IMSI_List))
BEGIN
	SET @RowNumb = @RowNumb + 1
	SET @CurrIMSI = (SELECT [IMSI] FROM #IMSI_List WHERE Row like @RowNumb)

	SET @GSM900_RxLev_Samples_Count				= (SELECT COUNT([RxLevFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 900' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM900_RxLev_Average					= (SELECT AVG  ([RxLevFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 900' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM900_RxLev_Median					= (SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [RxLevFull]) OVER () AS Median FROM #GSMRadioRF WHERE [technology] like 'GSM 900' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM900_RxLev_Minimum					= (SELECT MIN  ([RxLevFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 900' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM900_RxLev_Maximum					= (SELECT MAX  ([RxLevFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 900' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM900_RxLev_StDev						= cast((SELECT STDEV([RxLevFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 900' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @GSM900_RxQual_Samples_Count			= (SELECT COUNT([RxQualFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 900' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM900_RxQual_Average					= (SELECT AVG  ([RxQualFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 900' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM900_RxQual_Median					= (SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [RxQualFull]) OVER () AS Median FROM #GSMRadioRF WHERE [technology] like 'GSM 900' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM900_RxQual_Minimum					= (SELECT MIN  ([RxQualFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 900' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM900_RxQual_Maximum					= (SELECT MAX  ([RxQualFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 900' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM900_RxQual_StDev					= cast((SELECT STDEV([RxQualFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 900' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @GSM1800_RxLev_Samples_Count			= (SELECT COUNT([RxLevFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 1800' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM1800_RxLev_Average					= (SELECT AVG  ([RxLevFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 1800' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM1800_RxLev_Median					= (SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [RxLevFull]) OVER () AS Median FROM #GSMRadioRF WHERE [technology] like 'GSM 1800' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM1800_RxLev_Minimum					= (SELECT MIN  ([RxLevFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 1800' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM1800_RxLev_Maximum					= (SELECT MAX  ([RxLevFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 1800' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM1800_RxLev_StDev					= cast((SELECT STDEV([RxLevFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 1800' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @GSM1800_RxQual_Samples_Count			= (SELECT COUNT([RxQualFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 1800' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM1800_RxQual_Average					= (SELECT AVG  ([RxQualFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 1800' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM1800_RxQual_Median					= (SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [RxQualFull]) OVER () AS Median FROM #GSMRadioRF WHERE [technology] like 'GSM 1800' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM1800_RxQual_Minimum					= (SELECT MIN  ([RxQualFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 1800' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM1800_RxQual_Maximum					= (SELECT MAX  ([RxQualFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 1800' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @GSM1800_RxQual_StDev					= cast((SELECT STDEV([RxQualFull]) FROM #GSMRadioRF WHERE [technology] like 'GSM 1800' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))

	SET @UMTS2100_RSCP_Samples_Count			= (SELECT COUNT([AggrRSCP]) FROM #UMTSRadioRF WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )

	SET @UMTS2100_RSCP_Average					= cast((SELECT AVG  ([AggrRSCP]) FROM #UMTSRadioRF WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @UMTS2100_RSCP_Median					= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [AggrRSCP]) OVER () AS Median FROM #UMTSRadioRF WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @UMTS2100_RSCP_Minimum					= cast((SELECT MIN  ([AggrRSCP]) FROM #UMTSRadioRF WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @UMTS2100_RSCP_Maximum					= cast((SELECT MAX  ([AggrRSCP]) FROM #UMTSRadioRF WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @UMTS2100_RSCP_StDev					= cast((SELECT STDEV([AggrRSCP]) FROM #UMTSRadioRF WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))

	SET @UMTS2100_EcNo_Samples_Count			= (SELECT COUNT([AggrEcIo]) FROM #UMTSRadioRF WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )

	SET @UMTS2100_EcNo_Average					= cast((SELECT AVG  ([AggrEcIo]) FROM #UMTSRadioRF WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @UMTS2100_EcNo_Median					= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [AggrEcIo]) OVER () AS Median FROM #UMTSRadioRF WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @UMTS2100_EcNo_Minimum					= cast((SELECT MIN  ([AggrEcIo]) FROM #UMTSRadioRF WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @UMTS2100_EcNo_Maximum					= cast((SELECT MAX  ([AggrEcIo]) FROM #UMTSRadioRF WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @UMTS2100_EcNo_StDev					= cast((SELECT STDEV([AggrEcIo]) FROM #UMTSRadioRF WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))

	SET @UMTS2100_TxPwr_Samples_Count			= (SELECT COUNT([TxPwr]) FROM #UMTSRadioTx WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )

    SET @UMTS2100_TxPwr_Average					= cast((SELECT AVG  ([TxPwr]) FROM #UMTSRadioTx WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @UMTS2100_TxPwr_Median					= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [TxPwr]) OVER () AS Median FROM #UMTSRadioTx WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @UMTS2100_TxPwr_Minimum					= cast((SELECT MIN  ([TxPwr]) FROM #UMTSRadioTx WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @UMTS2100_TxPwr_Maximum					= cast((SELECT MAX  ([TxPwr]) FROM #UMTSRadioTx WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @UMTS2100_TxPwr_StDev					= cast((SELECT STDEV([TxPwr]) FROM #UMTSRadioTx WHERE [technology] like 'UMTS 2100' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))

	SET @UMTS2100_UL_ALL_Samples_Count	        = (SELECT COUNT([Throughput]) FROM #ThroughputData WHERE [technology] like 'UMTS 2100' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) )

	SET @UMTS2100_UL_ALL_Average		        = cast((SELECT AVG  ([Throughput]) FROM #ThroughputData WHERE [technology] like 'UMTS 2100' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @UMTS2100_UL_ALL_Median			        = cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [Throughput]) OVER () AS Median FROM #ThroughputData WHERE [technology] like 'UMTS 2100' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @UMTS2100_UL_ALL_Minimum		        = cast((SELECT MIN  ([Throughput]) FROM #ThroughputData WHERE [technology] like 'UMTS 2100' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @UMTS2100_UL_ALL_Maximum		        = cast((SELECT MAX  ([Throughput]) FROM #ThroughputData WHERE [technology] like 'UMTS 2100' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @UMTS2100_UL_ALL_StDev			        = cast((SELECT STDEV([Throughput]) FROM #ThroughputData WHERE [technology] like 'UMTS 2100' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))

	SET @UMTS2100_UL_TestAvg_Samples_Count		= (SELECT COUNT([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%UMTS%' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) )
	SET @UMTS2100_UL_TestAvg_Average			= cast((SELECT AVG  ([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%UMTS%' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @UMTS2100_UL_TestAvg_Median				= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [UL_bytesSec]) OVER () AS Median FROM #Tests WHERE [UL_bytesSec] is not null and [technology] like '%UMTS%' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @UMTS2100_UL_TestAvg_Minimum			= cast((SELECT MIN  ([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%UMTS%' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @UMTS2100_UL_TestAvg_Maximum			= cast((SELECT MAX  ([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%UMTS%' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))

	SET @UMTS2100_DL_ALL_Samples_Count	        = (SELECT COUNT([Throughput]) FROM #ThroughputData WHERE [technology] like 'UMTS 2100' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) )
	SET @UMTS2100_DL_ALL_Average		        = cast((SELECT AVG  ([Throughput]) FROM #ThroughputData WHERE [technology] like 'UMTS 2100' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @UMTS2100_DL_ALL_Median			        = cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [Throughput]) OVER () AS Median FROM #ThroughputData WHERE [technology] like 'UMTS 2100' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @UMTS2100_DL_ALL_Minimum		        = cast((SELECT MIN  ([Throughput]) FROM #ThroughputData WHERE [technology] like 'UMTS 2100' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @UMTS2100_DL_ALL_Maximum		        = cast((SELECT MAX  ([Throughput]) FROM #ThroughputData WHERE [technology] like 'UMTS 2100' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @UMTS2100_DL_ALL_StDev			        = cast((SELECT STDEV([Throughput]) FROM #ThroughputData WHERE [technology] like 'UMTS 2100' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))

	SET @UMTS2100_DL_TestAvg_Samples_Count		= (SELECT COUNT([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%UMTS%' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) )
	SET @UMTS2100_DL_TestAvg_Average			= cast((SELECT AVG  ([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%UMTS%' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @UMTS2100_DL_TestAvg_Median				= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [DL_bytesSec]) OVER () AS Median FROM #Tests WHERE [DL_bytesSec] is not null and [technology] like '%UMTS%' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @UMTS2100_DL_TestAvg_Minimum			= cast((SELECT MIN  ([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%UMTS%' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @UMTS2100_DL_TestAvg_Maximum			= cast((SELECT MAX  ([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%UMTS%' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))

	SET @LTE800_RSRP_Samples_Count				= (SELECT COUNT([RSRP]) FROM #LTERadioRF WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @LTE800_RSRP_Average					= cast((SELECT AVG  ([RSRP]) FROM #LTERadioRF WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE800_RSRP_Median						= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [RSRP]) OVER () AS Median FROM #LTERadioRF WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE800_RSRP_Minimum					= cast((SELECT MIN  ([RSRP]) FROM #LTERadioRF WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE800_RSRP_Maximum					= cast((SELECT MAX  ([RSRP]) FROM #LTERadioRF WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE800_RSRP_StDev						= cast((SELECT STDEV([RSRP]) FROM #LTERadioRF WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))

	SET @LTE800_RSRQ_Samples_Count				= (SELECT COUNT([RSRQ]) FROM #LTERadioRF WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @LTE800_RSRQ_Average					= cast((SELECT AVG  ([RSRQ]) FROM #LTERadioRF WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE800_RSRQ_Median						= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [RSRQ]) OVER () AS Median FROM #LTERadioRF WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE800_RSRQ_Minimum					= cast((SELECT MIN  ([RSRQ]) FROM #LTERadioRF WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE800_RSRQ_Maximum					= cast((SELECT MAX  ([RSRQ]) FROM #LTERadioRF WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE800_RSRQ_StDev						= cast((SELECT STDEV([RSRQ]) FROM #LTERadioRF WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))

	SET @LTE800_TxPwr_Samples_Count				= (SELECT COUNT([PuschTxPower]) FROM #LTERadioTx WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
    SET @LTE800_TxPwr_Average					= cast((SELECT AVG  ([PuschTxPower]) FROM #LTERadioTx WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @LTE800_TxPwr_Median					= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [PuschTxPower]) OVER () AS Median FROM #LTERadioTx WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @LTE800_TxPwr_Minimum					= cast((SELECT MIN  ([PuschTxPower]) FROM #LTERadioTx WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @LTE800_TxPwr_Maximum					= cast((SELECT MAX  ([PuschTxPower]) FROM #LTERadioTx WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @LTE800_TxPwr_StDev						= cast((SELECT STDEV([PuschTxPower]) FROM #LTERadioTx WHERE [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))

	SET @LTE800_UL_ALL_Samples_Count			= (SELECT COUNT([Throughput]) FROM #ThroughputData WHERE [technology] like '%20' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) )
	SET @LTE800_UL_ALL_Average					= cast((SELECT AVG  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%20' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE800_UL_ALL_Median					= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [Throughput]) OVER () AS Median FROM #ThroughputData WHERE [technology] like '%20' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE800_UL_ALL_Minimum					= cast((SELECT MIN  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%20' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE800_UL_ALL_Maximum					= cast((SELECT MAX  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%20' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE800_UL_ALL_StDev					= cast((SELECT STDEV([Throughput]) FROM #ThroughputData WHERE [technology] like '%20' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))

	SET @LTE800_UL_TestAvg_Samples_Count		= (SELECT COUNT([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) )
	SET @LTE800_UL_TestAvg_Average				= cast((SELECT AVG  ([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE800_UL_TestAvg_Median				= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [UL_bytesSec]) OVER () AS Median FROM #Tests WHERE [UL_bytesSec] is not null and [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE800_UL_TestAvg_Minimum				= cast((SELECT MIN  ([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE800_UL_TestAvg_Maximum				= cast((SELECT MAX  ([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))

	SET @LTE800_DL_ALL_Samples_Count			= (SELECT COUNT([Throughput]) FROM #ThroughputData WHERE [technology] like '%20' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) )
	SET @LTE800_DL_ALL_Average					= cast((SELECT AVG  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%20' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @LTE800_DL_ALL_Median					= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [Throughput]) OVER () AS Median FROM #ThroughputData WHERE [technology] like '%20' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @LTE800_DL_ALL_Minimum					= cast((SELECT MIN  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%20' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @LTE800_DL_ALL_Maximum					= cast((SELECT MAX  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%20' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @LTE800_DL_ALL_StDev					= cast((SELECT STDEV([Throughput]) FROM #ThroughputData WHERE [technology] like '%20' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))

	SET @LTE800_DL_TestAvg_Samples_Count		= (SELECT COUNT([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) )
	SET @LTE800_DL_TestAvg_Average				= cast((SELECT AVG  ([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE800_DL_TestAvg_Median				= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [DL_bytesSec]) OVER () AS Median FROM #Tests WHERE [DL_bytesSec] is not null and [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE800_DL_TestAvg_Minimum				= cast((SELECT MIN  ([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE800_DL_TestAvg_Maximum				= cast((SELECT MAX  ([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%20' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))

	SET @LTE1800_RSRP_Samples_Count				= (SELECT COUNT([RSRP]) FROM #LTERadioRF WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @LTE1800_RSRP_Average					= cast((SELECT AVG  ([RSRP]) FROM #LTERadioRF WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE1800_RSRP_Median					= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [RSRP]) OVER () AS Median FROM #LTERadioRF WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE1800_RSRP_Minimum					= cast((SELECT MIN  ([RSRP]) FROM #LTERadioRF WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE1800_RSRP_Maximum					= cast((SELECT MAX  ([RSRP]) FROM #LTERadioRF WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE1800_RSRP_StDev						= cast((SELECT STDEV([RSRP]) FROM #LTERadioRF WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))

	SET @LTE1800_RSRQ_Samples_Count				= (SELECT COUNT([RSRQ]) FROM #LTERadioRF WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @LTE1800_RSRQ_Average					= cast((SELECT AVG  ([RSRQ]) FROM #LTERadioRF WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE1800_RSRQ_Median					= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [RSRQ]) OVER () AS Median FROM #LTERadioRF WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE1800_RSRQ_Minimum					= cast((SELECT MIN  ([RSRQ]) FROM #LTERadioRF WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE1800_RSRQ_Maximum					= cast((SELECT MAX  ([RSRQ]) FROM #LTERadioRF WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE1800_RSRQ_StDev						= cast((SELECT STDEV([RSRQ]) FROM #LTERadioRF WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))

	SET @LTE1800_TxPwr_Samples_Count			= (SELECT COUNT([PuschTxPower]) FROM #LTERadioTx WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
    SET @LTE1800_TxPwr_Average					= cast((SELECT AVG  ([PuschTxPower]) FROM #LTERadioTx WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @LTE1800_TxPwr_Median					= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [PuschTxPower]) OVER () AS Median FROM #LTERadioTx WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @LTE1800_TxPwr_Minimum					= cast((SELECT MIN  ([PuschTxPower]) FROM #LTERadioTx WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @LTE1800_TxPwr_Maximum					= cast((SELECT MAX  ([PuschTxPower]) FROM #LTERadioTx WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @LTE1800_TxPwr_StDev					= cast((SELECT STDEV([PuschTxPower]) FROM #LTERadioTx WHERE [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))

	SET @LTE1800_UL_ALL_Samples_Count	    	= (SELECT COUNT([Throughput]) FROM #ThroughputData WHERE [technology] like '%3' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) )
	SET @LTE1800_UL_ALL_Average		        	= cast((SELECT AVG  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%3' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE1800_UL_ALL_Median			    	= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [Throughput]) OVER () AS Median FROM #ThroughputData WHERE [technology] like '%3' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE1800_UL_ALL_Minimum		        	= cast((SELECT MIN  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%3' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE1800_UL_ALL_Maximum		        	= cast((SELECT MAX  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%3' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE1800_UL_ALL_StDev			    	= cast((SELECT STDEV([Throughput]) FROM #ThroughputData WHERE [technology] like '%3' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))

	SET @LTE1800_UL_TestAvg_Samples_Count		= (SELECT COUNT([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) )
	SET @LTE1800_UL_TestAvg_Average				= cast((SELECT AVG  ([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE1800_UL_TestAvg_Median				= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [UL_bytesSec]) OVER () AS Median FROM #Tests WHERE [UL_bytesSec] is not null and [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE1800_UL_TestAvg_Minimum				= cast((SELECT MIN  ([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE1800_UL_TestAvg_Maximum				= cast((SELECT MAX  ([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	
	SET @LTE1800_DL_ALL_Samples_Count	    	= (SELECT COUNT([Throughput]) FROM #ThroughputData WHERE [technology] like '%3' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) )
	SET @LTE1800_DL_ALL_Average		        	= cast((SELECT AVG  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%3' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @LTE1800_DL_ALL_Median			    	= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [Throughput]) OVER () AS Median FROM #ThroughputData WHERE [technology] like '%3' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @LTE1800_DL_ALL_Minimum		        	= cast((SELECT MIN  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%3' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @LTE1800_DL_ALL_Maximum		        	= cast((SELECT MAX  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%3' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @LTE1800_DL_ALL_StDev			    	= cast((SELECT STDEV([Throughput]) FROM #ThroughputData WHERE [technology] like '%3' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))

	SET @LTE1800_DL_TestAvg_Samples_Count		= (SELECT COUNT([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) )
	SET @LTE1800_DL_TestAvg_Average				= cast((SELECT AVG  ([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE1800_DL_TestAvg_Median				= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [DL_bytesSec]) OVER () AS Median FROM #Tests WHERE [DL_bytesSec] is not null and [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE1800_DL_TestAvg_Minimum				= cast((SELECT MIN  ([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE1800_DL_TestAvg_Maximum				= cast((SELECT MAX  ([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%3' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))

	SET @LTE2600_RSRP_Samples_Count				= (SELECT COUNT([RSRP]) FROM #LTERadioRF WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @LTE2600_RSRP_Average					= cast((SELECT AVG  ([RSRP]) FROM #LTERadioRF WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE2600_RSRP_Median					= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [RSRP]) OVER () AS Median FROM #LTERadioRF WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE2600_RSRP_Minimum					= cast((SELECT MIN  ([RSRP]) FROM #LTERadioRF WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE2600_RSRP_Maximum					= cast((SELECT MAX  ([RSRP]) FROM #LTERadioRF WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE2600_RSRP_StDev						= cast((SELECT STDEV([RSRP]) FROM #LTERadioRF WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))

	SET @LTE2600_RSRQ_Samples_Count				= (SELECT COUNT([RSRQ]) FROM #LTERadioRF WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
	SET @LTE2600_RSRQ_Average					= cast((SELECT AVG  ([RSRQ]) FROM #LTERadioRF WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE2600_RSRQ_Median					= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [RSRQ]) OVER () AS Median FROM #LTERadioRF WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE2600_RSRQ_Minimum					= cast((SELECT MIN  ([RSRQ]) FROM #LTERadioRF WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE2600_RSRQ_Maximum					= cast((SELECT MAX  ([RSRQ]) FROM #LTERadioRF WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
	SET @LTE2600_RSRQ_StDev						= cast((SELECT STDEV([RSRQ]) FROM #LTERadioRF WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))

	SET @LTE2600_TxPwr_Samples_Count			= (SELECT COUNT([PuschTxPower]) FROM #LTERadioTx WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) )
    SET @LTE2600_TxPwr_Average					= cast((SELECT AVG  ([PuschTxPower]) FROM #LTERadioTx WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @LTE2600_TxPwr_Median					= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [PuschTxPower]) OVER () AS Median FROM #LTERadioTx WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @LTE2600_TxPwr_Minimum					= cast((SELECT MIN  ([PuschTxPower]) FROM #LTERadioTx WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @LTE2600_TxPwr_Maximum					= cast((SELECT MAX  ([PuschTxPower]) FROM #LTERadioTx WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))
    SET @LTE2600_TxPwr_StDev					= cast((SELECT STDEV([PuschTxPower]) FROM #LTERadioTx WHERE [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI) ) as numeric (36,2))

	SET @LTE2600_UL_ALL_Samples_Count	    	= (SELECT COUNT([Throughput]) FROM #ThroughputData WHERE [technology] like '%7' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) )
	SET @LTE2600_UL_ALL_Average		        	= cast((SELECT AVG  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%7' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE2600_UL_ALL_Median			    	= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [Throughput]) OVER () AS Median FROM #ThroughputData WHERE [technology] like '%7' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE2600_UL_ALL_Minimum		        	= cast((SELECT MIN  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%7' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE2600_UL_ALL_Maximum		        	= cast((SELECT MAX  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%7' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE2600_UL_ALL_StDev			    	= cast((SELECT STDEV([Throughput]) FROM #ThroughputData WHERE [technology] like '%7' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))

	SET @LTE2600_UL_TestAvg_Samples_Count		= (SELECT COUNT([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) )
	SET @LTE2600_UL_TestAvg_Average				= cast((SELECT AVG  ([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE2600_UL_TestAvg_Median				= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [UL_bytesSec]) OVER () AS Median FROM #Tests WHERE [UL_bytesSec] is not null and [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE2600_UL_TestAvg_Minimum				= cast((SELECT MIN  ([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE2600_UL_TestAvg_Maximum				= cast((SELECT MAX  ([UL_bytesSec]) FROM #Tests WHERE  [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))

	SET @LTE2600_DL_ALL_Samples_Count	    	= (SELECT COUNT([Throughput]) FROM #ThroughputData WHERE [technology] like '%7' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) )
	SET @LTE2600_DL_ALL_Average		        	= cast((SELECT AVG  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%7' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @LTE2600_DL_ALL_Median			    	= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [Throughput]) OVER () AS Median FROM #ThroughputData WHERE [technology] like '%7' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @LTE2600_DL_ALL_Minimum		        	= cast((SELECT MIN  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%7' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @LTE2600_DL_ALL_Maximum		        	= cast((SELECT MAX  ([Throughput]) FROM #ThroughputData WHERE [technology] like '%7' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))
	SET @LTE2600_DL_ALL_StDev			    	= cast((SELECT STDEV([Throughput]) FROM #ThroughputData WHERE [technology] like '%7' and [Throughput] is not null and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_DL_TestID] is not null) ) as numeric (36,2))

	SET @LTE2600_DL_TestAvg_Samples_Count		= (SELECT COUNT([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) )
	SET @LTE2600_DL_TestAvg_Average				= cast((SELECT AVG  ([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE2600_DL_TestAvg_Median				= cast((SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [DL_bytesSec]) OVER () AS Median FROM #Tests WHERE [DL_bytesSec] is not null and [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE2600_DL_TestAvg_Minimum				= cast((SELECT MIN  ([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	SET @LTE2600_DL_TestAvg_Maximum				= cast((SELECT MAX  ([DL_bytesSec]) FROM #Tests WHERE  [technology] like '%7' and [SessionId] in (SELECT [SessionId] FROM #Tests WHERE [IMSI] like @CurrIMSI and [Data_UL_TestID] is not null) ) as numeric (36,2))
	
	IF @CurrIMSI is null BREAK
	INSERT INTO #FinalResults(
						IMSI,
						"GSM 900 RxLev (Samples Count)                            ",
						"GSM 900 RxLev (Average)                                  ",
						"GSM 900 RxLev (Median)                                   ",
						"GSM 900 RxLev (Minimum)                                  ",
						"GSM 900 RxLev (Maximum)                                  ",
						"GSM 900 RxLev (Standard Deviation)                       ",
						"GSM 900 RxQual (Samples Count)                           ",
						"GSM 900 RxQual (Average)                                 ",
						"GSM 900 RxQual (Median)                                  ",
						"GSM 900 RxQual (Minimum)                                 ",
						"GSM 900 RxQual (Maximum)                                 ",
						"GSM 900 RxQual (Standard Deviation)                      ",
						"GSM 1800 RxLev (Samples Count)                           ",
						"GSM 1800 RxLev (Average)                                 ",
						"GSM 1800 RxLev (Median)                                  ",
						"GSM 1800 RxLev (Minimum)                                 ",
						"GSM 1800 RxLev (Maximum)                                 ",
						"GSM 1800 RxLev (Standard Deviation)                      ",
						"GSM 1800 RxQual (Samples Count)                          ",
						"GSM 1800 RxQual (Average)                                ",
						"GSM 1800 RxQual (Median)                                 ",
						"GSM 1800 RxQual (Minimum)                                ",
						"GSM 1800 RxQual (Maximum)                                ",
						"GSM 1800 RxQual (Standard Deviation)                     ",
						"UMTS 2100 RSCP (Samples Count)                           ",
						"UMTS 2100 RSCP (Average)                                 ",
						"UMTS 2100 RSCP (Median)                                  ",
						"UMTS 2100 RSCP (Minimum)                                 ",
						"UMTS 2100 RSCP (Maximum)                                 ",
						"UMTS 2100 RSCP (Standard Deviation)                      ",
						"UMTS 2100 EcNo (Samples Count)                           ",
						"UMTS 2100 EcNo (Average)                                 ",
						"UMTS 2100 EcNo (Median)                                  ",
						"UMTS 2100 EcNo (Minimum)                                 ",
						"UMTS 2100 EcNo (Maximum)                                 ",
						"UMTS 2100 EcNo (Standard Deviation)                      ",
						"UMTS 2100 TxPwr (Samples Count)                          ",
						"UMTS 2100 TxPwr (Average)                                ",
						"UMTS 2100 TxPwr (Median)                                 ",
						"UMTS 2100 TxPwr (Minimum)                                ",
						"UMTS 2100 TxPwr (Maximum)                                ",
						"UMTS 2100 TxPwr (Standard Deviation)                     ",
						"UMTS 2100 UL Throughput ALL Samples (Samples Count)      ",
						"UMTS 2100 UL Throughput ALL Samples (Average)            ",
						"UMTS 2100 UL Throughput ALL Samples (Median)             ",
						"UMTS 2100 UL Throughput ALL Samples (Minimum)            ",
						"UMTS 2100 UL Throughput ALL Samples (Maximum)            ",
						"UMTS 2100 UL Throughput Test Average (Samples Count)     ",
						"UMTS 2100 UL Throughput Test Average (Average)           ",
						"UMTS 2100 UL Throughput Test Average (Median)            ",
						"UMTS 2100 UL Throughput Test Average (Minimum)           ",
						"UMTS 2100 UL Throughput Test Average (Maximum)           ",
						"UMTS 2100 DL Throughput ALL Samples (Samples Count)      ",
						"UMTS 2100 DL Throughput ALL Samples (Average)            ",
						"UMTS 2100 DL Throughput ALL Samples (Median)             ",
						"UMTS 2100 DL Throughput ALL Samples (Minimum)            ",
						"UMTS 2100 DL Throughput ALL Samples (Maximum)            ",
						"UMTS 2100 DL Throughput Test Average (Samples Count)     ",
						"UMTS 2100 DL Throughput Test Average (Average)           ",
						"UMTS 2100 DL Throughput Test Average (Median)            ",
						"UMTS 2100 DL Throughput Test Average (Minimum)           ",
						"UMTS 2100 DL Throughput Test Average (Maximum)           ",
						"LTE 800 RSRP (Samples Count)                             ",
						"LTE 800 RSRP (Average)                                   ",
						"LTE 800 RSRP (Median)                                    ",
						"LTE 800 RSRP (Minimum)                                   ",
						"LTE 800 RSRP (Maximum)                                   ",
						"LTE 800 RSRP (Standard Deviation)                        ",
						"LTE 800 RSRQ (Samples Count)                             ",
						"LTE 800 RSRQ (Average)                                   ",
						"LTE 800 RSRQ (Median)                                    ",
						"LTE 800 RSRQ (Minimum)                                   ",
						"LTE 800 RSRQ (Maximum)                                   ",
						"LTE 800 RSRQ (Standard Deviation)                        ",
						"LTE 800 TxPwr (Samples Count)                            ",
						"LTE 800 TxPwr (Average)                                  ",
						"LTE 800 TxPwr (Median)                                   ",
						"LTE 800 TxPwr (Minimum)                                  ",
						"LTE 800 TxPwr (Maximum)                                  ",
						"LTE 800 TxPwr (Standard Deviation)                       ",
						"LTE 800 UL Throughput ALL Samples (Samples Count)        ",
						"LTE 800 UL Throughput ALL Samples (Average)              ",
						"LTE 800 UL Throughput ALL Samples (Median)               ",
						"LTE 800 UL Throughput ALL Samples (Minimum)              ",
						"LTE 800 UL Throughput ALL Samples (Maximum)              ",
						"LTE 800 UL Throughput Test Average (Samples Count)       ",
						"LTE 800 UL Throughput Test Average (Average)             ",
						"LTE 800 UL Throughput Test Average (Median)              ",
						"LTE 800 UL Throughput Test Average (Minimum)             ",
						"LTE 800 UL Throughput Test Average (Maximum)             ",
						"LTE 800 DL Throughput ALL Samples (Samples Count)        ",
						"LTE 800 DL Throughput ALL Samples (Average)              ",
						"LTE 800 DL Throughput ALL Samples (Median)               ",
						"LTE 800 DL Throughput ALL Samples (Minimum)              ",
						"LTE 800 DL Throughput ALL Samples (Maximum)              ",
						"LTE 800 DL Throughput Test Average (Samples Count)       ",
						"LTE 800 DL Throughput Test Average (Average)             ",
						"LTE 800 DL Throughput Test Average (Median)              ",
						"LTE 800 DL Throughput Test Average (Minimum)             ",
						"LTE 800 DL Throughput Test Average (Maximum)             ",
						"LTE 1800 RSRP (Samples Count)                            ",
						"LTE 1800 RSRP (Average)                                  ",
						"LTE 1800 RSRP (Median)                                   ",
						"LTE 1800 RSRP (Minimum)                                  ",
						"LTE 1800 RSRP (Maximum)                                  ",
						"LTE 1800 RSRP (Standard Deviation)                       ",
						"LTE 1800 RSRQ (Samples Count)                            ",
						"LTE 1800 RSRQ (Average)                                  ",
						"LTE 1800 RSRQ (Median)                                   ",
						"LTE 1800 RSRQ (Minimum)                                  ",
						"LTE 1800 RSRQ (Maximum)                                  ",
						"LTE 1800 RSRQ (Standard Deviation)                       ",
						"LTE 1800 TxPwr (Samples Count)                           ",
						"LTE 1800 TxPwr (Average)                                 ",
						"LTE 1800 TxPwr (Median)                                  ",
						"LTE 1800 TxPwr (Minimum)                                 ",
						"LTE 1800 TxPwr (Maximum)                                 ",
						"LTE 1800 TxPwr (Standard Deviation)                      ",
						"LTE 1800 UL Throughput ALL Samples (Samples Count)       ",
						"LTE 1800 UL Throughput ALL Samples (Average)             ",
						"LTE 1800 UL Throughput ALL Samples (Median)              ",
						"LTE 1800 UL Throughput ALL Samples (Minimum)             ",
						"LTE 1800 UL Throughput ALL Samples (Maximum)             ",
						"LTE 1800 UL Throughput Test Average (Samples Count)      ",
						"LTE 1800 UL Throughput Test Average (Average)            ",
						"LTE 1800 UL Throughput Test Average (Median)             ",
						"LTE 1800 UL Throughput Test Average (Minimum)            ",
						"LTE 1800 UL Throughput Test Average (Maximum)            ",
						"LTE 1800 DL Throughput ALL Samples (Samples Count)       ",
						"LTE 1800 DL Throughput ALL Samples (Average)             ",
						"LTE 1800 DL Throughput ALL Samples (Median)              ",
						"LTE 1800 DL Throughput ALL Samples (Minimum)             ",
						"LTE 1800 DL Throughput ALL Samples (Maximum)             ",
						"LTE 1800 DL Throughput Test Average (Samples Count)      ",
						"LTE 1800 DL Throughput Test Average (Average)            ",
						"LTE 1800 DL Throughput Test Average (Median)             ",
						"LTE 1800 DL Throughput Test Average (Minimum)            ",
						"LTE 1800 DL Throughput Test Average (Maximum)            ",
						"LTE 2600 RSRP (Samples Count)                            ",
						"LTE 2600 RSRP (Average)                                  ",
						"LTE 2600 RSRP (Median)                                   ",
						"LTE 2600 RSRP (Minimum)                                  ",
						"LTE 2600 RSRP (Maximum)                                  ",
						"LTE 2600 RSRP (Standard Deviation)                       ",
						"LTE 2600 RSRQ (Samples Count)                            ",
						"LTE 2600 RSRQ (Average)                                  ",
						"LTE 2600 RSRQ (Median)                                   ",
						"LTE 2600 RSRQ (Minimum)                                  ",
						"LTE 2600 RSRQ (Maximum)                                  ",
						"LTE 2600 RSRQ (Standard Deviation)                       ",
						"LTE 2600 TxPwr (Samples Count)                           ",
						"LTE 2600 TxPwr (Average)                                 ",
						"LTE 2600 TxPwr (Median)                                  ",
						"LTE 2600 TxPwr (Minimum)                                 ",
						"LTE 2600 TxPwr (Maximum)                                 ",
						"LTE 2600 TxPwr (Standard Deviation)                      ",
						"LTE 2600 UL Throughput ALL Samples (Samples Count)       ",
						"LTE 2600 UL Throughput ALL Samples (Average)             ",
						"LTE 2600 UL Throughput ALL Samples (Median)              ",
						"LTE 2600 UL Throughput ALL Samples (Minimum)             ",
						"LTE 2600 UL Throughput ALL Samples (Maximum)             ",
						"LTE 2600 UL Throughput Test Average (Samples Count)      ",
						"LTE 2600 UL Throughput Test Average (Average)            ",
						"LTE 2600 UL Throughput Test Average (Median)             ",
						"LTE 2600 UL Throughput Test Average (Minimum)            ",
						"LTE 2600 UL Throughput Test Average (Maximum)            ",
						"LTE 2600 DL Throughput ALL Samples (Samples Count)       ",
						"LTE 2600 DL Throughput ALL Samples (Average)             ",
						"LTE 2600 DL Throughput ALL Samples (Median)              ",
						"LTE 2600 DL Throughput ALL Samples (Minimum)             ",
						"LTE 2600 DL Throughput ALL Samples (Maximum)             ",
						"LTE 2600 DL Throughput Test Average (Samples Count)      ",
						"LTE 2600 DL Throughput Test Average (Average)            ",
						"LTE 2600 DL Throughput Test Average (Median)             ",
						"LTE 2600 DL Throughput Test Average (Minimum)            ",
						"LTE 2600 DL Throughput Test Average (Maximum)            ")
	SELECT @CurrIMSI                                  
		    ,@GSM900_RxLev_Samples_Count				  
			,@GSM900_RxLev_Average				      
			,@GSM900_RxLev_Median				      
			,@GSM900_RxLev_Minimum				      
			,@GSM900_RxLev_Maximum				      
			,@GSM900_RxLev_StDev					  
			,@GSM900_RxQual_Samples_Count		      
			,@GSM900_RxQual_Average				      
			,@GSM900_RxQual_Median				      
			,@GSM900_RxQual_Minimum				      
			,@GSM900_RxQual_Maximum				      
			,@GSM900_RxQual_StDev				      
			,@GSM1800_RxLev_Samples_Count		      
			,@GSM1800_RxLev_Average				      
			,@GSM1800_RxLev_Median				      
			,@GSM1800_RxLev_Minimum				      
			,@GSM1800_RxLev_Maximum				      
			,@GSM1800_RxLev_StDev				      
			,@GSM1800_RxQual_Samples_Count		      
			,@GSM1800_RxQual_Average				  
			,@GSM1800_RxQual_Median				      
			,@GSM1800_RxQual_Minimum				  
			,@GSM1800_RxQual_Maximum				  
			,@GSM1800_RxQual_StDev				      
			,@UMTS2100_RSCP_Samples_Count		      
			,@UMTS2100_RSCP_Average				      
			,@UMTS2100_RSCP_Median				      
			,@UMTS2100_RSCP_Minimum				      
			,@UMTS2100_RSCP_Maximum				      
			,@UMTS2100_RSCP_StDev				      
			,@UMTS2100_EcNo_Samples_Count		      
			,@UMTS2100_EcNo_Average				      
			,@UMTS2100_EcNo_Median				      
			,@UMTS2100_EcNo_Minimum				      
			,@UMTS2100_EcNo_Maximum				      
			,@UMTS2100_EcNo_StDev				      
			,@UMTS2100_TxPwr_Samples_Count		      
			,@UMTS2100_TxPwr_Average				  
			,@UMTS2100_TxPwr_Median				      
			,@UMTS2100_TxPwr_Minimum				  
			,@UMTS2100_TxPwr_Maximum				  
			,@UMTS2100_TxPwr_StDev				      
			,@UMTS2100_UL_ALL_Samples_Count	          
			,@UMTS2100_UL_ALL_Average		          
			,@UMTS2100_UL_ALL_Median			      
			,@UMTS2100_UL_ALL_Minimum		          
			,@UMTS2100_UL_ALL_Maximum		          
			,@UMTS2100_UL_TestAvg_Samples_Count	      
			,@UMTS2100_UL_TestAvg_Average		      
			,@UMTS2100_UL_TestAvg_Median			  
			,@UMTS2100_UL_TestAvg_Minimum		      
			,@UMTS2100_UL_TestAvg_Maximum		      
			,@UMTS2100_DL_ALL_Samples_Count	          
			,@UMTS2100_DL_ALL_Average		          
			,@UMTS2100_DL_ALL_Median			      
			,@UMTS2100_DL_ALL_Minimum		          
			,@UMTS2100_DL_ALL_Maximum		          
			,@UMTS2100_DL_TestAvg_Samples_Count	      
			,@UMTS2100_DL_TestAvg_Average		      
			,@UMTS2100_DL_TestAvg_Median			  
			,@UMTS2100_DL_TestAvg_Minimum		      
			,@UMTS2100_DL_TestAvg_Maximum		      
			,@LTE800_RSRP_Samples_Count			      
			,@LTE800_RSRP_Average				      
			,@LTE800_RSRP_Median					  
			,@LTE800_RSRP_Minimum				      
			,@LTE800_RSRP_Maximum				      
			,@LTE800_RSRP_StDev					      
			,@LTE800_RSRQ_Samples_Count			      
			,@LTE800_RSRQ_Average				      
			,@LTE800_RSRQ_Median					  
			,@LTE800_RSRQ_Minimum				      
			,@LTE800_RSRQ_Maximum				      
			,@LTE800_RSRQ_StDev					      
			,@LTE800_TxPwr_Samples_Count			  
			,@LTE800_TxPwr_Average				      
			,@LTE800_TxPwr_Median				      
			,@LTE800_TxPwr_Minimum				      
			,@LTE800_TxPwr_Maximum				      
			,@LTE800_TxPwr_StDev					  
			,@LTE800_UL_ALL_Samples_Count		      
			,@LTE800_UL_ALL_Average				      
			,@LTE800_UL_ALL_Median				      
			,@LTE800_UL_ALL_Minimum				      
			,@LTE800_UL_ALL_Maximum				      
			,@LTE800_UL_TestAvg_Samples_Count	      
			,@LTE800_UL_TestAvg_Average			      
			,@LTE800_UL_TestAvg_Median			      
			,@LTE800_UL_TestAvg_Minimum			      
			,@LTE800_UL_TestAvg_Maximum			      
			,@LTE800_DL_ALL_Samples_Count		      
			,@LTE800_DL_ALL_Average				      
			,@LTE800_DL_ALL_Median				      
			,@LTE800_DL_ALL_Minimum				      
			,@LTE800_DL_ALL_Maximum				      
			,@LTE800_DL_TestAvg_Samples_Count	      
			,@LTE800_DL_TestAvg_Average			      
			,@LTE800_DL_TestAvg_Median			      
			,@LTE800_DL_TestAvg_Minimum			      
			,@LTE800_DL_TestAvg_Maximum			      
			,@LTE1800_RSRP_Samples_Count			  
			,@LTE1800_RSRP_Average				      
			,@LTE1800_RSRP_Median				      
			,@LTE1800_RSRP_Minimum				      
			,@LTE1800_RSRP_Maximum				      
			,@LTE1800_RSRP_StDev					  
			,@LTE1800_RSRQ_Samples_Count			  
			,@LTE1800_RSRQ_Average				      
			,@LTE1800_RSRQ_Median				      
			,@LTE1800_RSRQ_Minimum				      
			,@LTE1800_RSRQ_Maximum				      
			,@LTE1800_RSRQ_StDev					  
			,@LTE1800_TxPwr_Samples_Count		      
			,@LTE1800_TxPwr_Average				      
			,@LTE1800_TxPwr_Median				      
			,@LTE1800_TxPwr_Minimum				      
			,@LTE1800_TxPwr_Maximum				      
			,@LTE1800_TxPwr_StDev				      
			,@LTE1800_UL_ALL_Samples_Count	          
			,@LTE1800_UL_ALL_Average		          
			,@LTE1800_UL_ALL_Median			          
			,@LTE1800_UL_ALL_Minimum		          
			,@LTE1800_UL_ALL_Maximum		          
			,@LTE1800_UL_TestAvg_Samples_Count	      
			,@LTE1800_UL_TestAvg_Average			  
			,@LTE1800_UL_TestAvg_Median			      
			,@LTE1800_UL_TestAvg_Minimum			  
			,@LTE1800_UL_TestAvg_Maximum			  
			,@LTE1800_DL_ALL_Samples_Count	          
			,@LTE1800_DL_ALL_Average		          
			,@LTE1800_DL_ALL_Median			          
			,@LTE1800_DL_ALL_Minimum		          
			,@LTE1800_DL_ALL_Maximum		          
			,@LTE1800_DL_TestAvg_Samples_Count	      
			,@LTE1800_DL_TestAvg_Average			  
			,@LTE1800_DL_TestAvg_Median			      
			,@LTE1800_DL_TestAvg_Minimum			  
			,@LTE1800_DL_TestAvg_Maximum			  
			,@LTE2600_RSRP_Samples_Count			  
			,@LTE2600_RSRP_Average				      
			,@LTE2600_RSRP_Median				      
			,@LTE2600_RSRP_Minimum				      
			,@LTE2600_RSRP_Maximum				      
			,@LTE2600_RSRP_StDev					  
			,@LTE2600_RSRQ_Samples_Count			  
			,@LTE2600_RSRQ_Average				      
			,@LTE2600_RSRQ_Median				      
			,@LTE2600_RSRQ_Minimum				      
			,@LTE2600_RSRQ_Maximum				      
			,@LTE2600_RSRQ_StDev					  
			,@LTE2600_TxPwr_Samples_Count		      
			,@LTE2600_TxPwr_Average				      
			,@LTE2600_TxPwr_Median				      
			,@LTE2600_TxPwr_Minimum				      
			,@LTE2600_TxPwr_Maximum				      
			,@LTE2600_TxPwr_StDev				      
			,@LTE2600_UL_ALL_Samples_Count	          
			,@LTE2600_UL_ALL_Average		          
			,@LTE2600_UL_ALL_Median			          
			,@LTE2600_UL_ALL_Minimum		          
			,@LTE2600_UL_ALL_Maximum		          
			,@LTE2600_UL_TestAvg_Samples_Count	      
			,@LTE2600_UL_TestAvg_Average			  
			,@LTE2600_UL_TestAvg_Median			      
			,@LTE2600_UL_TestAvg_Minimum			  
			,@LTE2600_UL_TestAvg_Maximum			  
			,@LTE2600_DL_ALL_Samples_Count	          
			,@LTE2600_DL_ALL_Average		          
			,@LTE2600_DL_ALL_Median			          
			,@LTE2600_DL_ALL_Minimum		          
			,@LTE2600_DL_ALL_Maximum		          
			,@LTE2600_DL_TestAvg_Samples_Count	      
			,@LTE2600_DL_TestAvg_Average			  
			,@LTE2600_DL_TestAvg_Median			      
			,@LTE2600_DL_TestAvg_Minimum			  
			,@LTE2600_DL_TestAvg_Maximum			  
       FROM #Tests WHERE [IMSI] like @CurrIMSI
END

SELECT DISTINCT * FROM #FinalResults