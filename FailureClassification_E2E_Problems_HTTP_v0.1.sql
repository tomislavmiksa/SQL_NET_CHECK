-- Extract all tests that failed due Timeout
IF OBJECT_ID ('tempdb..#TimeoutSessions' ) IS NOT NULL
    DROP TABLE #TimeoutSessions
SELECT [TestId]
      ,[SessionID]
	  ,[MODUL]
  INTO #TimeoutSessions
  FROM [o2_Data_2016_Q2_3G].[dbo].[NC_ROUTES]
  WHERE [ServiceResult] like 'Test timeout' and [ServiceType] like 'HTTPBrowser'

-- Extract NETWORK Identity-s
IF OBJECT_ID ('tempdb..#NetworkInformation' ) IS NOT NULL
    DROP TABLE #NetworkInformation
SELECT [NetworkId]
      ,[FileId]
      ,[HomeOperator]
      ,[HOMCC]
      ,[HOMNC]
      ,[Operator]
      ,[MsgTime]
      ,[MCC]
      ,[MNC]
      ,[LAC]
      ,[technology]
      ,[CId] as GSM_CID
	  ,CASE
			WHEN [SC1] is not null and [SC2] is not null and [SC3] is not null THEN CONVERT(varchar(3),[SC1]) + ', ' + CONVERT(varchar(3),[SC2]) + ', ' + CONVERT(varchar(3),[SC3])
			WHEN [SC1] is not null and [SC2] is not null THEN CONVERT(varchar(3),[SC1]) + ', ' + CONVERT(varchar(3),[SC2])
			WHEN [SC1] is not null THEN CONVERT(varchar(3),[SC1])
			END AS UMTS_SC
  INTO #NetworkInformation
  FROM [o2_Data_2016_Q2].[dbo].[NetworkInfo]

-- Extract all HTTP Failure Messages
IF OBJECT_ID ('tempdb..#FailureExtract' ) IS NOT NULL
    DROP TABLE #FailureExtract
