-- CREATE SRVCC TABLE LIST
IF OBJECT_ID ('tempdb..#SRVCCMarkers' ) IS NOT NULL
              DROP TABLE #SRVCCMarkers
select	 a.SessionId	
	    ,b.Home_Operator_A	as Operator
		,a.KPIId
		,a.StartTime
		,a.EndTime
		,a.Duration		as "ExecTime [ms]"
		,a.ErrorCode
		,a.Value3
		,a.Value4
  INTO  #SRVCCMarkers
  from	ResultsKPI a
  join NEW_CDR b on a.SessionId = b.[SessionID_A] OR a.SessionId = b.[SessionID_B]
  where kpiid= 38040

-- SRVCC Statistics
SELECT Operator,
	   CASE ErrorCode
		WHEN 0 THEN 'SUCCESS'
		WHEN 108003 THEN 'FAILED'
		END AS SRVCC_RESULT,
	   COUNT(Value3) AS SAMPLES_COUNT,
	   AVG("ExecTime [ms]") AS "AvgExecTime [ms]",
	   MIN("ExecTime [ms]") AS "MinExecTime [ms]",
	   MAX("ExecTime [ms]") AS "MaxExecTime [ms]"
FROM  #SRVCCMarkers 
GROUP BY Operator,ErrorCode 
ORDER BY Operator,ErrorCode