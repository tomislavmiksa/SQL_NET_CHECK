DECLARE @Timestmp_Start	datetime2(3)
DECLARE @Timestmp_End	datetime2(3)

-- Measurement Start and End Timestamp
SET @Timestmp_Start = CONVERT(datetime,'Jul 25 17:00:00 2017')
SET @Timestmp_End   = CONVERT(datetime,'Jul 26 09:00:00 2017')


-- VOICE SECTION
IF OBJECT_ID ('tempdb..#AtoBvoice' ) IS NOT NULL
    DROP TABLE #AtoBvoice
SELECT [Year]
      ,[Month]
      ,[Week]
      ,[Day]
      ,[Hour]
      ,[Operator]
      ,[Session_Type]
	  ,Call_Start_Time
      ,[Call_Direction]
      ,[Call_Status]
      ,[CST(Dial->Alerting)]
	  ,[SessionId_A]
      ,[UE_A]
      ,[FW_A]
      ,[IMEI_A]
      ,[IMSI_A]
      ,[FileId_A]
      ,[Sequenz_ID_per_File_A]
      ,[File_Name_A]
      ,[L1_callMode_A]
      ,[HandoversInfo_A]
	  ,[SessionId_B]
      ,[UE_B]
      ,[FW_B]
      ,[IMEI_B]
      ,[IMSI_B]
      ,[L1_callMode_B]
      ,[HandoversInfo_B]
  INTO #AtoBvoice
  FROM [NEW_CDR_VOICE_2017]
  WHERE Validity = 1 and Call_Direction like 'A->B'
		and Call_Start_Time between @Timestmp_Start and @Timestmp_End

IF OBJECT_ID ('tempdb..#BtoAvoice' ) IS NOT NULL
    DROP TABLE #BtoAvoice
SELECT [Year]
      ,[Month]
      ,[Week]
      ,[Day]
      ,[Hour]
      ,[Operator]
      ,[Session_Type]
      ,[Call_Direction]
      ,[Call_Status]
      ,[CST(Dial->Alerting)]				
	  ,[SessionId_A]
      ,[UE_A]
      ,[FW_A]
      ,[IMEI_A]
      ,[IMSI_A]
      ,[FileId_A]
      ,[Sequenz_ID_per_File_A]
      ,[File_Name_A]
      ,[L1_callMode_A]
      ,[HandoversInfo_A]
	  ,[SessionId_B]
      ,[UE_B]
      ,[FW_B]
      ,[IMEI_B]
      ,[IMSI_B]
      ,[L1_callMode_B]
      ,[HandoversInfo_B]
  INTO #BtoAvoice
  FROM [NEW_CDR_VOICE_2017]
  WHERE Validity = 1 and Call_Direction like 'B->A'
		and Call_Start_Time between @Timestmp_Start and @Timestmp_End


-- HANDOVER PART
IF OBJECT_ID ('tempdb..#HOvoiceA' ) IS NOT NULL
    DROP TABLE #HOvoiceA
SELECT * 
INTO #HOvoiceA
FROM 
      (SELECT 
			s.SessionId,
			KPIStatus,
			kpi.StartTime,
			case 
				when kpiid = 34050 then '2G-Handover'
				when kpiid = 34070 then '2G-Handover'
				when kpiid = 35020 then '2G->3G-InterSystemHO'
				when kpiid = 35030 then '3G->2G-InterSystemHO'
				when kpiid = 35040 then '3G->2G-InterSystemHO'
				when kpiid = 35041 then '3G->2G-InterSystemHO' 	
				when kpiid = 35100 then '3G-Handover'			
				when kpiid = 35107 then '3G-Handover(interFreq)'
				when kpiid = 38040 then '4G->3G-InterSystemHO'
				when kpiid = 38100 then '4G-Handover'
			else null end as KPIId     
      from
            vresultskpi kpi
			left outer join sessions s on kpi.SessionId=s.SessionId) AS T
where KPIId is not null

IF OBJECT_ID ('tempdb..#HOvoiceAStat' ) IS NOT NULL
    DROP TABLE #HOvoiceAStat
SELECT   KPIId
		,COUNT(KPIId) AS HO_Count
		,SUM(CASE WHEN KPIStatus like 'Succe%' THEN 1 ELSE 0 END ) AS HO_Success_Count
INTO #HOvoiceAStat
FROM #HOvoiceA WHERE SessionId in (Select SessionId_A FROM #BtoAvoice) or SessionId in (Select SessionId_A FROM #AtoBvoice) 
GROUP BY KPIId

IF OBJECT_ID ('tempdb..#HOvoiceB' ) IS NOT NULL
    DROP TABLE #HOvoiceB
SELECT * 
INTO #HOvoiceB
FROM
(SELECT 
			sb.SessionId,
			KPIStatus,
			kpi.StartTime,
			case 
				when kpiid = 34050 then '2G-Handover'
				when kpiid = 34070 then '2G-Handover'
				when kpiid = 35020 then '2G->3G-InterSystemHO'
				when kpiid = 35030 then '3G->2G-InterSystemHO'
				when kpiid = 35040 then '3G->2G-InterSystemHO'
				when kpiid = 35041 then '3G->2G-InterSystemHO' 	
				when kpiid = 35100 then '3G-Handover'			
				when kpiid = 35107 then '3G-Handover(interFreq)'
				when kpiid = 38040 then '4G->3G-InterSystemHO'
				when kpiid = 38100 then '4G-Handover'
			else null end as KPIId                         
      from
            vresultskpi kpi 
			left outer join SessionsB sb on kpi.SessionId=sb.SessionId WHERE sb.SessionId is not null ) AS T
where KPIId is not null

IF OBJECT_ID ('tempdb..#HOvoiceBStat' ) IS NOT NULL
    DROP TABLE #HOvoiceBStat
SELECT   KPIId
		,COUNT(KPIId) AS HO_Count
		,SUM(CASE WHEN KPIStatus like 'Succe%' THEN 1 ELSE 0 END ) AS HO_Success_Count
INTO #HOvoiceBStat
FROM #HOvoiceB WHERE SessionId in (Select SessionId_B FROM #BtoAvoice) or SessionId in (Select SessionId_B FROM #AtoBvoice) 
GROUP BY KPIId

-- SPEECH SECTION
IF OBJECT_ID ('tempdb..#speechA1' ) IS NOT NULL
    DROP TABLE #speechA1
