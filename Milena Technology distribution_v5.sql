-- FUNCTION TO EXTRACT BANDS FOR SPECIFIC SESSION ID 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- DROP function if already exists
IF EXISTS (
    SELECT * FROM sysobjects WHERE id = object_id(N'BandsExtract') 
    AND xtype IN (N'FN', N'IF', N'TF')
)
    DROP FUNCTION BandsExtract
GO
-- CREATE FUNCTION THAT WILL EXTRACT ALL BANDS IN ACTIVE CALL
Create FUNCTION BandsExtract
(
    @sessID int,
	@startTime datetime2(3),
	@endTime datetime2(3)
)
RETURNS varchar(1000)
AS
BEGIN
			DECLARE @CodeNameString varchar(1000)
			DECLARE @OneNetIDCode varchar(1000) = ''
			DECLARE @PrevTech varchar(1000) = '';
			DECLARE @Temp TABLE (linija int, timestamps datetime2(3), operator varchar(50), tech varchar(50))

			-- Insert Network ID for more precise technology
			INSERT INTO @Temp (linija,timestamps,operator,tech)
			SELECT   rownum = ROW_NUMBER() OVER (ORDER BY a.[MsgTime])
					,a.[MsgTime]
					,b.[Operator]
					,b.[technology]
			FROM [NetworkIdRelation] a
			LEFT OUTER JOIN [NetworkInfo] b
				ON a.[NetworkId] = b.[NetworkId]
			WHERE a.[SessionId] = @sessID 
					AND (Type like 'NetworkId' or Type like 'SessionId')
					AND a.[MsgTime] <= @endTime
					AND DATEADD(MILLISECOND,b.[Duration],a.[MsgTime]) > @startTime
			ORDER BY a.[MsgTime]

			SET  @OneNetIDCode =  @OneNetIDCode + (SELECT operator from @Temp where linija = 1) + ' - ' + (SELECT tech from @Temp where linija = 1)

			SET @CodeNameString=''
			SELECT  @CodeNameString = @CodeNameString + 
					CASE 
						WHEN a.linija = 2 THEN operator + ' - ' + tech
						WHEN a.linija > 2 and operator != (SELECT operator from @Temp where linija = (a.linija - 1) ) THEN  ' , ' + operator + ' - ' + tech
						WHEN a.linija > 2 and tech     != (SELECT tech     from @Temp where linija = (a.linija - 1) ) THEN  ' , ' + operator + ' - ' + tech
						ELSE ''
						END
				FROM @Temp a
				WHERE a.linija != 1

			RETURN CASE (SELECT count(operator) from @Temp ) 
						WHEN 1 THEN @OneNetIDCode
						ELSE @CodeNameString
						END
END
GO

-- BANDS Extract DISTINCT
-- DROP function if already exists
		IF EXISTS (
			SELECT * FROM sysobjects WHERE id = object_id(N'BandsExtractDistinct') 
			AND xtype IN (N'FN', N'IF', N'TF')
		)
			DROP FUNCTION BandsExtractDistinct
		GO
		-- CREATE FUNCTION THAT WILL EXTRACT ALL BANDS IN ACTIVE CALL
		Create FUNCTION BandsExtractDistinct
		(
			@sessID int,
			@startTime datetime2(3),
			@endTime datetime2(3)
		)
		RETURNS varchar(1000)
		AS
		BEGIN
			DECLARE @CodeNameString varchar(1000)
			DECLARE @Temp TABLE (linija int, timestamps datetime2(3), operator varchar(50), tech varchar(50))
			DECLARE @Temp2 TABLE (band varchar(50))

			-- Insert Network ID for more precise technology
			INSERT INTO @Temp (linija,timestamps,operator,tech)
			SELECT   rownum = ROW_NUMBER() OVER (ORDER BY a.[MsgTime])
					,a.[MsgTime]
					,b.[Operator]
					,b.[technology]
			FROM [NetworkIdRelation] a
			LEFT OUTER JOIN [NetworkInfo] b
				ON a.[NetworkId] = b.[NetworkId]
			WHERE a.[SessionId] = @sessID 
					AND (Type like 'NetworkId' or Type like 'SessionId')
					AND a.[MsgTime] <= @endTime
					AND DATEADD(MILLISECOND,b.[Duration],a.[MsgTime]) > @startTime
			ORDER BY a.[MsgTime]

			INSERT INTO @Temp2 (band)
			SELECT DISTINCT CAST((operator + ' - ' + tech) as varchar(50))
				FROM @Temp

			SET @CodeNameString=''
			SELECT  @CodeNameString = @CodeNameString + 
					CASE WHEN @CodeNameString = '' THEN band
					     ELSE ' , ' + band
						 END
				FROM @Temp2
			RETURN  @CodeNameString
		END
