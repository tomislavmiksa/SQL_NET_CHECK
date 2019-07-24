DECLARE @Operator varchar(60)
DECLARE @Location varchar(60)
SET @Operator = 'EPlus'
SET @Location = 'BAB'

-----------------------------------------------
--              GSM 900  Section             --
-----------------------------------------------
SELECT  sum(case when (([formatId] like 'DEDICATED' and [RxLevSub] <= -105) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <= -105)) then 1 end) as GSM_900_RxLev_less_105,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >= -105) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >= -105)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <= -100) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <= -100))) then 1 end) as GSM_900_RxLev_105_100,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >= -100) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >= -100)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -95) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -95))) then 1 end) as GSM_900_RxLev_100_95,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -95) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -95)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -90) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -90))) then 1 end) as GSM_900_RxLev_95_90,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -90) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -90)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -85) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -85))) then 1 end) as GSM_900_RxLev_90_85,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -85) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -85)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -80) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -80))) then 1 end) as GSM_900_RxLev_85_80,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -80) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -80)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -75) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -75))) then 1 end) as GSM_900_RxLev_80_75,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -75) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -75)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -70) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -70))) then 1 end) as GSM_900_RxLev_75_70,
		sum(case when (([formatId] like 'DEDICATED' and [RxLevSub] >= -70) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >= -70)) then 1 end) as GSM_900_RxLev_70_plus  
  FROM [o2_Voice_2016_Q1].[dbo].[MsgGSMLayer1]
  WHERE ([BCCH] < 124) or ([BCCH] < 1023 and [BCCH] > 955)
  and ([SessionId] in (
				  SELECT [SessionId]
				  FROM [o2_Voice_2016_Q1].[dbo].[NC_Calls_Distinct]
				  WHERE [Location] like @Location
					and [valid] like '1'
					and [Operator] like @Operator
	)
  or [SessionId] in (
				  SELECT [SessionIdB]
				  FROM [o2_Voice_2016_Q1].[dbo].[NC_Calls_Distinct]
				  WHERE [Location] like @Location
					and [valid] like '1'
					and [Operator] like @Operator
	))

-----------------------------------------------
--              GSM 1800  Section            --
-----------------------------------------------
SELECT  sum(case when (( [formatId] like 'DEDICATED' and [RxLevSub] <= -105) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <= -105)) then 1 end) as GSM_1800_RxLev_less_105,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >= -105) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >= -105)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <= -100) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <= -100))) then 1 end) as GSM_1800_RxLev_105_100,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >= -100) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >= -100)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -95) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -95))) then 1 end) as GSM_1800_RxLev_100_95,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -95) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -95)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -90) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -90))) then 1 end) as GSM_1800_RxLev_95_90,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -90) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -90)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -85) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -85))) then 1 end) as GSM_1800_RxLev_90_85,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -85) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -85)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -80) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -80))) then 1 end) as GSM_1800_RxLev_85_80,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -80) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -80)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -75) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -75))) then 1 end) as GSM_1800_RxLev_80_75,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -75) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -75)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -70) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -70))) then 1 end) as GSM_1800_RxLev_75_70,
		sum(case when (( [formatId] like 'DEDICATED' and [RxLevSub] >= -70) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >= -70)) then 1 end) as GSM_1800_RxLev_70_plus  
  FROM [o2_Voice_2016_Q1].[dbo].[MsgGSMLayer1]
  WHERE ([BCCH] < 885 and [BCCH] > 512)
  and ([SessionId] in (
				  SELECT [SessionId]
				  FROM [o2_Voice_2016_Q1].[dbo].[NC_Calls_Distinct]
				  WHERE [Location] like @Location
					and [valid] like '1'
					and [Operator] like @Operator
	)
  or [SessionId] in (
				  SELECT [SessionIdB]
				  FROM [o2_Voice_2016_Q1].[dbo].[NC_Calls_Distinct]
				  WHERE [Location] like @Location
					and [valid] like '1'
					and [Operator] like @Operator
	))
	
