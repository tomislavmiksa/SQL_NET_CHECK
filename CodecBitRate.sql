IF OBJECT_ID ('tempdb..#TimeStamps' ) IS NOT NULL
    DROP TABLE #CodecRate
SELECT TOP 10		-- Narowband Codecs 
			[SessionId],
			[TestId],
			MIN([MsgTime]) as SampleStart,
			sum(case 
					when ([CodecRate] in ('12.2', '10.2', '7.95', '7.4', '6.7', '5.9', '5.15', '4.75', '1.8')) then a.[Duration] 
					when ([CodecRate]  not in ('12.2', '10.2', '7.95', '7.4', '6.7', '5.9', '5.15', '4.75', '1.8')) then 0 
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
INTO #CodecRate
  FROM [o2_Voice_2016_Q1_VoLTE].[dbo].[VoiceCodecTest] a
  GROUP BY a.[SessionId],a.[TestId]

SELECT TOP 10 * from #CodecRate