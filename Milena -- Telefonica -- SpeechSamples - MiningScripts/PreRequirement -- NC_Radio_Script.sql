
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Alte Tabellen mit Daten löschen--------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

IF EXISTS(SELECT name FROM sysobjects WHERE name = N'NC_RADIO' AND type = 'U')    DROP TABLE [NC_RADIO]
GO

IF EXISTS(SELECT name FROM sysobjects WHERE name = N'NC_RADIO_CHECK' AND type = 'U')    DROP TABLE [NC_RADIO_CHECK]
GO

CREATE TABLE [dbo].[NC_RADIO](
      [Rnk] bigint      null,
      [Type] [varchar](50) NULL,
      [SessionId] [bigint] NULL,
      [TestId] [bigint] NULL,
      [MsgTime] [datetime2](3) NULL,
      [Tec] [varchar](4)  NULL,
      [SignalStrength] [real] NULL,
      [SignalQuality] [real] NULL
) ON [MainGroup]

GO

CREATE TABLE #Temp(
      [Type] [varchar](50) NULL,
      [SessionId] [bigint] NULL,
      [TestId] [bigint] NULL,
      [MsgTime] [datetime2](3) NULL,
      [Tec] [varchar](4)  NULL,
      [SignalStrength] [real] NULL,
      [SignalQuality] [real] NULL
) 

GO

insert INTO #temp
SELECT
      cast('Radio' as varchar(50)) as Type,
      SessionId,
      TestId,
      MsgTime,
      'GSM' AS Tec,
      CASE WHEN formatId LIKE 'DEDICATED' THEN RxLevSub  ELSE BCCH_RxLev     END AS SignalStrength,
      CASE WHEN formatId LIKE 'DEDICATED' THEN RxQualSub ELSE NULL           END AS SignalQuality

FROM 
      MsgGSMLayer1
WHERE RxLevSub IS NOT NULL OR RxQualSub IS NOT NULL


insert INTO #temp
SELECT DISTINCT
      'Radio' as Type,
      SessionId,
      TestId,
      MsgTime,
      'UMTS' AS Tec,
      AggrRSCP AS SignalStrength,
      AggrEcIo AS SignalQuality
FROM 
      WCDMAActiveSet
WHERE AggrRSCP IS NOT NULL OR AggrEcIo IS NOT NULL

insert INTO #temp
SELECT
      'Radio' as Type,
      SessionId,
      TestId,
      MsgTime,
      'LTE'                  AS Tec,
      RSRP AS SignalStrength,
      RSRQ AS SignalQuality
FROM 
      LTEMeasurementReport

WHERE RSRP IS NOT NULL OR RSRQ IS NOT NULL

GO

