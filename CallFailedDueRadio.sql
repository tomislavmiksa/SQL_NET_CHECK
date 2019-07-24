select
	A.valid,
	A.InvalidReason,
	A.sessionID,
	A.Channel,
	A.Operator,
	A.Session_Type,
	A.Call_Type,
	A.Call_Status,
	A.Call_Status_Extend,
	A.Call_Mode_A,
	A.Call_Mode_B,
	A.No_Service,
	A.Silence_Call,
	A.Bad_Speech_Call,
	A.Error_Cause,
	A.Error_Description,
	A.Personal_Analysis_Cause,
	A.Personal_Analysis_Description,
	A.Disconnect_Direction,
	A.Disconnect_Class,
	A.Disconnect_Cause,
	A.Disconnect_Location
from
    NC_Calls_Distinct A
where
    A.sessionID in (
        select B.SessionId from NC_RADIO_CHECK B where B.Rx_Radio_Result LIKE 'Critic'
)