IF OBJECT_ID ( 'NC_Scanner_RawData_LTE' ) IS NOT NULL 
    DROP Table NC_Scanner_RawData_LTE
GO

SELECT 
	tni.MsgId,
	tni.SessionId,
	tni.TestId,
	fl.Zone as SysID,
	tni.NetworkId,
	tni.PosId,
	tni.LTETopNId,
	tni.MsgTime,
	MCC,
	MNC,
	tni.Channel,
	ci.TAC,
	ci.CI,
	tn.PhCId,
	tn.RSRP,
	tn.RSRQ,
	tn.CINR,
	dbo.GetRFBand(tni.RFBand) AS RFBand,
	tni.Bandwidth


into NC_Scanner_RawData_LTE
from
	 MsgLTEScannerTopNInfo tni
	join MsgLTEScannerTopN tn on tni.LTETopNId=tn.LTETopNId  and RSRP is not null and Type=1
	left outer join MsgLTEScannerTopNCellInfo ci on tni.LTETopNId=ci.LTETopNId and ci.OrderId=tn.OrderId
	left outer join MsgLTEScannerTopNPLMN nplmn on nplmn.LTETopNId=tni.LTETopNId and ci.OrderId=nplmn.OrderId and nplmn.PLMNId=1 
	join sessions s on tni.sessionid=s.SessionId
	join Filelist fl on s.FileId=fl.Fileid

go
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160908-134823] ON [dbo].NC_Scanner_RawData_LTE
(
	
	[MsgTime] ASC,
	SysID ASC
	

)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO	