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
			DECLARE @PrevTech varchar(1000) = '';
			DECLARE @Temp TABLE (timestamps datetime2(3), operator varchar(50), tech varchar(50), linija int)

			INSERT INTO @Temp (timestamps, operator,tech,linija)
			SELECT  a.[MsgTime]
			       ,b.[Operator]
				   ,b.[technology]
				   ,rownum = ROW_NUMBER() OVER (ORDER BY a.[MsgTime])
				FROM [NetworkIdRelation] a
				LEFT OUTER JOIN [NetworkInfo] b
					ON a.[NetworkId] = b.[NetworkId]
				WHERE a.[SessionId] = @sessID and (a.[MsgTime] >= @startTime and a.[MsgTime] <= @endTime)

			SET @CodeNameString=''

			SELECT  @CodeNameString = @CodeNameString + 
					CASE 
						WHEN a.linija = 1 THEN operator + ' - ' + tech
						WHEN a.linija > 1 and operator != (SELECT operator from @Temp where linija = (a.linija - 1) ) THEN  ' , ' + operator + ' - ' + tech
						WHEN a.linija > 1 and tech     != (SELECT tech     from @Temp where linija = (a.linija - 1) ) THEN  ' , ' + operator + ' - ' + tech
						ELSE ''
						END
				FROM @Temp a
			RETURN  @CodeNameString
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
			DECLARE @Temp TABLE (operator varchar(50), tech varchar(50))

			INSERT INTO @Temp (operator,tech)
			SELECT DISTINCT b.[Operator],b.[technology]
				FROM [NetworkIdRelation] a
				LEFT OUTER JOIN [NetworkInfo] b
					ON a.[NetworkId] = b.[NetworkId]
				WHERE a.[SessionId] = @sessID and (a.[MsgTime] >= @startTime and a.[MsgTime] <= @endTime)

			SET @CodeNameString=''
			SELECT  @CodeNameString = @CodeNameString + 
					CASE WHEN @CodeNameString = '' THEN operator + ' - ' + tech
					     ELSE ' , ' + operator + ' - ' + tech
						 END
				FROM @Temp
			RETURN  @CodeNameString
		END
GO

-- IMSI and variables Definitions!!!
declare		@telefonica_2G_imsi					table (Id varchar(15))
declare		@telefonica_2G3G_imsi				table (Id varchar(15))
declare		@telekom_2G3G_imsi					table (Id varchar(15))
declare		@vodafone_2G3G_imsi					table (Id varchar(15))

INSERT INTO  @telefonica_2G_imsi				values				('262073946090582'), ('262073946090579')
INSERT INTO  @telefonica_2G3G_imsi				values				('262073999241756'), ('262073952891169')
INSERT INTO  @telekom_2G3G_imsi					values				('262019434133489'), ('262011205914188')
INSERT INTO  @vodafone_2G3G_imsi				values				('262021304593088'), ('262021304593086')

-- EXTRACT beginning of the call and end of the call
IF OBJECT_ID ('tempdb..#DialMarkers' ) IS NOT NULL                                                        
    DROP TABLE #DialMarkers
SELECT [SessionId]
      ,[MsgTime]
	  ,[Info] as Side
	  ,[MarkerText]
  INTO #DialMarkers
  FROM [Markers]
  WHERE [MarkerText] in ('Start Dial', 'Incoming Call')
  ORDER BY [MsgTime]

IF OBJECT_ID ('tempdb..#DisconnectMarkers' ) IS NOT NULL                                                  
    DROP TABLE #DisconnectMarkers
SELECT [SessionId]
      ,[MsgTime]
	  ,[Info] as Side
	  ,[MarkerText]
  INTO #DisconnectMarkers
  FROM [Markers]
  WHERE [MarkerText] in ('Released')
  ORDER BY [MsgTime]

  SELECT * from #DisconnectMarkers

IF OBJECT_ID ('tempdb..#CallMarkers' ) IS NOT NULL                                                  
    DROP TABLE #CallMarkers
