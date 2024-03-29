----------------
-- FUNCTIONs  --
---------------- 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- CREATE FUNCTION THAT WILL EXTRACT ALL BANDS IN ACTIVE CALL
-- DROP function if already exists
IF EXISTS ( SELECT * FROM sysobjects WHERE id = object_id(N'BandsExtract') AND xtype IN (N'FN', N'IF', N'TF') )
    DROP FUNCTION BandsExtract
GO
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
			DECLARE @PrevTech varchar(1000) = '';
			DECLARE @Temp TABLE (sessionID bigint, timestamps datetime2(3), technology varchar(50), networkID bigint, band varchar(50), row_num int)

			-- Extract network information between call start and call end
			INSERT INTO @Temp (sessionID, timestamps, technology, networkID, band, row_num)
			SELECT a.[SessionId]
				  ,a.[MsgTime]
				  ,a.[Technology]
				  ,a.[NetworkId]
				  ,b.[Operator] + '-' + b.[technology] AS FreqBand
				  ,row_num = ROW_NUMBER() OVER (ORDER BY a.[MsgTime])
			  FROM [AN_Layer3] a
			  LEFT OUTER JOIN [NetworkInfo] b
				ON a.[NetworkId] = b.[NetworkId]
			  WHERE a.[SessionId] = @sessID and a.[MsgTime] > @startTime and a.[MsgTime] < @endTime

			SET @CodeNameString=''

			SELECT  @CodeNameString = @CodeNameString + 
					CASE 
						WHEN a.row_num = 1 THEN a.band
						WHEN a.row_num > 1 and  band != (SELECT band from @Temp where row_num = (a.row_num - 1) ) THEN  ' , ' + a.band
						ELSE ''
						END
				FROM @Temp a
			RETURN  @CodeNameString
END
GO
-- CREATE FUNCTION THAT WILL EXTRACT LIST OF BANDS USED IN ACTIVE CALL
IF EXISTS ( SELECT * FROM sysobjects WHERE id = object_id(N'BandsSummary') AND xtype IN (N'FN', N'IF', N'TF') )
    DROP FUNCTION BandsSummary
GO
Create FUNCTION BandsSummary
(
    @sessID int,
	@startTime datetime2(3),
	@endTime datetime2(3)
)
RETURNS varchar(1000)
AS
BEGIN
			DECLARE @CodeNameString varchar(1000)
			DECLARE @PrevTech varchar(1000) = '';
			DECLARE @Temp TABLE (band varchar(50))

			-- Extract network information between call start and call end
			INSERT INTO @Temp (band)
			SELECT DISTINCT b.[Operator] + '-' + b.[technology] AS FreqBand
			  FROM [o2_BAB_Q2_2nd_round].[dbo].[AN_Layer3] a
			  LEFT OUTER JOIN [NetworkInfo] b
				ON a.[NetworkId] = b.[NetworkId]
			  WHERE a.[SessionId] = @sessID and a.[MsgTime] > @startTime and a.[MsgTime] < @endTime

			SET @CodeNameString=''

			SELECT  @CodeNameString = @CodeNameString + 
						CASE
							WHEN @CodeNameString like '' THEN a.band
							ELSE ' , ' + a.band
							END
				FROM @Temp a
			RETURN  @CodeNameString
END
GO
-- CREATE FUNCTION THAT WILL DELETE 4 SUBSTRINGS FROM ORIGINAL STRING
IF EXISTS ( SELECT * FROM sysobjects WHERE id = object_id(N'Delete4Substrings') AND xtype IN (N'FN', N'IF', N'TF') )
    DROP FUNCTION Delete4Substrings
GO
Create FUNCTION Delete4Substrings
(
    @orig_string varchar(1000),
	@substring1 varchar(50),
	@substring2 varchar(50),
	@substring3 varchar(50),
	@substring4 varchar(50)
)
RETURNS varchar(1000)
AS
BEGIN
			DECLARE @orig_string_1 varchar(1000) = REPLACE(@orig_string,@substring1,'')
			DECLARE @orig_string_2 varchar(1000) = REPLACE(@orig_string_1,@substring2,'')
			DECLARE @orig_string_3 varchar(1000) = REPLACE(@orig_string_2,@substring3,'')
			DECLARE @orig_string_4 varchar(1000) = REPLACE(@orig_string_3,@substring4,'')

			RETURN  @orig_string_4
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

