-- SCRIPT for Milena-s request
-- Telefonica wants to correlete bad samples with Radio Conditions of HO
-- Telefonica want information about Codec Smple Rate and POLQA Value

-- PreRequirement
-- NC_scripts: 04_Create_NC_Speech_Sample_Quality_V3.sql, 06_3_Create_NC_Calls_v30_DriveVoice_Testphase .sql
-- Folder Name: D:\SQL Scripts\Milena -- Telefonica -- SpeechSamples - MiningScripts
-- Script in Folder: PreRequirement -- NC_Radio_Script.sql

-- VARIABLES USED FOR DATA MINING
DECLARE @Operator	varchar(50)       = 'EPlus' ;
DECLARE @CallSTAT	varchar(50)       = '%Comple%' ;

-- Extract bitrate absolute time duration into Temporary Table
IF OBJECT_ID ('tempdb..#CodecBitRate1' ) IS NOT NULL
    DROP TABLE #CodecBitRate1
SELECT 		[SessionId],
			[TestId],
			MIN([MsgTime]) as SampleStart,
			sum(case 
					when ([CodecRate] in ('12.2', '10.2', '7.95', '7.4', '6.7', '5.9', '5.15', '4.75', '1.8')) then a.[Duration] 
					when ([CodecRate] not in ('12.2', '10.2', '7.95', '7.4', '6.7', '5.9', '5.15', '4.75', '1.8')) then 0 
				end) as "NB_TOTAL_ms",
			sum(case 
					when ([CodecRate] in ('12.2')) then a.[Duration] 
					when ([CodecRate]  not in ('12.2')) then 0 
				end) as "NB_12.2_ms",
			sum(case 
					when ([CodecRate] in ('10.2')) then a.[Duration] 
					when ([CodecRate]  not in ('10.2')) then 0 
				end) as "NB_10.2_ms",
			sum(case 
					when ([CodecRate] in ('7.95')) then a.[Duration] 
					when ([CodecRate]  not in ('7.95')) then 0 
				end) as "NB_7.95_ms",
			sum(case 
					when ([CodecRate] in ('7.4')) then a.[Duration] 
					when ([CodecRate]  not in ('7.4')) then 0 
				end) as "NB_7.4_ms",
			sum(case 
					when ([CodecRate] in ('6.7')) then a.[Duration] 
					when ([CodecRate]  not in ('6.7')) then 0 
				end) as "NB_6.7_ms",
			sum(case 
					when ([CodecRate] in ('5.15')) then a.[Duration] 
					when ([CodecRate]  not in ('5.15')) then 0 
				end) as "NB_5.15_ms",
			sum(case 
					when ([CodecRate] in ('5.9')) then a.[Duration] 
					when ([CodecRate]  not in ('5.9')) then 0 
				end) as "NB_5.9_ms",
			sum(case 
					when ([CodecRate] in ('4.75')) then a.[Duration] 
					when ([CodecRate]  not in ('4.75')) then 0 
				end) as "NB_4.75_ms",
			sum(case 
					when ([CodecRate] in ('1.8')) then a.[Duration] 
					when ([CodecRate]  not in ('1.8')) then 0 
				end) as "NB_1.8_ms",
			sum(case 
					when ([CodecRate] in ('23.85', '23.05', '19.85', '18.25', '15.85', '14.25', '12.65', '8.85', '6.6')) then a.[Duration] 
					when ([CodecRate]  not in ('23.85', '23.05', '19.85', '18.25', '15.85', '14.25', '12.65', '8.85', '6.6')) then 0 
				end) as "WB_TOTAL_ms",
			sum(case 
					when ([CodecRate] in ('23.85')) then a.[Duration] 
					when ([CodecRate]  not in ('23.85')) then 0 
				end) as "WB_23.85_ms",
			sum(case 
					when ([CodecRate] in ('23.05')) then a.[Duration] 
					when ([CodecRate]  not in ('23.05')) then 0 
				end) as "WB_23.05_ms",
			sum(case 
					when ([CodecRate] in ('19.85')) then a.[Duration] 
					when ([CodecRate]  not in ('19.85')) then 0 
				end) as "WB_19.85_ms",
			sum(case 
					when ([CodecRate] in ('18.25')) then a.[Duration] 
					when ([CodecRate]  not in ('18.25')) then 0 
				end) as "WB_18.25_ms",
			sum(case 
					when ([CodecRate] in ('15.85')) then a.[Duration] 
					when ([CodecRate]  not in ('15.85')) then 0 
				end) as "WB_15.85_ms",
			sum(case 
					when ([CodecRate] in ('14.25')) then a.[Duration] 
					when ([CodecRate]  not in ('14.25')) then 0 
				end) as "WB_14.25_ms",
			sum(case 
					when ([CodecRate] in ('12.65')) then a.[Duration] 
					when ([CodecRate]  not in ('12.65')) then 0 
				end) as "WB_12.65_ms",
			sum(case 
					when ([CodecRate] in ('8.85')) then a.[Duration] 
					when ([CodecRate]  not in ('8.85')) then 0 
				end) as "WB_8.85_ms",
			sum(case 
					when ([CodecRate] in ('6.6')) then a.[Duration] 
					when ([CodecRate]  not in ('6.6')) then 0 
				end) as "WB_6.6_ms"
  INTO #CodecBitRate1
  FROM [o2_Voice_2016_Q1].[dbo].[VoiceCodecTest] a
  GROUP BY a.[SessionId],a.[TestId]

-- Extract bitrate relative (%) time duration into Temporary Table
IF OBJECT_ID ('tempdb..#CodecRate1' ) IS NOT NULL
    DROP TABLE #CodecRate1
SELECT		[SessionId],
			[TestId],
			[SampleStart],
			-- Narowband Codecs 
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([NB_TOTAL_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "NB_TOTAL_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([NB_12.2_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as "NB_12.2_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([NB_10.2_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "NB_10.2_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([NB_7.95_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "NB_7.95_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([NB_7.4_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "NB_7.4_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([NB_6.7_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as "NB_6.7_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([NB_5.9_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "NB_5.9_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([NB_5.15_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "NB_5.15_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([NB_4.75_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "NB_4.75_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([NB_1.8_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "NB_1.8_%",
			-- Wideband Codecs 
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([WB_TOTAL_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "WB_TOTAL_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([WB_23.85_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "WB_23.85_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([WB_23.05_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "WB_23.05_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([WB_19.85_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "WB_19.85_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([WB_18.25_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "WB_18.25_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([WB_15.85_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "WB_15.85_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([WB_14.25_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "WB_14.25_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([WB_12.65_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "WB_12.65_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([WB_8.85_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as "WB_8.85_%",
			CASE WHEN [NB_TOTAL_ms] != 0 OR WB_TOTAL_ms != 0
				THEN 100*CAST([WB_6.6_ms] as FLOAT)/([NB_TOTAL_ms] + WB_TOTAL_ms)
				END as  "WB_6.6_%"
  INTO #CodecRate1
  FROM #CodecBitRate1 a

SELECT a.[SessionId]
      ,a.[TestId]
      ,a.[Call_Status]
      ,a.[StartTime]
      ,a.[Direction]
      ,a.[qualityIndication]
      ,a.[LQ]
      ,a.[LQCat]
      ,a.[qualityCode]
      ,a.[SpeedAvg]
      ,a.[Hard_Handover_COUNT]
      ,a.[timeClipping]
      ,a.[Total_Gain]
      ,a.[NoiseRcv]
      ,a.[StaticSNR]
      ,a.[DelaySpread]
      ,a.[DelayDeviation]
      ,a.[ReceiveDelay]
      ,a.[MissedVoice]
      ,a.[Narrow_Band_Bandwith] as Fequency_Range
      ,a.[LowerFilterLimit]
      ,a.[UpperFilterLimit]
	  -- RadioInformation
	  ,(SELECT TOP 1 [Tec] FROM [o2_Voice_2016_Q1].[dbo].[NC_RADIO] where [SessionId] like a.[SessionId] and [MsgTime] > a.[StartTime]) as Technology
	  ,(SELECT TOP 1 [SignalStrength] FROM [o2_Voice_2016_Q1].[dbo].[NC_RADIO] where [SessionId] like a.[SessionId] and [MsgTime] > a.[StartTime]) as SignalStrength
	  ,(SELECT TOP 1 [SignalQuality] FROM [o2_Voice_2016_Q1].[dbo].[NC_RADIO] where [SessionId] like a.[SessionId] and [MsgTime] > a.[StartTime]) as SignalQuality
	  -- Codec Bitrate Info
	  ,b.*
  FROM [o2_Voice_2016_Q1].[dbo].[NC_Speech_Samples] a 
  JOIN #CodecRate1 b
  ON a.[SessionId] = b.[SessionId] and a.[TestId] = b.[TestId]
  WHERE a.[SessionId] in (SELECT [SessionId] FROM [o2_Voice_2016_Q1].[dbo].[NC_Calls] WHERE [Call_Status] like @CallSTAT and [Operator] like @Operator) and  b.[NB_TOTAL_%] is not null
  ORDER BY a.[SessionId],a.[TestId]

-- Release memory by clearing Temporary Tables
IF OBJECT_ID ('tempdb..#CodecBitRate1' ) IS NOT NULL
    DROP TABLE #CodecBitRate1
IF OBJECT_ID ('tempdb..#CodecRate1' ) IS NOT NULL
    DROP TABLE #CodecRate1