SELECT
            sa.SessionId,
            sb.SessionId AS SessionID_B,

            sa.FileId AS FILE_ID_A,
            sb.FileId AS FILE_ID_B,
            sa.sessionType,
            MAX(CASE WHEN MarkerText LIKE 'Start Dial'           AND m.Info LIKE 'A'          THEN m.MsgTime  ELSE NULL    END) AS Start_Dial_A,
            MAX(CASE WHEN MarkerText LIKE 'Dial'                 AND m.Info LIKE 'A'          THEN m.MsgTime  ELSE NULL    END) AS Dial_A,
            MAX(CASE WHEN MarkerText LIKE 'Incoming Call'        AND m.Info LIKE 'A'          THEN m.MsgTime  ELSE NULL    END) AS Incoming_Call_A,
            MAX(CASE WHEN MarkerText LIKE 'Connected'            AND m.Info LIKE 'A'          THEN m.MsgTime  ELSE NULL    END) AS Connected_A,
            MAX(CASE WHEN MarkerText LIKE 'Disconnect'           AND m.Info LIKE 'A'          THEN m.MsgTime  ELSE NULL    END) AS Disconnect_A,
            MAX(CASE WHEN MarkerText LIKE 'Released'             AND m.Info LIKE 'A'          THEN m.MsgTime  ELSE NULL    END) AS Released_A,
            MAX(CASE WHEN MarkerText LIKE 'Break'                AND m.Info LIKE 'A'          THEN m.MsgTime  ELSE NULL    END) AS 'Break_A',
            MAX(CASE WHEN MarkerText LIKE 'ConnectFailed'        AND m.Info LIKE 'A'          THEN m.MsgTime  ELSE NULL    END) AS ConnectFailed_A,
            MAX(CASE WHEN MarkerText LIKE 'System Release'       AND m.Info LIKE 'A'          THEN m.MsgTime  ELSE NULL    END) AS System_Release_A,
            MAX(CASE WHEN MarkerText LIKE 'Start Dial'           AND m.Info LIKE 'B'          THEN m.MsgTime  ELSE NULL    END) AS Start_Dial_B,
            MAX(CASE WHEN MarkerText LIKE 'Dial'                 AND m.Info LIKE 'B'          THEN m.MsgTime  ELSE NULL    END) AS Dial_B,
            MAX(CASE WHEN MarkerText LIKE 'Incoming Call'        AND m.Info LIKE 'B'          THEN m.MsgTime  ELSE NULL    END) AS Incoming_Call_B,
            MAX(CASE WHEN MarkerText LIKE 'Connected'            AND m.Info LIKE 'B'          THEN m.MsgTime  ELSE NULL    END) AS Connected_B,
            MAX(CASE WHEN MarkerText LIKE 'Disconnect'           AND m.Info LIKE 'B'          THEN m.MsgTime  ELSE NULL    END) AS Disconnect_B,
            MAX(CASE WHEN MarkerText LIKE 'Released'             AND m.Info LIKE 'B'          THEN m.MsgTime  ELSE NULL    END) AS Released_B,
            MAX(CASE WHEN MarkerText LIKE 'Break'                AND m.Info LIKE 'B'          THEN m.MsgTime  ELSE NULL    END) AS 'Break_B',
            MAX(CASE WHEN MarkerText LIKE 'ConnectFailed'        AND m.Info LIKE 'B'          THEN m.MsgTime  ELSE NULL    END) AS ConnectFailed_B,
            MAX(CASE WHEN MarkerText LIKE 'System Release'       AND m.Info LIKE 'B'          THEN m.MsgTime  ELSE NULL    END) AS System_Release_B

            INTO #temp1

            FROM Sessions sa

            JOIN SessionsB sb                  ON sa.SessionId = sb.SessionIdA
            LEFT OUTER JOIN Markers m          ON sa.SessionId =  m.sessionID

GROUP BY sa.SessionId, sb.SessionId, sa.sessionType, sa.FileId, sb.FileId 
ORDER BY sa.SESSiONID

GO

insert into #temp
select 
      'Break_A',
      SessionID, 
      null,
      Break_A,
      null,
      null,
      null
from
      #temp1
where Break_A is not null

insert into #temp
select 
      'ConnectFailed_A',
      SessionID, 
      null,
      ConnectFailed_A,
      null,
      null,
      null
from
      #temp1
where ConnectFailed_A is not null


insert into #temp
select 
      'Break_B',
      SessionID_B, 
      null,
      Break_B,
      null,
      null,
      null
from
      #temp1
where Break_B is not null


insert into #temp
select 
      'ConnectFailed_B',
      SessionID_B, 
      null,
      ConnectFailed_B,
      null,
      null,
      null
from
      #temp1
where ConnectFailed_B is not null

insert into NC_Radio
select 
      ROW_NUMBER() over(partition by sessionid order by msgtime) as rnk,* 
from 
      #temp



