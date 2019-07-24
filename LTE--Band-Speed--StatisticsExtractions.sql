-- VARIABLES
DECLARE @LTEBand int
DECLARE @Technology varchar(4)
-- SET CORRECT VALUES
SET @LTEBand = 6300
SET @Technology = 'LTE'

-- calculate statistically Valubale data for Band
select 
	count (NC_TEC_Advance.TestId) as Samples_Count,
	AVG(NC_TRANSACTIONS_DATA.Mean_Data_Rate) as Average_Speed,
	MIN(NC_TRANSACTIONS_DATA.Mean_Data_Rate) as Minimum_Speed,
	MAX(NC_TRANSACTIONS_DATA.Mean_Data_Rate) as Maximum_Speed
from NC_TEC_Advance
       full outer join  NC_TRANSACTIONS_DATA
             on NC_TRANSACTIONS_DATA.TestId=NC_TEC_Advance.TestId
       full outer join NC_earfcn
             on NC_earfcn.TestId=NC_TEC_Advance.TestId
       full outer join NC_arfcn
             on NC_arfcn.TestId=NC_TEC_Advance.TestId
       full outer join NC_uarfcn
             on NC_uarfcn.TestId=NC_TEC_Advance.TestId
where (NC_TEC_Advance.Test_TEC = @Technology and NC_earfcn.EARFCN=@LTEBand and NC_TRANSACTIONS_DATA.Mean_Data_Rate is not null)

-- Calculate percentiles (10%, 20%, 30% ... of array)
SELECT TOP 1
	PERCENTILE_CONT(0.1) WITHIN GROUP ( ORDER BY NC_TRANSACTIONS_DATA.Mean_Data_Rate) 
			OVER (PARTITION BY NC_TEC_Advance.Test_TEC) AS Med_10,
	PERCENTILE_CONT(0.2) WITHIN GROUP ( ORDER BY NC_TRANSACTIONS_DATA.Mean_Data_Rate) 
			OVER (PARTITION BY NC_TEC_Advance.Test_TEC) AS Med_20,
	PERCENTILE_CONT(0.3) WITHIN GROUP ( ORDER BY NC_TRANSACTIONS_DATA.Mean_Data_Rate) 
			OVER (PARTITION BY NC_TEC_Advance.Test_TEC) AS Med_30,
	PERCENTILE_CONT(0.4) WITHIN GROUP ( ORDER BY NC_TRANSACTIONS_DATA.Mean_Data_Rate) 
			OVER (PARTITION BY NC_TEC_Advance.Test_TEC) AS Med_40,
	PERCENTILE_CONT(0.5) WITHIN GROUP ( ORDER BY NC_TRANSACTIONS_DATA.Mean_Data_Rate) 
			OVER (PARTITION BY NC_TEC_Advance.Test_TEC) AS Med_50,
	PERCENTILE_CONT(0.6) WITHIN GROUP ( ORDER BY NC_TRANSACTIONS_DATA.Mean_Data_Rate) 
			OVER (PARTITION BY NC_TEC_Advance.Test_TEC) AS Med_60,
	PERCENTILE_CONT(0.7) WITHIN GROUP ( ORDER BY NC_TRANSACTIONS_DATA.Mean_Data_Rate) 
			OVER (PARTITION BY NC_TEC_Advance.Test_TEC) AS Med_70,
	PERCENTILE_CONT(0.8) WITHIN GROUP ( ORDER BY NC_TRANSACTIONS_DATA.Mean_Data_Rate) 
			OVER (PARTITION BY NC_TEC_Advance.Test_TEC) AS Med_80,
	PERCENTILE_CONT(0.9) WITHIN GROUP ( ORDER BY NC_TRANSACTIONS_DATA.Mean_Data_Rate) 
			OVER (PARTITION BY NC_TEC_Advance.Test_TEC) AS Med_90
from NC_TEC_Advance
	full outer join  NC_TRANSACTIONS_DATA
		on NC_TRANSACTIONS_DATA.TestId=NC_TEC_Advance.TestId
	full outer join NC_earfcn
		on NC_earfcn.TestId=NC_TEC_Advance.TestId
	full outer join NC_arfcn
		on NC_arfcn.TestId=NC_TEC_Advance.TestId
	full outer join NC_uarfcn
		on NC_uarfcn.TestId=NC_TEC_Advance.TestId
