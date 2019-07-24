IF OBJECT_ID ( 'NC_Scanner_RawData_WCDMA' ) IS NOT NULL 
    DROP Table NC_Scanner_RawData_WCDMA
GO

select 

			identity (int,1,1) as ID, 
			spi.MsgTime,
			fl.Zone as SysId,
			sp.CId,
			sp.MCC,
			sp.MNC,
			sp.LAC,
			spi.Channel,
			sp.number as PSC,
			spi.IO as 'RSSI',
			spi.IO + sp.EcIoData as 'RSCP',
			sp.EcIoData as 'Ec/No',
			spi.SessionId,
			spi.TestId,
			spi.PosId,
			spi.NetworkId
		
into  NC_Scanner_RawData_WCDMA
from 

	MsgWCDMAScannerPilotInfo spi
	join MsgWCDMAScannerPilot sp on spi.WPilotId=sp.WPilotId
	join sessions s on spi.SessionId=s.sessionid
	join FileList fl on s.FileId=fl.fileID

go
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160908-134823] ON [dbo].NC_Scanner_RawData_WCDMA
(
	
	[MsgTime] ASC,
	SysId ASC
	
	

)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO	
 
	

	