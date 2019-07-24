-- REQUIREMENTS
-- Calls need to be imported in DB
-- AN3 Table must Exist
-- NC_Calls Table must exist

-- Imports for filtering (USER INPUT)
DECLARE @Date_Year                  int               = 2016 ;
DECLARE @Date_Month                 int               = 5 ;
DECLARE @Date_Day                   int               = 13 ;
DECLARE @Dialing_IMSI				varchar(50)		  = '%' ;
DECLARE @Dial_Number_1				varchar(50)       = '%9834' ;
DECLARE @Dial_Number_2				varchar(50)       = '%1085' ;
DECLARE @Dial_Number_3				varchar(50)       = 'none' ;
DECLARE @A_SideFile_1				varchar(50)       = '%' ;
DECLARE @A_SideFile_2				varchar(50)       = 'none' ;
DECLARE @A_SideFile_3				varchar(50)       = 'none' ;

-- Create Temporary Table with all Concerned Timestamps
IF OBJECT_ID ('tempdb..#TimeStamps' ) IS NOT NULL
    DROP TABLE #TimeStamps
SELECT  [SessionId],
        [Call_Status] ,
               -- SIP INVITE Timestamp
        CASE
               WHEN [Call_Type] like 'M2S' THEN (SELECT TOP 1 [MsgTime] FROM [VDF_HUAWEI_SBC_Measurement] .[dbo]. [AN_Layer3] WHERE ([MessageTypeName] like '%IMS%INVITE%(Request)%' or [MessageTypeName] like 'Setup') and [Direction] like 'U' and [SessionId] like a.[SessionId])
               WHEN [Call_Type] like 'S2M' THEN (SELECT TOP 1 [MsgTime] FROM [VDF_HUAWEI_SBC_Measurement] .[dbo]. [AN_Layer3] WHERE ([MessageTypeName] like '%IMS%INVITE%(Request)%' or [MessageTypeName] like 'Setup') and [Direction] like 'U' and [SessionId] like a.[SessionIdB])
               ELSE NULL
               END AS SIP_Invite,
               -- SIP Trying Timestamp
        CASE
               WHEN [Call_Type] like 'M2S' THEN (SELECT TOP 1 [MsgTime] FROM [VDF_HUAWEI_SBC_Measurement] .[dbo]. [AN_Layer3] WHERE ([MessageTypeName] like '%IMS%Trying%' or [MessageTypeName] like 'Call Pro%') and [Direction] like 'D' and [SessionId] like a .[SessionId])
               WHEN [Call_Type] like 'S2M' THEN (SELECT TOP 1 [MsgTime] FROM [VDF_HUAWEI_SBC_Measurement] .[dbo]. [AN_Layer3] WHERE ([MessageTypeName] like '%IMS%Trying%' or [MessageTypeName] like 'Call Pro%') and [Direction] like 'D' and [SessionId] like a .[SessionIdB])
               ELSE NULL
               END AS SIP_Trying,
               -- SIP Session Progress Timestamp
        CASE
               WHEN [Call_Type] like 'M2S' THEN (SELECT TOP 1 [MsgTime] FROM [VDF_HUAWEI_SBC_Measurement] .[dbo]. [AN_Layer3] WHERE ([MessageTypeName] like '%Session%Progress%' or [MessageTypeName] like 'Facility') and [Direction] like 'D' and [SessionId] like a .[SessionId])
               WHEN [Call_Type] like 'S2M' THEN (SELECT TOP 1 [MsgTime] FROM [VDF_HUAWEI_SBC_Measurement] .[dbo]. [AN_Layer3] WHERE ([MessageTypeName] like '%Session%Progress%' or [MessageTypeName] like 'Facility') and [Direction] like 'D' and [SessionId] like a .[SessionIdB])
               ELSE NULL
               END AS SIP_SessionProgress,
               -- SIP Ringing Timestamp
        CASE
               WHEN [Call_Type] like 'M2S' THEN (SELECT TOP 1 [MsgTime] FROM [VDF_HUAWEI_SBC_Measurement] .[dbo]. [AN_Layer3] WHERE ([MessageTypeName] like '%IMS%INVITE%Ringing)%' or [MessageTypeName] like '%Alerting%') and [Direction] like 'D' and [SessionId] like a.[SessionId])
               WHEN [Call_Type] like 'S2M' THEN (SELECT TOP 1 [MsgTime] FROM [VDF_HUAWEI_SBC_Measurement] .[dbo]. [AN_Layer3] WHERE ([MessageTypeName] like '%IMS%INVITE%Ringing)%' or [MessageTypeName] like '%Alerting%') and [Direction] like 'D' and [SessionId] like a.[SessionIdB])
               ELSE NULL
               END AS SIP_Ringing,
               -- SIP 200OK Timestamp
        CASE
               WHEN [Call_Type] like 'M2S' THEN (SELECT TOP 1 [MsgTime] FROM [VDF_HUAWEI_SBC_Measurement] .[dbo]. [AN_Layer3] WHERE  ([MessageTypeName] like '%IMS%INVITE%OK%' or [MessageTypeName] like 'Connect') and [Direction] like 'D' and [SessionId] like a .[SessionId])
               WHEN [Call_Type] like 'S2M' THEN (SELECT TOP 1 [MsgTime] FROM [VDF_HUAWEI_SBC_Measurement] .[dbo]. [AN_Layer3] WHERE  ([MessageTypeName] like '%IMS%INVITE%OK%' or [MessageTypeName] like 'Connect') and [Direction] like 'D' and [SessionId] like a . [SessionIdB])
               ELSE NULL
               END AS SIP_200OK,
        CASE
               WHEN [Call_Type] like 'M2S' THEN (SELECT TOP 1 [MsgTime] FROM [VDF_HUAWEI_SBC_Measurement] .[dbo]. [AN_Layer3] WHERE ([MessageTypeName] like '%IMS%INVITE%Ringing)%' or [MessageTypeName] like '%Alerting%') and [Direction] like 'U' and [SessionId] like a.[SessionIdB])
               WHEN [Call_Type] like 'S2M' THEN (SELECT TOP 1 [MsgTime] FROM [VDF_HUAWEI_SBC_Measurement] .[dbo]. [AN_Layer3] WHERE ([MessageTypeName] like '%IMS%INVITE%Ringing)%' or [MessageTypeName] like '%Alerting%') and [Direction] like 'U' and [SessionId] like a.[SessionId])
               ELSE NULL
               END AS SIP_Ringing_SideB,
               -- SIP 200OK Timestamp
        CASE
               WHEN [Call_Type] like 'M2S' THEN (SELECT TOP 1 [MsgTime] FROM [VDF_HUAWEI_SBC_Measurement] .[dbo]. [AN_Layer3] WHERE ([MessageTypeName] like '%IMS%INVITE%OK%' or [MessageTypeName] like 'Connect')  and [Direction] like 'U' and [SessionId] like a .[SessionIdB])
               WHEN [Call_Type] like 'S2M' THEN (SELECT TOP 1 [MsgTime] FROM [VDF_HUAWEI_SBC_Measurement] .[dbo]. [AN_Layer3] WHERE ([MessageTypeName] like '%IMS%INVITE%OK%' or [MessageTypeName] like 'Connect') and [Direction] like 'U' and [SessionId] like a .[SessionId])
               ELSE NULL
               END AS SIP_200OK_SideB
  INTO #TimeStamps
  FROM [VDF_HUAWEI_SBC_Measurement] .[dbo]. [NC_Calls] a
  WHERE [valid]							like '1'
        and [Call_Status]				like 'Completed'
        and [Year]						like @Date_Year
        and [Month]						like @Date_Month
        --and [Day]						like @Date_Day	
		and ([Day] like 9 or [Day] like 10 or [Day] like 11 or [Day] like 12 or [Day] like 13)			
		and [IMSI]						like @Dialing_IMSI
        and ([Dialnumber]               like @Dial_Number_1		or [Dialnumber]			like @Dial_Number_2		or [Dialnumber]			like @Dial_Number_3 )
        and ([ASideFileName]            like @A_SideFile_1		or [ASideFileName]		like @A_SideFile_2		or [ASideFileName]		like @A_SideFile_3  )

