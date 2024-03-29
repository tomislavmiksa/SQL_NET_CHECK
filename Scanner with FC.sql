declare @SessionIdentity int = 1024

-- TABLE with list of channels for LTE in Germany
declare @LTEChannel table (Operator varchar(100),Channel int)
insert into @LTEChannel values ('o2',6200)
insert into @LTEChannel values ('o2',3350)
insert into @LTEChannel values ('Telekom',6400)
insert into @LTEChannel values ('Telekom',1275)
insert into @LTEChannel values ('Telekom',1300)
insert into @LTEChannel values ('Telekom',3050)
insert into @LTEChannel values ('Vodafone',6300)
insert into @LTEChannel values ('Vodafone',2850)

-- TABLE with list of channels for UMTS in Germany
declare @UMTSChannel table (Operator varchar(100),Channel int,Frequency varchar(2))
insert into @UMTSChannel values ('o2',10738,'f1')
insert into @UMTSChannel values ('o2',10786,'f2')
insert into @UMTSChannel values ('o2',10762,'f3')
insert into @UMTSChannel values ('Telekom',10812,'f1')
insert into @UMTSChannel values ('Telekom',10836,'f2')
insert into @UMTSChannel values ('Vodafone',10564,'f1')
insert into @UMTSChannel values ('Vodafone',10588,'f2')
insert into @UMTSChannel values ('Vodafone',10612,'f3')
insert into @UMTSChannel values ('EPlus',10712,'f1')
insert into @UMTSChannel values ('EPlus',10639,'f2')
insert into @UMTSChannel values ('EPlus',10663,'f3')
insert into @UMTSChannel values ('EPlus',10687,'f4')

-- TABLE with list of channels for UMTS in Germany
declare @GSMChannel table (Operator varchar(100),ARFCN_Start int,ARFCN_End int,Band varchar(10))
insert into @GSMChannel values ('Telekom',14,49,'GSM 900')
insert into @GSMChannel values ('Telekom',82,102,'GSM 900')
insert into @GSMChannel values ('Telekom',123,124,'GSM 900')
insert into @GSMChannel values ('Telekom',512,610,'GSM 1800')
insert into @GSMChannel values ('Vodafone',1,12,'GSM 900')
insert into @GSMChannel values ('Vodafone',50,80,'GSM 900')
insert into @GSMChannel values ('Vodafone',103,121,'GSM 900')
insert into @GSMChannel values ('Vodafone',725,751,'GSM 1800')
insert into @GSMChannel values ('EPlus',777,863,'GSM 1800')
insert into @GSMChannel values ('EPlus',975,999,'GSM 900')
insert into @GSMChannel values ('EPlus',611,636,'GSM 1800')
insert into @GSMChannel values ('EPlus',752,776,'GSM 1800')
insert into @GSMChannel values ('o2',0,0,'GSM 900')
insert into @GSMChannel values ('o2',637,723,'GSM 1800')
insert into @GSMChannel values ('o2',1000,1023,'GSM 900')

declare @SessionInformation table (  Tab_sessionType               varchar(15)
									,Tab_Operator				   varchar(15)
									,Tab_SessionId				   int
									,Tab_SessionIdB				   int
									,Tab_UE						   varchar(30)
									,Tab_IMEI					   varchar(30)
									,Tab_IMSI                      varchar(30)
									,Tab_Dialnumber                varchar(30)
									,Tab_City_None_City            varchar(30)
									,Tab_Modul                     varchar(30)
									,Tab_Location                  varchar(30)
									,Tab_Drive_Walk                varchar(30)
									,Tab_Call_Status               varchar(30)
									,Tab_startTime                 datetime2(3)
									,Tab_endTime                   datetime2(3)
									,Tab_Call_Start_Time_Stamp     datetime2(3)
									,Tab_Call_End_Time_Stamp       datetime2(3)) 
INSERT INTO @SessionInformation (Tab_sessionType ,Tab_Operator,Tab_SessionId ,Tab_SessionIdB ,Tab_UE ,Tab_IMEI ,Tab_IMSI ,Tab_Dialnumber ,Tab_City_None_City ,Tab_Modul ,Tab_Location ,Tab_Drive_Walk ,Tab_Call_Status ,Tab_startTime ,Tab_endTime ,Tab_Call_Start_Time_Stamp ,Tab_Call_End_Time_Stamp)