-----------------------------------------------
--              UMTS 900 Section             --
-----------------------------------------------
SELECT  sum(case when ([AggrRSCP] <= -115) then 1 end) as UMTS_900_RSCP_less_115,
		sum(case when ([AggrRSCP] >= -115 AND [AggrRSCP] < -110) then 1 end) as UMTS_900_RSCP_115_110,
		sum(case when ([AggrRSCP] >= -110 AND [AggrRSCP] < -105) then 1 end) as UMTS_900_RSCP_110_105,
		sum(case when ([AggrRSCP] >= -105 AND [AggrRSCP] < -100) then 1 end) as UMTS_900_RSCP_105_100,
		sum(case when ([AggrRSCP] >= -100 AND [AggrRSCP] <  -95) then 1 end) as UMTS_900_RSCP_100_95,
		sum(case when ([AggrRSCP] >=  -95 AND [AggrRSCP] <  -90) then 1 end) as UMTS_900_RSCP_95_90,
		sum(case when ([AggrRSCP] >=  -90 AND [AggrRSCP] <  -85) then 1 end) as UMTS_900_RSCP_90_85,
		sum(case when ([AggrRSCP] >=  -85 AND [AggrRSCP] <  -80) then 1 end) as UMTS_900_RSCP_85_80,
		sum(case when ([AggrRSCP] >=  -80 AND [AggrRSCP] <  -75) then 1 end) as UMTS_900_RSCP_80_75,
		sum(case when ([AggrRSCP] >=  -75 AND [AggrRSCP] <  -70) then 1 end) as UMTS_900_RSCP_75_70,
		sum(case when ([AggrRSCP] >=  -70) then 1 end) as UMTS_900_RSCP_70_plus  
  FROM [o2_Voice_2016_Q1].[dbo].[WCDMAActiveSet]
  WHERE (FreqDL > 2937 and FreqDL < 3088)
  and ([SessionId] in (
				  SELECT [SessionId]
				  FROM [o2_Voice_2016_Q1].[dbo].[NC_Calls_Distinct]
				  WHERE [Location] like @Location
					and [valid] like '1'
					and [Operator] like @Operator
	)
  or [SessionId] in (
				  SELECT [SessionIdB]
				  FROM [o2_Voice_2016_Q1].[dbo].[NC_Calls_Distinct]
				  WHERE [Location] like @Location
					and [valid] like '1'
					and [Operator] like @Operator
	))

-----------------------------------------------
--              UMTS 2100 Section            --
-----------------------------------------------
SELECT  sum(case when ([AggrRSCP] <= -115) then 1 end) as UMTS_2100_RSCP_less_115,
		sum(case when ([AggrRSCP] >= -115 AND [AggrRSCP] < -110) then 1 end) as UMTS_2100_RSCP_115_110,
		sum(case when ([AggrRSCP] >= -110 AND [AggrRSCP] < -105) then 1 end) as UMTS_2100_RSCP_110_105,
		sum(case when ([AggrRSCP] >= -105 AND [AggrRSCP] < -100) then 1 end) as UMTS_2100_RSCP_105_100,
		sum(case when ([AggrRSCP] >= -100 AND [AggrRSCP] <  -95) then 1 end) as UMTS_2100_RSCP_100_95,
		sum(case when ([AggrRSCP] >=  -95 AND [AggrRSCP] <  -90) then 1 end) as UMTS_2100_RSCP_95_90,
		sum(case when ([AggrRSCP] >=  -90 AND [AggrRSCP] <  -85) then 1 end) as UMTS_2100_RSCP_90_85,
		sum(case when ([AggrRSCP] >=  -85 AND [AggrRSCP] <  -80) then 1 end) as UMTS_2100_RSCP_85_80,
		sum(case when ([AggrRSCP] >=  -80 AND [AggrRSCP] <  -75) then 1 end) as UMTS_2100_RSCP_80_75,
		sum(case when ([AggrRSCP] >=  -75 AND [AggrRSCP] <  -70) then 1 end) as UMTS_2100_RSCP_75_70,
		sum(case when ([AggrRSCP] >=  -70) then 1 end) as UMTS_2100_RSCP_70_plus  
  FROM [o2_Voice_2016_Q1].[dbo].[WCDMAActiveSet]
  WHERE (FreqDL > 10562 and FreqDL < 10838)
  and ([SessionId] in (
				  SELECT [SessionId]
				  FROM [o2_Voice_2016_Q1].[dbo].[NC_Calls_Distinct]
				  WHERE [Location] like @Location
					and [valid] like '1'
					and [Operator] like @Operator
	)
  or [SessionId] in (
				  SELECT [SessionIdB]
				  FROM [o2_Voice_2016_Q1].[dbo].[NC_Calls_Distinct]
				  WHERE [Location] like @Location
					and [valid] like '1'
					and [Operator] like @Operator
	))
	