select 
      'Break_A' as Type,
      r.SessionId,
      r1.Tec,
      
      _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r1.SignalStrength))) as [AVG_RxLevel_last_8_till_4_Samples],     
      _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r2.SignalStrength))) as [AVG_RxLevel_last_4_till_1_Samples],   
        _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r3.SignalStrength))) as [AVG_RxLevel_last_Sample],   
 
        ABS(_Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r1.SignalStrength))) - _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r3.SignalStrength)))) as DELTA_RxLevel,

      CAST(null AS varchar(500)) AS RxLevel_CHECK,
      CAST(null AS varchar(500)) AS RxLevel_TREND,  
      
        CASE WHEN r1.Tec = 'GSM' THEN avg(r1.SignalQuality)
                                         ELSE _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r1.SignalQuality))) END AS [AVG_RxQuality_last_8_till_4_Samples], 
      
      CASE WHEN r1.Tec = 'GSM' THEN avg(r2.SignalQuality)
                                         ELSE _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r2.SignalQuality))) END AS [AVG_RxQuality_last_4_till_1_Samples], 
      
      CASE WHEN r1.Tec = 'GSM' THEN avg(r3.SignalQuality)
                                         ELSE _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r3.SignalQuality))) END AS [AVG_RxQuality_last_Sample], 

      CASE WHEN r1.Tec = 'GSM' THEN ABS(avg(r1.SignalQuality) - avg(r3.SignalQuality))
                                         ELSE ABS(_Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r1.SignalQuality))) - _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r3.SignalQuality)))) END AS DELTA_RxQuality,

      CAST(null AS varchar(500)) AS RxQuality_CHECK,  
      CAST(null AS varchar(500)) AS RxQuality_TREND,
      CAST(null AS varchar(500)) AS Rx_Radio_Result 
        

INTO NC_RADIO_CHECK            
from 
      NC_Radio r
      join NC_RADIO r0 on r.SessionId=r0.SessionId and r.Type='Break_A' and r0.Type='Radio' and r.Rnk=r0.rnk+1 
      join NC_RADIO r1 on r.SessionId=r1.SessionId and r.Type='Break_A' and r1.Type='Radio' and r.Rnk>r1.rnk and (r.Rnk-r1.Rnk)<= 7 and (r.Rnk-r1.Rnk)> 4 and r1.Tec<>'LTE' and r1.tec=r0.tec
      join NC_RADIO r2 on r.SessionId=r2.SessionId and r.Type='Break_A' and r2.Type='Radio' and r.Rnk>r2.rnk and (r.Rnk-r2.Rnk)<= 4 and (r.Rnk-r1.Rnk)> 1 and r2.Tec<>'LTE' and r2.tec=r0.tec
      join NC_RADIO r3 on r.SessionId=r3.SessionId and r.Type='Break_A' and r3.Type='Radio' and r.Rnk>r3.rnk and (r.Rnk-r3.Rnk)<= 1 and r3.Tec<>'LTE' and r3.tec=r0.tec

group by r.sessionid,r1.Tec,r2.Tec,r3.Tec
union all
select 
      'Break_B' as Type,
      r.SessionId,
      r1.Tec,
      
      _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r1.SignalStrength))) as [AVG_RxLevel_last_8_till_4_Samples],     
      _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r2.SignalStrength))) as [AVG_RxLevel_last_4_till_1_Samples],   
        _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r3.SignalStrength))) as [AVG_RxLevel_last_Sample],   
 
        ABS(_Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r1.SignalStrength))) - _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r3.SignalStrength)))) as DELTA_RxLevel,

      CAST(null AS varchar(500)) AS RxLevel_CHECK,
      CAST(null AS varchar(500)) AS RxLevel_TREND,  
  
      
        CASE WHEN r1.Tec = 'GSM' THEN avg(r1.SignalQuality)
                                         ELSE _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r1.SignalQuality))) END AS [AVG_RxQuality_last_8_till_4_Samples], 
      
      CASE WHEN r1.Tec = 'GSM' THEN avg(r2.SignalQuality)
                                         ELSE _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r2.SignalQuality))) END AS [AVG_RxQuality_last_4_till_1_Samples], 
      
      CASE WHEN r1.Tec = 'GSM' THEN avg(r3.SignalQuality)
                                         ELSE _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r3.SignalQuality))) END AS [AVG_RxQuality_last_Sample], 

      CASE WHEN r1.Tec = 'GSM' THEN ABS(avg(r1.SignalQuality) - avg(r3.SignalQuality))
                                         ELSE ABS(_Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r1.SignalQuality))) - _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r3.SignalQuality)))) END AS DELTA_RxQuality,

      CAST(null AS varchar(500)) AS RxQuality_CHECK,  
      CAST(null AS varchar(500)) AS RxQuality_TREND,  
      CAST(null AS varchar(500)) AS Rx_Radio_Result 
     
            