SELECT a.[sessionType]
	  ,b.[Operator]
      ,b.[SessionId]
      ,b.[SessionIdB]
      ,b.[UE]
      ,b.[IMEI]
      ,b.[IMSI]
      ,b.[Dialnumber]
      ,b.[City/None_City]
      ,b.[Modul]
      ,b.[Location]
      ,b.[Drive/Walk]
      ,b.[Call_Status]
      ,a.[startTime]
	  ,DATEADD(ms,a.duration,a.[startTime]) as endTime
      ,b.[Call_Start_Time_Stamp]
      ,b.[Call_End_Time_Stamp]
  FROM [o2_Voice_2016_Q3_VoLTE].[dbo].[Sessions] a
  LEFT OUTER JOIN [o2_Voice_2016_Q3_VoLTE].[dbo].[NC_Calls_Distinct] b
	ON a.[SessionId] = b.[SessionId]
  WHERE b.SessionId = @SessionIdentity
  ORDER BY a.SessionId

SELECT * FROM  @SessionInformation

-- LTE SCANNER FOR THE SESSION
SELECT a.[MsgTime]
	  ,b.longitude
	  ,b.latitude
	  ,(SELECT TOP 1 Operator FROM @LTEChannel WHERE a.[Channel] = Channel) as Operator_CH
      ,CASE a.[RFBand]
			WHEN 'LTE E-UTRA 7' THEN 'LTE-2600'
			WHEN 'LTE E-UTRA 3' THEN 'LTE-1800'
			WHEN 'LTE E-UTRA 20' THEN 'LTE-800'
			ELSE '-'
		END AS LTE_BAND
      ,a.[Bandwidth]
      ,a.[Channel]
      ,a.[PhCId] as PCI
      ,a.[RSRP]
      ,a.[RSRQ]
      ,a.[CINR] as SINR
  FROM [o2_Scanner_2016_Q3].[dbo].[NC_Scanner_RawData_LTE] a
  LEFT OUTER JOIN [o2_Scanner_2016_Q3].[dbo].[Position] b
    ON a.PosId=b.PosId
  WHERE SysId = 'System 23881' 
			and a.[MsgTime] > (SELECT TOP 1 Tab_startTime FROM @SessionInformation) 
			and a.[MsgTime] < (SELECT TOP 1 Tab_endTime FROM @SessionInformation)
			and (SELECT TOP 1 Operator FROM @LTEChannel WHERE a.[Channel] = Channel) = (SELECT TOP 1 Tab_Operator FROM @SessionInformation)
  Order BY MsgTime  ASC, RSRP DESC

-- UMTS SCANNER FOR THE SESSION
  SELECT TOP 1000  a.[MsgTime]
	   ,b.longitude
	   ,b.latitude
	   ,(SELECT TOP 1 Operator FROM @UMTSChannel WHERE Channel = a.[Channel]) as Operator_CH
       ,a.[Channel] AS DL_UARFCN
       ,a.[PSC]
       ,a.[RSCP]
       ,a.[Ec/No]
  FROM [o2_Scanner_2016_Q3].[dbo].[NC_Scanner_RawData_WCDMA] a
  LEFT OUTER JOIN [o2_Scanner_2016_Q3].[dbo].[Position] b
    ON a.PosId=b.PosId
  WHERE SysId = 'System 23881' 
			and a.[MsgTime] > (SELECT TOP 1 Tab_startTime FROM @SessionInformation) 
			and a.[MsgTime] < (SELECT TOP 1 Tab_endTime FROM @SessionInformation)
			and (SELECT TOP 1 Operator FROM @UMTSChannel WHERE a.[Channel] = Channel) = (SELECT TOP 1 Tab_Operator FROM @SessionInformation)
  Order BY MsgTime  ASC, RSCP DESC

-- GSM SCANNER FOR THE SESSION
SELECT a.[MsgTime]
	  ,b.longitude
	  ,b.latitude
	  ,(SELECT TOP 1 Operator FROM @GSMChannel WHERE ARFCN_Start <= a.[Channel] and ARFCN_End >= a.[Channel]) as Operator_CH
	  ,(SELECT TOP 1 Band FROM @GSMChannel WHERE ARFCN_Start <= a.[Channel] and ARFCN_End >= a.[Channel]) as GSM_BAND
      ,a.[Channel]
      ,a.[RxLev]
      ,a.[CoverI]
  FROM [o2_Scanner_2016_Q3].[dbo].[NC_Scanner_RawData_GSM] a
  LEFT OUTER JOIN [o2_Scanner_2016_Q3].[dbo].[Position] b
    ON a.PosId=b.PosId
  WHERE SysId = 'System 23881' 
			and a.[MsgTime] > (SELECT TOP 1 Tab_startTime FROM @SessionInformation) 
			and a.[MsgTime] < (SELECT TOP 1 Tab_endTime FROM @SessionInformation)
			and (SELECT TOP 1 Operator FROM @GSMChannel WHERE ARFCN_Start <= a.[Channel] and ARFCN_End >= a.[Channel]) = (SELECT TOP 1 Tab_Operator FROM @SessionInformation)