-- Extracting All Data Required and creating Temp Table for those
IF OBJECT_ID ('tempdb..#Times_Final' ) IS NOT NULL
    DROP TABLE #Times_Final
SELECT  [SessionId],
        [Call_Status],
        SIP_Invite ,
        SIP_Trying ,
        SIP_SessionProgress ,
        SIP_Ringing ,
        SIP_200OK ,
		-- Important CST Values for Vodafone
        DATEDIFF(MILLISECOND ,SIP_Invite, SIP_Trying)                           AS Invite_Trying_ms,
        DATEDIFF(MILLISECOND ,SIP_Invite, SIP_SessionProgress)					AS Invite_Session_ms,
        DATEDIFF(MILLISECOND ,SIP_SessionProgress, SIP_Ringing)					AS Session_Ringing_ms,
        DATEDIFF(MILLISECOND ,SIP_Ringing, SIP_200OK)                           AS Ringing_200OK_ms,
        DATEDIFF(MILLISECOND ,SIP_Invite, SIP_200OK)                            AS Invite_200OK_ms,
		DATEDIFF(MILLISECOND ,SIP_Ringing_SideB, SIP_200OK_SideB)               AS BSide_Ringing_200OK_ms,
		-- MT Side Timers and Data
		SIP_Ringing_SideB,
		SIP_200OK_SideB,
		DATEDIFF(MILLISECOND ,SIP_Invite, SIP_200OK) - DATEDIFF(MILLISECOND ,SIP_Ringing_SideB, SIP_200OK_SideB) as VDF_CST
 INTO #Times_Final
 FROM #TimeStamps
 ORDER BY [SessionId]

 --------------------------------------------------
 -- What is beeing Displayed and Required by VDF --
 --------------------------------------------------
 -- Display Times Extracted Table
 SELECT *
 FROM #Times_Final
 ORDER BY [SessionId]

 -- Calculating Statistical Values
 SELECT
           -- Invite to Trying Statistics
           AVG   ( Invite_Trying_ms)																							AS AVG_Invite_Trying_ms,
           (SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY Invite_Trying_ms) OVER () AS Median FROM #Times_Final )	AS Median_Invite_Trying_ms,
           MIN   ( Invite_Trying_ms)																							AS MIN_Invite_Trying_ms,
           MAX   ( Invite_Trying_ms)																							AS MAX_Invite_Trying_ms,
           STDEV ( Invite_Trying_ms)																							AS StDev_Invite_Trying_ms,
           -- Invite to Session in Progress Statistics
           AVG   ( Invite_Session_ms)																							AS AVG_Invite_Session_ms,
           (SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY Invite_Session_ms) OVER () AS Median FROM #Times_Final )	AS Median_Invite_Session_ms,
           MIN   ( Invite_Session_ms)																							AS MIN_Invite_Session_ms,
           MAX   ( Invite_Session_ms)																							AS MAX_Invite_Session_ms,
           STDEV ( Invite_Session_ms)																							AS StDev_Invite_Session_ms,
           -- Session Progress to Ringing Statistics
           AVG   ( Session_Ringing_ms)																							AS AVG_Session_Ringing_ms,
           (SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY Session_Ringing_ms) OVER () AS Median FROM #Times_Final ) AS Median_Session_Ringing_ms,
           MIN   ( Session_Ringing_ms)																							AS MIN_Session_Ringing_ms,
           MAX   ( Session_Ringing_ms)																							AS MAX_Session_Ringing_ms,
           STDEV ( Session_Ringing_ms)																							AS StDev_Session_Ringing_ms,
           -- Ringing to 200OK Statistics
           AVG   ( Ringing_200OK_ms)																							AS AVG_Ringing_200OK_ms,
           (SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY Ringing_200OK_ms) OVER () AS Median FROM #Times_Final )	AS Median_Ringing_200OK_ms,
           MIN   ( Ringing_200OK_ms)																							AS MIN_Ringing_200OK_ms,
           MAX   ( Ringing_200OK_ms)																							AS MAX_Ringing_200OK_ms,
           STDEV ( Ringing_200OK_ms)																							AS StDev_Ringing_200OK_ms,
		   -- Invite to 200OK Statistics
           AVG   ( Invite_200OK_ms)																								AS AVG_Invite_200OK_ms,
           (SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY Invite_200OK_ms) OVER () AS Median FROM #Times_Final )	AS Median_Invite_200OK_ms,
           MIN   ( Invite_200OK_ms)																								AS MIN_Invite_200OK_ms,
           MAX   ( Invite_200OK_ms)																								AS MAX_Invite_200OK_ms,
           STDEV ( Invite_200OK_ms)																								AS StDev_Invite_200OK_ms,
		   -- Invite to 200OK Statistics - Ringing to 200ok on B Side
           AVG   ( VDF_CST)																										AS AVG_Invite_200OK_noBSide_ms,
           (SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY Invite_200OK_ms) OVER () AS Median FROM #Times_Final )	AS Median_Invite_200OK_noBSide_ms,
           MIN   ( VDF_CST)																										AS MIN_Invite_200OK_noBSide_ms,
           MAX   ( VDF_CST)																										AS MAX_Invite_200OK_noBSide_ms,
           STDEV ( VDF_CST)																										AS StDev_Invite_200OK_noBSide_ms
 FROM #Times_Final