from 
      NC_Radio r
      join NC_RADIO r0 on r.SessionId=r0.SessionId and r.Type='Break_B' and r0.Type='Radio' and r.Rnk=r0.rnk+1 
      join NC_RADIO r1 on r.SessionId=r1.SessionId and r.Type='Break_B' and r1.Type='Radio' and r.Rnk>r1.rnk and (r.Rnk-r1.Rnk)<= 7  and (r.Rnk-r1.Rnk)> 4 and r1.Tec<>'LTE' and r1.tec=r0.tec
      join NC_RADIO r2 on r.SessionId=r2.SessionId and r.Type='Break_B' and r2.Type='Radio' and r.Rnk>r2.rnk and (r.Rnk-r2.Rnk)<= 4  and (r.Rnk-r1.Rnk)> 1 and r2.Tec<>'LTE' and r2.tec=r0.tec
      join NC_RADIO r3 on r.SessionId=r3.SessionId and r.Type='Break_B' and r3.Type='Radio' and r.Rnk>r3.rnk and (r.Rnk-r3.Rnk)<= 1  and r3.Tec<>'LTE' and r3.tec=r0.tec


group by r.sessionid,r1.Tec,r2.Tec,r3.Tec

union all
select 
      'ConnectFailed_A' as Type,
      r.SessionId,
      r1.Tec,
      
      _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r1.SignalStrength))) as [AVG_RxLevel_last_8_till_4_Samples],     
      _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r2.SignalStrength))) as [AVG_RxLevel_last_4_till_1_Samples],   
        _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r3.SignalStrength))) as [AVG_RxLevel_last_Sample],   
 
        ABS(_Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r1.SignalStrength))) - _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r3.SignalStrength)))) as DELTA_RxLevel,

      CAST(null AS varchar(500)) AS RxLevel_CHECK,
      CAST(null AS varchar(500)) AS RxLevel_TREND,  
      
        CASE WHEN r1.Tec = 'GSM' THEN avg(r1.SignalQuality)
                                         ELSE _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r1.SignalQuality))) END AS [AVG_RxQuality_last_8_till_4_Samples], 
      
      CASE WHEN r1.Tec = 'GSM' THEN avg(r2.SignalQuality)
                                         ELSE _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r2.SignalQuality))) END AS [AVG_RxQuality_last_4_till_1_Samples], 
      
      CASE WHEN r1.Tec = 'GSM' THEN avg(r3.SignalQuality)
                                         ELSE _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r3.SignalQuality))) END AS [AVG_RxQuality_last_Sample], 

      CASE WHEN r1.Tec = 'GSM' THEN ABS(avg(r1.SignalQuality) - avg(r3.SignalQuality))
                                         ELSE ABS(_Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r1.SignalQuality))) - _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r3.SignalQuality)))) END AS DELTA_RxQuality,

      CAST(null AS varchar(500)) AS RxQuality_CHECK,  
      CAST(null AS varchar(500)) AS RxQuality_TREND,  
      CAST(null AS varchar(500)) AS Rx_Radio_Result 
            
from 
      NC_Radio r
      
      join NC_RADIO r0 on r.SessionId=r0.SessionId and r.Type='ConnectFailed_A' and r0.Type='Radio' and r.Rnk=r0.rnk+1 
      join NC_RADIO r1 on r.SessionId=r1.SessionId and r.Type='ConnectFailed_A' and r1.Type='Radio' and r.Rnk>r1.rnk and (r.Rnk-r1.Rnk)<= 7 and (r.Rnk-r1.Rnk)> 4 and r1.tec=r0.tec
      join NC_RADIO r2 on r.SessionId=r2.SessionId and r.Type='ConnectFailed_A' and r2.Type='Radio' and r.Rnk>r2.rnk and (r.Rnk-r2.Rnk)<= 4 and (r.Rnk-r1.Rnk)> 1 and r2.tec=r0.tec
      join NC_RADIO r3 on r.SessionId=r3.SessionId and r.Type='ConnectFailed_A' and r3.Type='Radio' and r.Rnk>r3.rnk and (r.Rnk-r3.Rnk)<= 1 and r3.tec=r0.tec

group by r.sessionid,r1.Tec,r2.Tec,r3.Tec
     
union all

