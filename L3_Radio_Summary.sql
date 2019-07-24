DECLARE @SESS_A bigint = 42471;
DECLARE @SESS_B bigint;
DECLARE @SESS_Start datetime2(3);
DECLARE @SESS_Stop datetime2(3);

SET @SESS_B = (SELECT [SessionidB]
				FROM [Burda_Voice_2015].[dbo].[NC_Calls_Distinct]
				WHERE Session_Type LIKE 'CALL' AND SessionId = @SESS_A)
				
SET @SESS_Start = (SELECT [Call_Start_Time_Stamp]
				FROM [Burda_Voice_2015].[dbo].[NC_Calls_Distinct]
				WHERE Session_Type LIKE 'CALL' AND SessionId = @SESS_A)
				
SET @SESS_Stop = (SELECT [Call_End_Time_Stamp]
				FROM [Burda_Voice_2015].[dbo].[NC_Calls_Distinct]
				WHERE Session_Type LIKE 'CALL' AND SessionId = @SESS_A)
				
-- Select General Information About Session
SELECT [valid]
      ,[InvalidReason]
      ,[Channel]
      ,[Operator]
      ,[SessionId]
      ,[SessionidB]
      ,[FileId]
      -- Call Timestamps
      ,[Call_Start_Time_Stamp]
      ,[Call_End_Time_Stamp]
      -- Disconnect Info
      ,[Disconnect_Class]
      ,[Disconnect_Cause]
      ,[Disconnect_Location]
      -- Call Information
      ,[Session_Type]
      ,[Call_Type]
      ,[Call_Status]
      ,[Call_Status_Extend]
      ,[Call_Mode_A]
      ,[Call_Mode_B]
      -- Flags
      ,[Silence_Call]
      ,[Bad_Speech_Call]
      ,[Error_Cause]
      ,[Error_Description]
      -- Where I Enter Data
      ,[Personal_Analysis_Cause]
      ,[Personal_Analysis_Description]
      -- Mapping Info
      ,[Rural/Urban]
      ,[Modul]
      ,[Location]
      ,[Location_Detail]
      ,[Drive/Walk]
      ,[Latitude]
      ,[Longitude]
      ,[SpeedAvg]
      ,[SpeedCategory]
      -- Technology Information
      ,[Session_Start_Technology_A-Side]
      ,[Session_Start_Technology_B-Side]
      ,[Call_Start_Technology_A-Side]
      ,[Call_Start_Technology_B-Side]
      ,[TEC]
      ,[TEC_Detail]
      ,[TIME_GSM_900]
      ,[TIME_GSM_1800]
      ,[TIME_UMTS_900]
      ,[TIME_UMTS_2100]
      ,[TIME_LTE_E_UTRA_1]
      ,[TIME_LTE_E_UTRA_3]
      ,[TIME_LTE_E_UTRA_7]
      ,[TIME_LTE_E_UTRA_10]
      ,[TIME_LTE_E_UTRA_20]
      ,[TIME_No_Service]
      ,[TIME_Emergency_calls_only]
      ,[Technology_Duration]
      ,[TEC B]
      ,[TEC_Detail B]
      ,[Year]
      ,[Week]
      ,[Month]
      ,[Day]
      ,[Hour]
      ,[ChannelRequest_RRCConncetionRequest_TimeStamp]
      ,[EMM-Extended_Service_Request_TimeStamp]
      ,[CMServiceRequest_MOC_TimeStamp]
      ,[Setup_TimeStamp_A]
      ,[Alerting_MOC_TimeStamp]
      ,[Connect_Timestamp]
      ,[ConnectAcknowledge_TimeStamp]
      ,[Connect_Timestamp_B]
      ,[CC_Disconnect_TimeStamp]
      ,[callDisconnectTimeStamp]
      ,[SQ_Post_Dial_Delay]
      ,[SQ_Setup_Time_Dial_Connect]
      ,[Time_MOC_Dail_CMServiceREquest]
      ,[Time_MOC_CMServiceREquest_Alerting]
      ,[Time_MOC_Alerting_Connect]
      ,[Time_MOC_Dail_Alerting]
      ,[Time_MOC_Dial_Connect]
      ,[SQ_Call_Duration]
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
      ,[Anzahl_Samples<2.0]
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
      ,[KPIId_10170_Time_LTE_CSFB_RRCConnectionRequest_mo_Data_Alerting]
      ,[KPIId_10175_Time_LTE_CSFB_EMM_ExtendedServiceRequest_RRCConnectionRequest]
      ,[KPIId_10178_Time_LTE_CSFB_EMM_ExtendedServiceRequest_Alerting]
      ,[KPIId_10180_Time_LTE_CSFB_RRCConnectionReleaseWithRedirectedCarrierInfo_SystemInformationBCH]
      ,[UE]
      ,[IMEI]
      ,[IMSI]
      ,[Dialnumber]
      -- Cell Information
      ,[code]
      ,[MCC]
      ,[MNC]
      ,[LAC]
      ,[CellID]
      ,[BCCH]
      ,[SC1]
      ,[SC2]
      ,[SC3]
      ,[BSIC]
  FROM [Burda_Voice_2015].[dbo].[NC_Calls_Distinct]
  WHERE Session_Type LIKE 'CALL' AND SessionId = @SESS_A

-- Radio Conditions Side B
SELECT
	a.SessionId as sessID
	,a.TestId
	,a.MsgTime as mtime
	,a.Tec as mtech
	,'Radio' as mtype
	,'-' as Channel
	,'-' as Direction
		,'-' AS ISUP
	,'-' as Msg
	,Empfangspegel as Str_Param
	,Empfangsqualität as Qua_Param
	,CASE
		WHEN (a.MsgTime > @SESS_Start AND a.MsgTime < @SESS_Stop) THEN 'IN_TEST'
		ELSE '-'
	END AS Validity
	FROM [Burda_Voice_2015].[dbo].[NC_RADIO] a
	WHERE (a.SessionId like @SESS_A OR a.SessionId like @SESS_B)
UNION
SELECT
	b.SessionID as sessID
	,b.TestID
	,b.MSgTime as mtime 
	,b.TEC as mtech
	,Layer  as mtype
	,Channel
	,Direction
	,CASE
		WHEN (Layer LIKE 'CC') THEN Msg
		ELSE '-'
	END AS ISUP
	,Msg
	,'' as Str_Param
	,'' as Qua_Param
	,CASE
		WHEN (b.MsgTime > @SESS_Start AND b.MsgTime < @SESS_Stop) THEN 'IN_TEST'
		ELSE '-'
	END AS Validity
	FROM [Burda_Voice_2015].[dbo].[NC_Layer3] b
	WHERE (b.SessionId like @SESS_A OR b.SessionId like @SESS_B)
ORDER BY sessID, mtime