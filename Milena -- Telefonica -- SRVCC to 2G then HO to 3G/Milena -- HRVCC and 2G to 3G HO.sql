-- Temporary Table of sessions where SRVCC occured
IF OBJECT_ID ('tempdb..#SRVCCSessions' ) IS NOT NULL                                                           -- Delete Temp Table if Exists
    DROP TABLE #SRVCCSessions
SELECT [SessionIdA]
  INTO #SRVCCSessions
  FROM [o2_Voice_2016_Q1_VoLTE].[dbo].[AN_Layer3] where [Message] like '%EUTRA%'

-- Temporary Table of sessions where 2G -> 3G HO occured
IF OBJECT_ID ('tempdb..#2G3GSessions' ) IS NOT NULL                                                           -- Delete Temp Table if Exists
    DROP TABLE #2G3GSessions
SELECT [SessionIdA]
  INTO #2G3GSessions
  FROM [o2_Voice_2016_Q1_VoLTE].[dbo].[AN_Layer3] where [Message] like 'Inter%to%UTRA%'

-- List all calls where both criteria above match
SELECT *
  FROM [o2_Voice_2016_Q1_VoLTE].[dbo].[NC_Calls_Distinct] calls
  WHERE [SessionId] in (SELECT * from #SRVCCSessions) and [SessionId] in (SELECT * from #2G3GSessions)