select 
      'ConnectFailed_B' as Type,
      r.SessionId,
      r1.Tec,
      
      _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r1.SignalStrength))) as [AVG_RxLevel_last_8_till_4_Samples],     
      _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r2.SignalStrength))) as [AVG_RxLevel_last_4_till_1_Samples],   
        _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r3.SignalStrength))) as [AVG_RxLevel_last_Sample],   
 
        ABS(_Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r1.SignalStrength))) - _Master_DB.dbo.Lin_dBm( avg(_Master_DB.dbo.dBm_Lin(r3.SignalStrength)))) as DELTA_RxLevel,

      CAST(null AS varchar(500)) AS RxLevel_CHECK,
      CAST(null AS varchar(500)) AS RxLevel_TREND,  
      
        CASE WHEN r1.Tec = 'GSM' THEN avg(r1.SignalQuality)
                                         ELSE _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r1.SignalQuality))) END AS [AVG_RxQuality_last_8_till_4_Samples], 
      
      CASE WHEN r1.Tec = 'GSM' THEN avg(r2.SignalQuality)
                                         ELSE _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r2.SignalQuality))) END AS [AVG_RxQuality_last_4_till_1_Samples], 
      
      CASE WHEN r1.Tec = 'GSM' THEN avg(r3.SignalQuality)
                                         ELSE _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r3.SignalQuality))) END AS [AVG_RxQuality_last_Sample], 

      CASE WHEN r1.Tec = 'GSM' THEN ABS(avg(r1.SignalQuality) - avg(r3.SignalQuality))
                                         ELSE ABS(_Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r1.SignalQuality))) - _Master_DB.dbo.Lin_dB(avg(_Master_DB.dbo.dB_Lin(r3.SignalQuality)))) END AS DELTA_RxQuality,

      CAST(null AS varchar(500)) AS RxQuality_CHECK,  
      CAST(null AS varchar(500)) AS RxQuality_TREND,  
      CAST(null AS varchar(500)) AS Rx_Radio_Result  
       
       
FROM
      NC_Radio r
      join NC_RADIO r0 on r.SessionId=r0.SessionId and r.Type='ConnectFailed_B' and r0.Type='Radio' and r.Rnk=r0.rnk+1 
      join NC_RADIO r1 on r.SessionId=r1.SessionId and r.Type='ConnectFailed_B' and r1.Type='Radio' and r.Rnk>r1.rnk and (r.Rnk-r1.Rnk)<= 7 and (r.Rnk-r1.Rnk)> 4 and r1.tec=r0.tec
      join NC_RADIO r2 on r.SessionId=r2.SessionId and r.Type='ConnectFailed_B' and r2.Type='Radio' and r.Rnk>r2.rnk and (r.Rnk-r2.Rnk)<= 4 and (r.Rnk-r1.Rnk)> 1 and r2.tec=r0.tec
      join NC_RADIO r3 on r.SessionId=r3.SessionId and r.Type='ConnectFailed_B' and r3.Type='Radio' and r.Rnk>r3.rnk and (r.Rnk-r3.Rnk)<= 1 and r3.tec=r0.tec

group by r.sessionid,r1.Tec,r2.Tec,r3.Tec
order by r.sessionid

GO


UPDATE NC_RADIO_CHECK

