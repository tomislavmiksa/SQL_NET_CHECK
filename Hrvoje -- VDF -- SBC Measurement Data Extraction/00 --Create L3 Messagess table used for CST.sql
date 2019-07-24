-------------------------------------------------------------------------------------------
-- Creat: AN_Layer 3 Table
-- Contains all 
-- GSM Layer3 (vMsgGsmL3Data), 
-- WCDMA RRC, 
-- LTE RRC, LTE NAS Messages, 
-- IMS SIP Messages 
--
-- ACHTUNG, auf neuer Datenbank müssen auch die Views erstellen !!!
--
-- 	
--
--
--
-- (c) Andreas Nagorsen 2015
-------------------------------------------------------------------------------------------
-- select * from an_layer3 ORDER BY MsgTime
-------------------------------------------------------------------------------------------
--	CREATE TABLE, Nur ausführen, wenn sich was geändert hat
-------------------------------------------------------------------------------------------

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF object_id(N'AN_Layer3') IS NOT NULL	DROP TABLE AN_Layer3
GO 
CREATE TABLE [dbo].[AN_Layer3](
	[FileId] bigint NULL,
	[Source] [varchar](50) NOT NULL,
	[SourceMsgId] [bigint] NOT NULL,
	[MsgTime] [datetime2](3) NULL,
	[SessionId] [bigint] NULL,
	[SessionIdA] [bigint] NULL,
	[SessionIdB] [bigint] NULL,
	[Side] [varchar](4) NULL,
	[TestId] [bigint] NULL,
	[Technology] [varchar](50) NULL,
	[NetworkId] [bigint] NULL,
	[MsgType] [varchar](100) NULL,
	[Layer] [varchar](25) NULL,
	[Type] [varchar](25) NULL,
	[Channel] [varchar](25) NULL,
	[Direction] [varchar](2) NULL,
	[Message] [varchar](5000) NULL,
	[MessageTypeName] [varchar](100) NULL,
	[Cause] [varchar](255) NULL,
	[CauseLocation] [varchar](255) NULL,
	[CauseClass] [varchar](255) NULL,
	[CauseValue] [varchar](255) NULL,
	[Details] [varchar](5000) NULL,

	[TMSI] [varchar](255) NULL,
	[m_TMSI] [varchar](255) NULL,
	[p_TMSI] [varchar](255) NULL,

	[My_m_TMSI] [varchar](255) NULL,
	[My_p_TMSI] [varchar](255) NULL,

	[Paging] [varchar](255) NULL,

	[STATE] varchar(255) NULL,
	[STATE2] varchar(255) NULL,
	[STATE3] varchar(255) NULL,

	[StateChange] varchar(255) NULL,
	[TechnoChange] varchar(255) NULL


) ON [MainGroup]
GO

SET ANSI_PADDING OFF
GO


-- ALTER TABLE AN_Layer3 ADD  [STATE] varchar(255) NULL

----------------------------------------------------------------
-- DLL Initialisieren, nur so zur Sicherheit :-)
EXEC master.dbo.SQKeyValueInit 'c:\sql_erweiterungen\L3KeyValue'
GO
----------------------------------------------------------------

-- ========================================================================================
--	SELECT top 10 * FROM AN_Layer3

-------------------------------------------------------------------------------------------
--	INSERT GSM Layer3 Daten  
-------------------------------------------------------------------------------------------

INSERT INTO [dbo].[AN_Layer3]
           ([Source],[SourceMsgId],[MsgTime],[SessionId],[TestId],[Technology],[NetworkId], [MsgType],[Layer],[Type],[Channel],[Direction],[Message],[MessageTypeName],[Cause],[CauseLocation],[CauseClass],[CauseValue],[Details])
     
		SELECT --top 1000000
			'vMsgGsmL3Data'										AS 'Source',
			t1.MsgId											AS 'SourceMsgId',				
			t1.MsgTime											AS 'MsgTime',
			t1.SessionId										AS 'SessionId',
			t1.TestId											AS 'TestId',

			ni.technology										AS 'Technology',
			ni.NetworkId										AS 'NetworkId',
			CAST (t1.MsgType AS Varchar)						AS 'MsgType',
			t1.Layer											AS 'Layer',
			0													AS 'Type',				-- @GSMDataType: 0: GSM L3 Data (parseCode 626 of table MsgGSMData)			
			''													AS 'Channel',
			t1.Direction										AS 'Direction',
			t1.message											AS 'Message',
			t1.Msg												AS 'MessageTypeName',
			''													AS 'Cause',
			''													AS 'CauseLocation',
			''													AS 'CauseClass',
			''													AS 'CauseValue',
			''													AS 'Details'
		FROM 
			vMsgGsmL3Data t1
					LEFT OUTER JOIN AN_Layer3 l3 ON (l3.Source = 'vMsgGsmL3Data' AND t1.msgId = l3.SourceMsgId)
					LEFT OUTER JOIN NetworkInfo ni ON t1.networkId = ni.NetworkId
					WHERE l3.SourceMsgId IS NULL

--	SELECT (SELECT count(*) FROM vMsgGsmL3Data) AS 'ORG', (SELECT count(*) FROM [AN_Layer3] WHERE Source = 'vMsgGsmL3Data') AS 'AN_Layer3'

