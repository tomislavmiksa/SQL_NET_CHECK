----------------
-- FUNCTIONs  --
---------------- 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- CREATE FUNCTION THAT WILL EXTRACT ALL BANDS IN ACTIVE CALL
-- DROP function if already exists
IF EXISTS ( SELECT * FROM sysobjects WHERE id = object_id(N'PCIExtract') AND xtype IN (N'FN', N'IF', N'TF') )
    DROP FUNCTION PCIExtract
GO
Create FUNCTION PCIExtract
(
    @sessID		bigint,
	@testid		bigint,
	@pci		bigint	
)
RETURNS varchar(1000)
AS
BEGIN
			DECLARE @CodeNameString varchar(1000)
			DECLARE @Temp TABLE (PCI bigint)

			INSERT INTO @Temp (pci)
			SELECT DISTINCT b.[PCI]
			FROM [Press_pre_D_Data_TDG_DEU_Q3].[dbo].[LTEServingCellInfo] a
			LEFT OUTER JOIN [Press_pre_D_Data_TDG_DEU_Q3].[dbo].[LTECACellInfo] b
				on a.LTECACellInfoId = b.LTECACellInfoId
			WHERE a.[SessionId]=@sessID and a.[TestId]=@testid and a.[PhyCellId]=@pci

			SELECT  @CodeNameString = @CodeNameString + pci
				FROM @Temp a
			RETURN @CodeNameString
END
GO

IF OBJECT_ID ('tempdb..#TempCA' ) IS NOT NULL
    DROP TABLE #TempCA
SELECT DISTINCT
	   a.[SessionId]
      ,a.[TestId]
	  ,a.[CellIdentity]
      ,a.[PhyCellId]
	  ,a.[BandIndicator]
      ,a.[DLBandWidth]
      ,a.[ULBandWidth]
      ,a.[TAC]
      ,a.[MCC]
      ,a.[MNC]
      ,a.[DetectedAntennas]
      ,a.[PMax]
      ,a.[MaxTxPower]
      ,b.[RFBand]			 as [SCell_RFBand]
      ,b.[EARFCN]			 as [SCell_EARFCN]
      ,b.[PCI]				 as [SCell_PCI]
      ,b.[DLBandWidth]		 as [SCell_DLBandWidth]
      ,b.[AntennaPortCount]	 as [SCell_AntennaPortCount]
      ,b.[TransmissionMode]	 as [SCell_TransmissionMode]
  INTO #TempCA
  FROM [Press_pre_D_Data_TDG_DEU_Q3].[dbo].[LTEServingCellInfo] a
  LEFT OUTER JOIN [Press_pre_D_Data_TDG_DEU_Q3].[dbo].[LTECACellInfo] b
  on a.LTECACellInfoId = b.LTECACellInfoId
  WHERE a.[LTECACellInfoId] is not null
  ORDER BY a.[SessionId],a.[TestId]

  SELECT * FROM #TempCA ORDER BY [SessionId],[TestId]

IF OBJECT_ID ('tempdb..#TempCA1' ) IS NOT NULL
    DROP TABLE #TempCA1
  SELECT DISTINCT
		 [SessionId]
		 ,[TestId]
		 ,[PhyCellId] as Prim_PCI
		 ,1+COUNT([SCell_PCI]) as CA_PCI_Count
   INTO #TempCA1
   FROM #TempCA
   GROUP BY [SessionId],[TestId],[PhyCellId]
   ORDER BY [SessionId]

SELECT  a.*
		,dbo.PCIExtract(SessionID,TestID,Prim_PCI)
   FROM #TempCA1 a