SET [RxLevel_CHECK]= CASE WHEN Tec = 'GSM'  AND (AVG_RxLevel_last_Sample <= -100 OR AVG_RxLevel_last_8_till_4_Samples     <= -100)                                                                                                                         THEN 'Critic'
                                     WHEN Tec = 'GSM'  AND (AVG_RxLevel_last_Sample <= -90      OR AVG_RxLevel_last_8_till_4_Samples     <= -90)    AND  ( AVG_RxLevel_last_Sample > -100 OR AVG_RxLevel_last_8_till_4_Samples > -100) THEN 'Bad'
                                      WHEN Tec = 'GSM'  AND (AVG_RxLevel_last_Sample  > -90  OR AVG_RxLevel_last_8_till_4_Samples      > -90)                                                                                                                             THEN 'OK'
                             
                                     WHEN Tec = 'UMTS'  AND (AVG_RxLevel_last_Sample <= -100 OR AVG_RxLevel_last_8_till_4_Samples    <= -100)                                                                                                                                   THEN 'Critic'
                                     WHEN Tec = 'UMTS'  AND (AVG_RxLevel_last_Sample <= -90      OR AVG_RxLevel_last_8_till_4_Samples <= -90)  AND  ( AVG_RxLevel_last_Sample > -100 OR AVG_RxLevel_last_8_till_4_Samples > -100) THEN 'Bad'
                                     WHEN Tec = 'UMTS'  AND (AVG_RxLevel_last_Sample  > -90  OR AVG_RxLevel_last_8_till_4_Samples     > -90)                                                                                                                              THEN 'OK'

                                     WHEN Tec = 'LTE'  AND (AVG_RxLevel_last_Sample <= -110 OR AVG_RxLevel_last_8_till_4_Samples     <= -110)                                                                                                                                  THEN 'Critic'
                                     WHEN Tec = 'LTE'  AND (AVG_RxLevel_last_Sample <= -100      OR AVG_RxLevel_last_8_till_4_Samples <= -100) AND  ( AVG_RxLevel_last_Sample > -110 OR AVG_RxLevel_last_8_till_4_Samples > -110) THEN 'Bad'
                                     WHEN Tec = 'LTE'  AND (AVG_RxLevel_last_Sample  > -100  OR AVG_RxLevel_last_8_till_4_Samples     > -100)                                                                                                                             THEN 'OK'
                    
ELSE '???' END

GO

UPDATE NC_RADIO_CHECK

SET RxLevel_TREND = CASE 

                                   WHEN DELTA_RxLevel <   6 AND AVG_RxLevel_last_Sample > AVG_RxLevel_last_4_till_1_Samples AND AVG_RxLevel_last_4_till_1_Samples > AVG_RxLevel_last_8_till_4_Samples THEN '+'
                                   WHEN DELTA_RxLevel >=  6 AND DELTA_RxLevel < 12 AND AVG_RxLevel_last_Sample > AVG_RxLevel_last_4_till_1_Samples AND AVG_RxLevel_last_4_till_1_Samples > AVG_RxLevel_last_8_till_4_Samples THEN '+ +'
                                   WHEN DELTA_RxLevel >= 12 AND AVG_RxLevel_last_Sample > AVG_RxLevel_last_4_till_1_Samples AND AVG_RxLevel_last_4_till_1_Samples > AVG_RxLevel_last_8_till_4_Samples THEN '+ + +'


                                   WHEN DELTA_RxLevel <   6 AND AVG_RxLevel_last_Sample < AVG_RxLevel_last_4_till_1_Samples AND AVG_RxLevel_last_4_till_1_Samples < AVG_RxLevel_last_8_till_4_Samples THEN '-'
                                   WHEN DELTA_RxLevel >=  6 AND DELTA_RxLevel < 12 AND  AVG_RxLevel_last_Sample < AVG_RxLevel_last_4_till_1_Samples AND AVG_RxLevel_last_4_till_1_Samples < AVG_RxLevel_last_8_till_4_Samples THEN '- -'
                                   WHEN DELTA_RxLevel >= 12 AND AVG_RxLevel_last_Sample < AVG_RxLevel_last_4_till_1_Samples AND AVG_RxLevel_last_4_till_1_Samples < AVG_RxLevel_last_8_till_4_Samples THEN '- - -'



                             ELSE '=' END
GO