SELECT [MsgId]
      ,[SessionId]
      ,[TestId]
      ,[MsgTime]
      ,[PosId]
      ,[NetworkId]
      ,[src]
      ,[dst]
      ,[protocol]
      ,[msg]
  INTO #FailureExtract
  FROM [o2_Data_2016_Q2_3G].[dbo].[MsgEthereal]
  WHERE [TestId] in (SELECT DISTINCT [TestId] FROM #TimeoutSessions) and [protocol] like 'HTTP' and [msg] not in ('Continuation or non-HTTP traffic', 'HTTP/1.1 200 OK', 'HTTP/1.1 302 Found', 'HTTP/1.1 302 Moved Temporarily') and [msg] not like '%GET%'
  ORDER BY [MsgTime]

-- MERGE HTTP ERROR CODES WITH ERROR SESSIONS
  IF OBJECT_ID ('tempdb..#TimestampExtract' ) IS NOT NULL
    DROP TABLE #TimestampExtract
  SELECT [SessionID]
        ,[TestId]
	    ,[MODUL]
		-- 200 Codes Secion
		,(SELECT TOP 1 [MsgTime] FROM #FailureExtract WHERE [msg] like 'HTTP/1.1 204 No Content' and [TestId] = a.[TestId])				as HTTP_204_No_Content
		,(SELECT TOP 1 [MsgTime] FROM #FailureExtract WHERE [msg] like 'HTTP/1.1 206 Partial Content' and [TestId] = a.[TestId])		as HTTP_206_Partial_Content
		-- Redirection Section (actually no Error
		,(SELECT TOP 1 [MsgTime] FROM #FailureExtract WHERE [msg] like 'HTTP/1.1 301 Moved Permanently' and [TestId] = a.[TestId])		as HTTP_301_Moved_Permanently
		,(SELECT TOP 1 [MsgTime] FROM #FailureExtract WHERE [msg] like 'HTTP/1.1 302 Object moved' and [TestId] = a.[TestId])			as HTTP_302_Object_Moved
		,(SELECT TOP 1 [MsgTime] FROM #FailureExtract WHERE [msg] like 'HTTP/1.1 304 Not Modified' and [TestId] = a.[TestId])			as HTTP_304_Not_Modified
		-- 400 Errors Sestion
		,(SELECT TOP 1 [MsgTime] FROM #FailureExtract WHERE [msg] like 'HTTP/1.0 400 Bad request' and [TestId] = a.[TestId])			as HTTP_400_Bad_Request
		,(SELECT TOP 1 [MsgTime] FROM #FailureExtract WHERE [msg] like 'HTTP/1.1 403 Forbidden' and [TestId] = a.[TestId])				as HTTP_403_Forbidden
		,(SELECT TOP 1 [MsgTime] FROM #FailureExtract WHERE [msg] like 'HTTP/1.1 404 Not Found' and [TestId] = a.[TestId])				as HTTP_404_Not_Found
		,(SELECT TOP 1 [MsgTime] FROM #FailureExtract WHERE [msg] like 'HTTP/1.0 408 Request Time-out' and [TestId] = a.[TestId])		as HTTP_408_Request_Timeout
		-- Global Error Section (highest priority)
		,(SELECT TOP 1 [MsgTime] FROM #FailureExtract WHERE [msg] like 'HTTP/1.1 500 Internal Server Error' and [TestId] = a.[TestId])	as HTTP_500_Server_Internal_Error
		,(SELECT TOP 1 [MsgTime] FROM #FailureExtract WHERE [msg] like 'HTTP/1.1 502 Bad Gateway' and [TestId] = a.[TestId])			as HTTP_502_Bad_Gateway
		,(SELECT TOP 1 [MsgTime] FROM #FailureExtract WHERE [msg] like 'HTTP/1.1 503 Service Unavailable' and [TestId] = a.[TestId])	as HTTP_503_Service_Unavailable
		,(SELECT TOP 1 [MsgTime] FROM #FailureExtract WHERE [msg] like 'HTTP/1.1 504 Gateway Time-out' and [TestId] = a.[TestId])		as HTTP_504_Gateway_Timeout
  INTO #TimestampExtract
  FROM #TimeoutSessions a
  ORDER BY [SessionID], [TestId]

  IF OBJECT_ID ('tempdb..#TimestampExtract1' ) IS NOT NULL
    DROP TABLE #TimestampExtract1
  SELECT * 
         ,CASE
			WHEN HTTP_500_Server_Internal_Error is not null THEN HTTP_500_Server_Internal_Error
			WHEN HTTP_502_Bad_Gateway is not null THEN HTTP_502_Bad_Gateway
			WHEN HTTP_503_Service_Unavailable is not null THEN HTTP_503_Service_Unavailable
			WHEN HTTP_504_Gateway_Timeout is not null THEN HTTP_504_Gateway_Timeout
			WHEN HTTP_400_Bad_Request is not null THEN HTTP_400_Bad_Request
			WHEN HTTP_403_Forbidden is not null THEN HTTP_403_Forbidden
			WHEN HTTP_404_Not_Found is not null THEN HTTP_404_Not_Found
			WHEN HTTP_408_Request_Timeout is not null THEN HTTP_408_Request_Timeout
			WHEN HTTP_204_No_Content is not null THEN HTTP_204_No_Content
			WHEN HTTP_206_Partial_Content is not null THEN HTTP_206_Partial_Content
		END AS FailureTime
  INTO #TimestampExtract1
  FROM #TimestampExtract

  SELECT * 
		,CASE
			WHEN FailureTime is null THEN '-'
			WHEN FailureTime is not null
				THEN (SELECT TOP 1 [technology] FROM #NetworkInformation WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC)
			END as "Technology"
		,CASE
			WHEN FailureTime is null THEN '-'
			WHEN FailureTime is not null and (SELECT TOP 1 [technology] FROM #NetworkInformation WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) like '%GSM%'
				THEN cast((SELECT TOP 1 GSM_CID FROM #NetworkInformation WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) as varchar(20))
			WHEN FailureTime is not null and (SELECT TOP 1 [technology] FROM #NetworkInformation WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) like '%UMTS%'
				THEN cast((SELECT TOP 1 UMTS_SC FROM #NetworkInformation WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) as varchar(20))
			WHEN FailureTime is not null and (SELECT TOP 1 [technology] FROM #NetworkInformation WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) like 'LTE%'
				THEN cast((SELECT TOP 1 [PhyCellId] FROM [LTEMeasurementReport] WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) as varchar(20))
			END as "Cell_ID/PSC/PCI"
			,CASE
				WHEN FailureTime is null THEN '-'
				WHEN FailureTime is not null and (SELECT TOP 1 [technology] FROM #NetworkInformation WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) like '%GSM%'
					THEN cast((SELECT TOP 1 [RxLevSub] FROM [GSMMeasReport] WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) as varchar(20))
				WHEN FailureTime is not null and (SELECT TOP 1 [technology] FROM #NetworkInformation WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) like '%UMTS%'
					THEN cast((SELECT TOP 1 AggrRSCP FROM WCDMAActiveSet WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) as varchar(20))
				WHEN FailureTime is not null and (SELECT TOP 1 [technology] FROM #NetworkInformation WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) like 'LTE%'
					THEN cast((SELECT TOP 1 RSRP FROM [LTEMeasurementReport] WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) as varchar(20))
				END as "SignalStrength"
		,CASE
			WHEN FailureTime is null THEN '-'
			WHEN FailureTime is not null and (SELECT TOP 1 [technology] FROM #NetworkInformation WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) like '%GSM%'
				THEN cast((SELECT TOP 1 [RxQualSub] FROM [GSMMeasReport] WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) as varchar(20))
			WHEN FailureTime is not null and (SELECT TOP 1 [technology] FROM #NetworkInformation WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) like '%UMTS%'
				THEN cast((SELECT TOP 1 AggrEcIo FROM WCDMAActiveSet WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) as varchar(20))
			WHEN FailureTime is not null and (SELECT TOP 1 [technology] FROM #NetworkInformation WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) like 'LTE%'
				THEN cast((SELECT TOP 1 RSRQ FROM [LTEMeasurementReport] WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) as varchar(20))
		END as "SignalQuality"
		,CASE
			WHEN FailureTime is null THEN '-'
			WHEN FailureTime is not null and (SELECT TOP 1 [technology] FROM #NetworkInformation WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) like '%UMTS%'
				THEN cast((SELECT TOP 1 TxPwr FROM WCDMAAGC WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) as varchar(20))
			WHEN FailureTime is not null and (SELECT TOP 1 [technology] FROM #NetworkInformation WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) like 'LTE%'
				THEN cast((SELECT TOP 1 PuschTxPower FROM LTEPUSCHStatisticsInfo WHERE tmps.FailureTime > [MsgTime] ORDER BY [MsgTime] DESC) as varchar(20))
		END as "TxPWR"
  FROM #TimestampExtract1 tmps

-- CLEAN ALL JUNK
IF OBJECT_ID ('tempdb..#TimeoutSessions' ) IS NOT NULL
    DROP TABLE #TimeoutSessions
IF OBJECT_ID ('tempdb..#FailureExtract' ) IS NOT NULL
    DROP TABLE #FailureExtract
IF OBJECT_ID ('tempdb..#TimestampExtract' ) IS NOT NULL
    DROP TABLE #TimestampExtract
IF OBJECT_ID ('tempdb..#TimestampExtract1' ) IS NOT NULL
    DROP TABLE #TimestampExtract1