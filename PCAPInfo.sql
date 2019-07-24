SELECT
	   [MsgId]
      ,[SessionId]
      ,[TestId]
      ,[MsgTime]
      ,[PosId]
      ,[NetworkId]
      ,[src]
      ,[dst]
      ,[protocol]
      ,[msg]
  FROM [Burda_Data_2015].[dbo].[MsgEthereal]
  WHERE SessionId like '2'
  ORDER BY MsgTime