UPDATE NC_RADIO_CHECK
SET [RxQuality_CHECK]= CASE WHEN Tec = 'GSM' AND (AVG_RxQuality_last_Sample >= 6  OR AVG_RxQuality_last_8_till_4_Samples >= 6)                                                                                                                                       THEN 'Critic'
                                         WHEN Tec = 'GSM' AND (AVG_RxQuality_last_Sample >= 5  OR AVG_RxQuality_last_8_till_4_Samples >= 5) AND  (AVG_RxQuality_last_Sample < 6 OR AVG_RxQuality_last_8_till_4_Samples < 6)             THEN 'Bad'
                                         WHEN Tec = 'GSM' AND (AVG_RxQuality_last_Sample <  5  OR AVG_RxQuality_last_8_till_4_Samples <  5)                                                                                                                                    THEN 'OK'
                                         
                                         WHEN Tec = 'UMTS' AND (AVG_RxQuality_last_Sample <= -15  OR AVG_RxQuality_last_8_till_4_Samples <= -15)                                                                                                                             THEN 'Critic'
                                         WHEN Tec = 'UMTS' AND (AVG_RxQuality_last_Sample <= -10  OR AVG_RxQuality_last_8_till_4_Samples <= -10) AND (AVG_RxQuality_last_Sample > -15 OR AVG_RxQuality_last_8_till_4_Samples > -15)     THEN 'Bad'
                                         WHEN Tec = 'UMTS' AND (AVG_RxQuality_last_Sample >  -10  OR AVG_RxQuality_last_8_till_4_Samples >  -10)                                                                                                                             THEN 'OK'

                                         WHEN Tec = 'LTE' AND (AVG_RxQuality_last_Sample <= -30  OR AVG_RxQuality_last_8_till_4_Samples <= -30)                                                                                                                              THEN 'Critic'
                                         WHEN Tec = 'LTE' AND (AVG_RxQuality_last_Sample <= -20  OR AVG_RxQuality_last_8_till_4_Samples <= -20) AND (AVG_RxQuality_last_Sample > -30 OR AVG_RxQuality_last_8_till_4_Samples > -30)     THEN 'Bad'
                                         WHEN Tec = 'LTE' AND (AVG_RxQuality_last_Sample >  -20  OR AVG_RxQuality_last_8_till_4_Samples >  -20)                                                                                                                              THEN 'OK'
                                     
                                         ELSE '???' END

GO

UPDATE NC_RADIO_CHECK

SET RxQuality_TREND = CASE  WHEN DELTA_RxQuality <  3 AND TEC IN ('LTE','UMTS') AND (AVG_RxQuality_last_8_till_4_Samples > AVG_RxQuality_last_4_till_1_Samples AND AVG_RxQuality_last_4_till_1_Samples > AVG_RxQuality_last_Sample)  THEN '-'
                                         WHEN DELTA_RxQuality >= 3 AND DELTA_RxQuality < 6 AND TEC IN ('LTE','UMTS') AND (AVG_RxQuality_last_8_till_4_Samples > AVG_RxQuality_last_4_till_1_Samples AND AVG_RxQuality_last_4_till_1_Samples > AVG_RxQuality_last_Sample)  THEN '- - -'
                                         WHEN DELTA_RxQuality >= 6 AND TEC IN ('LTE','UMTS') AND (AVG_RxQuality_last_8_till_4_Samples > AVG_RxQuality_last_4_till_1_Samples AND AVG_RxQuality_last_4_till_1_Samples > AVG_RxQuality_last_Sample)  THEN '- - -'    
                                         
                                         WHEN DELTA_RxQuality <  3 AND TEC IN ('GSM')   AND (AVG_RxQuality_last_8_till_4_Samples > AVG_RxQuality_last_4_till_1_Samples AND AVG_RxQuality_last_4_till_1_Samples > AVG_RxQuality_last_Sample) THEN '+'          
                                         WHEN DELTA_RxQuality >= 3 AND DELTA_RxQuality < 6 AND TEC IN ('GSM') AND (AVG_RxQuality_last_8_till_4_Samples > AVG_RxQuality_last_4_till_1_Samples AND AVG_RxQuality_last_4_till_1_Samples > AVG_RxQuality_last_Sample)   THEN '+ +'
                                         WHEN DELTA_RxQuality >= 6 AND TEC IN ('GSM')   AND (AVG_RxQuality_last_8_till_4_Samples > AVG_RxQuality_last_4_till_1_Samples AND AVG_RxQuality_last_4_till_1_Samples > AVG_RxQuality_last_Sample) THEN '+ + +'
                                         
                                         WHEN DELTA_RxQuality <  3 AND TEC IN ('LTE','UMTS') AND (AVG_RxQuality_last_8_till_4_Samples < AVG_RxQuality_last_4_till_1_Samples AND AVG_RxQuality_last_4_till_1_Samples < AVG_RxQuality_last_Sample)  THEN '+'
                                         WHEN DELTA_RxQuality >= 3 AND DELTA_RxQuality < 6 AND TEC IN ('LTE','UMTS') AND (AVG_RxQuality_last_8_till_4_Samples < AVG_RxQuality_last_4_till_1_Samples AND AVG_RxQuality_last_4_till_1_Samples < AVG_RxQuality_last_Sample)  THEN '+ +'
                                         WHEN DELTA_RxQuality >= 6 AND TEC IN ('LTE','UMTS') AND (AVG_RxQuality_last_8_till_4_Samples < AVG_RxQuality_last_4_till_1_Samples AND AVG_RxQuality_last_4_till_1_Samples < AVG_RxQuality_last_Sample)  THEN '+ + +'

                                         WHEN DELTA_RxQuality <  3 AND TEC IN ('GSM')   AND (AVG_RxQuality_last_8_till_4_Samples < AVG_RxQuality_last_4_till_1_Samples AND AVG_RxQuality_last_4_till_1_Samples < AVG_RxQuality_last_Sample)  THEN '-'
                                          WHEN DELTA_RxQuality >= 3 AND DELTA_RxQuality < 6 AND TEC IN ('GSM') AND (AVG_RxQuality_last_8_till_4_Samples < AVG_RxQuality_last_4_till_1_Samples AND AVG_RxQuality_last_4_till_1_Samples < AVG_RxQuality_last_Sample)  THEN '- -'
                                         WHEN DELTA_RxQuality >= 6 AND  TEC IN ('GSM')  AND (AVG_RxQuality_last_8_till_4_Samples < AVG_RxQuality_last_4_till_1_Samples AND AVG_RxQuality_last_4_till_1_Samples < AVG_RxQuality_last_Sample)  THEN '- - -'

                                         ELSE '=' END


