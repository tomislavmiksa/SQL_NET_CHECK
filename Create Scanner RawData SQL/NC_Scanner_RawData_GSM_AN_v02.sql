IF OBJECT_ID ( 'NC_Scanner_RawData_GSM' ) IS NOT NULL 
    DROP Table NC_Scanner_RawData_GSM
GO

-- select * from 

select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		1 as RNK,	
		cast(substring(SUBSTRING(top20,1+0*31,30) ,1,4) as int)  as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+0*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+0*31,30) ,11,3) as float) as CoverI
into NC_Scanner_RawData_GSM
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		2 as RNK,	
		cast(substring(SUBSTRING(top20,1+1*31,30) ,1,4) as int)as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+1*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+1*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		3 as RNK,	
		cast(substring(SUBSTRING(top20,1+2*31,30) ,1,4) as int)  as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+2*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+2*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		4 as RNK,	
		cast(substring(SUBSTRING(top20,1+3*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+3*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+3*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		5 as RNK,	
		cast(substring(SUBSTRING(top20,1+4*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+4*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+4*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		6 as RNK,	
		cast(substring(SUBSTRING(top20,1+5*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+5*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+5*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		7 as RNK,	
		cast(substring(SUBSTRING(top20,1+6*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+6*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+6*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		8 as RNK,	
		cast(substring(SUBSTRING(top20,1+7*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+7*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+7*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		9 as RNK,	
		cast(substring(SUBSTRING(top20,1+8*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+8*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+8*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		10 as RNK,	
		cast(substring(SUBSTRING(top20,1+9*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+9*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+9*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		11 as RNK,	
		cast(substring(SUBSTRING(top20,1+10*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+10*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+10*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		12 as RNK,	
		cast(substring(SUBSTRING(top20,1+11*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+11*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+11*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		13 as RNK,	
		cast(substring(SUBSTRING(top20,1+12*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+12*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+12*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		14 as RNK,	
		cast(substring(SUBSTRING(top20,1+13*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+13*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+13*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		15 as RNK,	
		cast(substring(SUBSTRING(top20,1+14*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+14*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+14*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		16 as RNK,	
		cast(substring(SUBSTRING(top20,1+15*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+15*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+15*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		17 as RNK,	
		cast(substring(SUBSTRING(top20,1+16*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+16*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+16*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		18 as RNK,	
		cast(substring(SUBSTRING(top20,1+17*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+17*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+17*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		19 as RNK,	
		cast(substring(SUBSTRING(top20,1+18*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+18*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+18*31,30) ,11,3) as float) as CoverI
from MsgHotChannels
union all
select 
		msgID,
		MsgTime,
		PosId,
		NetworkId,
		RFBand,
		SessionId,
		Testid,
		20 as RNK,	
		cast(substring(SUBSTRING(top20,1+19*31,30) ,1,4) as int) as Channel,
		cast(SUBSTRING(SUBSTRING(top20,1+19*31,30) ,6,4) as float) as RxLev ,
		cast(SUBSTRING(SUBSTRING(top20,1+19*31,30) ,11,3) as float) as CoverI
from MsgHotChannels




select * from NC_Scanner_RawData_GSM


SELECT top 1000 * FROM  MsgHotChannels