-----------------------------------------------
--              LTE 800 Section              --
-----------------------------------------------
SELECT  sum(case when ([RSRP] <= -130) then 1 end) as LTE_800_RSRP_less_130,
		sum(case when ([RSRP] >= -130 AND [RSRP] < -125) then 1 end) as LTE_800_RSRP_120_115,
		sum(case when ([RSRP] >= -125 AND [RSRP] < -120) then 1 end) as LTE_800_RSRP_120_115,
		sum(case when ([RSRP] >= -120 AND [RSRP] < -115) then 1 end) as LTE_800_RSRP_120_115,
		sum(case when ([RSRP] >= -115 AND [RSRP] < -110) then 1 end) as LTE_800_RSRP_115_110,
		sum(case when ([RSRP] >= -110 AND [RSRP] < -105) then 1 end) as LTE_800_RSRP_110_105,
		sum(case when ([RSRP] >= -105 AND [RSRP] < -100) then 1 end) as LTE_800_RSRP_105_100,
		sum(case when ([RSRP] >= -100 AND [RSRP] <  -95) then 1 end) as LTE_800_RSRP_100_95,
		sum(case when ([RSRP] >=  -95 AND [RSRP] <  -90) then 1 end) as LTE_800_RSRP_95_90,
		sum(case when ([RSRP] >=  -90 AND [RSRP] <  -85) then 1 end) as LTE_800_RSRP_90_85,
		sum(case when ([RSRP] >=  -85 AND [RSRP] <  -80) then 1 end) as LTE_800_RSRP_85_80,
		sum(case when ([RSRP] >=  -80 AND [RSRP] <  -75) then 1 end) as LTE_800_RSRP_80_75,
		sum(case when ([RSRP] >=  -75 AND [RSRP] <  -70) then 1 end) as LTE_800_RSRP_75_70,
		sum(case when ([RSRP] >=  -70) then 1 end) as LTE_800_RSRP_70_plus  
  FROM [o2_Voice_2016_Q1].[dbo].[LTEMeasurementReport]
  WHERE ([EARFCN] like '6200' or [EARFCN] like '6300' or [EARFCN] like '6400')
  and ([SessionId] in (
				  SELECT [SessionId]
				  FROM [o2_Voice_2016_Q1].[dbo].[NC_Calls_Distinct]
				  WHERE [Location] like 'BAB'
					and [valid] like '1'
					and [Operator] like @Operator
	)
  or [SessionId] in (
				  SELECT [SessionIdB]
				  FROM [o2_Voice_2016_Q1].[dbo].[NC_Calls_Distinct]
				  WHERE [Location] like 'BAB'
					and [valid] like '1'
					and [Operator] like @Operator
	))
	
