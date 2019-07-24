SELECT 
valid,
InvalidReason,
sessionID,
Channel,
Operator,
Session_Type,
Call_Type,
Call_Status,
Call_Status_Extend,
Call_Mode_A,
Call_Mode_B,
No_Service,
Silence_Call,
Bad_Speech_Call,
Error_Cause,
Error_Description,
Personal_Analysis_Cause,
Personal_Analysis_Description,
Disconnect_Direction,
Disconnect_Class,
Disconnect_Cause,
Disconnect_Location

FROM NC_Calls_Distinct
WHERE	Session_Type LIKE 'CALL' AND Call_Status NOT LIKE 'Completed' 	---AND Channel LIKE 'CH1'

ORDER BY Error_Cause, Error_Description