-------------------------------------------------------------------------------------------
--	INSERT GSM GMM Daten  
---------------------------------------------------------------------------------------
INSERT INTO [dbo].[AN_Layer3]
           ([Source],[SourceMsgId],[MsgTime],[SessionId],[TestId],[Technology],[NetworkId], [MsgType],[Layer],[Type],[Channel],[Direction],[Message],[MessageTypeName],[Cause],[CauseLocation],[CauseClass],[CauseValue],[Details])
     
		SELECT --top 1000000
			'vGPRSInterLayerGMMSM'								AS 'Source',
			t1.MsgId											AS 'SourceMsgId',				
			t1.MsgTime											AS 'MsgTime',
			t1.SessionId										AS 'SessionId',
			t1.TestId											AS 'TestId',

			ni.technology										AS 'Technology',
			ni.NetworkId										AS 'NetworkId',
			CAST (t1.MsgType AS Varchar)						AS 'MsgType',
			t1.ProtDiscr										AS 'Layer',
			1													AS 'Type',				-- @GSMDataType: 0: GSM L3 Data (parseCode 626 of table MsgGSMData)	
																						--               1: GPRS GMM/SM (parseCodee 62G1 of table MsgGPRSInterLayerGMMSM)	
			''													AS 'Channel',
			t1.Direction										AS 'Direction',
			t1.message											AS 'Message',
			t1.msgTypeTxt										AS 'MessageTypeName',
			''													AS 'Cause',
			''													AS 'CauseLocation',
			''													AS 'CauseClass',
			''													AS 'CauseValue',
			''													AS 'Details'
		FROM 
			vGPRSInterLayerGMMSM t1
					LEFT OUTER JOIN AN_Layer3 l3 ON (l3.Source = 'vGPRSInterLayerGMMSM' AND t1.msgId = l3.SourceMsgId)
					LEFT OUTER JOIN NetworkInfo ni ON t1.networkId = ni.NetworkId
					WHERE l3.SourceMsgId IS NULL




-------------------------------------------------------------------------------------------
--	INSERT WCDMA RRC Daten  
-------------------------------------------------------------------------------------------
INSERT INTO [dbo].[AN_Layer3]
           ([Source], [SourceMsgId],[MsgTime],[SessionId],[TestId],[Technology], [NetworkId], [MsgType],[Layer],[Type],[Channel],[Direction],[Message],[MessageTypeName],[Cause],[CauseLocation],[CauseClass],[CauseValue],[Details])
     
		SELECT --top 10000
			'vWCDMARRCMessages'									AS 'Source',
			t1.MsgId											AS 'SourceMsgId',	
			t1.MsgTime											AS 'MsgTime',
			t1.SessionId										AS 'SessionId',
			t1.TestId											AS 'TestId',
			ni.technology										AS 'Technology',
			ni.NetworkId										AS 'NetworkId',
			CAST(t1.MsgIdent AS Varchar)						AS 'MsgType',
			'RRC'												AS 'Layer',
			t1.LogChanType										AS 'Type',
			CASE 
				WHEN LogChanType = 0 THEN 'UL CCCH'
				WHEN LogChanType = 1 THEN 'UL DCCH'
				WHEN LogChanType = 2 THEN 'DL CCCH'
				WHEN LogChanType = 3 THEN 'DL DCCH'
				WHEN LogChanType = 4 THEN 'DL BCCH: BCH'
				WHEN LogChanType = 5 THEN 'DL BCCH: FACH'
				WHEN LogChanType = 6 THEN 'DL PCCH'
				ELSE CAST(LogChanType AS varchar(25))
			END													AS 'Channel',
			t1.Direction,
			t1.Msg												AS 'Message',
			t1.MsgType											AS 'MessageTypeName',
			ISNULL(t2.EstablishmentCause,'')					AS 'Cause',
			''													AS 'CauseLocation',
			''													AS 'CauseClass',
			''													AS 'CauseValue',
			''													AS 'Details'
		FROM 
			vWCDMARRCMessages t1
					LEFT OUTER JOIN vRRCEstablishmentCause	t2 On t1.SessionId = t2.SessionId AND t1.MsgTime = t2.MsgTime	
					LEFT OUTER JOIN AN_Layer3 l3 ON (l3.Source = 'vWCDMARRCMessages' AND t1.msgId = l3.SourceMsgId)
					LEFT OUTER JOIN NetworkInfo ni ON t1.networkId = ni.NetworkId
				WHERE l3.SourceMsgId IS NULL


--	SELECT (SELECT count(*) FROM vWCDMARRCMessages) AS 'ORG', (SELECT count(*) FROM [AN_Layer3] WHERE Source = 'vWCDMARRCMessages') AS 'AN_Layer3'
--	SELECT MAX(LEN(Msg)) FROM vWCDMARRCMessages) 


-------------------------------------------------------------------------------------------
--	INSERT WCDMA RRCState Daten  
-------------------------------------------------------------------------------------------
 INSERT INTO [dbo].[AN_Layer3]
           ([Source], [SourceMsgId],[MsgTime],[SessionId],[TestId],[Technology], [NetworkId], [MsgType],[Type],[STATE])
     
		SELECT --top 1000000
						'WCDMARRCState'										AS 'Source',
			t1.MsgId											AS 'SourceMsgId',				
			t1.MsgTime											AS 'MsgTime',
			t1.SessionId										AS 'SessionId',
			t1.TestId											AS 'TestId',
			ni.technology										AS 'Technology',
			ni.NetworkId										AS 'NetworkId',
			'RRCState'											AS 'MsgType',
			RRCState											AS 'Type',					
			
			CASE	WHEN RRCState = 0 THEN 'Disconnecting'
				WHEN RRCState = 1 THEN 'Connecting'
				WHEN RRCState = 2 THEN 'CELL FACH'
				WHEN RRCState = 3 THEN 'CELL DCH'
				WHEN RRCState = 4 THEN 'CELL PCH'
				WHEN RRCState = 5 THEN 'URA PCH'
				ELSE '???' END															AS 'STATE2'

		FROM 
			WCDMARRCState t1
					LEFT OUTER JOIN AN_Layer3 l3 ON (l3.Source = 'WCDMARRCState' AND t1.msgId = l3.SourceMsgId)
					LEFT OUTER JOIN NetworkInfo ni ON t1.networkId = ni.NetworkId
					WHERE l3.SourceMsgId IS NULL