GO

-- DROP function if already exists
IF EXISTS (
    SELECT * FROM sysobjects WHERE id = object_id(N'BandsExtractNoOperator') 
    AND xtype IN (N'FN', N'IF', N'TF')
)
    DROP FUNCTION BandsExtractNoOperator
GO
-- CREATE FUNCTION THAT WILL EXTRACT ALL BANDS IN ACTIVE CALL
Create FUNCTION BandsExtractNoOperator
(
    @OriginalString varchar(1000)
)
RETURNS varchar(1000)
AS
BEGIN
			DECLARE @NoEplus varchar(1000)
			DECLARE @NoTelefonica varchar(1000)
			DECLARE @NoVodafone varchar(1000)
			DECLARE @NoTelekom varchar(1000)
			
			SET @NoEplus = REPLACE(@OriginalString,'E-Plus - ','')
			SET @NoTelefonica = REPLACE(@NoEplus,'O2 - ','')
			SET @NoVodafone = REPLACE(@NoTelefonica,'Vodafone - ','')
			SET @NoTelekom = REPLACE(@NoVodafone,'T-Mobile - ','')
			RETURN @NoTelekom
END
GO

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

-- EXTRACT beginning of the call timestamp and side for Both MO and MT
IF OBJECT_ID ('tempdb..#DialMarkersMO' ) IS NOT NULL                                                        
    DROP TABLE #DialMarkersMO
SELECT [SessionId]
      ,[MsgTime]
	  ,[Info] as Side
	  ,[MarkerText]
  INTO #DialMarkersMO
  FROM [Markers]
  WHERE [MarkerText] like 'Start Dial' -- , 'Incoming Call')
  ORDER BY [MsgTime]

IF OBJECT_ID ('tempdb..#DialMarkersMT'  ) IS NOT NULL                                                     
    DROP TABLE #DialMarkersMT
SELECT [SessionId]
      ,[MsgTime]
	  ,[Info] as Side
	  ,[MarkerText]
  INTO #DialMarkersMT
  FROM [Markers]
  WHERE [MarkerText] like 'Incoming Call'
  ORDER BY [MsgTime]

IF OBJECT_ID ('tempdb..#ConnectMarkers'  ) IS NOT NULL                                                     
    DROP TABLE #ConnectMarkers
SELECT [SessionId]
      ,[MsgTime]
	  ,[Info] as Side
	  ,[MarkerText]
  INTO #ConnectMarkers
  FROM [Markers]
  WHERE [MarkerText] like 'Connected'
  ORDER BY [MsgTime]

-- MERGE MO MT Dial Sessions to have all data in one row
IF OBJECT_ID ('tempdb..#DialMarkers1'  ) IS NOT NULL
    DROP TABLE #DialMarkers1
SELECT a.[SessionId]
	  ,a.[Side]
      ,a.[MsgTime] as MO_Start_Test
	  ,b.[MsgTime] as MT_Start_Test
	  ,a.[MarkerText]
  INTO #DialMarkers1
  FROM #DialMarkersMO a
  LEFT OUTER JOIN #DialMarkersMT b
	ON a.SessionId = b.SessionId

IF OBJECT_ID ('tempdb..#DialMarkers2'  ) IS NOT NULL
    DROP TABLE #DialMarkers2
SELECT   a.[SessionId]
		,a.Side
		,a.[MarkerText]
		,a.MO_Start_Test
		,b.[MsgTime] as MO_Start
		,a.MT_Start_Test
INTO #DialMarkers2
FROM #DialMarkers1 a
LEFT OUTER JOIN #ConnectMarkers b
	ON a.[SessionId]=b.[SessionId] and a.Side=b.Side

IF OBJECT_ID ('tempdb..#DialMarkers'  ) IS NOT NULL
    DROP TABLE #DialMarkers
SELECT   a.[SessionId]
		,a.Side as MO_Side
		,a.[MarkerText]
		,a.MO_Start_Test
		,a.MO_Start
		,a.MT_Start_Test
		,b.[MsgTime] as MT_Start
INTO #DialMarkers
FROM #DialMarkers2 a
LEFT OUTER JOIN #ConnectMarkers b
	ON a.[SessionId]=b.[SessionId] and a.Side!=b.Side

-- EXTRACT end of the call timestamp and side for Both MO and MT
IF OBJECT_ID ('tempdb..#DisconnectMarkers' ) IS NOT NULL                                                  
    DROP TABLE #DisconnectMarkers