IF OBJECT_ID ('tempdb..#Temp2'  ) IS NOT NULL
    DROP TABLE #Temp2
SELECT   RefSessID
		,Call_Status
		,IMSI
		,Home_Operator
		,MO_SessionId
		,MO_Setup
		,MO_Connected
		,MO_Disconnect
		,dbo.BandsSummary(MO_SessionId, MO_Setup    , MO_Disconnect) as MO_Bands_Used_in_Setup_Disconnect
		--,dbo.BandsExtract(MO_SessionId, MO_Setup    , MO_Disconnect) as MO_Bands_Timeline_in_Setup_Disconnect
		--,dbo.BandsSummary(MO_SessionId, MO_Connected, MO_Disconnect) as MO_Bands_Used_in_ConAck_Disconnect
		--,dbo.BandsExtract(MO_SessionId, MO_Connected, MO_Disconnect) as MO_Bands_Timepline_in_ConAck_Disconnect
		,MT_SessionId
		,MT_Setup
		,MT_Connected
		,MT_Disconnect
		,dbo.BandsSummary(MT_SessionId, MT_Setup    , MT_Disconnect) as MT_Bands_Used_in_Setup_Disconnect
		--,dbo.BandsExtract(MT_SessionId, MT_Setup    , MT_Disconnect) as MT_Bands_Timeline_in_Setup_Disconnect
		--,dbo.BandsSummary(MT_SessionId, MT_Connected, MT_Disconnect) as MT_Bands_Used_in_ConAck_Disconnect
		--,dbo.BandsExtract(MT_SessionId, MT_Connected, MT_Disconnect) as MT_Bands_Timeline_in_ConAck_Disconnect
INTO #Temp2
FROM #Temp1
ORDER BY RefSessID

IF OBJECT_ID ('tempdb..#Temp3'  ) IS NOT NULL
    DROP TABLE #Temp3
SELECT   RefSessID
		,Call_Status
		,IMSI
		,Home_Operator
		,MO_SessionId
		,MO_Setup
		,MO_Connected
		,MO_Disconnect
		,MO_Bands_Used_in_Setup_Disconnect
		,CASE 
			WHEN (REPLACE(MO_Bands_Used_in_Setup_Disconnect,',','') = MO_Bands_Used_in_Setup_Disconnect) THEN MO_Bands_Used_in_Setup_Disconnect
			ELSE dbo.BandsExtract(MO_SessionId, MO_Setup    , MO_Disconnect) 
			END AS MO_Bands_Timeline_in_Setup_Disconnect
		,MT_SessionId
		,MT_Setup
		,MT_Connected
		,MT_Disconnect
		,MT_Bands_Used_in_Setup_Disconnect
		,CASE 
			WHEN (REPLACE(MT_Bands_Used_in_Setup_Disconnect,',','') = MT_Bands_Used_in_Setup_Disconnect) THEN MT_Bands_Used_in_Setup_Disconnect
			ELSE dbo.BandsExtract(MT_SessionId, MT_Setup    , MT_Disconnect) 
			END AS MT_Bands_Timeline_in_Setup_Disconnect
INTO #Temp3
FROM #Temp2

IF OBJECT_ID ('tempdb..#Temp4'  ) IS NOT NULL
    DROP TABLE #Temp4
SELECT   RefSessID
		,Call_Status
		,IMSI
		,Home_Operator
		,MO_SessionId
		,MO_Setup
		,MO_Connected
		,MO_Disconnect
		,MO_Bands_Used_in_Setup_Disconnect
		,MO_Bands_Timeline_in_Setup_Disconnect
		,dbo.Delete4Substrings(MO_Bands_Timeline_in_Setup_Disconnect,'O2-','E-Plus-','Vodafone-','T-Mobile-') as MO_TMP
		,MT_SessionId
		,MT_Setup
		,MT_Connected
		,MT_Disconnect
		,MT_Bands_Used_in_Setup_Disconnect
		,MT_Bands_Timeline_in_Setup_Disconnect
		,dbo.Delete4Substrings(MT_Bands_Timeline_in_Setup_Disconnect,'O2-','E-Plus-','Vodafone-','T-Mobile-') as MT_TMP
INTO #Temp4
FROM #Temp3

