-- REQUIREMENTS
-- Calls need to be imported in DB
-- AN3 Table must Exist
-- NC_Calls Table must exist

-- Declaration of Variables that will be used later for filtering and similar
declare @myYear						table (Id int)
declare @myMonth					table (Id int)
declare @myDays						table (Id int)
declare @myFILES					table (Id varchar(100))
declare @myDIAL						table (Id varchar(100))

--------------------------------------------------------------------------
--                            FILTERS INPUTS                            --
--------------------------------------------------------------------------
-- FILTER DATES
insert into @myYear					values (2016)							-- Year 2016
insert into @myMonth				values (6)								-- Month 6
insert into @myDays					values (15), (16)						-- Day  15, multiple values would be "insert into @myList values (1), (2), (5), (7), (10)"

-- FILTER FILES
DECLARE @FILTER_FILES				varchar(1)			= 'Y' ;				-- enables filtering by Specific File or list of files (Y/N) , UNLIMITED but requires whole file name
INSERT INTO  @myFILES				values				('2016-06-15-15-39-47-0000-6317-5801-0004-A.mf'), ('2016-06-15-15-43-26-0000-6317-4416-0004-A.mf')

-- DIAL NUMBER FILTER
-- Imports for filtering (USER INPUT)
DECLARE @DIAL_NUM_FILTER_ENABLE		varchar(1)		  = 'Y' ;				-- enables filtering by Dial Number (Y/N)
DECLARE @DIAL_NUM_FILTER_WILDCARD	varchar(1)		  = 'Y' ;				-- enables filtering by Dial Number by two wildcard entries (Y/N)
DECLARE @Dial_Wildcard_1			varchar(50)       = '0162%' ;
DECLARE @Dial_Wildcard_2			varchar(50)       = 'none' ;
DECLARE @DIAL_NUM_FILTER_LIST		varchar(1)		  = 'N' ;				-- enables filtering by Dial Number list (Y/N), UNLIMITED but requires whole number dialed
INSERT INTO  @myDIAL				values			  ('01731373322'), ('01731042072')	

--------------------------------------------------------------------------
--                           SCRIPT EXECUTION                           --
--------------------------------------------------------------------------

-- Get list of Concerned Sessions
-- HERE WE DOO ALL FILTERING!!!
	IF OBJECT_ID ('tempdb..#ConcernedSessions' ) IS NOT NULL
		DROP TABLE #ConcernedSessions
	SELECT  [SessionId],
			[SessionIdB]
	  INTO #ConcernedSessions
	  FROM [NC_Calls] a
	  WHERE [valid] like '1' and [Call_Status] like 'Completed'
			and [Year] in (SELECT * FROM @myYear) and [Month] in (SELECT * FROM @myMonth) and [Day] in (SELECT * FROM @myDays)
			-- DIAL NUMBER FILTERS PART
			AND (
					(@DIAL_NUM_FILTER_ENABLE like 'Y' AND @DIAL_NUM_FILTER_WILDCARD like 'Y' and ([Dialnumber] like @Dial_Wildcard_1 or [Dialnumber] like @Dial_Wildcard_2) ) OR 
					(@DIAL_NUM_FILTER_ENABLE like 'Y' AND @DIAL_NUM_FILTER_LIST like 'Y' and [Dialnumber] collate SQL_Latin1_General_CP1_CI_AS in (SELECT Id FROM @myDIAL)) OR 
					(@DIAL_NUM_FILTER_ENABLE like 'N')
				)
			-- FILE FILTERS PART
			AND (
					(@FILTER_FILES like 'Y' AND [ASideFileName] collate SQL_Latin1_General_CP1_CI_AS in (SELECT Id FROM @myFILES)) OR 
					(@FILTER_FILES like 'N')
				)