SELECT [SessionId]
      ,dateadd(MILLISECOND,-1500,[MsgTime]) as MsgTime
	  ,[Info] as Side
	  ,[MarkerText]
  INTO #DisconnectMarkers
  FROM [Markers]
  WHERE [MarkerText] like 'Released'
  ORDER BY [MsgTime]

-- MERGE MO Dial and Disconnect and MT Dial Sessions to have all data in one row
IF OBJECT_ID ('tempdb..#CallMarkers1' ) IS NOT NULL                                                  
    DROP TABLE #CallMarkers1
SELECT a.[SessionId]
	  ,a.[MO_Side]
	  ,CASE [MO_Side]
			WHEN 'A' THEN 'B'
			WHEN 'B' THEN 'A'
			ELSE NULL
			END AS MT_Side
      ,a.[MO_Start_Test]
	  ,a.[MO_Start]
	  ,b.[MsgTime] as MO_End
	  ,a.[MT_Start_Test]
	  ,a.[MT_Start]
  INTO #CallMarkers1
  FROM #DialMarkers a
  LEFT OUTER JOIN #DisconnectMarkers b
	ON a.[SessionId] = b.[SessionId] and a.[MO_Side] collate SQL_Latin1_General_CP1_CI_AS = b.[Side]

IF OBJECT_ID ('tempdb..#CallMarkers2' ) IS NOT NULL                                                  
    DROP TABLE #CallMarkers2
