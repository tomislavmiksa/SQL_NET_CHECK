-----------------
-- MAIN SCRIPT --
-----------------
-- IMSI and variables Definitions!!!
declare		@telefonica_2G_imsi					table (Id varchar(15))
declare		@telefonica_2G3G_imsi				table (Id varchar(15))
declare		@telekom_2G3G_imsi					table (Id varchar(15))
declare		@vodafone_2G3G_imsi					table (Id varchar(15))

INSERT INTO  @telefonica_2G_imsi				values				('262073946090582'), ('262073946090579')
INSERT INTO  @telefonica_2G3G_imsi				values				('262073999241756'), ('262073952891169')
INSERT INTO  @telekom_2G3G_imsi					values				('262019434133489'), ('262011205914188')
INSERT INTO  @vodafone_2G3G_imsi				values				('262021304593088'), ('262021304593086')

IF OBJECT_ID ('tempdb..#MOSetup'  ) IS NOT NULL
    DROP TABLE #MOSetup
SELECT [MsgTime]
      ,[SessionId]
      ,[SessionIdA]
      ,[SessionIdB]
      ,[Side]
      ,[Technology]
      ,[NetworkId]
	  ,[Direction]
      ,[MessageTypeName]
  INTO #MOSetup
  FROM [AN_Layer3]
  WHERE [MessageTypeName] like 'Setup' and [Direction] like 'U'

IF OBJECT_ID ('tempdb..#MTSetup'  ) IS NOT NULL
    DROP TABLE #MTSetup
SELECT [MsgTime]
      ,[SessionId]
      ,[SessionIdA]
      ,[SessionIdB]
      ,[Side]
      ,[Technology]
      ,[NetworkId]
	  ,[Direction]
      ,[MessageTypeName]
  INTO #MTSetup
  FROM [AN_Layer3]
  WHERE [MessageTypeName] like 'Setup' and [Direction] like 'D'

IF OBJECT_ID ('tempdb..#MOConAck'  ) IS NOT NULL
    DROP TABLE #MOConAck
SELECT [MsgTime]
      ,[SessionId]
      ,[SessionIdA]
      ,[SessionIdB]
      ,[Side]
      ,[Technology]
      ,[NetworkId]
	  ,[Direction]
      ,[MessageTypeName]
  INTO #MOConAck
  FROM [AN_Layer3]
  WHERE [MessageTypeName] like 'Connect Ack%' and [Direction] like 'U'

IF OBJECT_ID ('tempdb..#MTConAck'  ) IS NOT NULL
    DROP TABLE #MTConAck
SELECT [MsgTime]
      ,[SessionId]
      ,[SessionIdA]
      ,[SessionIdB]
      ,[Side]
      ,[Technology]
      ,[NetworkId]
	  ,[Direction]
      ,[MessageTypeName]
  INTO #MTConAck
  FROM [AN_Layer3]
  WHERE [MessageTypeName] like 'Connect Ack%' and [Direction] like 'D'

IF OBJECT_ID ('tempdb..#Disconnect'  ) IS NOT NULL
    DROP TABLE #Disconnect
SELECT [MsgTime]
      ,[SessionId]
      ,[SessionIdA]
      ,[SessionIdB]
      ,[Side]
      ,[Technology]
      ,[NetworkId]
	  ,[Direction]
      ,[MessageTypeName]
  INTO #Disconnect
  FROM [AN_Layer3]
  WHERE [MessageTypeName] like 'Disconnect'

IF OBJECT_ID ('tempdb..#Markers1st'  ) IS NOT NULL
    DROP TABLE #Markers1st
SELECT   a.[SessionIdA] as RefSessID
		,a.[SessionId] as MO_SessionId
		,a.[MsgTime] as MO_Setup
		,b.[MsgTime] as MO_Connected
		,c.[MsgTime] as MO_Disconnect
		,CASE a.[SessionId]
			WHEN a.[SessionIdA] then a.[SessionIdB]
			WHEN a.[SessionIdB] then a.[SessionIdA]
			END AS MT_SessionId
INTO #Markers1st
FROM #MOSetup a
LEFT OUTER JOIN #MOConAck b
	ON a.[SessionId] = b.[SessionId] and b.[MsgTime] > a.[MsgTime]
LEFT OUTER JOIN #Disconnect c
	ON a.[SessionId] = c.[SessionId] and c.[MsgTime] > b.[MsgTime]
ORDER BY a.[SessionId]

-- All Markers Set
IF OBJECT_ID ('tempdb..#Markers'  ) IS NOT NULL
    DROP TABLE #Markers
SELECT   a.RefSessID
		,a.MO_SessionId
		,a.MO_Setup
		,a.MO_Connected
		,a.MO_Disconnect
		,a.MT_SessionId
		,b.[MsgTime] as MT_Setup
		,c.[MsgTime] as MT_Connected
		,d.[MsgTime] as MT_Disconnect
INTO #Markers
FROM #Markers1st a
LEFT OUTER JOIN #MTSetup b
	ON a.MT_SessionId = b.[SessionId] and b.[MsgTime] > a.MO_Setup
LEFT OUTER JOIN #MTConAck c
	ON a.MT_SessionId = c.[SessionId] and c.[MsgTime] > b.[MsgTime]
LEFT OUTER JOIN #Disconnect d
	ON a.MT_SessionId = d.[SessionId] and d.[MsgTime] > c.[MsgTime]
ORDER BY a.RefSessID

SELECT   a.RefSessID
		,a.MO_SessionId
		,a.MO_Setup
		,a.MO_Connected
		,a.MO_Disconnect
		,a.MT_SessionId
		,a.MT_Setup
		,a.MT_Connected
		,a.MT_Disconnect
FROM #Markers a
