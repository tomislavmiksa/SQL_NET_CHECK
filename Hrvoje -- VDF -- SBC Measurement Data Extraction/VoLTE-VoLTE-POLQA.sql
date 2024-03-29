-- REQUIREMENTS
-- Calls need to be imported in DB
-- NC_Speech Table must Exist
-- NC_Calls Table must exist

-- Date when Measurement was Performed
DECLARE @Date_Year   int              = 2016;
DECLARE @Date_Month  int              = 5;
DECLARE @Date_Day    int              = 13;

-- Information about dialing SIM and Dialed Number
-- If just one Dial Number needs to be extracted (@Dial_Number_1 = @Dial_Number_2 = @Dial_Number_1)
-- If 2 Dial Number needs to be extracted (@Dial_Number_2 = @Dial_Number_1)
DECLARE @Dialing_IMSI      varchar(50)		 = '%' ;
DECLARE @Dial_Number_1     varchar(50)       = '%1068' ;
DECLARE @Dial_Number_2     varchar(50)       = '%8648' ;
DECLARE @Dial_Number_3     varchar(50)       = 'none' ;
DECLARE @A_SideFile_1      varchar(50)       = '%' ;
DECLARE @A_SideFile_2      varchar(50)       = 'none' ;
DECLARE @A_SideFile_3      varchar(50)       = 'none' ;

-- Create Temporary Table with VALID SessionID-s that have to be extracted (matching Criteria in NC_Calls that will be evaluated for POLQA)
IF OBJECT_ID ('tempdb..#ValidSessions' ) IS NOT NULL                                                           -- Delete Temp Table if Exists
    DROP TABLE #ValidSessions
SELECT  [SessionId]                                                                -- Create TempTable with SessionID-s we are interested for
        INTO #ValidSessions
        FROM [VDF_HUAWEI_SBC_Measurement]. [dbo].[NC_Calls]
        WHERE       [valid]                      like '1'
                and [Call_Status]                like 'Completed'
                and [Year]                       like @Date_Year
                and [Month]                      like @Date_Month
                --and [Day]                        like @Date_Day
				and ([Day] like 9 or [Day] like 10 or [Day] like 11 or [Day] like 12 or [Day] like 13)
                and [IMSI]                       like @Dialing_IMSI
                and ([Dialnumber]                like @Dial_Number_1	or [Dialnumber]			like @Dial_Number_2		or [Dialnumber]			like @Dial_Number_3 )
                and ([ASideFileName]             like @A_SideFile_1		or [ASideFileName]		like @A_SideFile_2		or [ASideFileName]		like @A_SideFile_3  )

 --------------------------------------------------
 -- What is beeing Displayed and Required by VDF --
 --------------------------------------------------
SELECT cast (@Date_Year as VARCHAR ) + '-' + cast ( @Date_Month  as VARCHAR ) + '-' + cast ( @Date_Day  as VARCHAR ) as Measurement_Date,
          ROUND ( AVG( [LQ] ), 2 ) as Average ,
          -- Calculating MEDIAN VALUE from POLQA Samples
          (SELECT TOP 1 PERCENTILE_CONT( 0.5) WITHIN GROUP (ORDER BY [LQ]) OVER () AS Median
                      FROM [VDF_HUAWEI_SBC_Measurement]. [dbo]. [NC_Speech_Samples]
                      WHERE [SessionId] in (Select [SessionId] from #ValidSessions) ) as Median ,
          MIN([LQ] ) as Minimum,
          MAX([LQ] ) as Maximum,
          ROUND ( STDEV( [LQ]), 2 ) as StandardDeviation
  FROM [VDF_HUAWEI_SBC_Measurement].[dbo]. [NC_Speech_Samples] POLQA_Samples
  WHERE ( [SessionId] in (Select [SessionId] from #ValidSessions))
  
