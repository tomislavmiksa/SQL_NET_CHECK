IF OBJECT_ID ( 'NC_Scanner_RawData_GSM' ) IS NOT NULL 
    DROP Table NC_Scanner_RawData_GSM
GO



select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		1 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+0*31,30) ,1,4) as int)  as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+0*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+0*31,30) ,11,3) as float) as CoverI
into NC_Scanner_RawData_GSM
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		2 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+1*31,30) ,1,4) as int)as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+1*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+1*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		3 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+2*31,30) ,1,4) as int)  as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+2*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+2*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		4 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+3*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+3*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+3*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		5 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+4*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+4*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+4*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		6 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+5*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+5*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+5*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		7 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+6*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+6*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+6*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		8 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+7*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+7*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+7*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		9 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+8*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+8*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+8*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		10 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+9*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+9*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+9*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		11 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+10*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+10*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+10*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		12 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+11*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+11*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+11*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		13 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+12*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+12*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+12*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		14 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+13*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+13*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+13*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		15 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+14*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+14*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+14*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		16 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+15*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+15*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+15*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		17 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+16*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+16*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+16*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		18 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+17*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+17*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+17*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		19 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+18*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+18*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+18*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
union all
select 
		msgID,
		MsgTime,
		fl.Zone as SysID,
		h.PosId,
		h.NetworkId,
		RFBand,
		h.SessionId,
		Testid,
		20 as Top20Rnk,	
		cast(substring(SUBSTRING(top20,1+19*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+19*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+19*31,30) ,11,3) as float) as CoverI
from
	 MsgHotChannels h 
	join sessions s on h.sessionid=s.sessionid 
	join Filelist fl on s.fileid=fl.fileid
go
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160908-134823] ON [dbo].NC_Scanner_RawData_GSM
(
	
	[MsgTime] ASC,
	SysID ASC
	
	

)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO	



