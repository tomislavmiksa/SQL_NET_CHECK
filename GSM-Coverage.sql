DECLARE @Operator varchar(60)
DECLARE @Location varchar(60)
SET @Operator = 'EPlus'
SET @Location = 'BAB'

-- GSM 900
SELECT  sum(case when (([formatId] like 'DEDICATED' and [RxLevSub] <= -105) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <= -105)) then 1 end) as RxLev_less_105,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >= -105) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >= -105)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <= -100) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <= -100))) then 1 end) as GSM_900_RxLev_105_100,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >= -100) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >= -100)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -95) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -95))) then 1 end) as GSM_900_RxLev_100_95,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -95) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -95)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -90) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -90))) then 1 end) as GSM_900_RxLev_95_90,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -90) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -90)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -85) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -85))) then 1 end) as GSM_900_RxLev_90_85,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -85) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -85)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -80) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -80))) then 1 end) as GSM_900_RxLev_85_80,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -80) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -80)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -75) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -75))) then 1 end) as GSM_900_RxLev_80_75,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -75) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -75)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -70) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -70))) then 1 end) as GSM_900_RxLev_75_70,
		sum(case when (([formatId] like 'DEDICATED' and [RxLevSub] >= -70) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >= -70)) then 1 end) as RxLev_70_plus  
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

	-- GSM 1800
SELECT  sum(case when (([formatId] like 'DEDICATED' and [RxLevSub] <= -105) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <= -105)) then 1 end) as RxLev_less_105,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >= -105) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >= -105)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <= -100) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <= -100))) then 1 end) as GSM_1800_RxLev_105_100,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >= -100) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >= -100)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -95) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -95))) then 1 end) as GSM_1800_RxLev_100_95,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -95) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -95)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -90) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -90))) then 1 end) as GSM_1800_RxLev_95_90,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -90) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -90)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -85) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -85))) then 1 end) as GSM_1800_RxLev_90_85,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -85) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -85)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -80) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -80))) then 1 end) as GSM_1800_RxLev_85_80,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -80) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -80)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -75) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -75))) then 1 end) as GSM_1800_RxLev_80_75,
		sum(case when ((([formatId] like 'DEDICATED' and [RxLevSub] >=  -75) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >=  -75)) AND (([formatId] like 'DEDICATED' and [RxLevSub] <=  -70) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev <=  -70))) then 1 end) as GSM_1800_RxLev_75_70,
		sum(case when (([formatId] like 'DEDICATED' and [RxLevSub] >= -70) OR ([formatId] not like 'DEDICATED' and BCCH_RxLev >= -70)) then 1 end) as RxLev_70_plus  
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