-------------------------------------------------------------------------------------------
--	INSERT LTE RRC Daten von vLTERRCMessages
-------------------------------------------------------------------------------------------
INSERT INTO [dbo].[AN_Layer3]
           ([Source],[SourceMsgId],[MsgTime],[SessionId],[TestId],[Technology], [NetworkId], [MsgType],[Layer],[Type],[Channel],[Direction],[Message],[MessageTypeName],[Cause],[CauseLocation],[CauseClass],[CauseValue],[Details])
 
		SELECT  --top 10000
			'vLTERRCMessages'									AS 'Source',
			t1.MsgId											AS 'SourceMsgId',	
			t1.MsgTime											AS 'MsgTime',
			t1.SessionId										AS 'SessionId',
			t1.TestId											AS 'TestId',
			ni.technology										AS 'Technology',
			ni.NetworkId										AS 'NetworkId',

			CAST (t1.MsgType AS Varchar)						AS 'MsgType',
			'RRC'												AS 'Layer',
			t1.ChnType											AS 'Type',
			CASE 
				WHEN ChnType = 2 THEN 'BCCH_DL_SCH'
				WHEN ChnType = 3 THEN 'PCCH'
				WHEN ChnType = 4 THEN 'DL_CCCH'
				WHEN ChnType = 5 THEN 'DL_DCCH'
				WHEN ChnType = 6 THEN 'UL_CCCH'
				WHEN ChnType = 7 THEN 'UL_DCCH'
				ELSE CAST(ChnType AS varchar(25))  
			END													AS 'Channel',

			t1.Direction										AS 'Direction',
			t1.Msg												AS 'Message',
			t1.MsgTypeName										AS 'MessageTypeName',
			''													AS 'Cause',
			''													AS 'CauseLocation',
			''													AS 'CauseClass',
			''													AS 'CauseValue',
			''													AS 'Details'
		FROM 
			vLTERRCMessages t1
					LEFT OUTER JOIN AN_Layer3 l3 ON (l3.Source = 'vLTERRCMessages' AND t1.msgId = l3.SourceMsgId)
					LEFT OUTER JOIN NetworkInfo ni ON t1.networkId = ni.NetworkId

				WHERE l3.SourceMsgId IS NULL


--	SELECT (SELECT count(*) FROM vLTERRCMessages) AS 'ORG', (SELECT count(*) FROM [AN_Layer3] WHERE Source = 'vLTERRCMessages') AS 'AN_Layer3'
--	SELECT MAX(LEN(Msg)) FROM vLTERRCMessages

-------------------------------------------------------------------------------------------
--	INSERT LTE NAS Daten von 
-------------------------------------------------------------------------------------------
INSERT INTO [dbo].[AN_Layer3]
           ([Source], [SourceMsgId],[MsgTime],[SessionId],[TestId],[Technology], [NetworkId], [MsgType],[Layer],[Type],[Channel],[Direction],[Message],[MessageTypeName],[Cause],[CauseLocation],[CauseClass],[CauseValue],[Details])
 
		SELECT --top 10000
			'LTENASMessages'									AS 'Source',
			t1.MsgId											AS 'SourceMsgId',	
			t1.MsgTime											AS 'MsgTime',


			t1.SessionId										AS 'SessionId',
			t1.TestId											AS 'TestId',
			ni.technology										AS 'Technology',
			ni.NetworkId										AS 'NetworkId', 
			CAST (t1.MsgType AS Varchar)						AS 'MsgType',
			CASE 
				WHEN t1.PROTOCOL LIKE 'ESM' THEN 'ESM'
				WHEN t1.PROTOCOL LIKE 'EMM' THEN 'EMM' 
				ELSE NULL  
			END													AS 'Layer',
			''													AS 'Type',
			''													AS 'Channel',
			t1.Direction										AS 'Direction',
			t1.Msg												AS 'Message',
			t1.MsgTypeName										AS 'MessageTypeName',
			''													AS 'Cause',
			''													AS 'CauseLocation',
			''													AS 'CauseClass',
			''													AS 'CauseValue',
			''													AS 'Details'

		FROM 
			LTENASMessages t1
						LEFT OUTER JOIN AN_Layer3 l3 ON (l3.Source = 'LTENASMessages' AND t1.msgId = l3.SourceMsgId)
						LEFT OUTER JOIN NetworkInfo ni ON t1.networkId = ni.NetworkId
				WHERE l3.SourceMsgId IS NULL


--	SELECT (SELECT count(*) FROM LTENASMessages) AS 'ORG', (SELECT count(*) FROM [AN_Layer3] WHERE Source = 'LTENASMessages') AS 'AN_layer3'
--	SELECT MAX(LEN(Msg)) FROM LTENASMessages
--*/

-------------------------------------------------------------------------------------------
--	INSERT IMS SIP Messages
-------------------------------------------------------------------------------------------
INSERT INTO [dbo].[AN_Layer3]
           ([Source], [SourceMsgId],[MsgTime],[SessionId],[TestId],[Technology], [NetworkId], [MsgType],[Layer],[Type],[Channel],[Direction],[Message],[MessageTypeName],[Cause],[CauseLocation],[CauseClass],[CauseValue],[Details])
     
		SELECT --top 1000
			'vIMSSIPMessage'									AS 'Source',
			t1.MsgId											AS 'SourceMsgId',				
			t1.MsgTime											AS 'MsgTime',
			t1.SessionId										AS 'SessionId',
			t2.TestId											AS 'TestId',

			ni.technology										AS 'Technology',
			ni.NetworkId										AS 'NetworkId',

			NULL												AS 'MsgType',
			'IMS SIP'											AS 'Layer',
			0													AS 'Type',					
			''													AS 'Channel',
			CASE WHEN t1.Direction = 'UE to Network' THEN 'U'
				 WHEN t1.Direction = 'Network to UE' THEN 'D' 
				 WHEN t1.Direction = 'Unknown'		 THEN 'x' 
				 ELSE 'xx' END									AS 'Direction',
			LEFT(t1.message,5000)								AS 'Message',
