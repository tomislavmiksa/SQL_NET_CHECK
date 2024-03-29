DECLARE @callDuration			int = 120
DECLARE @maxCallSetupTime		int = 30


-- Extract all important messages to TEMP DB-s
IF OBJECT_ID ('tempdb..#DIALTrigger' ) IS NOT NULL
    DROP TABLE #DIALTrigger
SELECT a.[SessionId]
      ,a.[SessionIdA]
      ,a.[SessionIdB]
      ,a.[Side] as MO_Side
      ,a.[MsgTime]
      ,a.[Message]
  INTO #DIALTrigger
  FROM [AN_Layer3] a
  WHERE [Message] like 'Dial%'
  ORDER BY [SessionId]

IF OBJECT_ID ('tempdb..#SETUPUL' ) IS NOT NULL
    DROP TABLE #SETUPUL
SELECT a.[SessionId]
      ,a.[SessionIdA]
      ,a.[SessionIdB]
      ,a.[Side]
      ,a.[MsgTime]
      ,a.[Message]
  INTO #SETUPUL
  FROM [AN_Layer3] a
  WHERE ([Message] like 'Setup' or [Message] like 'IMS%SIP%INVITE%Request%' )
			and [Direction] like 'U'

IF OBJECT_ID ('tempdb..#ALERTINGDL' ) IS NOT NULL
    DROP TABLE #ALERTINGDL
SELECT a.[SessionId]
      ,a.[SessionIdA]
      ,a.[SessionIdB]
      ,a.[Side]
      ,a.[MsgTime]
      ,a.[Message]
  INTO #ALERTINGDL
  FROM [AN_Layer3] a
  WHERE ([Message] like 'Alerting' or [Message] like 'IMS%SIP%INVITE%Ringing%' )
			and [Direction] like 'D'

IF OBJECT_ID ('tempdb..#ACKUL' ) IS NOT NULL
    DROP TABLE #ACKUL
SELECT a.[SessionId]
      ,a.[SessionIdA]
      ,a.[SessionIdB]
      ,a.[Side]
      ,a.[MsgTime]
      ,a.[Message]
  INTO #ACKUL
  FROM [AN_Layer3] a
  WHERE ([Message] like 'Connect Ack%' or [Message] like 'IMS SIP ACK (Request)' )
			and [Direction] like 'U'

IF OBJECT_ID ('tempdb..#ACKDL' ) IS NOT NULL
    DROP TABLE #ACKDL
SELECT a.[SessionId]
      ,a.[SessionIdA]
      ,a.[SessionIdB]
      ,a.[Side]
      ,a.[MsgTime]
      ,a.[Message]
  INTO #ACKDL
  FROM [AN_Layer3] a
  WHERE ([Message] like 'Connect Ack%' or [Message] like 'IMS SIP ACK (Request)' )
			and [Direction] like 'D'

IF OBJECT_ID ('tempdb..#DisconnectUL' ) IS NOT NULL
    DROP TABLE #DisconnectUL
SELECT a.[SessionId]
      ,a.[SessionIdA]
      ,a.[SessionIdB]
      ,a.[Side]
      ,a.[MsgTime]
      ,a.[Message]
  INTO #DisconnectUL
  FROM [AN_Layer3] a
  WHERE ([Message] like 'Disconnect' or [Message] like 'IMS SIP CANCEL (Request)' or [Message] like 'IMS SIP BYE (Request)' )
			and [Direction] like 'U'

-- Processing data to final timestamps table
IF OBJECT_ID ('tempdb..#Timestamps' ) IS NOT NULL
    DROP TABLE #Timestamps
SELECT a.[MO_Side]
	  ,a.[SessionIdA]
      ,a.[SessionIdB]
      ,a.[MsgTime] as DIAL_TIMESTAMP
	  ,b.[MsgTime] as UL_Setup_TIMESTAMP
	  ,c.[MsgTime] as DL_Alerting_TIMESTAMP
	  ,d.[MsgTime] as UL_ConnectACK_TIMESTAMP
	  ,e.[MsgTime] as DL_ConnectACK_TIMESTAMP
	  ,f.[MsgTime] as UL_Disconnect_TIMESTAMP
  INTO #Timestamps
  FROM #DIALTrigger a
  LEFT OUTER JOIN #SETUPUL b
	ON a.[SessionIdA] = b.[SessionIdA]
  LEFT OUTER JOIN #ALERTINGDL c
	ON a.[SessionIdA] = c.[SessionIdA]
  LEFT OUTER JOIN #ACKUL d
	ON a.[SessionIdA] = d.[SessionIdA]
  LEFT OUTER JOIN #ACKDL e
	ON a.[SessionIdA] = e.[SessionIdA]
  LEFT OUTER JOIN #DisconnectUL f
	ON a.[SessionIdA] = f.[SessionIdA]
  ORDER BY a.[SessionId]

-- PostProcessing
IF OBJECT_ID ('tempdb..#Timestamps1' ) IS NOT NULL
    DROP TABLE #Timestamps1
SELECT  * 
		,CASE
			WHEN DL_ConnectACK_TIMESTAMP is not null then DL_ConnectACK_TIMESTAMP
			WHEN DL_ConnectACK_TIMESTAMP is null THEN UL_Disconnect_TIMESTAMP
			ELSE NULL
			END AS CONNECT_TIME
	INTO #Timestamps1
	FROM #Timestamps

SELECT   a.[MO_Side]	
		,a.[SessionIdA]
		,a.[SessionIdB]	
		,a.[DIAL_TIMESTAMP]	
		,a.[UL_Setup_TIMESTAMP]	
		,a.[DL_Alerting_TIMESTAMP]	
		,a.[UL_ConnectACK_TIMESTAMP]	
		,a.[DL_ConnectACK_TIMESTAMP]	
		,a.[CONNECT_TIME]
		,a.[UL_Disconnect_TIMESTAMP]
		,DATEDIFF(SECOND,[DIAL_TIMESTAMP], [CONNECT_TIME]) as CALL_SETUP_DURATION
		,DATEDIFF(SECOND,[CONNECT_TIME], [UL_Disconnect_TIMESTAMP]) as ACTIVE_CALL_DURATION
		,CASE 
			WHEN DATEDIFF(SECOND, DIAL_TIMESTAMP, CONNECT_TIME) > (@maxCallSetupTime - 1 ) THEN 'CALL_SETUP_WINDOW_EXPIRED'
			WHEN DATEDIFF(SECOND, CONNECT_TIME, UL_Disconnect_TIMESTAMP) < (@callDuration - 1 ) THEN 'POTENTIAL_UE_DROP'
			ELSE '-'
			END AS FLAGS
		,b.[OPERATOR]
        ,b.[CALL_STATUS]
        ,b.[SESSIONID]
        ,b.[FAILURE_PHASE]
        ,b.[FAILURE_SIDE]
        ,b.[TECHNOLOGY]
        ,b.[FAILURE_CLASS]
        ,b.[FAILURE_CATEGORY]
        ,b.[FAILURE_SUBCATEGORY]
        ,b.[COMMENT]
	FROM #Timestamps1 a
	LEFT OUTER JOIN [NC_FailureClassification] b
		on a.[SessionIdA] = b.[SESSIONID]
	WHERE a.[SessionIdA] is not null
	ORDER BY [SessionIdA]