where (NC_TEC_Advance.Test_TEC = @Technology and NC_earfcn.EARFCN=@LTEBand and NC_TRANSACTIONS_DATA.Mean_Data_Rate is not null)

-- calculates number of speed samples in certain sppes threhols in Mbit/sec
SELECT 
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate <   500) then 1 end)													as f0_t05,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate >   500 and NC_TRANSACTIONS_DATA.Mean_Data_Rate <  1000) then 1 end)	as f05_t1,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate >  1000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate <  2000) then 1 end)	as f1_t2,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate >  2000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate <  4000) then 1 end)	as f2_t04,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate >  4000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate <  6000) then 1 end)	as f4_t06,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate >  6000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate <  8000) then 1 end)	as f6_t08,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate >  8000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 10000) then 1 end)	as f8_t10,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 10000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 12000) then 1 end)	as f10_t12,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 12000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 14000) then 1 end)	as f12_t14,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 14000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 16000) then 1 end)	as f14_t16,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 16000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 18000) then 1 end)	as f16_t18,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 18000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 20000) then 1 end)	as f18_t20,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 20000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 22000) then 1 end)	as f20_t22,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 22000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 24000) then 1 end)	as f22_t24,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 24000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 26000) then 1 end)	as f24_t26,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 26000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 28000) then 1 end)	as f26_t28,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 28000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 30000) then 1 end)	as f28_t30,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 30000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 32000) then 1 end)	as f30_t32,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 32000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 34000) then 1 end)	as f32_t34,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 34000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 36000) then 1 end)	as f34_t36,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 36000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 38000) then 1 end)	as f36_t38,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 38000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 40000) then 1 end)	as f38_t40,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 40000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 42000) then 1 end)	as f40_t42,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 42000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 44000) then 1 end)	as f42_t44,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 44000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 46000) then 1 end)	as f44_t46,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 46000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 48000) then 1 end)	as f46_t48,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 48000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 50000) then 1 end)	as f48_t50,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 50000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 52000) then 1 end)	as f50_t52,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 52000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 54000) then 1 end)	as f52_t54,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 54000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 56000) then 1 end)	as f54_t56,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 56000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 58000) then 1 end)	as f56_t58,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 58000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 60000) then 1 end)	as f58_t60,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 60000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 62000) then 1 end)	as f60_t62,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 62000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 64000) then 1 end)	as f62_t64,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 64000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 66000) then 1 end)	as f64_t66,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 66000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 68000) then 1 end)	as f66_t68,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 68000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 70000) then 1 end)	as f68_t70,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 70000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 72000) then 1 end)	as f70_t72,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 72000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 74000) then 1 end)	as f72_t74,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 74000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 76000) then 1 end)	as f74_t76,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 76000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 78000) then 1 end)	as f76_t78,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 78000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 80000) then 1 end)	as f78_t80,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 80000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 82000) then 1 end)	as f80_t82,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 82000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 84000) then 1 end)	as f82_t84,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 84000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 86000) then 1 end)	as f84_t86,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 86000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 88000) then 1 end)	as f86_t88,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 88000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 90000) then 1 end)	as f88_t90,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 90000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 92000) then 1 end)	as f90_t92,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 92000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 94000) then 1 end)	as f92_t94,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 94000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 96000) then 1 end)	as f94_t96,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 96000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 98000) then 1 end)	as f96_t98,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 98000 and NC_TRANSACTIONS_DATA.Mean_Data_Rate < 100000) then 1 end) as f98_t100,
       sum(case when (NC_TRANSACTIONS_DATA.Mean_Data_Rate > 100000) then 1 end)													as f100_t
from NC_TEC_Advance
       full outer join  NC_TRANSACTIONS_DATA
             on NC_TRANSACTIONS_DATA.TestId=NC_TEC_Advance.TestId
       full outer join NC_earfcn
             on NC_earfcn.TestId=NC_TEC_Advance.TestId
       full outer join NC_arfcn
             on NC_arfcn.TestId=NC_TEC_Advance.TestId
       full outer join NC_uarfcn
             on NC_uarfcn.TestId=NC_TEC_Advance.TestId 
where (NC_TEC_Advance.Test_TEC = @Technology and NC_earfcn.EARFCN=@LTEBand and NC_TRANSACTIONS_DATA.Mean_Data_Rate is not null)