--			t1.MessageId										AS 'MessageTypeName',
			t1.MessageId + ' (' + t1.ResponseCode + ')'			AS 'MessageTypeName',
			--t1.ResponseCode										AS 'Cause',
			''													AS 'Cause',
			''													AS 'CauseLocation',
			''													AS 'CauseClass',
			''													AS 'CauseValue',
			t1.SIPCallId										AS 'Details'
		FROM 
			[vIMSSIPMessage] t1
					LEFT OUTER JOIN AN_Layer3 l3 ON (l3.Source = 'vIMSSIPMessage' AND t1.msgId = l3.SourceMsgId)
					INNER JOIN IMSSIPMessage t2 ON t1.MsgId = t2.MsgId
					LEFT OUTER JOIN NetworkInfo ni ON t2.networkId = ni.NetworkId
					WHERE l3.SourceMsgId IS NULL


--	SELECT (SELECT count(*) FROM vIMSSIPMessage) AS 'ORG', (SELECT count(*) FROM [AN_Layer3] WHERE Source = 'vIMSSIPMessage') AS 'AN_layer3'
-- DELETE AN_Layer3 WHERE Source = 'vIMSSIPMessage'



-------------------------------------------------------------------------------------------
-- UPDATE AREA	
--
--
-------------------------------------------------------------------------------------------
/*
	SELECT top 1000 * from AN_Layer3 order by msgTime
*/
-------------------------------------------------------------------------------------------
--	***************************************************************************************
--  ******************************   Dies und Dass   **************************************
--	***************************************************************************************
-------------------------------------------------------------------------------------------
--	UPDATE SessionId's & Side
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET 
	[SessionIdA] = COALESCE(b1.SessionIdA, b2.SessionIdA),
	[SessionIdB] = COALESCE(b1.SessionId,  b2.SessionId),
	[Side]		 = CASE WHEN s.sessionType IS NOT NULL THEN 'A' ELSE 'B' END
		
	FROM AN_Layer3 l3
		LEFT OUTER JOIN Sessions   s ON l3.SessionId = s.SessionId
		LEFT OUTER JOIN SessionsB b1 ON l3.SessionId = b1.SessionIdA
		LEFT OUTER JOIN SessionsB b2 ON l3.SessionId = b2.SessionId
	WHERE l3.[SessionIdA] IS NULL
	
--------------------------------------------------------------------------------------------
-- FileId hinzufügen                                                                     
--------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET FileId = s.FileId from AN_Layer3 t1 	INNER JOIN Sessions	s  ON t1.SessionId = s.SessionId	WHERE t1.FileId is NULL
UPDATE AN_Layer3 SET FileId = s.FileId from AN_Layer3 t1 	INNER JOIN SessionsB s ON t1.SessionId = s.SessionId	WHERE t1.FileId is NULL

--	SELECT * FROM AN_Layer3
--------------------------------------------------------------------------------------------
-- DISCONNET Message                                                                      OK
--------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET 
-- SELECT *, 
		[Cause]			= 	master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;DISCONNECT;Cause;Cause;Cause value;Value'),
		[CauseLocation] = 	master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;DISCONNECT;Cause;Cause;Location'),
		[CauseClass]	= 	master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;DISCONNECT;Cause;Cause;Cause value;Class'),
		[CauseValue]	= 	master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;DISCONNECT;Cause;Cause;Cause value;Value')
	FROM AN_Layer3 l3
	WHERE Source = 'vMsgGSML3Data' AND MessageTypeName = 'Disconnect'

--	SELECT * from AN_Layer3 WHERE Source = 'vMsgGSML3Data' AND MessageTypeName = 'Disconnect' 
--	SELECT DISTINCT Cause, CauseLocation, CauseClass, CauseValue from AN_Layer3 WHERE Source = 'vMsgGSML3Data' AND MessageTypeName = 'Disconnect' 





--	***************************************************************************************
--	*************************************    LTE    ***************************************
--	***************************************************************************************
--------------------------------------------------------------------------------------------
-- LTENASMessages	EMM	Attach reject                                                     OK
--------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET 
--	SELECT *,
		[Cause] = master.dbo.SQLTENASKeyValue(Message, Direction, 'EMM Cause')
	FROM AN_Layer3 WHERE Source = 'LTENASMessages' AND MessageTypeName = 'Attach request'

--------------------------------------------------------------------------------------------
-- LTENASMessages	EMM	Attach request                                                     OK
--------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET 
--	SELECT *,
		[TMSI] = master.dbo.SQLTENASKeyValue(Message, Direction, 'Identity')
	FROM AN_Layer3 WHERE Source = 'LTENASMessages' AND MessageTypeName = 'Attach request'

--------------------------------------------------------------------------------------------
-- LTENASMessages	EMM	Attach accept                                                     OK
--------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET 
--	SELECT *,
		[m_TMSI]		= master.dbo.SQLTENASKeyValue(Message, Direction, 'M-TMSI'),
		[Details]  = master.dbo.SQLTENASKeyValue(Message, Direction, 'IPv4 Address')
	FROM AN_Layer3 WHERE Source = 'LTENASMessages' AND MessageTypeName = 'Attach accept'

-------------------------------------------------------------------------------------------
--	LTENASMessages	ESM	PDN connectivity reject											 OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET 
--	SELECT *,
		[Cause] = master.dbo.SQLTENASKeyValue(Message, Direction, 'Cause value')
	FROM AN_Layer3 WHERE Source = 'LTENASMessages' AND MessageTypeName = 'PDN connectivity reject'

