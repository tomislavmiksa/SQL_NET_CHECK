SELECT TOP 1000 [MsgId]
      ,[SessionId]
      ,[TestId]
      ,[MsgTime]
      ,[PosId]
      ,[NetworkId]
      ,[info]
      ,[side]
      ,[MeasId]
  FROM [Burda_Data_2015].[dbo].[MsgLogTrace]
  WHERE SessionId like '2'
  ORDER BY MsgTime