GO


UPDATE NC_RADIO_CHECK

SET Rx_Radio_Result = CASE  WHEN RxLevel_CHECK LIKE 'OK'     AND RxQuality_CHECK LIKE 'OK'                        THEN 'OK'
                                         WHEN RxLevel_CHECK LIKE 'Critic'  OR RxQuality_CHECK LIKE 'Critic'                THEN 'Critic'
                                         
                                         WHEN (RxLevel_CHECK LIKE 'Bad' AND RxLevel_TREND IN     ('- -','- - -')) OR (RxQuality_CHECK LIKE 'Bad' AND RxQuality_TREND IN ('- -','- - -')) THEN 'Critic'
                                         WHEN (RxLevel_CHECK LIKE 'Bad' AND RxLevel_TREND NOT IN ('- -','- - -')) OR (RxQuality_CHECK LIKE 'Bad' AND RxQuality_TREND NOT IN ('- -','- - -')) THEN 'OK'

                                         WHEN  RxLevel_CHECK   LIKE 'OK' AND ((RxQuality_CHECK LIKE 'Bad' AND RxQuality_TREND IN ('- -','- - -')) OR RxQuality_CHECK LIKE 'Critic') THEN 'Critic'                                                     
                                         WHEN  RxQuality_CHECK LIKE 'OK' AND ((RxLevel_CHECK   LIKE 'Bad' AND RxLevel_TREND   IN ('- -','- - -')) OR RxLevel_CHECK LIKE 'Critic')      THEN 'Critic'    
                                                                                  
                                         ELSE '???' END

GO

DROP TABLE #temp

GO

DROP TABLE #temp1

/*
GO

SELECT

Type,
SessionId,
Tec,
ROUND (AVG_RxLevel_last_8_till_4_Samples,1) AS RxLevel_last_8_till_4_Samples,
ROUND (AVG_RxLevel_last_4_till_1_Samples,1)    AS RxLevel_last_4_till_1_Samples,
ROUND (AVG_RxLevel_last_Sample,1)              AS RxLevel_last_Sample,
ROUND (DELTA_RxLevel,1)                              AS DELTA_RxLevel,
RxLevel_CHECK,
RxLevel_TREND,
ROUND (AVG_RxQuality_last_8_till_4_Samples,1) AS RxQuality_last_8_till_4_Samples,
ROUND (AVG_RxQuality_last_4_till_1_Samples,1) AS RxQuality_last_4_till_1_Samples,
ROUND (AVG_RxQuality_last_Sample,1)              AS RxQuality_last_Sample,
ROUND (DELTA_RxQuality,1)                              AS DELTA_RxQuality,
RxQuality_CHECK,
RxQuality_TREND,
Rx_Radio_Result

FROM NC_RADIO_CHECK
ORDER BY TEC
*/
