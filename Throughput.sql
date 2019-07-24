SELECT TOP 1000 [MsgId]
      ,[SessionId]
      ,[TestId]
      ,[MsgTime]
      ,[PosId]
      ,[NetworkId]
      ,[direction]
      ,[throughput]
      ,[bytesTransferred]
  FROM [Burda_Data_2015].[dbo].[MsgIPThroughput]
  WHERE SessionId like '2'
  ORDER BY MsgTime