SELECT	*
		,CASE 
			WHEN MT_Side like 'A' THEN (SELECT TOP 1 [MsgTime] from #DisconnectMarkers WHERE [SessionId] like a.[SessionId] and Side like 'A')
			WHEN MT_Side like 'B' THEN (SELECT TOP 1 [MsgTime] from #DisconnectMarkers WHERE [SessionId] like a.[SessionId] and Side like 'B')
			ELSE NULL
			END AS MT_End1
INTO #CallMarkers2
FROM #CallMarkers1 a

IF OBJECT_ID ('tempdb..#CallMarkers' ) IS NOT NULL                                                  
    DROP TABLE #CallMarkers
SELECT	a.SessionId
		,b.valid
		,b.Call_Status
		,b.IMSI
		,CASE 
			WHEN a.MO_Side like 'A' then a.SessionId
			WHEN a.MO_Side like 'B' then b.SessionIdB
			END AS MO_SessionID
		,CASE 
			WHEN a.MT_Side like 'A' then a.SessionId
			WHEN a.MT_Side like 'B' then b.SessionIdB
			END AS MT_SessionID
		,a.MO_Start_Test
		,a.MO_Start
		,a.MO_End
		,a.MT_Start_Test
		,a.MT_Start
		,CASE 
			WHEN  a.MT_End1 is null THEN a.MO_End
			ELSE  a.MT_End1
			END AS MT_End
INTO #CallMarkers 
FROM #CallMarkers2 a 
LEFT OUTER JOIN [NC_Calls_Distinct] b
	ON b.[SessionId] = a.SessionId
WHERE MT_Start is not null and MO_End is not null and b.Call_Status not like 'System Release' and b.valid=1

-- INSERT TO FINAL DB after all Markers finally extracted
IF OBJECT_ID ('tempdb..#FINAL1' ) IS NOT NULL                                                  
    DROP TABLE #FINAL1
SELECT   a.SessionId
		,a.valid
		,a.Call_Status
		,CASE
			WHEN a.[IMSI]  collate SQL_Latin1_General_CP1_CI_AS in (SELECT * FROM @telefonica_2G_imsi)		then 'Telefonica (2G)'
			WHEN a.[IMSI]  collate SQL_Latin1_General_CP1_CI_AS in (SELECT * FROM @telefonica_2G3G_imsi)	then 'Telefonica (2G3G)'
			WHEN a.[IMSI]  collate SQL_Latin1_General_CP1_CI_AS in (SELECT * FROM @telekom_2G3G_imsi)		then 'Telekom (2G3G)'
			WHEN a.[IMSI]  collate SQL_Latin1_General_CP1_CI_AS in (SELECT * FROM @vodafone_2G3G_imsi)		then 'Vodafone (2G3G)'
			END AS Home_Operator
		,a.IMSI
		,a.MO_SessionID
		,a.MT_SessionID
		,a.MO_Start_Test
		,a.MO_Start
		,a.MO_End
		,dbo.BandsExtractDistinct(a.MO_SessionID,a.MO_Start,a.MO_End) as MO_Tech_Summary
		,dbo.BandsExtract(a.MO_SessionID,a.MO_Start,a.MO_End) as MO_Tech_Timeline
		,dbo.BandsExtractNoOperator( dbo.BandsExtract(a.MO_SessionID,a.MO_Start,a.MO_End) ) as MO_Tech_Timeline_no_Operator
		,a.MT_Start_Test
		,a.MT_Start
		,a.MT_End
		,dbo.BandsExtractDistinct(a.MT_SessionID,a.MT_Start,a.MT_End) as MT_Tech_Summary
		,dbo.BandsExtract(a.MT_SessionID,a.MT_Start,a.MT_End) as MT_Tech_Timeline
		,dbo.BandsExtractNoOperator( dbo.BandsExtract(a.MT_SessionID,a.MT_Start,a.MT_End) ) as MT_Tech_Timeline_no_Operator
  INTO #FINAL1
  FROM #CallMarkers a

IF OBJECT_ID ('tempdb..#FINAL') IS NOT NULL                                                  
    DROP TABLE #FINAL
SELECT	SessionId
		,valid
		,Call_Status
		,Home_Operator
		,IMSI
		,MO_SessionID
		,MT_SessionID
		,MO_Start_Test
		,MO_Start
		,MO_End
		,MO_Tech_Summary
		,MO_Tech_Timeline
		,MO_Tech_Timeline_no_Operator
		,(LEN(MO_Tech_Timeline) - LEN( REPLACE(MO_Tech_Timeline, 'GSM 900'		, '') ))/7	as MO_GSM900_Count
		,(LEN(MO_Tech_Timeline) - LEN( REPLACE(MO_Tech_Timeline, 'GSM 1800'	, '') ))/8		as MO_GSM1800_Count
		,(LEN(MO_Tech_Timeline) - LEN( REPLACE(MO_Tech_Timeline, 'UMTS 2100'	, '') ))/9	as MO_UMTS2100_Count
		, LEN(MO_Tech_Timeline) - LEN( REPLACE(MO_Tech_Timeline, ','			, '') )		as MO_TOTAL_interTech_HO_Count
		,(LEN(MO_Tech_Timeline_no_Operator) - LEN( REPLACE(MO_Tech_Timeline_no_Operator, 'GSM 900 , GSM 1800', '') ))/18 as MO_GSM900_GSM1800_HO_Count
		,(LEN(MO_Tech_Timeline_no_Operator) - LEN( REPLACE(MO_Tech_Timeline_no_Operator, 'GSM 1800 , GSM 900', '') ))/18 as MO_GSM1800_GSM900_HO_Count
		,(LEN(MO_Tech_Timeline_no_Operator) - LEN( REPLACE(MO_Tech_Timeline_no_Operator, 'GSM 900 , GSM 1800', '') ))/18 + (LEN(MO_Tech_Timeline_no_Operator) - LEN( REPLACE(MO_Tech_Timeline_no_Operator, 'GSM 1800 , GSM 900', '') ))/18 as MO_GSM_GSM_HO_Count
		,(LEN(MO_Tech_Timeline_no_Operator) - LEN( REPLACE(MO_Tech_Timeline_no_Operator, 'UMTS 2100 , GSM 900', '') ))/19 + (LEN(MO_Tech_Timeline_no_Operator) - LEN( REPLACE(MO_Tech_Timeline_no_Operator, 'UMTS 2100 , GSM 1800', '') ))/20 as MO_UMTS_GSM_HO_Count
		,(LEN(MO_Tech_Timeline_no_Operator) - LEN( REPLACE(MO_Tech_Timeline_no_Operator, 'GSM 900 , UMTS 2100', '') ))/19 + (LEN(MO_Tech_Timeline_no_Operator) - LEN( REPLACE(MO_Tech_Timeline_no_Operator, 'GSM 1800 , UMTS 2100', '') ))/20 as MO_GSM_UMTS_HO_Count
		,MT_Start_Test
		,MT_Start
		,MT_End
		,MT_Tech_Summary
		,MT_Tech_Timeline
		,MT_Tech_Timeline_no_Operator
		,(LEN(MT_Tech_Timeline) - LEN( REPLACE(MT_Tech_Timeline, 'GSM 900'		, '') ))/7	as MT_GSM900_Count
		,(LEN(MT_Tech_Timeline) - LEN( REPLACE(MT_Tech_Timeline, 'GSM 1800'	, '') ))/8		as MT_GSM1800_Count
		,(LEN(MT_Tech_Timeline) - LEN( REPLACE(MT_Tech_Timeline, 'UMTS 2100'	, '') ))/9	as MT_UMTS2100_Count
		, LEN(MT_Tech_Timeline) - LEN( REPLACE(MT_Tech_Timeline, ','			, '') )		as MT_TOTAL_interTech_HO_Count
		,(LEN(MT_Tech_Timeline_no_Operator) - LEN( REPLACE(MT_Tech_Timeline_no_Operator, 'GSM 900 , GSM 1800', '') ))/18 as MT_GSM900_GSM1800_HO_Count
		,(LEN(MT_Tech_Timeline_no_Operator) - LEN( REPLACE(MT_Tech_Timeline_no_Operator, 'GSM 1800 , GSM 900', '') ))/18 as MT_GSM1800_GSM900_HO_Count
		,(LEN(MT_Tech_Timeline_no_Operator) - LEN( REPLACE(MT_Tech_Timeline_no_Operator, 'GSM 900 , GSM 1800', '') ))/18 + (LEN(MT_Tech_Timeline_no_Operator) - LEN( REPLACE(MT_Tech_Timeline_no_Operator, 'GSM 1800 , GSM 900', '') ))/18 as MT_GSM_GSM_HO_Count
		,(LEN(MT_Tech_Timeline_no_Operator) - LEN( REPLACE(MT_Tech_Timeline_no_Operator, 'UMTS 2100 , GSM 900', '') ))/19 + (LEN(MT_Tech_Timeline_no_Operator) - LEN( REPLACE(MT_Tech_Timeline_no_Operator, 'UMTS 2100 , GSM 1800', '') ))/20 as MT_UMTS_GSM_HO_Count
		,(LEN(MT_Tech_Timeline_no_Operator) - LEN( REPLACE(MT_Tech_Timeline_no_Operator, 'GSM 900 , UMTS 2100', '') ))/19 + (LEN(MT_Tech_Timeline_no_Operator) - LEN( REPLACE(MT_Tech_Timeline_no_Operator, 'GSM 1800 , UMTS 2100', '') ))/20 as MT_GSM_UMTS_HO_Count
INTO #FINAL
FROM #FINAL1
ORDER BY [SessionID]

-- WA for manually verified sessions
UPDATE #FINAL
SET MT_Tech_Timeline = 'Vodafone - UMTS 2100 , Vodafone - GSM 900', MT_Tech_Timeline_no_Operator = 'UMTS 2100 , GSM 900'
WHERE SessionID in ('1380', '1924')

-- Printing each and every call
SELECT  SessionId
		,valid
		,Call_Status
		,Home_Operator
		,IMSI
		,MO_SessionID
		,MT_SessionID
		,MO_Start_Test
		,MO_Start as MO_Connected
		,MO_End
		,MO_Tech_Summary	MO_Tech_Timeline
		,MO_Tech_Timeline_no_Operator
		,MO_GSM900_Count	MO_GSM1800_Count
		,MO_UMTS2100_Count
		,MO_TOTAL_interTech_HO_Count
		,MO_GSM900_GSM1800_HO_Count
		,MO_GSM1800_GSM900_HO_Count
		,MO_GSM_GSM_HO_Count	MO_UMTS_GSM_HO_Count
		,MO_GSM_UMTS_HO_Count
		,MT_Start_Test
		,MT_Start as MT_Connected
		,MT_End
		,MT_Tech_Summary
		,MT_Tech_Timeline
		,MT_Tech_Timeline_no_Operator
		,MT_GSM900_Count	MT_GSM1800_Count
		,MT_UMTS2100_Count
		,MT_TOTAL_interTech_HO_Count
		,MT_GSM900_GSM1800_HO_Count
		,MT_GSM1800_GSM900_HO_Count
		,MT_GSM_GSM_HO_Count
		,MT_UMTS_GSM_HO_Count
		,MT_GSM_UMTS_HO_Count
FROM #FINAL
ORDER BY SessionId


/*
-- Printing MO Statistics
SELECT   Home_Operator
		,MO_Tech_Summary
		,Call_Status
		,COUNT(SessionId) as "Counting (Number)"
	FROM #FINAL
	GROUP BY Home_Operator,MO_Tech_Summary,Call_Status
	ORDER BY Home_Operator,MO_Tech_Summary,Call_Status

-- Printing MT Statistics
SELECT   Home_Operator
		,MT_Tech_Summary
		,Call_Status
		,COUNT(SessionId) as "Counting (Number)"
	FROM #FINAL
	GROUP BY Home_Operator,MT_Tech_Summary,Call_Status
	ORDER BY Home_Operator,MT_Tech_Summary,Call_Status

*/