-----------------------------------------------
--              LTE 1800 Section             --
-----------------------------------------------
SELECT  sum(case when ([RSRP] <= -130) then 1 end) as LTE_1800_RSRP_less_130,
		sum(case when ([RSRP] >= -130 AND [RSRP] < -125) then 1 end) as LTE_1800_RSRP_120_115,
		sum(case when ([RSRP] >= -125 AND [RSRP] < -120) then 1 end) as LTE_1800_RSRP_120_115,
		sum(case when ([RSRP] >= -120 AND [RSRP] < -115) then 1 end) as LTE_1800_RSRP_120_115,
		sum(case when ([RSRP] >= -115 AND [RSRP] < -110) then 1 end) as LTE_1800_RSRP_115_110,
		sum(case when ([RSRP] >= -110 AND [RSRP] < -105) then 1 end) as LTE_1800_RSRP_110_105,
		sum(case when ([RSRP] >= -105 AND [RSRP] < -100) then 1 end) as LTE_1800_RSRP_105_100,
		sum(case when ([RSRP] >= -100 AND [RSRP] <  -95) then 1 end) as LTE_1800_RSRP_100_95,
		sum(case when ([RSRP] >=  -95 AND [RSRP] <  -90) then 1 end) as LTE_1800_RSRP_95_90,
		sum(case when ([RSRP] >=  -90 AND [RSRP] <  -85) then 1 end) as LTE_1800_RSRP_90_85,
		sum(case when ([RSRP] >=  -85 AND [RSRP] <  -80) then 1 end) as LTE_1800_RSRP_85_80,
		sum(case when ([RSRP] >=  -80 AND [RSRP] <  -75) then 1 end) as LTE_1800_RSRP_80_75,
		sum(case when ([RSRP] >=  -75 AND [RSRP] <  -70) then 1 end) as LTE_1800_RSRP_75_70,
		sum(case when ([RSRP] >=  -70) then 1 end) as LTE_1800_RSRP_70_plus  
  FROM [o2_Voice_2016_Q1].[dbo].[LTEMeasurementReport]
  WHERE ([EARFCN] like '1275' or [EARFCN] like '1300' or [EARFCN] like '1426'  or [EARFCN] like '1830' or [EARFCN] like '1805' or [EARFCN] like '1855')
  and ([SessionId] in (
				  SELECT [SessionId]
				  FROM [o2_Voice_2016_Q1].[dbo].[NC_Calls_Distinct]
				  WHERE [Location] like 'BAB'
					and [valid] like '1'
					and [Operator] like @Operator
	)
  or [SessionId] in (
				  SELECT [SessionIdB]
				  FROM [o2_Voice_2016_Q1].[dbo].[NC_Calls_Distinct]
				  WHERE [Location] like 'BAB'
					and [valid] like '1'
					and [Operator] like @Operator
	))
	
-----------------------------------------------
--              LTE 2600 Section             --
-----------------------------------------------
SELECT  sum(case when ([RSRP] <= -130) then 1 end) as LTE_2600_RSRP_less_130,
		sum(case when ([RSRP] >= -130 AND [RSRP] < -125) then 1 end) as LTE_2600_RSRP_120_115,
		sum(case when ([RSRP] >= -125 AND [RSRP] < -120) then 1 end) as LTE_2600_RSRP_120_115,
		sum(case when ([RSRP] >= -120 AND [RSRP] < -115) then 1 end) as LTE_2600_RSRP_120_115,
		sum(case when ([RSRP] >= -115 AND [RSRP] < -110) then 1 end) as LTE_2600_RSRP_115_110,
		sum(case when ([RSRP] >= -110 AND [RSRP] < -105) then 1 end) as LTE_2600_RSRP_110_105,
		sum(case when ([RSRP] >= -105 AND [RSRP] < -100) then 1 end) as LTE_2600_RSRP_105_100,
		sum(case when ([RSRP] >= -100 AND [RSRP] <  -95) then 1 end) as LTE_2600_RSRP_100_95,
		sum(case when ([RSRP] >=  -95 AND [RSRP] <  -90) then 1 end) as LTE_2600_RSRP_95_90,
		sum(case when ([RSRP] >=  -90 AND [RSRP] <  -85) then 1 end) as LTE_2600_RSRP_90_85,
		sum(case when ([RSRP] >=  -85 AND [RSRP] <  -80) then 1 end) as LTE_2600_RSRP_85_80,
		sum(case when ([RSRP] >=  -80 AND [RSRP] <  -75) then 1 end) as LTE_2600_RSRP_80_75,
		sum(case when ([RSRP] >=  -75 AND [RSRP] <  -70) then 1 end) as LTE_2600_RSRP_75_70,
		sum(case when ([RSRP] >=  -70) then 1 end) as LTE_2600_RSRP_70_plus  
  FROM [o2_Voice_2016_Q1].[dbo].[LTEMeasurementReport]
  WHERE ([EARFCN] like '2850' or [EARFCN] like '3050' or [EARFCN] like '3350')
  and ([SessionId] in (
				  SELECT [SessionId]
				  FROM [o2_Voice_2016_Q1].[dbo].[NC_Calls_Distinct]
				  WHERE [Location] like 'BAB'
					and [valid] like '1'
					and [Operator] like @Operator
	)
  or [SessionId] in (
				  SELECT [SessionIdB]
				  FROM [o2_Voice_2016_Q1].[dbo].[NC_Calls_Distinct]
				  WHERE [Location] like 'BAB'
					and [valid] like '1'
					and [Operator] like @Operator
	))
	