SELECT a.[SessionId]
      ,a.[MsgTime]		as Call_Start_Time
	  ,b.[MsgTime]		as Call_End_Time
	  ,CASE a.[MarkerText] 
			WHEN 'Start Dial' THEN 'MO'
			ELSE 'MT'
			END as Call_Side
  INTO #CallMarkers
  FROM #DialMarkers a
  LEFT OUTER JOIN #DisconnectMarkers b
    ON a.[SessionId] = b.[SessionId] and a.Side = b.Side

-- INSERT TO FINAL DB
IF OBJECT_ID ('tempdb..#FINAL1' ) IS NOT NULL                                                  
    DROP TABLE #FINAL1
SELECT a.[SessionId]
	  ,Call_Side
	  ,CASE
		WHEN b.[IMSI]  collate SQL_Latin1_General_CP1_CI_AS in (SELECT * FROM @telefonica_2G_imsi)	then 'Telefonica (2G)'
		WHEN b.[IMSI]  collate SQL_Latin1_General_CP1_CI_AS in (SELECT * FROM @telefonica_2G3G_imsi)	then 'Telefonica (2G3G)'
		WHEN b.[IMSI]  collate SQL_Latin1_General_CP1_CI_AS in (SELECT * FROM @telekom_2G3G_imsi)		then 'Telekom (2G3G)'
		WHEN b.[IMSI]  collate SQL_Latin1_General_CP1_CI_AS in (SELECT * FROM @vodafone_2G3G_imsi)	then 'Vodafone (2G3G)'
		END AS Home_Operator
	  ,b.[Call_Status]
      ,Call_Start_Time
	  ,Call_End_Time
	  ,dbo.BandsExtractDistinct(a.[SessionId],a.Call_Start_Time,a.Call_End_Time) as Tech_used_in_Call
	  ,dbo.BandsExtract(a.[SessionId],a.Call_Start_Time,a.Call_End_Time) as Technology_Timeline
  INTO #FINAL1
  FROM #CallMarkers a
  LEFT OUTER JOIN [NC_Calls_Distinct] b
    ON a.[SessionId] = b.[SessionId]
  WHERE Call_End_Time is not null and b.[valid] like '1'

IF OBJECT_ID ('tempdb..#FINAL' ) IS NOT NULL                                                  
    DROP TABLE #FINAL
SELECT *
	   ,LEN(Technology_Timeline) - LEN( REPLACE(Technology_Timeline, ','			, '') )		as Total_interTech_HO
	   ,(LEN(Technology_Timeline) - LEN( REPLACE(Technology_Timeline, 'GSM 900'		, '') ))/7	as GSM900_Count
	   ,(LEN(Technology_Timeline) - LEN( REPLACE(Technology_Timeline, 'GSM 1800'	, '') ))/8	as GSM1800_Count
	   ,(LEN(Technology_Timeline) - LEN( REPLACE(Technology_Timeline, 'UMTS 2100'	, '') ))/9	as UMTS2100_Count
INTO #FINAL
FROM #FINAL1
ORDER BY [SessionID]


SELECT  Home_Operator
		,[Call_Status]
		,Tech_used_in_Call
		,COUNT(Tech_used_in_Call) as number_of_samples
FROM #FINAL1
WHERE [Call_Status] not like 'System Release'
GROUP BY Home_Operator,[Call_Status], Tech_used_in_Call
ORDER BY Home_Operator,[Call_Status], Tech_used_in_Call

SELECT *
	   ,CASE
			WHEN GSM900_Count = Total_interTech_HO + 1								THEN 'GSM only'
			WHEN GSM1800_Count = Total_interTech_HO + 1								THEN 'GSM only'
			WHEN GSM900_Count + GSM1800_Count = Total_interTech_HO + 1				THEN 'GSM only'
			WHEN UMTS2100_Count = Total_interTech_HO + 1							THEN 'UMTS only'
			ELSE 'GSM and UMTS'
			END AS Technology_Description
FROM #FINAL
ORDER BY SessionId