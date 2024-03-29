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

IF OBJECT_ID ('tempdb..#Temp1'  ) IS NOT NULL
    DROP TABLE #Temp1
SELECT   a.RefSessID
		,b.Call_Status
		,b.IMSI
		,CASE 
			WHEN b.IMSI collate SQL_Latin1_General_CP1_CI_AS in (SELECT * FROM @telefonica_2G_imsi)		THEN 'O2-2G'
			WHEN b.IMSI collate SQL_Latin1_General_CP1_CI_AS in (SELECT * FROM @telefonica_2G3G_imsi)	THEN 'O2-2G3G'
			WHEN b.IMSI collate SQL_Latin1_General_CP1_CI_AS in (SELECT * FROM @telekom_2G3G_imsi)		THEN 'Telekom-2G3G'
			WHEN b.IMSI collate SQL_Latin1_General_CP1_CI_AS in (SELECT * FROM @vodafone_2G3G_imsi)		THEN 'VDF-2G3G'
			ELSE '-'
			END AS Home_Operator
		,a.MO_SessionId
		,a.MO_Setup
		,a.MO_Connected
		,a.MO_Disconnect
		,a.MT_SessionId
		,a.MT_Setup
		,a.MT_Connected
		,a.MT_Disconnect
INTO #Temp1
FROM #Markers a
LEFT OUTER JOIN NC_Calls_Distinct b
	ON  a.RefSessID = b.SessionID
WHERE a.MO_Setup is not null and a.MO_Connected is not null and a.MO_Disconnect is not null and b.Call_Status not like 'Syste%'
ORDER BY a.RefSessID

-- SELECT * FROM #Temp1

-- All Markers Set
IF OBJECT_ID ('tempdb..#ConcernedHO'  ) IS NOT NULL
    DROP TABLE #ConcernedHO
SELECT [MsgId]
      ,[SessionId]
      ,[NetworkId]
      ,[PosId]
      ,case 
				when kpiid = 34050 then '2G-Handover'
				when kpiid = 34060 then '2G-ChannelModify'
				when kpiid = 34070 then '2G-IntraCellHO'
				when kpiid = 35010 then '3G-CompressMode'
				when kpiid = 35020 then '2G->3G-InterSystemHO'
				when kpiid = 35030 then '3G->2G-InterSystemHO'
				when kpiid = 35040 then '3G->2G-InterSystemHO-DuringTransfer'
				when kpiid = 35041 then '3G->2G-InterSystemHO-RAU' 				
				when kpiid = 35060 then '2G->3G-InterSystemHO-IdleReselect'
				when kpiid = 35061 then '2G->3G-InterSystemHOToLAU-IdleReselect'
				when kpiid = 35070 then '3G->2G-InterSystemHO-IdleReselect'
				when kpiid = 35071 then '3G->2G-InterSystemHOToLAU-IdleReselect'
				when kpiid = 35080 then '3G-P-TMSI Reallocation'
				when kpiid = 35100 then '3G-Handover'
				when kpiid = 35101 then '3G-CellUpdate'
				when kpiid = 35106 then '3G-InterFrequencyReselection'				
				when kpiid = 35107 then '3G-InterFrequencyHO'
				when kpiid = 35110 then '3G-HSPA-CellChange'
				when kpiid = 35111 then '3G-HSPA R99-LinkChange' 
				when kpiid = 38020 then '4G->3G-InterSystemHO-IdleReselect'
				when kpiid = 38021 then '4G->3G-RedirectionToUARFCN'
				when kpiid = 38030 then '3G->4G-InterSystemHO-IdleReselect'
				when kpiid = 38040 then '4G->3G-InterSystemHO'
				when kpiid = 38100 then '4G-Handover'
			else null end as KPIId
      ,[KPIStatus]
	  ,[Value4]
	  ,[Value5]
      ,[StartTime]
      ,[EndTime]
      ,[Duration]
  INTO #ConcernedHO
  FROM [vResultsKPI]
  WHERE KPIId in (34050,34060,34070,35010,35020,35030,35040,35041,35060,35061,35070,35071,35080,35100,35101,35106,35107,35110,35111,38020,38021,38030,38040,38100)
  ORDER BY [SessionId]

IF OBJECT_ID ('tempdb..#MTHO'  ) IS NOT NULL
    DROP TABLE #MTHO
SELECT     a.RefSessID
			,a.Call_Status
			,a.IMSI
			,a.Home_Operator
			,a.MT_SessionId
			,a.MT_Setup
			,a.MT_Connected
			,a.MT_Disconnect
			,b.KPIId as HO_Type
			,b.KPIStatus as HO_Result
			,b.[StartTime] as 'HO_Start_Time'
			,b.[EndTime] as 'HO_End_Time'
			,b.[Duration] as 'HO_Duration'
			,case
				WHEN REPLACE(b.Value5,'Added','') != b.Value5 and REPLACE(b.Value5,'Removed','')  = b.Value5 and REPLACE(b.Value5,'/','') = b.Value5 THEN 'Adding in AS'
				WHEN REPLACE(b.Value5,'Added','') = b.Value5 and REPLACE(b.Value5,'Removed','')  != b.Value5 and REPLACE(b.Value5,'/','') = b.Value5 THEN 'Removing from AS'
				WHEN (REPLACE(b.Value5,'Added','') != b.Value5 and REPLACE(b.Value5,'Removed','')  != b.Value5) or REPLACE(b.Value5,'/','') != b.Value5 THEN 'Replacing from AS'
				END AS Detailed_Type
INTO #MTHO
FROM #Temp1 a
LEFT OUTER JOIN #ConcernedHO b
  ON a.MT_SessionId = B.SessionId and a.MT_Connected < b.StartTime and a.MT_Disconnect > b.StartTime
WHERE b.KPIId is not null

SELECT * FROM #MTHO ORDER BY RefSessID

SELECT Home_Operator,HO_Type,HO_Result,Detailed_Type,Count(Home_Operator) as Count_Number 
FROM #MTHO
GROUP BY Home_Operator,HO_Type,HO_Result,Detailed_Type
ORDER BY Home_Operator,HO_Type,HO_Result,Detailed_Type