--------------------------------------------------
-- PRINT CALL SESSION TABLE IN STANDARD FORMAT  --
--------------------------------------------------
SELECT [valid]
      ,[InvalidReason]
      ,[Channel]
      ,[Operator]
      ,[SessionId]
      ,[SessionIdB]
      ,[Call_Status]
      ,[FileId]
      ,[Sequenz_ID_per_File]
      ,[ASideFileName]
      ,[BSideFileName]
      ,[UE]
      ,[IMEI]
      ,[IMSI]
      ,[Dialnumber]
      ,[City/None_City]
      ,[Modul]
      ,[Location]
      ,[Drive/Walk]
      ,[Latitude]
      ,[Longitude]
      ,[SpeedAvg]
      ,[SpeedCategory]
      ,[Session_Type]
      ,[Call_Type]
      ,[Call_Mode_A_Side]
      ,[First_CS_TEC_A]
      ,[Call_Mode_B_Side]
      ,[First_CS_TEC_B]
      ,[Call_Status_Extend]
      ,[callmode]
      ,[No_Service]
      ,[Silence_Call]
      ,[Bad_Speech_Call]
      ,[Error_Cause]
      ,[Error_Description]
      ,[Personal_Analysis_Cause]
      ,[Personal_Analysis_Description]
      ,[Disconnect_Direction_A]
      ,[Disconnect_Class]
      ,[Disconnect_Cause]
      ,[Disconnect_Location]
      ,[code]
      ,[Disconnect_Direction_B]
      ,[Disconnect_LAC,CId,BCCH_A]
      ,[Disconnect_LAC,CId,BCCH_B]
      ,[MCC_A]
      ,[MNC_A]
      ,[LAC,CId,BCCH_A]
      ,[SC1_A]
      ,[SC2_A]
      ,[SC3_A]
      ,[BSIC_A]
      ,[TEC_A]
      ,[TEC_Detail_A]
      ,[TIME_GSM_900_A]
      ,[TIME_GSM_1800_A]
      ,[TIME_UMTS_900_A]
      ,[TIME_UMTS_2100_A]
      ,[TIME_LTE_E_UTRA_3_A]
      ,[TIME_LTE_E_UTRA_7_A]
      ,[TIME_LTE_E_UTRA_20_A]
      ,[TIME_No_Service_A]
      ,[Technology_Duration_A]
      ,[MCC_B]
      ,[MNC_B]
      ,[LAC,CId,BCCH_B]
      ,[SC1_B]
      ,[SC2_B]
      ,[SC3_B]
      ,[BSIC_B]
      ,[TEC_B]
      ,[TEC_Detail_B]
      ,[TIME_GSM_900_B]
      ,[TIME_GSM_1800_B]
      ,[TIME_UMTS_900_B]
      ,[TIME_UMTS_2100_B]
      ,[TIME_LTE_E_UTRA_3_B]
      ,[TIME_LTE_E_UTRA_7_B]
      ,[TIME_LTE_E_UTRA_20_B]
      ,[TIME_No_Service_B]
      ,[Technology_Duration_B]
      ,[Year]
      ,[Week]
      ,[Month]
      ,[Day]
      ,[Hour]
      ,[Call_Start_Time_Stamp]
      ,[Call_End_Time_Stamp]
      ,[ChannelRequest_RRCConncetionRequest_TimeStamp]
      ,[CMServiceRequest_MOC_TimeStamp]
      ,[Alerting_MOC_TimeStamp]
      ,[Paging_MTC_TimeStamp]
      ,[ConnectAcknowledge_TimeStamp]
      ,[CC_Disconnect_TimeStamp]
      ,[callDisconnectTimeStamp]
      ,[SQ_Post_Dial_Delay]
      ,[SQ_Setup_Time_Dial_Connect]
      ,[Setup_Time_NC_con_ack]
      ,[Setup_Time_NC_Alerting]
      ,[Setup_Time_Alert_10100]
      ,[Setup_Time_Connect_10101]
      ,[VoLTE_Post_Dial_Delay_11000]
      ,[VoLTE_Call_Access_11010]
      ,[VoLTE_Call_Establishment_11100]
      ,[Time_MOC_Dail_CMServiceREquest]
      ,[Time_MOC_CMServiceREquest_Alerting]
      ,[Time_MOC_Alerting_Connect]
      ,[Time_MTC_Dail_Paging]
      ,[SQ_Call_Duration]
      ,[Call_Duration_20101]
      ,[VoLTE_Call_Completion_Time_21010]
      ,[TP_Dail_Time]
      ,[TP_Setup_Time]
      ,[TP_Call_Duration]
      ,[TP_Release_Time]
      ,[TP_Release_End_Time]
      ,[Samples]
      ,[Samples_DL]
      ,[Samples_UL]
      ,[SUMME_POLQA]
      ,[SUMME_POLQA_DL]
      ,[SUMME_POLQA_UL]
      ,[POLQA]
      ,[POLQA_DL]
      ,[POLQA_UL]
      ,[MIN_POLQA]
      ,[MIN_POLQA_DL]
      ,[MIN_POLQA_UL]
      ,[MAX_POLQA]
      ,[MAX_POLQA_DL]
      ,[MAX_POLQA_UL]
      ,[Anzahl_Samples<1.8]
      ,[Time_Clipping]
      ,[Total_Gain]
      ,[Noise_Level]
      ,[Static_SNR]
      ,[Delay_Spread]
      ,[Delay_Deviation]
      ,[Receive_Delay]
      ,[Missed_Voice]
      ,[Narrow_Band_Bandwith]
      ,[KPIId_10100_Time_RRCConnectionRequest/ChannelRequest_Alerting]
      ,[KPIId_10110_Time_RRCConnectionRequest/ChannelRequest_Disconnect]
      ,[KPIId_10102_Time_MOC_CMServiceRequest_Alerting]
      ,[KPIId_10153_Time_MOC_Dial_RRCConnectionRequest/ChannelRequest]
      ,[KPIId_10141_Time_MTC_Dial_Paging]
      ,[KPIId_10150_Time_MTC_Paging_Alerting]
      ,[KPIId_10152_Time_MTC_Paging_RRCConnectionRequest/ChannelRequest]
      ,[KPIId_10151_Time_MTC_RRCConnectionRequest/ChannelRequest_Alerting]
      ,[KPIId_10160_Time_MTC_Dial_RRCConnectionRelease/ChannelRelease]
      ,[KPIId_10165_Time_MTC_Paging_RRCConnectionRelease/ChannelRelease]
      ,[KPIId_10170_Time_LTE_CSFB_RRCConnectionRequest_mo_Data_Alerting]
      ,[KPIId_10175_Time_LTE_CSFB_EMM_ExtendedServiceRequest_RRCConnectionRequest]
      ,[KPIId_10178_Time_LTE_CSFB_EMM_ExtendedServiceRequest_Alerting]
      ,[KPIId_10180_Time_LTE_CSFB_RRCConnectionReleaseWithRedirectedCarrierInfo_SystemInformationBCH]
      ,[avgRxQual]
      ,[avgRxLev]
      ,[avgTA]
      ,[avgMsTxPwr]
      ,[avgUERxPwr]
      ,[avgTotEcIo]
      ,[avgBLER]
      ,[avgUETxPwr]
  FROM [NC_Calls]
  WHERE  [SessionId] in (SELECT [SessionId] FROM #ConcernedSessions)

-----------------------------
-- PRINT POLQA STATISTICS  --
-----------------------------
SELECT    ROUND ( AVG( [LQ] ), 2 ) as POLQA_Average ,
          -- Calculating MEDIAN VALUE from POLQA Samples
          (SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [LQ]) OVER () AS Median
                      FROM [NC_Speech_Samples]
                      WHERE [SessionId] in (SELECT [SessionId] FROM #ConcernedSessions) ) as POLQA_Median ,
          MIN([LQ] ) as POLQA_Minimum,
          MAX([LQ] ) as POLQA_Maximum,
          ROUND ( STDEV( [LQ]), 2 ) as POLQA_StandardDeviation
  FROM [NC_Speech_Samples] POLQA_Samples
  WHERE [SessionId] in (SELECT [SessionId] FROM #ConcernedSessions)

--------------------------------------------
-- CALL SETUP TIME (CST) EXTRACTION PART  --
--------------------------------------------
-- Create Temporary Tables with all relevant Messages
	-- ALL INITIAL INVITE OR SETUP TIMESTAMPS
	IF OBJECT_ID ('tempdb..#TempMessagesInviteUL' ) IS NOT NULL
		DROP TABLE #TempMessagesInviteUL
	SELECT [MsgTime]
		   ,[SessionId]
		   ,[SessionIdA]
		   ,[SessionIdB]
	 INTO #TempMessagesInviteUL
	 FROM [AN_Layer3] 
	 WHERE  ([MessageTypeName] like '%IMS%INVITE%(Request)%') 
			and [Direction] like 'U' 
			and ([SessionId] in (SELECT [SessionId] FROM #ConcernedSessions) OR [SessionId] in (SELECT [SessionIdB] FROM #ConcernedSessions))

	-- ALL Trying OR Call Proceeding TIMESTAMPS
	IF OBJECT_ID ('tempdb..#TempMessagesTryingDL' ) IS NOT NULL
		DROP TABLE #TempMessagesTryingDL
	SELECT [MsgTime]
		   ,[SessionId]
		   ,[SessionIdA]
		   ,[SessionIdB]
	 INTO #TempMessagesTryingDL
	 FROM [AN_Layer3] 
	 WHERE  ([MessageTypeName] like '%IMS%Trying%') 
			and [Direction] like 'D' 
			and ([SessionId] in (SELECT [SessionId] FROM #ConcernedSessions) OR [SessionId] in (SELECT [SessionIdB] FROM #ConcernedSessions))

	-- ALL SessionProgress OR Facility TIMESTAMPS
	IF OBJECT_ID ('tempdb..#TempMessagessessProgDL' ) IS NOT NULL
		DROP TABLE #TempMessagessessProgDL
	SELECT [MsgTime]
		   ,[SessionId]
		   ,[SessionIdA]
		   ,[SessionIdB]
	 INTO #TempMessagessessProgDL
	 FROM [AN_Layer3] 
	 WHERE  ([MessageTypeName] like '%Session%Progress%') 
			and [Direction] like 'D' 
			and ([SessionId] in (SELECT [SessionId] FROM #ConcernedSessions) OR [SessionId] in (SELECT [SessionIdB] FROM #ConcernedSessions))

	-- ALL MO ALERTING
	IF OBJECT_ID ('tempdb..#TempMOAlerting' ) IS NOT NULL
		DROP TABLE #TempMOAlerting
	SELECT [MsgTime]
		   ,[SessionId]
		   ,[SessionIdA]
		   ,[SessionIdB]
	 INTO #TempMOAlerting
	 FROM [AN_Layer3] 
	 WHERE  ([MessageTypeName] like '%IMS%INVITE%Ringing)%') 
			and [Direction] like 'D' 
			and ([SessionId] in (SELECT [SessionId] FROM #ConcernedSessions) OR [SessionId] in (SELECT [SessionIdB] FROM #ConcernedSessions))

	-- ALL MT ALERTING
	IF OBJECT_ID ('tempdb..#TempMTAlerting' ) IS NOT NULL
		DROP TABLE #TempMTAlerting
	SELECT [MsgTime]
		   ,[SessionId]
		   ,[SessionIdA]
		   ,[SessionIdB]
	 INTO #TempMTAlerting
	 FROM [AN_Layer3] 
	 WHERE  ([MessageTypeName] like '%IMS%INVITE%Ringing)%') 
			and [Direction] like 'U' 
			and ([SessionId] in (SELECT [SessionId] FROM #ConcernedSessions) OR [SessionId] in (SELECT [SessionIdB] FROM #ConcernedSessions))

	-- ALL MO 200_OK
	IF OBJECT_ID ('tempdb..#TempMO200OK' ) IS NOT NULL
		DROP TABLE #TempMO200OK
	SELECT [MsgTime]
		   ,[SessionId]
		   ,[SessionIdA]
		   ,[SessionIdB]
	 INTO #TempMO200OK
	 FROM [AN_Layer3] 
	 WHERE  ([MessageTypeName] like '%IMS%INVITE%OK%') 
			and [Direction] like 'D' 
			and ([SessionId] in (SELECT [SessionId] FROM #ConcernedSessions) OR [SessionId] in (SELECT [SessionIdB] FROM #ConcernedSessions))

	-- ALL MT 200_OK
	IF OBJECT_ID ('tempdb..#TempMT200OK' ) IS NOT NULL
		DROP TABLE #TempMT200OK
	SELECT [MsgTime]
		   ,[SessionId]
		   ,[SessionIdA]
		   ,[SessionIdB]
	 INTO #TempMT200OK
	 FROM [AN_Layer3] 
	 WHERE  ([MessageTypeName] like '%IMS%INVITE%OK%') 
			and [Direction] like 'U' 
			and ([SessionId] in (SELECT [SessionId] FROM #ConcernedSessions) OR [SessionId] in (SELECT [SessionIdB] FROM #ConcernedSessions))

	-- JOIN ALL CONERNED MESSAGES
	IF OBJECT_ID ('tempdb..#Timestamps' ) IS NOT NULL
		DROP TABLE #Timestamps
	SELECT  a.[SessionIdA]	as SessionID
		   ,a.[MsgTime]		as MO_INVITE
		   ,b.[MsgTime]		as MO_Trying
		   ,c.[MsgTime]		as MO_SessionProgress
		   ,d.[MsgTime]		as MO_Alerting
		   ,e.[MsgTime]		as MT_Alerting
		   ,f.[MsgTime]		as MO_200_OK
		   ,g.[MsgTime]		as MT_200_OK
	 INTO #Timestamps
	 FROM #TempMessagesInviteUL					a
	 LEFT OUTER JOIN #TempMessagesTryingDL		b	ON a.[SessionIdA] = b.[SessionIdA]
	 LEFT OUTER JOIN #TempMessagessessProgDL	c	ON a.[SessionIdA] = c.[SessionIdA]
	 LEFT OUTER JOIN #TempMOAlerting			d	ON a.[SessionIdA] = d.[SessionIdA]
	 LEFT OUTER JOIN #TempMTAlerting			e	ON a.[SessionIdA] = e.[SessionIdA]
	 LEFT OUTER JOIN #TempMO200OK				f	ON a.[SessionIdA] = f.[SessionIdA]
	 LEFT OUTER JOIN #TempMT200OK				g	ON a.[SessionIdA] = g.[SessionIdA]

	 -- CST Table
	 IF OBJECT_ID ('tempdb..#TimestampsFINAL' ) IS NOT NULL
		DROP TABLE #TimestampsFINAL
	 SELECT SessionID																							AS "Session ID"
			,dbo.DelphiDateTime(MO_INVITE)																		AS "MO INVITE"
			,dbo.DelphiDateTime(MO_Trying)																		AS "MO Trying"
			,dbo.DelphiDateTime(MO_SessionProgress)																AS "MO SessionProgress"
			,dbo.DelphiDateTime(MO_Alerting)																	AS "MO Ringing"
			,dbo.DelphiDateTime(MT_Alerting)																	AS "MT Ringing"
			,dbo.DelphiDateTime(MO_200_OK)																		AS "MO 200 OK"
			,dbo.DelphiDateTime(MT_200_OK)																		AS "MT 200 OK"
			,DATEDIFF(MILLISECOND ,MO_INVITE, MO_Trying)														AS "MO INVITE -> Trying (ms)"
			,DATEDIFF(MILLISECOND ,MO_INVITE, MO_SessionProgress)												AS "MO INVITE -> SessionProgress (ms)"
			,DATEDIFF(MILLISECOND ,MO_SessionProgress, MO_Alerting)												AS "MO SessionProgress -> Ringing (ms)"
			,DATEDIFF(MILLISECOND ,MO_Alerting, MO_200_OK)														AS "MO Ringing -> 200 OK (ms)"
			,DATEDIFF(MILLISECOND ,MO_INVITE, MO_200_OK)														AS "MO INVITE -> 200 OK (ms)"
			,DATEDIFF(MILLISECOND ,MT_Alerting, MT_200_OK)														AS "MT Ringing -> 200 OK (ms)"
			,DATEDIFF(MILLISECOND ,MO_INVITE, MO_200_OK) - DATEDIFF(MILLISECOND ,MT_Alerting, MT_200_OK)		as "(MO INVITE -> 200 OK) - (MT Ringing -> 200 OK) (ms)"
		INTO #TimestampsFINAL
		FROM #Timestamps
		ORDER BY MO_INVITE

		SELECT * FROM #TimestampsFINAL ORDER BY [Session ID]
	  
	  -- CREATE STATISTICS TEMP TABLE
	 IF OBJECT_ID ('tempdb..#TempStatistics' ) IS NOT NULL
		DROP TABLE #TempStatistics
	  CREATE TABLE #TempStatistics(
								Extracted varchar(60),
								Value Float)
	  -- MO INVITE -> Trying Statistics
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO INVITE -> Trying -- Average ',	AVG("MO INVITE -> Trying (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO INVITE -> Trying -- Minimum',	MIN("MO INVITE -> Trying (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO INVITE -> Trying -- Maximum',	MAX("MO INVITE -> Trying (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO INVITE -> Trying -- StDev',		cast(STDEV("MO INVITE -> Trying (ms)") as numeric(36,2)) FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO INVITE -> Trying -- Median',	(SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY "MO INVITE -> Trying (ms)") OVER () AS Median FROM #TimestampsFINAL))

	  -- MO INVITE -> SessionProgress Statistics
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO INVITE -> SessionProgress -- Average ',	AVG("MO INVITE -> SessionProgress (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO INVITE -> SessionProgress -- Minimum',	MIN("MO INVITE -> SessionProgress (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO INVITE -> SessionProgress -- Maximum',	MAX("MO INVITE -> SessionProgress (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO INVITE -> SessionProgress -- StDev',		cast(STDEV("MO INVITE -> SessionProgress (ms)") as numeric(36,2)) FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO INVITE -> SessionProgress -- Median',	(SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY "MO INVITE -> SessionProgress (ms)") OVER () AS Median FROM #TimestampsFINAL))

	  -- MO SessionProgress -> Ringing Statistics
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO SessionProgress -> Ringing -- Average ',	AVG("MO SessionProgress -> Ringing (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO SessionProgress -> Ringing -- Minimum',	MIN("MO SessionProgress -> Ringing (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO SessionProgress -> Ringing -- Maximum',	MAX("MO SessionProgress -> Ringing (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO SessionProgress -> Ringing -- StDev',		cast(STDEV("MO SessionProgress -> Ringing (ms)") as numeric(36,2)) FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO SessionProgress -> Ringing -- Median',	(SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY "MO SessionProgress -> Ringing (ms)") OVER () AS Median FROM #TimestampsFINAL))

	  -- MO Ringing -> 200 OK Statistics
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO Ringing -> 200 OK -- Average ',	AVG("MO Ringing -> 200 OK (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO Ringing -> 200 OK -- Minimum',	MIN("MO Ringing -> 200 OK (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO Ringing -> 200 OK -- Maximum',	MAX("MO Ringing -> 200 OK (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO Ringing -> 200 OK -- StDev',		cast(STDEV("MO Ringing -> 200 OK (ms)") as numeric(36,2)) FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO Ringing -> 200 OK -- Median',	(SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY "MO Ringing -> 200 OK (ms)") OVER () AS Median FROM #TimestampsFINAL))

	  -- MO INVITE -> 200 OK Statistics
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO INVITE -> 200 OK -- Average ',	AVG("MO INVITE -> 200 OK (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO INVITE -> 200 OK -- Minimum',	MIN("MO INVITE -> 200 OK (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO INVITE -> 200 OK -- Maximum',	MAX("MO INVITE -> 200 OK (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO INVITE -> 200 OK -- StDev',		cast(STDEV("MO INVITE -> 200 OK (ms)") as numeric(36,2)) FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MO INVITE -> 200 OK -- Median',	(SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY "MO INVITE -> 200 OK (ms)") OVER () AS Median FROM #TimestampsFINAL))

	  -- MT Ringing -> 200 OK Statistics
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MT Ringing -> 200 OK -- Average ',	AVG("MT Ringing -> 200 OK (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MT Ringing -> 200 OK -- Minimum',	MIN("MT Ringing -> 200 OK (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MT Ringing -> 200 OK -- Maximum',	MAX("MT Ringing -> 200 OK (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MT Ringing -> 200 OK -- StDev',		cast(STDEV("MT Ringing -> 200 OK (ms)") as numeric(36,2)) FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT 'MT Ringing -> 200 OK -- Median',	(SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY "MT Ringing -> 200 OK (ms)") OVER () AS Median FROM #TimestampsFINAL))

	  	  -- (MO INVITE -> 200 OK) - (MT Ringing -> 200 OK) Statistics
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT '(MO INVITE -> 200 OK) - (MT Ringing -> 200 OK) -- Average ',	AVG("(MO INVITE -> 200 OK) - (MT Ringing -> 200 OK) (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT '(MO INVITE -> 200 OK) - (MT Ringing -> 200 OK) -- Minimum',	MIN("(MO INVITE -> 200 OK) - (MT Ringing -> 200 OK) (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT '(MO INVITE -> 200 OK) - (MT Ringing -> 200 OK) -- Maximum',	MAX("(MO INVITE -> 200 OK) - (MT Ringing -> 200 OK) (ms)") FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT '(MO INVITE -> 200 OK) - (MT Ringing -> 200 OK) -- StDev',		cast(STDEV("(MO INVITE -> 200 OK) - (MT Ringing -> 200 OK) (ms)") as numeric(36,2)) FROM #TimestampsFINAL)
	  INSERT INTO #TempStatistics (Extracted, Value)
		(SELECT '(MO INVITE -> 200 OK) - (MT Ringing -> 200 OK) -- Median',	(SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY "(MO INVITE -> 200 OK) - (MT Ringing -> 200 OK) (ms)") OVER () AS Median FROM #TimestampsFINAL))

	  SELECT	Extracted		as 'Parameter Description'
				,Value			as '[ms]'
	  FROM #TempStatistics