IF OBJECT_ID ('tempdb..#FINAL'  ) IS NOT NULL
    DROP TABLE #FINAL
SELECT   RefSessID
		,Call_Status
		,IMSI
		,Home_Operator
		,MO_SessionId
		,MO_Setup
		,MO_Connected
		,MO_Disconnect
		,MO_Bands_Used_in_Setup_Disconnect
		,MO_Bands_Timeline_in_Setup_Disconnect
		, LEN(MO_TMP) - LEN( REPLACE(MO_TMP, ','			, '') )		as MO_TOTAL_interTech_HO_Count
		,(LEN(MO_TMP) - LEN( REPLACE(MO_TMP, 'GSM 900 , GSM 1800', '') ))/18 as MO_GSM900_GSM1800_HO_Count
		,(LEN(MO_TMP) - LEN( REPLACE(MO_TMP, 'GSM 1800 , GSM 900', '') ))/18 as MO_GSM1800_GSM900_HO_Count
		,(LEN(MO_TMP) - LEN( REPLACE(MO_TMP, 'GSM 900 , GSM 1800', '') ))/18 + (LEN(MO_TMP) - LEN( REPLACE(MO_TMP, 'GSM 1800 , GSM 900', '') ))/18 as MO_GSM_GSM_HO_Count
		,(LEN(MO_TMP) - LEN( REPLACE(MO_TMP, 'UMTS 2100 , GSM 900', '') ))/19 + (LEN(MO_TMP) - LEN( REPLACE(MO_TMP, 'UMTS 2100 , GSM 1800', '') ))/20 as MO_UMTS_GSM_HO_Count
		,(LEN(MO_TMP) - LEN( REPLACE(MO_TMP, 'GSM 900 , UMTS 2100', '') ))/19 + (LEN(MO_TMP) - LEN( REPLACE(MO_TMP, 'GSM 1800 , UMTS 2100', '') ))/20 as MO_GSM_UMTS_HO_Count
		,MT_SessionId
		,MT_Setup
		,MT_Connected
		,MT_Disconnect
		,MT_Bands_Used_in_Setup_Disconnect
		,MT_Bands_Timeline_in_Setup_Disconnect
		, LEN(MT_TMP) - LEN( REPLACE(MT_TMP, ','			, '') )		as MT_TOTAL_interTech_HO_Count
		,(LEN(MT_TMP) - LEN( REPLACE(MT_TMP, 'GSM 900 , GSM 1800', '') ))/18 as MT_GSM900_GSM1800_HO_Count
		,(LEN(MT_TMP) - LEN( REPLACE(MT_TMP, 'GSM 1800 , GSM 900', '') ))/18 as MT_GSM1800_GSM900_HO_Count
		,(LEN(MT_TMP) - LEN( REPLACE(MT_TMP, 'GSM 900 , GSM 1800', '') ))/18 + (LEN(MT_TMP) - LEN( REPLACE(MT_TMP, 'GSM 1800 , GSM 900', '') ))/18 as MT_GSM_GSM_HO_Count
		,(LEN(MT_TMP) - LEN( REPLACE(MT_TMP, 'UMTS 2100 , GSM 900', '') ))/19 + (LEN(MT_TMP) - LEN( REPLACE(MT_TMP, 'UMTS 2100 , GSM 1800', '') ))/20 as MT_UMTS_GSM_HO_Count
		,(LEN(MT_TMP) - LEN( REPLACE(MT_TMP, 'GSM 900 , UMTS 2100', '') ))/19 + (LEN(MT_TMP) - LEN( REPLACE(MT_TMP, 'GSM 1800 , UMTS 2100', '') ))/20 as MT_GSM_UMTS_HO_Count
INTO #FINAL
FROM #Temp4

SELECT * FROM #FINAL

SELECT  Home_Operator
		,Call_Status
		,MO_Bands_Used_in_Setup_Disconnect
		,COUNT(Call_Status) as "MO Samples COUNT"
FROM #FINAL
GROUP BY Home_Operator,Call_Status,MO_Bands_Used_in_Setup_Disconnect

SELECT  Home_Operator
		,Call_Status
		,MT_Bands_Used_in_Setup_Disconnect
		,COUNT(Call_Status) as "MT Samples COUNT"
FROM #FINAL
GROUP BY Home_Operator,Call_Status,MT_Bands_Used_in_Setup_Disconnect