-------------------------------------------------------------------------------------------
--	LTENASMessages	EMM	Service reject													 OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET 
--	SELECT *,
		[Cause] = master.dbo.SQLTENASKeyValue(Message, Direction, 'EMM Cause')
	FROM AN_Layer3 WHERE Source = 'LTENASMessages' AND MessageTypeName = 'Service reject'

--------------------------------------------------------------------------------------------
-- LTE Tracking area update reject Message												  OK        
--------------------------------------------------------------------------------------------	
UPDATE AN_Layer3 SET 
--	SELECT *,
		[Cause] = master.dbo.SQLTENASKeyValue(Message, Direction, 'EMM Cause')
	FROM AN_Layer3 WHERE Source = 'LTENASMessages' AND MessageTypeName = 'Tracking Area update reject'

--------------------------------------------------------------------------------------------
-- LTE Tracking area update request Message												  OK        
--------------------------------------------------------------------------------------------	
UPDATE AN_Layer3 SET 
--	select *, 
		[TMSI] = master.dbo.SQLTENASKeyValue(Message, Direction, 'M-TMSI')
	FROM AN_Layer3 WHERE Source = 'LTENASMessages' AND MessageTypeName = 'Tracking Area update request'

--------------------------------------------------------------------------------------------
-- LTE Tracking area update accept Message												  OK        
--------------------------------------------------------------------------------------------	
UPDATE AN_Layer3 SET 
--	select *, 
		[m_TMSI] = master.dbo.SQLTENASKeyValue(Message, Direction, 'M-TMSI')
	FROM AN_Layer3 WHERE Source = 'LTENASMessages' AND MessageTypeName = 'Tracking Area update accept'





-------------------------------------------------------------------------------------------
-- 	LTENASMessages 	EMM Extended service request								         OK       
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET 
--	SELECT *,
		[Cause]		= master.dbo.SQLTENASKeyValue(Message, Direction, 'Switch off'),
		[TMSI]		= master.dbo.SQLTENASKeyValue(Message, Direction, 'Identity digits')
	FROM AN_Layer3 WHERE Source = 'LTENASMessages' AND MessageTypeName = 'Extended service request'

--------------------------------------------------------------------------------------------
-- LTE UECapabilityEnquiry												          
--------------------------------------------------------------------------------------------	
--UPDATE AN_Layer3 SET 
----	SELECT top 1000 *,
--		[Cause] = master.dbo.SQLTERRCKeyValue(Message, MsgType, 'RAT_Type[0]')
--	FROM AN_Layer3 WHERE Source = 'vLTERRCMessages' AND MessageTypeName = 'UECapabilityEnquiry'







-------------------------------------------------------------------------------------------
--	vLTERRCMessages	RRC	RRCConnectionReestablishmentReject							no DATA
-------------------------------------------------------------------------------------------
-- Gibt kein Reject Cause !!!

--	SELECT * FROM AN_Layer3 WHERE Source = 'vLTERRCMessages' AND MessageTypeName = 'RRCConnectionReestablishmentReject'

-------------------------------------------------------------------------------------------
-- vLTERRCMessages RRCConnectionRelease													 OK        
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET 
--	SELECT *,
		[Cause] = master.dbo.SQLTERRCKeyValue(Message, Type, 'releaseCause')
	FROM AN_Layer3 WHERE Source = 'vLTERRCMessages' AND MessageTypeName = 'RRCConnectionRelease'

-------------------------------------------------------------------------------------------
-- vLTERRCMessages RRCConnectionRequest											         OK      
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
--	SELECT *,
		[Cause]		= master.dbo.SQLTERRCKeyValue(Message, Type, 'establishmentCause'),
		[TMSI]		= master.dbo.SQLTERRCKeyValue(Message, Type, 'm_TMSI')--,

	FROM AN_Layer3 WHERE Source = 'vLTERRCMessages' AND MessageTypeName = 'RRCConnectionRequest'

-------------------------------------------------------------------------------------------
-- vLTERRCMessages RRCConnectionSetupComplete											         OK      
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
--	SELECT TOP 10000 *,
		[TMSI]		= master.dbo.SQLTERRCKeyValue(Message, Type, 'Identity digits'),
		[m_TMSI]		= master.dbo.SQLTERRCKeyValue(Message, Type, 'M-TMSI')
	FROM AN_Layer3 WHERE Source = 'vLTERRCMessages' AND MessageTypeName = 'RRCConnectionSetupComplete'



-------------------------------------------------------------------------------------------
-- vLTERRCMessages RRC Paging													         OK    
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET 
--	SELECT *,
		[Paging] = master.dbo.SQLTERRCKeyValue(Message, Type, 'm_TMSI')
	FROM AN_Layer3 WHERE Source = 'vLTERRCMessages' AND MessageTypeName = 'Paging'
	--and sessionid = 8



----------------------------------------------------------------
-- DLL Initialisieren, nur so zur Sicherheit :-)
EXEC master.dbo.SQKeyValueInit 'c:\sql_erweiterungen\L3KeyValue'
GO
----------------------------------------------------------------




--	***************************************************************************************
--	*************************************    WCDMA    *************************************
--	***************************************************************************************
-------------------------------------------------------------------------------------------
--	vWCDMARRCMessages	RRC	RRCConnectionReject                                          OK                    
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
-- SELECT *, 
		[Cause] = master.dbo.SQUMTSKeyValue(Message, Type, MessageTypeName, 'rejectionCause')
	FROM AN_Layer3 WHERE Source = 'vWCDMARRCMessages' AND MessageTypeName = 'RRCConnectionReject'

