IF OBJECT_ID ('tempdb..#SRVCCTrigger' ) IS NOT NULL
              DROP TABLE #SRVCCTrigger
SELECT [MsgTime],[SessionIdA],[Message],[SessionId]
INTO #SRVCCTrigger
FROM [o2_Voice_2016_Q3_VoLTE].[dbo].[AN_Layer3] 
WHERE [Message] in ('MobilityFromEUTRACommand')

IF OBJECT_ID ('tempdb..#SIPINVITEMAX' ) IS NOT NULL
              DROP TABLE #SIPINVITEMAX
SELECT [MsgTime],[SessionId],[SessionIdA],[Message] 
INTO #SIPINVITEMAX
	FROM (SELECT row_number() over (partition by [Message]
										order by [MsgTime] desc) as rn
				 ,*
				from [o2_Voice_2016_Q3_VoLTE].[dbo].[AN_Layer3] 
					WHERE [Message] in ('IMS SIP INVITE (Request)')
		 ) as SubQueryAlias

SELECT 
	a.*,
	b.*
	FROM #SRVCCTrigger a
	LEFT OUTER JOIN #SIPINVITEMAX b
		ON a.[SessionId] = b.[SessionId] and a.MsgTime < b.MsgTime
	WHERE a.SessionIdA in (SELECT [SessionID_A] FROM [o2_Voice_2016_Q3_VoLTE].[dbo].[NEW_CDR] WHERE SQ_Call_Status like 'Completed') and b.MsgTime is not null