SELECT [SessionIdA]
      ,[SessionIdB]
      ,[direction]
      ,[LQ]
      ,[BW]
      ,[Resampling]
      ,[Playing_Technology]
      ,[Playing_Codec]
      ,[Recording Technology]
      ,[Recording Codec]
  INTO #speechA1
  FROM [NEW_SpeechQuality]
  WHERE SessionIdA in (Select SessionId_A FROM #AtoBvoice) 

IF OBJECT_ID ('tempdb..#speechA' ) IS NOT NULL
    DROP TABLE #speechA
SELECT COUNT(LQ)																									AS "POLQA_MOS_SAMPLES_COUNT",
	   SUM(CASE WHEN [LQ] >= 2.7 THEN 0 ELSE 1 END)																	AS "POLQA_MOS_POOR_SAMPLES_COUNT",
	   (SELECT MIN(LQ) FROM #speechA1)																				AS "POLQA_MOS_MIN",
	   (SELECT master.dbo.Quantil(LQ,0.1) FROM #speechA1)															AS "POLQA_MOS_PCTL_10",
	   (SELECT master.dbo.Quantil(LQ,0.2) FROM #speechA1)															AS "POLQA_MOS_PCTL_20",
	   (SELECT master.dbo.Quantil(LQ,0.5) FROM #speechA1)															AS "POLQA_MOS_PCTL_50",
	   AVG(LQ)																										AS "POLQA_MOS_AVERAGE",
	   STDEV(LQ)																									AS "POLQA_MOS_STDEV",
	   (SELECT master.dbo.Quantil(LQ,0.8) FROM #speechA1)															AS "POLQA_MOS_PCTL_80",
	   (SELECT master.dbo.Quantil(LQ,0.9) FROM #speechA1)															AS "POLQA_MOS_PCTL_90",
	   (SELECT MAX(LQ) FROM #speechA1)																				AS "POLQA_MOS_MAX",
	   SUM(CASE WHEN BW like 'WB' THEN 1 ELSE 0 END)																AS "WB_SAMPLES_COUNT",
	   (SELECT MIN(LQ) FROM #speechA1 WHERE BW like 'WB')															AS "WB_POLQA_MOS_MIN",
	   (SELECT master.dbo.Quantil(LQ,0.1) FROM #speechA1 WHERE BW like 'WB')										AS "WB_POLQA_MOS_PCTL_10",
	   (SELECT master.dbo.Quantil(LQ,0.2) FROM #speechA1 WHERE BW like 'WB')										AS "WB_POLQA_MOS_PCTL_20",
	   (SELECT master.dbo.Quantil(LQ,0.5) FROM #speechA1 WHERE BW like 'WB')										AS "WB_POLQA_MOS_PCTL_50",
	   1.0* SUM(CASE WHEN BW like 'WB' THEN LQ ELSE 0 END)/nullif(SUM(CASE WHEN BW like 'WB' THEN 1 ELSE 0 END),0)	AS "WB_POLQA_MOS_AVERAGE",
	   (SELECT stdev(LQ) FROM #speechA1 WHERE BW like 'WB')															AS "WB_POLQA_MOS_STDEV",
	   (SELECT master.dbo.Quantil(LQ,0.8) FROM #speechA1 WHERE BW like 'WB')										AS "WB_POLQA_MOS_PCTL_80",
	   (SELECT master.dbo.Quantil(LQ,0.9) FROM #speechA1 WHERE BW like 'WB')										AS "WB_POLQA_MOS_PCTL_90",
	   (SELECT MAX(LQ) FROM #speechA1 WHERE BW like 'WB')															AS "WB_POLQA_MOS_MAX",
	   SUM(CASE WHEN BW like 'NB' THEN 1 ELSE 0 END)																AS "NB_SAMPLES_COUNT",
	   (SELECT MIN(LQ) FROM #speechA1 WHERE BW like 'NB')															AS "NB_POLQA_MOS_MIN",
	   (SELECT master.dbo.Quantil(LQ,0.1) FROM #speechA1 WHERE BW like 'NB')										AS "NB_POLQA_MOS_PCTL_10",
	   (SELECT master.dbo.Quantil(LQ,0.2) FROM #speechA1 WHERE BW like 'NB')										AS "NB_POLQA_MOS_PCTL_20",
	   (SELECT master.dbo.Quantil(LQ,0.5) FROM #speechA1 WHERE BW like 'NB')										AS "NB_POLQA_MOS_PCTL_50",
	   1.0* SUM(CASE WHEN BW like 'NB' THEN LQ ELSE 0 END)/nullif(SUM(CASE WHEN BW like 'NB' THEN 1 ELSE 0 END),0)	AS "NB_POLQA_MOS_AVERAGE",
	   (SELECT stdev(LQ) FROM #speechA1 WHERE BW like 'NB')															AS "NB_POLQA_MOS_STDEV",
	   (SELECT master.dbo.Quantil(LQ,0.8) FROM #speechA1 WHERE BW like 'NB')										AS "NB_POLQA_MOS_PCTL_80",
	   (SELECT master.dbo.Quantil(LQ,0.9) FROM #speechA1 WHERE BW like 'NB')										AS "NB_POLQA_MOS_PCTL_90",
	   (SELECT MAX(LQ) FROM #speechA1 WHERE BW like 'NB')															AS "NB_POLQA_MOS_MAX",
	   SUM(CASE WHEN Playing_Codec like '%HR%' or [Recording Codec] like '%HR%' THEN 1 ELSE 0 END)					AS "HR_SAMPLES_COUNT",
	   (SELECT MIN(LQ) FROM #speechA1 WHERE BW like '%HR%')															AS "HR_POLQA_MOS_MIN",
	   (SELECT master.dbo.Quantil(LQ,0.1) FROM #speechA1 WHERE BW like '%HR%')										AS "HR_POLQA_MOS_PCTL_10",
	   (SELECT master.dbo.Quantil(LQ,0.2) FROM #speechA1 WHERE BW like '%HR%')										AS "HR_POLQA_MOS_PCTL_20",
	   (SELECT master.dbo.Quantil(LQ,0.5) FROM #speechA1 WHERE BW like '%HR%')										AS "HR_POLQA_MOS_PCTL_50",
	   1.0* SUM(CASE WHEN BW like 'NB' THEN LQ ELSE 0 END)/nullif(SUM(CASE WHEN BW like 'NB' THEN 1 ELSE 0 END),0)	AS "HR_POLQA_MOS_AVERAGE",
	   (SELECT stdev(LQ) FROM #speechA1 WHERE BW like '%HR%')														AS "HR_POLQA_MOS_STDEV",
	   (SELECT master.dbo.Quantil(LQ,0.8) FROM #speechA1 WHERE BW like '%HR%')										AS "HR_POLQA_MOS_PCTL_80",
	   (SELECT master.dbo.Quantil(LQ,0.9) FROM #speechA1 WHERE BW like '%HR%')										AS "HR_POLQA_MOS_PCTL_90",
	   (SELECT MAX(LQ) FROM #speechA1 WHERE BW like '%HR%')															AS "HR_POLQA_MOS_MAX"
INTO #speechA
FROM #speechA1


IF OBJECT_ID ('tempdb..#speechB1' ) IS NOT NULL
    DROP TABLE #speechB1
SELECT [SessionIdA]
      ,[SessionIdB]
      ,[direction]
      ,[LQ]
      ,[BW]
      ,[Resampling]
      ,[Playing_Technology]
      ,[Playing_Codec]
      ,[Recording Technology]
      ,[Recording Codec]
  INTO #speechB1
  FROM [NEW_SpeechQuality]
  WHERE SessionIdA in (Select SessionId_A FROM #BtoAvoice)

IF OBJECT_ID ('tempdb..#speechB' ) IS NOT NULL
    DROP TABLE #speechB
SELECT COUNT(LQ)																									AS "POLQA_MOS_SAMPLES_COUNT",
	   SUM(CASE WHEN [LQ] >= 2.7 THEN 0 ELSE 1 END)																	AS "POLQA_MOS_POOR_SAMPLES_COUNT",
	   (SELECT MIN(LQ) FROM #speechB1)																				AS "POLQA_MOS_MIN",
	   (SELECT master.dbo.Quantil(LQ,0.1) FROM #speechB1)															AS "POLQA_MOS_PCTL_10",
	   (SELECT master.dbo.Quantil(LQ,0.2) FROM #speechB1)															AS "POLQA_MOS_PCTL_20",
	   (SELECT master.dbo.Quantil(LQ,0.5) FROM #speechB1)															AS "POLQA_MOS_PCTL_50",
	   AVG(LQ)																										AS "POLQA_MOS_AVERAGE",
	   STDEV(LQ)																									AS "POLQA_MOS_STDEV",
	   (SELECT master.dbo.Quantil(LQ,0.8) FROM #speechB1)															AS "POLQA_MOS_PCTL_80",
	   (SELECT master.dbo.Quantil(LQ,0.9) FROM #speechB1)															AS "POLQA_MOS_PCTL_90",
	   (SELECT MAX(LQ) FROM #speechB1)																				AS "POLQA_MOS_MAX",
	   SUM(CASE WHEN BW like 'WB' THEN 1 ELSE 0 END)																AS "WB_SAMPLES_COUNT",
	   (SELECT MIN(LQ) FROM #speechB1 WHERE BW like 'WB')															AS "WB_POLQA_MOS_MIN",
	   (SELECT master.dbo.Quantil(LQ,0.1) FROM #speechB1 WHERE BW like 'WB')										AS "WB_POLQA_MOS_PCTL_10",
	   (SELECT master.dbo.Quantil(LQ,0.2) FROM #speechB1 WHERE BW like 'WB')										AS "WB_POLQA_MOS_PCTL_20",
	   (SELECT master.dbo.Quantil(LQ,0.5) FROM #speechB1 WHERE BW like 'WB')										AS "WB_POLQA_MOS_PCTL_50",
	   1.0* SUM(CASE WHEN BW like 'WB' THEN LQ ELSE 0 END)/nullif(SUM(CASE WHEN BW like 'WB' THEN 1 ELSE 0 END),0)	AS "WB_POLQA_MOS_AVERAGE",
	   (SELECT stdev(LQ) FROM #speechB1 WHERE BW like 'WB')															AS "WB_POLQA_MOS_STDEV",
	   (SELECT master.dbo.Quantil(LQ,0.8) FROM #speechB1 WHERE BW like 'WB')										AS "WB_POLQA_MOS_PCTL_80",
	   (SELECT master.dbo.Quantil(LQ,0.9) FROM #speechB1 WHERE BW like 'WB')										AS "WB_POLQA_MOS_PCTL_90",
	   (SELECT MAX(LQ) FROM #speechB1 WHERE BW like 'WB')															AS "WB_POLQA_MOS_MAX",
	   SUM(CASE WHEN BW like 'NB' THEN 1 ELSE 0 END)																AS "NB_SAMPLES_COUNT",
	   (SELECT MIN(LQ) FROM #speechB1 WHERE BW like 'NB')															AS "NB_POLQA_MOS_MIN",
	   (SELECT master.dbo.Quantil(LQ,0.1) FROM #speechB1 WHERE BW like 'NB')										AS "NB_POLQA_MOS_PCTL_10",
	   (SELECT master.dbo.Quantil(LQ,0.2) FROM #speechB1 WHERE BW like 'NB')										AS "NB_POLQA_MOS_PCTL_20",
	   (SELECT master.dbo.Quantil(LQ,0.5) FROM #speechB1 WHERE BW like 'NB')										AS "NB_POLQA_MOS_PCTL_50",
	   1.0* SUM(CASE WHEN BW like 'NB' THEN LQ ELSE 0 END)/nullif(SUM(CASE WHEN BW like 'NB' THEN 1 ELSE 0 END),0)	AS "NB_POLQA_MOS_AVERAGE",
	   (SELECT stdev(LQ) FROM #speechB1 WHERE BW like 'NB')															AS "NB_POLQA_MOS_STDEV",
	   (SELECT master.dbo.Quantil(LQ,0.8) FROM #speechB1 WHERE BW like 'NB')										AS "NB_POLQA_MOS_PCTL_80",
	   (SELECT master.dbo.Quantil(LQ,0.9) FROM #speechB1 WHERE BW like 'NB')										AS "NB_POLQA_MOS_PCTL_90",
	   (SELECT MAX(LQ) FROM #speechB1 WHERE BW like 'NB')															AS "NB_POLQA_MOS_MAX",
	   SUM(CASE WHEN Playing_Codec like '%HR%' or [Recording Codec] like '%HR%' THEN 1 ELSE 0 END)					AS "HR_SAMPLES_COUNT",
	   (SELECT MIN(LQ) FROM #speechB1 WHERE BW like '%HR%')															AS "HR_POLQA_MOS_MIN",
	   (SELECT master.dbo.Quantil(LQ,0.1) FROM #speechB1 WHERE BW like '%HR%')										AS "HR_POLQA_MOS_PCTL_10",
	   (SELECT master.dbo.Quantil(LQ,0.2) FROM #speechB1 WHERE BW like '%HR%')										AS "HR_POLQA_MOS_PCTL_20",
	   (SELECT master.dbo.Quantil(LQ,0.5) FROM #speechB1 WHERE BW like '%HR%')										AS "HR_POLQA_MOS_PCTL_50",
	   1.0* SUM(CASE WHEN BW like 'NB' THEN LQ ELSE 0 END)/nullif(SUM(CASE WHEN BW like 'NB' THEN 1 ELSE 0 END),0)	AS "HR_POLQA_MOS_AVERAGE",
	   (SELECT stdev(LQ) FROM #speechB1 WHERE BW like '%HR%')														AS "HR_POLQA_MOS_STDEV",
	   (SELECT master.dbo.Quantil(LQ,0.8) FROM #speechB1 WHERE BW like '%HR%')										AS "HR_POLQA_MOS_PCTL_80",
	   (SELECT master.dbo.Quantil(LQ,0.9) FROM #speechB1 WHERE BW like '%HR%')										AS "HR_POLQA_MOS_PCTL_90",
	   (SELECT MAX(LQ) FROM #speechB1 WHERE BW like '%HR%')															AS "HR_POLQA_MOS_MAX"
INTO #speechB
FROM #speechB1

-- VOICE RESULTS
IF OBJECT_ID ('tempdb..#result' ) IS NOT NULL DROP TABLE #result
SELECT   'ASide' AS Side 
		,IMSI_A AS IMSI
		,SUM(CASE WHEN Call_Status like 'Completed'		THEN 1 ELSE 0 END)																					AS CALL_COMPLETED
		,SUM(CASE WHEN Call_Status like 'Failed'		THEN 1 ELSE 0 END)																					AS CALL_FAILED
		,SUM(CASE WHEN Call_Status like 'Dropped'		THEN 1 ELSE 0 END)																					AS CALL_DROPPED
		,AVG([CST(Dial->Alerting)])																															AS CALL_SETUP_TIME_AVERAGE
		,STDEV([CST(Dial->Alerting)])																														AS CALL_SETUP_TIME_STDEV
		,1.0*SUM(CASE WHEN L1_callMode_A like '%CSFB%' THEN [CST(Dial->Alerting)] ELSE 0 END)/SUM(CASE WHEN L1_callMode_A like '%CSFB%' THEN 1 ELSE 0 END)	AS CALL_SETUP_TIME_CSFB_AVERAGE
		,(SELECT STDEV([CST(Dial->Alerting)]) FROM #AtoBvoice WHERE L1_callMode_A like '%CSFB%')															AS CALL_SETUP_TIME_CSFB_STDEV
		,(SELECT TOP 1 "POLQA_MOS_SAMPLES_COUNT"      FROM #speechA) AS "POLQA_MOS_SAMPLES_COUNT"     
		,(SELECT TOP 1 "POLQA_MOS_POOR_SAMPLES_COUNT" FROM #speechA) AS "POLQA_MOS_POOR_SAMPLES_COUNT"
		,(SELECT TOP 1 "POLQA_MOS_MIN"                FROM #speechA) AS "POLQA_MOS_MIN"               
		,(SELECT TOP 1 "POLQA_MOS_PCTL_10"            FROM #speechA) AS "POLQA_MOS_PCTL_10"           
		,(SELECT TOP 1 "POLQA_MOS_PCTL_20"            FROM #speechA) AS "POLQA_MOS_PCTL_20"           
		,(SELECT TOP 1 "POLQA_MOS_PCTL_50"            FROM #speechA) AS "POLQA_MOS_PCTL_50"           
		,(SELECT TOP 1 "POLQA_MOS_AVERAGE"            FROM #speechA) AS "POLQA_MOS_AVERAGE"  
		,(SELECT TOP 1 "POLQA_MOS_STDEV"			  FROM #speechA) AS "POLQA_MOS_STDEV"          
		,(SELECT TOP 1 "POLQA_MOS_PCTL_80"            FROM #speechA) AS "POLQA_MOS_PCTL_80"           
		,(SELECT TOP 1 "POLQA_MOS_PCTL_90"            FROM #speechA) AS "POLQA_MOS_PCTL_90"           
		,(SELECT TOP 1 "POLQA_MOS_MAX"                FROM #speechA) AS "POLQA_MOS_MAX"               
		,(SELECT TOP 1 "WB_SAMPLES_COUNT"             FROM #speechA) AS "WB_SAMPLES_COUNT"            
		,(SELECT TOP 1 "WB_POLQA_MOS_MIN"             FROM #speechA) AS "WB_POLQA_MOS_MIN"            
		,(SELECT TOP 1 "WB_POLQA_MOS_PCTL_10"         FROM #speechA) AS "WB_POLQA_MOS_PCTL_10"        
		,(SELECT TOP 1 "WB_POLQA_MOS_PCTL_20"         FROM #speechA) AS "WB_POLQA_MOS_PCTL_20"        
		,(SELECT TOP 1 "WB_POLQA_MOS_PCTL_50"         FROM #speechA) AS "WB_POLQA_MOS_PCTL_50"        
		,(SELECT TOP 1 "WB_POLQA_MOS_AVERAGE"         FROM #speechA) AS "WB_POLQA_MOS_AVERAGE"   
		,(SELECT TOP 1 "WB_POLQA_MOS_STDEV"           FROM #speechA) AS "WB_POLQA_MOS_STDEV"       
		,(SELECT TOP 1 "WB_POLQA_MOS_PCTL_80"         FROM #speechA) AS "WB_POLQA_MOS_PCTL_80"        
		,(SELECT TOP 1 "WB_POLQA_MOS_PCTL_90"         FROM #speechA) AS "WB_POLQA_MOS_PCTL_90"        
		,(SELECT TOP 1 "WB_POLQA_MOS_MAX"             FROM #speechA) AS "WB_POLQA_MOS_MAX"            
		,(SELECT TOP 1 "NB_SAMPLES_COUNT"             FROM #speechA) AS "NB_SAMPLES_COUNT"            
		,(SELECT TOP 1 "NB_POLQA_MOS_MIN"             FROM #speechA) AS "NB_POLQA_MOS_MIN"            
		,(SELECT TOP 1 "NB_POLQA_MOS_PCTL_10"         FROM #speechA) AS "NB_POLQA_MOS_PCTL_10"        
		,(SELECT TOP 1 "NB_POLQA_MOS_PCTL_20"         FROM #speechA) AS "NB_POLQA_MOS_PCTL_20"        
		,(SELECT TOP 1 "NB_POLQA_MOS_PCTL_50"         FROM #speechA) AS "NB_POLQA_MOS_PCTL_50"        
		,(SELECT TOP 1 "NB_POLQA_MOS_AVERAGE"         FROM #speechA) AS "NB_POLQA_MOS_AVERAGE"   
		,(SELECT TOP 1 "NB_POLQA_MOS_STDEV"           FROM #speechA) AS "NB_POLQA_MOS_STDEV"       
		,(SELECT TOP 1 "NB_POLQA_MOS_PCTL_80"         FROM #speechA) AS "NB_POLQA_MOS_PCTL_80"        
		,(SELECT TOP 1 "NB_POLQA_MOS_PCTL_90"         FROM #speechA) AS "NB_POLQA_MOS_PCTL_90"        
		,(SELECT TOP 1 "NB_POLQA_MOS_MAX"             FROM #speechA) AS "NB_POLQA_MOS_MAX" 
		,(SELECT TOP 1 "HR_SAMPLES_COUNT"             FROM #speechA) AS "HR_SAMPLES_COUNT" 
		,(SELECT TOP 1 "HR_POLQA_MOS_MIN"             FROM #speechA) AS "HR_POLQA_MOS_MIN"            
		,(SELECT TOP 1 "HR_POLQA_MOS_PCTL_10"         FROM #speechA) AS "HR_POLQA_MOS_PCTL_10"        
		,(SELECT TOP 1 "HR_POLQA_MOS_PCTL_20"         FROM #speechA) AS "HR_POLQA_MOS_PCTL_20"        
		,(SELECT TOP 1 "HR_POLQA_MOS_PCTL_50"         FROM #speechA) AS "HR_POLQA_MOS_PCTL_50"        
		,(SELECT TOP 1 "HR_POLQA_MOS_AVERAGE"         FROM #speechA) AS "HR_POLQA_MOS_AVERAGE"   
		,(SELECT TOP 1 "HR_POLQA_MOS_STDEV"           FROM #speechA) AS "HR_POLQA_MOS_STDEV"       
		,(SELECT TOP 1 "HR_POLQA_MOS_PCTL_80"         FROM #speechA) AS "HR_POLQA_MOS_PCTL_80"        
		,(SELECT TOP 1 "HR_POLQA_MOS_PCTL_90"         FROM #speechA) AS "HR_POLQA_MOS_PCTL_90"        
		,(SELECT TOP 1 "HR_POLQA_MOS_MAX"             FROM #speechA) AS "HR_POLQA_MOS_MAX" 
		,(SELECT TOP 1 HO_Success_Count		FROM #HOvoiceAStat WHERE KPIId like '2G-Handover%')																AS "2G HO Success Count"
		,(SELECT TOP 1 HO_Count				FROM #HOvoiceAStat WHERE KPIId like '2G-Handover%')																AS "2G HO Attempts Count"
		,(SELECT TOP 1 HO_Success_Count		FROM #HOvoiceAStat WHERE KPIId like '3G-Handover%')																AS "3G HO Success Count"
		,(SELECT TOP 1 HO_Count				FROM #HOvoiceAStat WHERE KPIId like '3G-Handover%')																AS "3G HO Attempts Count"
		,(SELECT TOP 1 HO_Success_Count		FROM #HOvoiceAStat WHERE KPIId like '4G-Handover%')																AS "4G HO Success Count"
		,(SELECT TOP 1 HO_Count				FROM #HOvoiceAStat WHERE KPIId like '4G-Handover%')																AS "4G HO Attempts Count"
		,(SELECT TOP 1 HO_Success_Count		FROM #HOvoiceAStat WHERE KPIId like '4G->3G-InterSystemHO%')													AS "4G->3G HO Success Count"
		,(SELECT TOP 1 HO_Count				FROM #HOvoiceAStat WHERE KPIId like '4G->3G-InterSystemHO%')													AS "4G->3G HO Attempts Count"
		,(SELECT TOP 1 HO_Success_Count		FROM #HOvoiceAStat WHERE KPIId like '4G->2G-InterSystemHO%')													AS "4G->2G HO Success Count"
		,(SELECT TOP 1 HO_Count				FROM #HOvoiceAStat WHERE KPIId like '4G->2G-InterSystemHO%')													AS "4G->2G HO Attempts Count"
		,(SELECT TOP 1 HO_Success_Count		FROM #HOvoiceAStat WHERE KPIId like '3G->2G-InterSystemHO%')													AS "3G->2G HO Success Count"
		,(SELECT TOP 1 HO_Count				FROM #HOvoiceAStat WHERE KPIId like '3G->2G-InterSystemHO%')													AS "3G->2G HO Attempts Count"
		,(SELECT SUM(HO_Success_Count)		FROM #HOvoiceAStat WHERE KPIId like '%InterSystemHO%')															AS "Inter System HO Success Count"
		,(SELECT SUM(HO_Count)  			FROM #HOvoiceAStat WHERE KPIId like '%InterSystemHO%')															AS "Inter System HO Attempts Count"
INTO #result
FROM #AtoBvoice
GROUP BY IMSI_A
UNION ALL
SELECT  'BSide' AS Side 
		,IMSI_B AS IMSI
		,SUM(CASE WHEN Call_Status like 'Completed'		THEN 1 ELSE 0 END)																								AS CALL_COMPLETED
		,SUM(CASE WHEN Call_Status like 'Failed'		THEN 1 ELSE 0 END)																								AS CALL_FAILED
		,SUM(CASE WHEN Call_Status like 'Dropped'		THEN 1 ELSE 0 END)																								AS CALL_DROPPED
		,AVG([CST(Dial->Alerting)])																																		AS CALL_SETUP_TIME_AVERAGE
		,STDEV([CST(Dial->Alerting)])																																	AS CALL_SETUP_TIME_STDEV
		,1.0*SUM(CASE WHEN L1_callMode_B like '%CSFB%' THEN [CST(Dial->Alerting)] ELSE 0 END)/nullif(SUM(CASE WHEN L1_callMode_B like '%CSFB%' THEN 1 ELSE 0 END),0)	AS CALL_SETUP_TIME_CSFB_AVERAGE
		,(SELECT STDEV([CST(Dial->Alerting)]) FROM #BtoAvoice WHERE L1_callMode_B like '%CSFB%')																		AS CALL_SETUP_TIME_CSFB_STDEV
	    ,(SELECT TOP 1 "POLQA_MOS_SAMPLES_COUNT"      FROM #speechB) AS "POLQA_MOS_SAMPLES_COUNT"     
	    ,(SELECT TOP 1 "POLQA_MOS_POOR_SAMPLES_COUNT" FROM #speechB) AS "POLQA_MOS_POOR_SAMPLES_COUNT"
	    ,(SELECT TOP 1 "POLQA_MOS_MIN"                FROM #speechB) AS "POLQA_MOS_MIN"               
	    ,(SELECT TOP 1 "POLQA_MOS_PCTL_10"            FROM #speechB) AS "POLQA_MOS_PCTL_10"           
	    ,(SELECT TOP 1 "POLQA_MOS_PCTL_20"            FROM #speechB) AS "POLQA_MOS_PCTL_20"           
	    ,(SELECT TOP 1 "POLQA_MOS_PCTL_50"            FROM #speechB) AS "POLQA_MOS_PCTL_50"           
	    ,(SELECT TOP 1 "POLQA_MOS_AVERAGE"            FROM #speechB) AS "POLQA_MOS_AVERAGE"
		,(SELECT TOP 1 "POLQA_MOS_STDEV"              FROM #speechB) AS "POLQA_MOS_STDEV"           
	    ,(SELECT TOP 1 "POLQA_MOS_PCTL_80"            FROM #speechB) AS "POLQA_MOS_PCTL_80"           
	    ,(SELECT TOP 1 "POLQA_MOS_PCTL_90"            FROM #speechB) AS "POLQA_MOS_PCTL_90"           
	    ,(SELECT TOP 1 "POLQA_MOS_MAX"                FROM #speechB) AS "POLQA_MOS_MAX"               
	    ,(SELECT TOP 1 "WB_SAMPLES_COUNT"             FROM #speechB) AS "WB_SAMPLES_COUNT"            
	    ,(SELECT TOP 1 "WB_POLQA_MOS_MIN"             FROM #speechB) AS "WB_POLQA_MOS_MIN"            
	    ,(SELECT TOP 1 "WB_POLQA_MOS_PCTL_10"         FROM #speechB) AS "WB_POLQA_MOS_PCTL_10"        
	    ,(SELECT TOP 1 "WB_POLQA_MOS_PCTL_20"         FROM #speechB) AS "WB_POLQA_MOS_PCTL_20"        
	    ,(SELECT TOP 1 "WB_POLQA_MOS_PCTL_50"         FROM #speechB) AS "WB_POLQA_MOS_PCTL_50"        
	    ,(SELECT TOP 1 "WB_POLQA_MOS_AVERAGE"         FROM #speechB) AS "WB_POLQA_MOS_AVERAGE"     
		,(SELECT TOP 1 "WB_POLQA_MOS_STDEV"           FROM #speechB) AS "WB_POLQA_MOS_STDEV"      
	    ,(SELECT TOP 1 "WB_POLQA_MOS_PCTL_80"         FROM #speechB) AS "WB_POLQA_MOS_PCTL_80"        
	    ,(SELECT TOP 1 "WB_POLQA_MOS_PCTL_90"         FROM #speechB) AS "WB_POLQA_MOS_PCTL_90"        
	    ,(SELECT TOP 1 "WB_POLQA_MOS_MAX"             FROM #speechB) AS "WB_POLQA_MOS_MAX"            
	    ,(SELECT TOP 1 "NB_SAMPLES_COUNT"             FROM #speechB) AS "NB_SAMPLES_COUNT"            
	    ,(SELECT TOP 1 "NB_POLQA_MOS_MIN"             FROM #speechB) AS "NB_POLQA_MOS_MIN"            
	    ,(SELECT TOP 1 "NB_POLQA_MOS_PCTL_10"         FROM #speechB) AS "NB_POLQA_MOS_PCTL_10"        
	    ,(SELECT TOP 1 "NB_POLQA_MOS_PCTL_20"         FROM #speechB) AS "NB_POLQA_MOS_PCTL_20"        
	    ,(SELECT TOP 1 "NB_POLQA_MOS_PCTL_50"         FROM #speechB) AS "NB_POLQA_MOS_PCTL_50"        
	    ,(SELECT TOP 1 "NB_POLQA_MOS_AVERAGE"         FROM #speechB) AS "NB_POLQA_MOS_AVERAGE"   
		,(SELECT TOP 1 "NB_POLQA_MOS_STDEV"           FROM #speechB) AS "NB_POLQA_MOS_STDEV"      
	    ,(SELECT TOP 1 "NB_POLQA_MOS_PCTL_80"         FROM #speechB) AS "NB_POLQA_MOS_PCTL_80"        
	    ,(SELECT TOP 1 "NB_POLQA_MOS_PCTL_90"         FROM #speechB) AS "NB_POLQA_MOS_PCTL_90"        
	    ,(SELECT TOP 1 "NB_POLQA_MOS_MAX"             FROM #speechB) AS "NB_POLQA_MOS_MAX"
		,(SELECT TOP 1 "HR_SAMPLES_COUNT"             FROM #speechB) AS "HR_SAMPLES_COUNT" 
		,(SELECT TOP 1 "HR_POLQA_MOS_MIN"             FROM #speechB) AS "HR_POLQA_MOS_MIN"            
		,(SELECT TOP 1 "HR_POLQA_MOS_PCTL_10"         FROM #speechB) AS "HR_POLQA_MOS_PCTL_10"        
		,(SELECT TOP 1 "HR_POLQA_MOS_PCTL_20"         FROM #speechB) AS "HR_POLQA_MOS_PCTL_20"        
		,(SELECT TOP 1 "HR_POLQA_MOS_PCTL_50"         FROM #speechB) AS "HR_POLQA_MOS_PCTL_50"        
		,(SELECT TOP 1 "HR_POLQA_MOS_AVERAGE"         FROM #speechB) AS "HR_POLQA_MOS_AVERAGE"   
		,(SELECT TOP 1 "HR_POLQA_MOS_STDEV"           FROM #speechB) AS "HR_POLQA_MOS_STDEV"       
		,(SELECT TOP 1 "HR_POLQA_MOS_PCTL_80"         FROM #speechB) AS "HR_POLQA_MOS_PCTL_80"        
		,(SELECT TOP 1 "HR_POLQA_MOS_PCTL_90"         FROM #speechB) AS "HR_POLQA_MOS_PCTL_90"        
		,(SELECT TOP 1 "HR_POLQA_MOS_MAX"             FROM #speechB) AS "HR_POLQA_MOS_MAX"   
		,(SELECT TOP 1 HO_Success_Count		FROM #HOvoiceBStat WHERE KPIId like '2G-Handover%')																AS "2G HO Success Count"
		,(SELECT TOP 1 HO_Count				FROM #HOvoiceBStat WHERE KPIId like '2G-Handover%')																AS "2G HO Attempts Count"
		,(SELECT TOP 1 HO_Success_Count		FROM #HOvoiceBStat WHERE KPIId like '3G-Handover%')																AS "3G HO Success Count"
		,(SELECT TOP 1 HO_Count				FROM #HOvoiceBStat WHERE KPIId like '3G-Handover%')																AS "3G HO Attempts Count"
		,(SELECT TOP 1 HO_Success_Count		FROM #HOvoiceBStat WHERE KPIId like '4G-Handover%')																AS "4G HO Success Count"
		,(SELECT TOP 1 HO_Count				FROM #HOvoiceBStat WHERE KPIId like '4G-Handover%')																AS "4G HO Attempts Count"
		,(SELECT TOP 1 HO_Success_Count		FROM #HOvoiceBStat WHERE KPIId like '4G->3G-InterSystemHO%')													AS "4G->3G HO Success Count"
		,(SELECT TOP 1 HO_Count				FROM #HOvoiceBStat WHERE KPIId like '4G->3G-InterSystemHO%')													AS "4G->3G HO Attempts Count"
		,(SELECT TOP 1 HO_Success_Count		FROM #HOvoiceBStat WHERE KPIId like '4G->2G-InterSystemHO%')													AS "4G->2G HO Success Count"
		,(SELECT TOP 1 HO_Count				FROM #HOvoiceBStat WHERE KPIId like '4G->2G-InterSystemHO%')													AS "4G->2G HO Attempts Count"
		,(SELECT TOP 1 HO_Success_Count		FROM #HOvoiceBStat WHERE KPIId like '3G->2G-InterSystemHO%')													AS "3G->2G HO Success Count"
		,(SELECT TOP 1 HO_Count				FROM #HOvoiceBStat WHERE KPIId like '3G->2G-InterSystemHO%')													AS "3G->2G HO Attempts Count"
		,(SELECT SUM(HO_Success_Count)		FROM #HOvoiceBStat WHERE KPIId like '%InterSystemHO%')															AS "Inter System HO Success Count"
		,(SELECT SUM(HO_Count)  			FROM #HOvoiceBStat WHERE KPIId like '%InterSystemHO%')															AS "Inter System HO Attempts Count"
FROM #BtoAvoice
GROUP BY IMSI_B

SELECT 
 [Side]
,[IMSI]
,[CALL_ATTEMPTS]
,[CALL_COMPLETED]
,[CALL_FAILED]
,[CALL_DROPPED]
,[CALL_SETUP_FAILURE_RATE]
,1.96*(SQRT([CALL_SETUP_FAILURE_RATE]*(1- [CALL_SETUP_FAILURE_RATE]) / nullif([CALL_ATTEMPTS],0))) AS CALL_SETUP_FAILURE_RATE_95CI
,[CALL_DROP_RATE]
,1.96*(SQRT([CALL_DROP_RATE]*(1- [CALL_DROP_RATE]) / [CALL_ATTEMPTS])) AS CALL_DROP_RATE_95CI
,[CALL_SETUP_TIME_AVERAGE]
,1.96*[CALL_SETUP_TIME_STDEV] / nullif(SQRT([CALL_ATTEMPTS]),0) AS [CALL_SETUP_TIME_AVERAGE_95CI]
,[CALL_SETUP_TIME_CSFB_AVERAGE]
,1.96*[CALL_SETUP_TIME_CSFB_AVERAGE] / nullif(SQRT([CALL_ATTEMPTS]),0) AS [CALL_SETUP_TIME_CSFB_AVERAGE_95CI]
,[POLQA_MOS_SAMPLES_COUNT]
,[POLQA_MOS_POOR_SAMPLES_COUNT]
,[POLQA_MOS_POOR_SAMPLES_RATIO]
,1.96*(SQRT([POLQA_MOS_POOR_SAMPLES_RATIO]*(1- [POLQA_MOS_POOR_SAMPLES_RATIO]) / [POLQA_MOS_SAMPLES_COUNT])) AS [POLQA_MOS_POOR_SAMPLES_RATIO_95CI]
,[POLQA_MOS_MIN]
,[POLQA_MOS_PCTL_10]
,[POLQA_MOS_PCTL_20]
,[POLQA_MOS_PCTL_50]
,[POLQA_MOS_AVERAGE]
,1.96*[POLQA_MOS_STDEV] / nullif(SQRT([POLQA_MOS_SAMPLES_COUNT]),0) AS [POLQA_MOS_AVERAGE_95CI]
,[POLQA_MOS_PCTL_80]
,[POLQA_MOS_PCTL_90]
,[POLQA_MOS_MAX]
,[WB_SAMPLES_COUNT]
,[WB_SAMPLES_RATIO]
,1.96*(SQRT([WB_SAMPLES_RATIO]*(1- [WB_SAMPLES_RATIO]) / [POLQA_MOS_SAMPLES_COUNT])) AS WB_SAMPLES_RATIO_95CI
,[WB_POLQA_MOS_MIN]
,[WB_POLQA_MOS_PCTL_10]
,[WB_POLQA_MOS_PCTL_20]
,[WB_POLQA_MOS_PCTL_50]
,[WB_POLQA_MOS_AVERAGE]
,1.96*[WB_POLQA_MOS_STDEV] / nullif(SQRT([WB_SAMPLES_COUNT]),0) AS [WB_POLQA_MOS_AVERAGE_95CI]
,[WB_POLQA_MOS_PCTL_80]
,[WB_POLQA_MOS_PCTL_90]
,[WB_POLQA_MOS_MAX]
,[NB_SAMPLES_COUNT]
,[NB_SAMPLES_RATIO]
,1.96*(SQRT([NB_SAMPLES_RATIO]*(1- [NB_SAMPLES_RATIO]) / [POLQA_MOS_SAMPLES_COUNT])) AS NB_SAMPLES_RATIO_95CI
,[NB_POLQA_MOS_MIN]
,[NB_POLQA_MOS_PCTL_10]
,[NB_POLQA_MOS_PCTL_20]
,[NB_POLQA_MOS_PCTL_50]
,[NB_POLQA_MOS_AVERAGE]
,1.96*[NB_POLQA_MOS_STDEV]/ nullif(SQRT([NB_SAMPLES_COUNT]),0) AS [NB_POLQA_MOS_AVERAGE_95CI]
,[NB_POLQA_MOS_PCTL_80]
,[NB_POLQA_MOS_PCTL_90]
,[NB_POLQA_MOS_MAX]
,[HR_SAMPLES_COUNT]
,[HR_SAMPLES_RATIO]
,1.96*(SQRT([HR_SAMPLES_RATIO]*(1- [HR_SAMPLES_RATIO]) / [POLQA_MOS_SAMPLES_COUNT])) AS HR_SAMPLES_RATIO_95CI
,[HR_POLQA_MOS_MIN]
,[HR_POLQA_MOS_PCTL_10]
,[HR_POLQA_MOS_PCTL_20]
,[HR_POLQA_MOS_PCTL_50]
,[HR_POLQA_MOS_AVERAGE]
,1.96*[HR_POLQA_MOS_STDEV]/ nullif(SQRT([HR_SAMPLES_COUNT]),0) AS [HR_POLQA_MOS_AVERAGE_95CI]
,[HR_POLQA_MOS_PCTL_80]
,[HR_POLQA_MOS_PCTL_90]
,[HR_POLQA_MOS_MAX]
,[2G HO Success Count]
,[2G HO Attempts Count]
,[3G HO Success Count]
,[3G HO Attempts Count]
,[4G HO Success Count]
,[4G HO Attempts Count]
,[4G->3G HO Success Count]
,[4G->3G HO Attempts Count]
,[4G->2G HO Success Count]
,[4G->2G HO Attempts Count]
,[3G->2G HO Success Count]
,[3G->2G HO Attempts Count]
,[Inter System HO Success Count]
,[Inter System HO Attempts Count]
,[Inter System HO Success Rate]
,1.96*(SQRT([Inter System HO Success Rate]*(1- [Inter System HO Success Rate]) / [Inter System HO Attempts Count])) AS [Inter System HO Success Rate 95 CI]
FROM 
(select  [Side]
	,[IMSI]
	,([CALL_COMPLETED]+[CALL_FAILED]+[CALL_DROPPED]) AS CALL_ATTEMPTS
	,[CALL_COMPLETED]
	,[CALL_FAILED]
	,[CALL_DROPPED]
	,1.0*[CALL_FAILED]/([CALL_COMPLETED]+[CALL_FAILED]+[CALL_DROPPED]) AS CALL_SETUP_FAILURE_RATE
	,1.0*[CALL_DROPPED]/([CALL_COMPLETED]+[CALL_DROPPED]) AS CALL_DROP_RATE
	,[CALL_SETUP_TIME_AVERAGE]
	,[CALL_SETUP_TIME_STDEV]
	,[CALL_SETUP_TIME_CSFB_AVERAGE]
	,[CALL_SETUP_TIME_CSFB_STDEV]
	,[POLQA_MOS_SAMPLES_COUNT]
	,[POLQA_MOS_POOR_SAMPLES_COUNT]
	,1.0*[POLQA_MOS_POOR_SAMPLES_COUNT]/nullif([POLQA_MOS_SAMPLES_COUNT],0) AS [POLQA_MOS_POOR_SAMPLES_RATIO]
	,[POLQA_MOS_MIN]
	,[POLQA_MOS_PCTL_10]
	,[POLQA_MOS_PCTL_20]
	,[POLQA_MOS_PCTL_50]
	,[POLQA_MOS_AVERAGE]
	,[POLQA_MOS_STDEV]
	,[POLQA_MOS_PCTL_80]
	,[POLQA_MOS_PCTL_90]
	,[POLQA_MOS_MAX]
	,[WB_SAMPLES_COUNT]
	,1.0*[WB_SAMPLES_COUNT]/nullif([POLQA_MOS_SAMPLES_COUNT],0) AS WB_SAMPLES_RATIO
	,[WB_POLQA_MOS_MIN]
	,[WB_POLQA_MOS_PCTL_10]
	,[WB_POLQA_MOS_PCTL_20]
	,[WB_POLQA_MOS_PCTL_50]
	,[WB_POLQA_MOS_AVERAGE]
	,[WB_POLQA_MOS_STDEV]
	,[WB_POLQA_MOS_PCTL_80]
	,[WB_POLQA_MOS_PCTL_90]
	,[WB_POLQA_MOS_MAX]
	,[NB_SAMPLES_COUNT]
	,1.0*[NB_SAMPLES_COUNT]/nullif([POLQA_MOS_SAMPLES_COUNT],0) AS NB_SAMPLES_RATIO
	,[NB_POLQA_MOS_MIN]
	,[NB_POLQA_MOS_PCTL_10]
	,[NB_POLQA_MOS_PCTL_20]
	,[NB_POLQA_MOS_PCTL_50]
	,[NB_POLQA_MOS_AVERAGE]
	,[NB_POLQA_MOS_STDEV]
	,[NB_POLQA_MOS_PCTL_80]
	,[NB_POLQA_MOS_PCTL_90]
	,[NB_POLQA_MOS_MAX]
	,[HR_SAMPLES_COUNT]
	,1.0*[HR_SAMPLES_COUNT]/nullif([POLQA_MOS_SAMPLES_COUNT],0) AS HR_SAMPLES_RATIO
	,[HR_POLQA_MOS_MIN]
	,[HR_POLQA_MOS_PCTL_10]
	,[HR_POLQA_MOS_PCTL_20]
	,[HR_POLQA_MOS_PCTL_50]
	,[HR_POLQA_MOS_AVERAGE]
	,[HR_POLQA_MOS_STDEV]
	,[HR_POLQA_MOS_PCTL_80]
	,[HR_POLQA_MOS_PCTL_90]
	,[HR_POLQA_MOS_MAX]
	,[2G HO Success Count]
	,[2G HO Attempts Count]
	,[3G HO Success Count]
	,[3G HO Attempts Count]
	,[4G HO Success Count]
	,[4G HO Attempts Count]
	,[4G->3G HO Success Count]
	,[4G->3G HO Attempts Count]
	,[4G->2G HO Success Count]
	,[4G->2G HO Attempts Count]
	,[3G->2G HO Success Count]
	,[3G->2G HO Attempts Count]
	,[Inter System HO Success Count]
	,[Inter System HO Attempts Count]
	,1.0*[Inter System HO Success Count]/nullif([Inter System HO Attempts Count],0) AS [Inter System HO Success Rate]
 from #result) AS A

-- POLQA distribution Playing side
SELECT 'ASide_POLQA_DISTRIBUTION' AS Side,* FROM
	(SELECT [Playing_Codec] as Codec,LQ,COUNT(LQ) As SamplesCount
	FROM
		(SELECT [SessionIdA]
			  ,[SessionIdB]
			  ,[direction]
			  ,0.1*CAST(10 * [LQ] as int) AS LQ
			  ,[BW]
			  ,[Resampling]
			  ,[Playing_Technology]
			  ,[Playing_Codec]
			  ,[Recording Technology]
			  ,[Recording Codec]
		  FROM [NEW_SpeechQuality]
		  WHERE SessionIdA in (Select SessionId_A FROM #AtoBvoice)) AS T
	  WHERE LQ is not null
	  GROUP BY [Playing_Codec],LQ) AS Q
PIVOT(AVG(SamplesCount)
	FOR LQ IN ([1.0],[1.1],[1.2],[1.3],[1.4],[1.5],[1.6],[1.7],[1.8],[1.9],
			   [2.0],[2.1],[2.2],[2.3],[2.4],[2.5],[2.6],[2.7],[2.8],[2.9],
			   [3.0],[3.1],[3.2],[3.3],[3.4],[3.5],[3.6],[3.7],[3.8],[3.9],
			   [4.0],[4.1],[4.2],[4.3],[4.4],[4.5],[4.6],[4.7],[4.8],[4.9]) ) AS SampleA
UNION ALL
SELECT 'BSide_POLQA_DISTRIBUTION' As Side,* FROM
	(SELECT [Playing_Codec] AS Codec,LQ,COUNT(LQ) As SamplesCount
	FROM
		(SELECT [SessionIdA]
			  ,[SessionIdB]
			  ,[direction]
			  ,0.1*CAST(10 * [LQ] as int) AS LQ
			  ,[BW]
			  ,[Resampling]
			  ,[Playing_Technology]
			  ,[Playing_Codec]
			  ,[Recording Technology]
			  ,[Recording Codec]
		  FROM [NEW_SpeechQuality]
		  WHERE SessionIdA in (Select SessionId_A FROM #BtoAvoice)) AS T
	  WHERE LQ is not null
	  GROUP BY [Playing_Codec],LQ) AS Q
PIVOT(AVG(SamplesCount)
	FOR LQ IN ([1.0],[1.1],[1.2],[1.3],[1.4],[1.5],[1.6],[1.7],[1.8],[1.9],
			   [2.0],[2.1],[2.2],[2.3],[2.4],[2.5],[2.6],[2.7],[2.8],[2.9],
			   [3.0],[3.1],[3.2],[3.3],[3.4],[3.5],[3.6],[3.7],[3.8],[3.9],
			   [4.0],[4.1],[4.2],[4.3],[4.4],[4.5],[4.6],[4.7],[4.8],[4.9]) ) AS SampleB