-------------------------------------------------------------------------------------------
--	vWCDMARRCMessages	RRC	RRCConnectionReject                                          OK                    
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
-- SELECT *, 
		[Cause] = master.dbo.SQUMTSKeyValue(Message, Type, MessageTypeName, 'establishmentCause')--,
	--	[TMSI] =  master.dbo.SQUMTSKeyValue(Message, Type, MessageTypeName, 'tmsiDATA')		-- geht nicht

	FROM AN_Layer3 WHERE Source = 'vWCDMARRCMessages' AND MessageTypeName = 'RRCConnectionRequest'


-------------------------------------------------------------------------------------------
--	vWCDMARRCMessages	RRC	RadioBearerReconfiguration                                          OK                    
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
-- SELECT *, 
		[STATE] = master.dbo.SQUMTSKeyValue(Message, Type, MessageTypeName, 'rrc_StateIndicator')--,
	--	[TMSI] =  master.dbo.SQUMTSKeyValue(Message, Type, MessageTypeName, 'tmsiDATA')		-- geht nicht
	FROM AN_Layer3 WHERE Source = 'vWCDMARRCMessages' AND MessageTypeName = 'RRCConnectionSetup'

-------------------------------------------------------------------------------------------
--	vWCDMARRCMessages	RRC	RadioBearerReconfiguration                                   OK                    
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
--SELECT *, 
		[STATE] = master.dbo.SQUMTSKeyValue(Message, Type, MessageTypeName, 'rrc_StateIndicator')--,
	FROM AN_Layer3 WHERE Source = 'vWCDMARRCMessages' AND MessageTypeName = 'RadioBearerReconfiguration'

-------------------------------------------------------------------------------------------
--	vWCDMARRCMessages	RRC	PhysicalChannelReconfiguration                               OK                    
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
--	SELECT *, 
		[STATE] = master.dbo.SQUMTSKeyValue(Message, Type, MessageTypeName, 'rrc_StateIndicator')--,
	FROM AN_Layer3 WHERE Source = 'vWCDMARRCMessages' AND MessageTypeName = 'PhysicalChannelReconfiguration'

-------------------------------------------------------------------------------------------
--	vWCDMARRCMessages	RRC	PhysicalChannelReconfiguration                               OK 
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
--	SELECT *, 
		[CAUSE] = master.dbo.SQUMTSKeyValue(Message, Type, MessageTypeName, 'cellUpdateCause')--,
	FROM AN_Layer3 WHERE Source = 'vWCDMARRCMessages'	AND MessageTypeName = 'CellUpdate'

-------------------------------------------------------------------------------------------
--	
-------------------------------------------------------------------------------------------



		

--	***************************************************************************************
--	*************************************    GSM    ***************************************
--	***************************************************************************************
-------------------------------------------------------------------------------------------
--	vMsgGsmL3Data	MM	CM Service Reject												 OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
--	SELECT top 10000 *, 
		[Cause] = master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;CM SERVICE REJECT;Reject cause;Reject cause value;Cause value')
	FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName = 'CM Service Reject'

--	SELECT * FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName = 'CM Service Reject'
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--	vMsgGsmL3Data	RR	Immediate Assignment Reject
-------------------------------------------------------------------------------------------

--	SELECT * FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName = 'Immediate Assignment Reject'
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--	vMsgGsmL3Data	MM	Location Updating Reject										 OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
--	SELECT top 10000 *, 
		[Cause] = master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;LOCATION UPDATING REJECT;Reject cause;Reject cause value;Cause value')
	FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName = 'Location Updating Reject'

--	SELECT * FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName = 'Location Updating Reject'
-------------------------------------------------------------------------------------------
--	vMsgGsmL3Data	RR	Paging Type 1													 OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
--	SELECT top 10000 *, 
		[Paging] = master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;PAGING REQUEST TYPE 1;Mobile Identity 1;Identity digits') + 
				CASE WHEN		master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;PAGING REQUEST TYPE 1;Mobile Identity 2;Identity digits') <> '' 
					THEN ',' +	master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;PAGING REQUEST TYPE 1;Mobile Identity 2;Identity digits') --,
					ELSE '' END
	FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName LIKE 'Paging Request Type 1'

