SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- CREATE FUNCTION THAT WILL RETURN Radio Values in LTE
-- DROP function if already exists
IF EXISTS ( SELECT * FROM sysobjects WHERE id = object_id(N'BandsExtract') AND xtype IN (N'FN', N'IF', N'TF') )
    DROP FUNCTION BandsExtract
GO
Create FUNCTION BandsExtract
(
    @sessID int,
	@testID int,
	@timestamp datetime2(3)
)
RETURNS @RadioValues TABLE 
(
    -- Columns returned by the function
    SessID		int PRIMARY KEY NOT NULL,
	Timer		datetime2(3)	NULL,
    EARFCN		bigint			NULL, 
	RSRP		float			NULL,
	RSRQ		float			NULL,
	RSSI		float			NULL,
	SINR0		float			NULL,
	SINR1		float			NULL,
	RSRP_Rx0	float			NULL,
	RSRQ_Rx0	float			NULL,
	RSSI_Rx0	float			NULL,
	RSRP_Rx1	float			NULL,
	RSRQ_Rx1	float			NULL,
	RSSI_Rx1	float			NULL
)
AS
BEGIN
			-- Extract network information between call start and call end
			INSERT INTO @RadioValues (SessID, Timer, EARFCN, RSRP, RSRQ, RSSI, SINR0, SINR1, RSRP_Rx0, RSRQ_Rx0, RSSI_Rx0, RSRP_Rx1, RSRQ_Rx1, RSSI_Rx1)
			SELECT TOP 1
					[SessionId]
				   ,@timestamp as Timer
				   ,[EARFCN]
				   ,[RSRP]
				   ,[RSRQ]
				   ,[RSSI]
				   ,[SINR0]
				   ,[SINR1]
				   ,[RSRP_Rx0]
				   ,[RSRQ_Rx0]
				   ,[RSSI_Rx0]
				   ,[RSRP_Rx1]
				   ,[RSRQ_Rx1]
				   ,[RSSI_Rx1]
				FROM [Press_pre_D_Data_TDG_DEU_Q3].[dbo].[LTEMeasurementReport] a
				WHERE @sessID = a.[SessionId] and @testID = a.[TestId] and @timestamp >= a.[MsgTime]
				ORDER BY [MsgTime] DESC

			IF (SELECT SessID FROM @RadioValues) is null
				BEGIN
					INSERT INTO @RadioValues (SessID, Timer, EARFCN, RSRP, RSRQ, RSSI, SINR0, SINR1, RSRP_Rx0, RSRQ_Rx0, RSSI_Rx0, RSRP_Rx1, RSRQ_Rx1, RSSI_Rx1)
					SELECT TOP 1
							[SessionId]
						   ,@timestamp as Timer
						   ,[EARFCN]
						   ,[RSRP]
						   ,[RSRQ]
						   ,[RSSI]
						   ,[SINR0]
						   ,[SINR1]
						   ,[RSRP_Rx0]
						   ,[RSRQ_Rx0]
						   ,[RSSI_Rx0]
						   ,[RSRP_Rx1]
						   ,[RSRQ_Rx1]
						   ,[RSSI_Rx1]
					FROM [Press_pre_D_Data_TDG_DEU_Q3].[dbo].[LTEMeasurementReport] a
					WHERE @sessID = a.[SessionId] and @testID = a.[TestId] and @timestamp < a.[MsgTime]
					ORDER BY [MsgTime]
				END
			RETURN;	  
END
GO

-- Selecting Only Sessions we are interested to
-- In Where statement put Filter you want to apply
IF OBJECT_ID ('tempdb..#ValidSessions' ) IS NOT NULL
    DROP TABLE #ValidSessions
SELECT  SessionID,
		G_Level_1,
		G_Level_2,
		G_Level_4,
		Validity,
		Campaign_Customer,
		TIME_GSM_900_s,
		TIME_GSM_1800_s,
		TIME_UMTS_850_s,
		TIME_UMTS_900_s,
		TIME_UMTS_1900_s,
		TIME_UMTS_2100_s,
		TIME_LTE_800_s,
		TIME_LTE_900_s,
		TIME_LTE_1700_s,
		TIME_LTE_1800_s,
		TIME_LTE_2100_s,
		TIME_LTE_2600_s
into #ValidSessions
from  NEW_CDR_Data
where Campaign_Customer like '%Telekom'and G_Level_3 like 'Stuttgart'

IF OBJECT_ID ('tempdb..#NetworkStuff' ) IS NOT NULL
    DROP TABLE #NetworkStuff
SELECT 
	a.SessionId,
	a.TestId,
	a.MsgTime,
	a.PosId,
	a.NetworkId,
	a.LTEPDSCHInfoId,
	a.NumRecords,
	a.NumRank2,
	a.MaxNumLayer,
	a.MaxRBsFrame,
	a.MinRBsFrame,
	a.AvgRBsFrame,
	a.BytesTransferred,
	a.RequestedPDSCHThroughput,
	a.ScheduledPDSCHThroughput,
	a.NetPDSCHThroughput,
	a.BLER,
	a.FER,
	a.TBRate,
	a.MaxTBSize,
	a.MinTBSize,
	a.AvgTBSize,
	a.NumTBs,
	a.NumNewData,
	a.NumCRCPass,
	a.NumPassOnFirstAttempt,
	a.NumRecombining,
	a.NumDiscardedRetransmissions,
	a.NumNotTransmittedTBs,
	a.NumRBs,
	a.AvgMCS,
	a.TransmissionMode,
	a.NumQPSK,
	a.Num16QAM,
	a.Num64QAM,
	a.NumRetrans1,
	a.NumRetrans2,
	a.NumRetrans3orMore,
	a.NumCarriers,
	s.SessID, 
	s.Timer, 
	s.EARFCN, 
	s.RSRP, 
	s.RSRQ, 
	s.RSSI, 
	s.SINR0, 
	s.SINR1, 
	s.RSRP_Rx0, 
	s.RSRQ_Rx0, 
	s.RSSI_Rx0, 
	s.RSRP_Rx1, 
	s.RSRQ_Rx1, 
	s.RSSI_Rx1
into #NetworkStuff
from LTEPDSCHStatisticsInfo a
CROSS APPLY dbo.BandsExtract(a.SessionId,a.TestId,a.MsgTime) AS s
WHERE SessionId in (SELECT SessionId FROM #ValidSessions)

SELECT  a.*,
		b.*
FROM #ValidSessions a
LEFT OUTER JOIN #NetworkStuff b
	on a.SessionId=b.SessionId
ORDER BY a.SessionId, b.TestId, b.MsgTime