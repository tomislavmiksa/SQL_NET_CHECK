-- REQUIREMENTS
-- Calls need to be imported in DB
DECLARE @Operator					varchar(25)       = 'o2';
DECLARE @Date_Year                  int               = 2016 ;

-- Create Operator Sessions in this measurement
IF OBJECT_ID ('tempdb..#OperatorSessions' ) IS NOT NULL
    DROP TABLE #OperatorSessions
SELECT [SessionId]
      ,[SessionIdB]
  INTO #OperatorSessions
  FROM [o2_BAB_Q2].[dbo].[NC_Calls_Distinct]
  WHERE [Operator] like @Operator

-- Extract only Sessions where CM was Activated
IF OBJECT_ID ('tempdb..#OperatorCMSessions' ) IS NOT NULL
    DROP TABLE #OperatorCMSessions
SELECT [SessionId]
      ,[TestId]
      ,[MsgTime] as CMActivateTime
      ,[EventName]
  INTO #OperatorCMSessions
  FROM [o2_BAB_Q2].[dbo].[ResultsEvents]
  WHERE [EventName] like '%Compre%' and [TestId] not like '0' and ( [SessionId] in (SELECT [SessionId] FROM #OperatorSessions) OR [SessionId] in (SELECT [SessionIdB] FROM #OperatorSessions))

-- Main Extraction
SELECT  *,
		(SELECT TOP 1 [TxPwr] FROM [o2_BAB_Q2].[dbo].[WCDMAAGC] WHERE [TxPwr] is not null and [MsgTime] < DATEADD(second,-2,a.[CMActivateTime]) and [SessionId] like a.[SessionId] ORDER BY [MsgTime] DESC) as Tx_PWR_2sec_Before_CM,
		(SELECT TOP 1 [TxPwr] FROM [o2_BAB_Q2].[dbo].[WCDMAAGC] WHERE [TxPwr] is not null and [MsgTime] < DATEADD(second,-1,a.[CMActivateTime]) and [SessionId] like a.[SessionId] ORDER BY [MsgTime] DESC) as Tx_PWR_1sec_Before_CM,
		(SELECT TOP 1 [TxPwr] FROM [o2_BAB_Q2].[dbo].[WCDMAAGC] WHERE [TxPwr] is not null and [MsgTime] < a.[CMActivateTime] and [SessionId] like a.[SessionId] ORDER BY [MsgTime] DESC) as Tx_PWR_Before_CM,
		(SELECT TOP 1 [TxPwr] FROM [o2_BAB_Q2].[dbo].[WCDMAAGC] WHERE [TxPwr] is not null and [MsgTime] > a.[CMActivateTime] and [SessionId] like a.[SessionId] ORDER BY [MsgTime]) as Tx_PWR_After_CM,
		(SELECT TOP 1 [TxPwr] FROM [o2_BAB_Q2].[dbo].[WCDMAAGC] WHERE [TxPwr] is not null and [MsgTime] > DATEADD(second,1,a.[CMActivateTime]) and [SessionId] like a.[SessionId] ORDER BY [MsgTime]) as Tx_PWR_1sec_After_CM,
		(SELECT TOP 1 [TxPwr] FROM [o2_BAB_Q2].[dbo].[WCDMAAGC] WHERE [TxPwr] is not null and [MsgTime] > DATEADD(second,2,a.[CMActivateTime]) and [SessionId] like a.[SessionId] ORDER BY [MsgTime]) as Tx_PWR_2sec_After_CM
FROM #OperatorCMSessions a

-- DROP Temporary JUNK
DROP TABLE #OperatorSessions
DROP TABLE #OperatorCMSessions