--	SELECT * FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName Like 'Paging Request Type 1'
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--	vMsgGsmL3Data	RR	Paging Type 2													 OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
-- SELECT top 1000 *, 
		[Paging] =			master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;PAGING REQUEST TYPE 2;Mobile Identity 1;Identity digits') + master.dbo.SQGSMKeyValue(message,0,'Protocol Discriminator;PAGING REQUEST TYPE 2;Mobile Identity 1;TMSI/P-TMSI') + 

		CASE WHEN		   (master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;PAGING REQUEST TYPE 2;Mobile Identity 2;Identity digits') + master.dbo.SQGSMKeyValue(message,0,'Protocol Discriminator;PAGING REQUEST TYPE 2;Mobile Identity 2;TMSI/P-TMSI')) <> '' 
			 THEN ',' +		master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;PAGING REQUEST TYPE 2;Mobile Identity 2;Identity digits') + master.dbo.SQGSMKeyValue(message,0,'Protocol Discriminator;PAGING REQUEST TYPE 2;Mobile Identity 2;TMSI/P-TMSI') + 

			CASE WHEN	   (master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;PAGING REQUEST TYPE 2;Mobile Identity 3;Identity digits') + master.dbo.SQGSMKeyValue(message,0,'Protocol Discriminator;PAGING REQUEST TYPE 2;Mobile Identity 3;TMSI/P-TMSI')) <> '' 
				 THEN ',' + master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;PAGING REQUEST TYPE 2;Mobile Identity 3;Identity digits') + master.dbo.SQGSMKeyValue(message,0,'Protocol Discriminator;PAGING REQUEST TYPE 2;Mobile Identity 3;TMSI/P-TMSI') 
				 ELSE '' END 
			ELSE '' END

	FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName LIKE 'Paging Request Type 2'

--	SELECT * FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName Like 'Paging Request Type 2'
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--	vMsgGsmL3Data	RR	Paging Type 3													 OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
--	SELECT TOP 10000 *,
		[Paging] =				 master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;PAGING REQUEST TYPE 3;Mobile Identity 1;TMSI/P-TMSI') + 

		CASE WHEN				 master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;PAGING REQUEST TYPE 3;Mobile Identity 2;TMSI/P-TMSI') <> '' 
			 THEN ',' +			 master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;PAGING REQUEST TYPE 3;Mobile Identity 2;TMSI/P-TMSI') + 

			CASE WHEN			 master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;PAGING REQUEST TYPE 3;Mobile Identity 3;TMSI/P-TMSI') <> '' 
				 THEN ',' +		 master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;PAGING REQUEST TYPE 3;Mobile Identity 3;TMSI/P-TMSI') +

				CASE WHEN		 master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;PAGING REQUEST TYPE 3;Mobile Identity 4;TMSI/P-TMSI') <> '' 
					 THEN ',' +  master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;PAGING REQUEST TYPE 3;Mobile Identity 4;TMSI/P-TMSI') 
					 ELSE '' END 
				 ELSE '' END 
			ELSE '' END

	FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName LIKE 'Paging Request Type 3'

--	SELECT * FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName Like 'Paging Request Type 3'
-------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------
--	vMsgGsmL3Data	RR	Paging Response						     						 OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
--	SELECT TOP 10000 *,
		[TMSI] = master.dbo.SQGSMKeyValue(message,type,'Protocol Discriminator;PAGING RESPONSE;Mobile Identity;Identity digits')
	FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName = 'Paging Response'
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--	vMsgGsmL3Data	RR	LOCATION UPDATING REQUEST			     						 OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
--	SELECT TOP 1000 *,
		[TMSI] = master.dbo.SQGSMKeyValue(message,type,'Protocol Discriminator;LOCATION UPDATING REQUEST;Mobile identity;Identity digits')
	FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName = 'LOCATION UPDATING REQUEST'
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--	vMsgGsmL3Data	RR	LOCATION UPDATING ACCEPT				     					 OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
--	SELECT Top 1000 *,
		[TMSI] = master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;LOCATION UPDATING ACCEPT;Mobile identity;Identity digits')
	FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName = 'LOCATION UPDATING ACCEPT'
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--	vMsgGsmL3Data	RR	Identity Response				     					         OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
-- SELECT Top 1000 *,
		[TMSI] = master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;IDENTITY RESPONSE;Mobile identity;Identity digits')
	FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName = 'Identity Response'
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--	vMsgGsmL3Data	RR	Identity Response				     					         OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
-- SELECT Top 10000 *,
		[p_TMSI] = master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;ROUTING AREA UPDATE ACCEPT;Allocated P-TMSI;Mobile Identity;Identity digits')
	FROM AN_Layer3 WHERE Source = 'vGPRSInterLayerGMMSM' AND MessageTypeName = 'ROUTING AREA UPDATE ACCEPT'
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--	vMsgGsmL3Data	RR				     					         OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
-- SELECT top 1000 *,
		[Details] = master.dbo.SQGSMKeyValue(message,type,'Protocol Discriminator;ASSIGNMENT COMMAND;Description of the First Channel after time;Channel type and TDMA offset;Channel type and TDMA offset')
	FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName = 'Assignment Command'
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--	vMsgGsmL3Data	RR Measurement Report				     					         OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
-- SELECT TOP 1000 *,
		[Details] = master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;MEASUREMENT REPORT;Measurement Results;MEAS-VALID')
	FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName = 'Measurement Report'
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--	vMsgGsmL3Data	MM	CM SERVICE REQUEST			     					         OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
-- SELECT Top 1000 *,
		[TMSI] = master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;CM SERVICE REQUEST;Mobile identity;Identity digits')
	FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName = 'CM SERVICE REQUEST'

-------------------------------------------------------------------------------------------
--	vMsgGsmL3Data	MM		TMSI REALLOCATION COMMAND		     					         OK
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET
-- SELECT Top 1000 *,
		[TMSI] = master.dbo.SQGSMKeyValue(message,Type,'Protocol Discriminator;TMSI REALLOCATION COMMAND;Mobile identity;Identity digits')
	FROM AN_Layer3 WHERE Source = 'vMsgGsmL3Data' AND MessageTypeName = 'TMSI REALLOCATION COMMAND'




--*****************************************************************************************
--
--*****************************************************************************************
-------------------------------------------------------------------------------------------
--	STATE Change in LTE
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET 
--SELECT *,  
	[StateChange] = CASE 
			WHEN MessageTypeName = 'RRCConnectionSetupComplete'		THEN 'idle => connected' 
			WHEN MessageTypeName = 'RRCConnectionRelease'			THEN 'connected => idle' 
			ELSE '' END			
	FROM AN_Layer3 
	WHERE source = 'vLTERRCMessages' AND MessageTypeName IN ('RRCConnectionSetupComplete', 'RRCConnectionRelease')

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--	STATE Change in WCDMA
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET 
--	SELECT *,  
	[StateChange] = CASE 
			WHEN MessageTypeName = 'RRCConnectionSetupComplete'		THEN 'idle => connected' 
			WHEN MessageTypeName = 'RRCConnectionRelease'			THEN 'connected => idle' 
			WHEN MessageTypeName = 'RadioBearerRelease'				THEN 'connected => idle'                               
			ELSE '' END			
	FROM AN_Layer3 
	WHERE source = 'vWCDMARRCMessages' AND MessageTypeName IN ('RRCConnectionSetupComplete', 'RRCConnectionRelease', 'RadioBearerRelease')



-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--	STATE Change in GSM
-------------------------------------------------------------------------------------------
UPDATE AN_Layer3 SET 
--	SELECT *,  
	[StateChange] = CASE 
			WHEN MessageTypeName = 'Assignment Command'			THEN 'idle => connected' 
			WHEN MessageTypeName = 'Channel Release'			THEN 'connected => idle' 
			ELSE '' END			
	FROM AN_Layer3 
	WHERE source = 'vMsgGsmL3Data' AND MessageTypeName IN ('Assignment Command', 'Channel Release')


-------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--	SET my_TMSI
-------------------------------------------------------------------------------------------








SELECT *
	FROM AN_Layer3
	ORDER BY SessionIdA, MSgTime

-- select *  	FROM AN_Layer3 	WHERE sessionId = 4305

/*
	SELECT Distinct Source, Layer, MessageTypeName, Cause FROM AN_Layer3 
		WHERE MessageTypeName LIKE '%Paging%' 
	
	ORDER BY Source, MessageTypeName

*/
                       
/*
p_name
Parameter

RA Update Timer Value
Access point name
Algorithm identifier
ARFCN
bandIndicator
BCC
BCCH ARFCN
BSIC
Called Party Number
Cause Class
Cause value
CellUpdate Cause
Channel type
Channel type and TDMA offset
Coding standard
Controlled Early Classmark Sending option (ES IND)
CPICH EcNo
CPICH RSCP
CS Completed
CS Dropped
CS Failed
CS Service Access
CS Start
cs_FallbackIndicator
Delay class
Delivery of erroneous
Delivery order
Enable64QAM
encryption algorithm A5/1
encryption algorithm A5/2
encryption algorithm A5/3
EPC mode
EstablishmentCause
Event Type
EventA1_Threshold_RSRP
EventA2_Threshold_RSRP
EventA3_Offset
EventA4_Threshold_RSRP
EventA5_Threshold1_RSRP
EventA5_Threshold2_RSRP
explicitListOfARFCNs
FC
Follow on Request
Force to standby
FPC/EPC
Frequency Band
GPRS Encryption Algorithm GEA/1
GPSM Cause value
GSM Handover
GSM to UMTS HO
GSM-CarrierRSSI
Guaranteed bit rate for downlink
Guaranteed bit rate for uplink
Hopping channel
IMEI Type of identity
IMSI Type of identity
IN-Code:1002 Connection successful
IN-Code:1004 Send header to request file 
IN-Code:1005 Send successful
IN-Code:1006 Receive data
IN-Code:1040 Connection established (SP)
IN-Code:1041 First packet from socket received (SP)
IN-Code:1103 Resource DL
Inter RAT Cell ID
LCS value added location request notification capability
Location
Location Area Code
LTE CSFB Redirect Success GSM
LTE CSFB Redirect Success UMTS
LTE HO Delay GSM/GPRS
LTE HO Delay UMTS
LTE HO Failure UMTS
LTE PS HO Attempt
LTE PS HO Failure GSM/GPRS
LTE PS HO Success
LTE PS Redirect Success UMTS
LTE Redirect Attempt GERAN
LTE Redirect Attempt UMTS
LUT
Max Allowed UL TX Power
Maximum bit rate for downlink
Maximum bit rate for uplink
Maximum SDU size
MCC
Mean throughput
Measurement ID
Measurement Identity
MNC
Mobile Classmark CM3
Mobile Country Code
Mobile Network Code
NC_pCI
NC_RSRP_Result
NC_RSRQ_Result
NCC
Network initiated MO CM connection request
non-DRX timer
NSAPI value
pCI
PDP Context Failed
PDP type number
Peak throughput
Power level
Prach_ConfigIndex
Precedence class
Primary Scrambling Code
PS capability
PS Completed
PS Dropped
PS Fail
PS Service Access
PS Start
PS Start Data Transfer
PTGEvent Phase
PTGEvent SubState
q_RxLevMin
RAC
RAS Event
RB_CQI
ReestablishmentCause
Reject cause
Rejection Cause
Release Cause
Reliability class
ReportConfigID
Requested LLC SAPI
Residual Bit Error Rate (BER)
Result of attach
Revision level
RF power capability
RL - AdditionInformationList Add CodeNumber
RL - AdditionInformationList Add SC
RL - AdditionInformationList Remove SC
RR cause value
rrc_StateIndicator
RRCTransactionIdentifier
SC_RSRP_Result
SC_RSRQ_Result
SDU error ratio
Service type
Serving HSDSCH_RL Indicator
Signalling Indication
SM capability
SoLSA
Source Statistics Descriptor
SS Screening Indicator
Suspension Cause Value
TargetPhysCellId
Timer Unit
Timeslot number
Timing advance value
TMSI
Traffic class
Traffic handling priority
Transfer delay
TransmissionMode
Transport Channel Type DCH
Transport Channel Type FACH
Type of attach
Type of Detach
UCS2 treatment
Udpate Result
UMTS Hard HO
UMTS soft HO
UMTS to GSM HO
User Break
utra_FDD
VBS
VGCS
ZeroCorrelationZoneConfig
*/

/*
MIB	System Bandwidth
SIB1	Cell ID, MCC, MNC, TAC, SIB Mapping
SIB2	Radio Resource Configuration, Preamble Power Ramping, Inter SubFrameHopping, UL Power Control, UL CP Length, UL EARFCN
SIB3	Cell Reselection,Info, Intra Freq Cell Reselection 
SIB4	Intra Frequency Neighbors (same frequency)
SIB5	Inter Frequency Neighbors (different frequency)
SIB6	WCDMA Neighbors
SIB7	GSM Neighbors
SIB8	CDMA2000 EVDO Neighbor
*/




