Select 
	msgId, 
	SessionID, 
	TestID, 
	dbo.DelphiDateTime(msgTime) as dTime, 
	CONVERT(varchar,msgTime,14) AS msgTime2, 
	networkId, 
	RTRIM(parseCode) as parseCode, 
	DataSent as message, 'U' AS direction,                                     
	'-' AS protDiscr,                                     
	'-' AS msgType,                                       
	'RR' AS Layer,                                       
	ChReqType AS msg,                                       
	0 as LogChanType,                                       
	'0' as MsgIdent,                                      
	0 as Rb_id,                                             
	0 as ChnType                                     
	into NC_L3 from vChannelRequest                                      
UNION Select 
	msgId, 
	SessionID, 
	TestID, 
	dbo.DelphiDateTime(msgTime) as dTime, 
	CONVERT(varchar,msgTime,14) AS msgTime2, 
	networkId, 
	'626' as parseCode,                        
	message,  
	direction,                                              
	protDiscr,                                              
	msgType,                                                
	Layer,                                                  
	msg,                                                    
	0 as LogChanType,                                       
	'0' as MsgIdent,                                      
	0 as Rb_id,                                             
	0 as ChnType                                     
	from vMsgGSML3Data                                       
UNION Select 
	msgId, 
	SessionID, 
	TestID, 
	dbo.DelphiDateTime(msgTime) as dTime, 
	CONVERT(varchar,msgTime,14) AS msgTime2, 
	networkId, '62G0' as parseCode,                       
	message,                                                
	direction,                                              
	protDiscr,                                              
	msgType COLLATE Latin1_General_CI_AS as msgType,        
	'GPRS RLC/MAC' AS Layer,                              
	msg,                                                    
	0 as LogChanType,                                       
	'0' as MsgIdent,                                      
	0 as Rb_id,                                             
	0 as ChnType                                     
	from vGPRSRLCMAC                                          
UNION Select 
	msgId, 
	SessionID, 
	TestID, 
	dbo.DelphiDateTime(msgTime) as dTime, 
	CONVERT(varchar,msgTime,14) AS msgTime2, 
	networkId, '62G1' as parseCode,                       
	message,                                                
	direction,                                              
	protDiscr,                                              
	msgType,                                                
	protDisc AS Layer,                                      
	msgTypeTxt as msg,                                      
	0 as LogChanType,                                       
	'0' as MsgIdent,                                      
	0 as Rb_id,                                             
	0 as ChnType                                     
	from vGPRSInterLayerGMMSM                               
UNION Select 
	msgId, 
	SessionID, 
	TestID, 
	dbo.DelphiDateTime(msgTime) as dTime, 
	CONVERT(varchar,msgTime,14) AS msgTime2, 
	NetworkId, 'RRC' as parseCode,                 
	msg as message,                                     
	Direction,                                          
	' ' as protDiscr,                                 
	RTRIM(msgType) as MsgType,                          
	'RRC' AS Layer,                                   
	MsgName as msg,                                     
	LogChanType,                                        
	MsgIdent,                                           
	Rb_id,                                              
	0 as ChnType                                 
	from vWCDMARRCMessages                              
	where  LogChanType <> 9  
UNION Select 
	msgId, 
	SessionID, 
	TestID, 
	dbo.DelphiDateTime(msgTime) as dTime, 
	CONVERT(varchar,msgTime,14) AS msgTime2, 
	NetworkId, 'LTE' as parseCode,                 
	Msg as message,                                     
	Direction,                                          
	' ' as protDiscr,                                 
	dbo.IntToHex(MsgType, 
	2) as MsgType,                
	'LTE-RRC' AS Layer,                               
	MsgName as msg,                                     
	NULL as LogChanType,                                
	NULL as MsgIdent,                                   
	NULL as Rb_id,                                      
	ChnType                                      
	from vLTERRCMessages                                 
UNION Select 
	msgId, 
	SessionID, 
	TestID, 
	dbo.DelphiDateTime(msgTime) as dTime, 
	CONVERT(varchar,msgTime,14) AS msgTime2, 
	NetworkId, 'LTE-NAS' as parseCode,             
	Msg as message,                                     
	Direction as direction,                             
	'0' as protDiscr,                                 
	dbo.IntToHex(MsgType, 2) as MsgType,                
	'LTE-NAS' AS Layer,                               
	Protocol + '- ' + MsgTypeName as msg,             
	NULL as LogChanType,                                
	NULL as MsgIdent,                                   
	NULL as Rb_id,                                      
	NULL as ChnType                              
	from LTENASMessages                                   
	order by dTime, MsgId
