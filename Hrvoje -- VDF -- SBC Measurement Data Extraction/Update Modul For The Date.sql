-- Declaration of Variables that will be used later for filtering and similar
declare @myYear						table (Id int)
declare @myMonth					table (Id int)
declare @myDays						table (Id int)
declare @myFILES					table (Id varchar(100))

-- FILTER DATES
insert into @myYear					values (2016)							-- Year 2016
insert into @myMonth				values (7)								-- Month 6
insert into @myDays					values (13)								-- Day  15, multiple values would be "insert into @myList values (1), (2), (5), (7), (10)"

-- FILTER FILES
DECLARE @FILTER_FILES				varchar(1)			= 'N' ;				-- enables filtering by Specific File or list of files (Y/N) , UNLIMITED but requires whole file name
INSERT INTO  @myFILES				values				('2016-06-15-15-39-47-0000-6317-5801-0004-A.mf'), ('2016-06-15-15-43-26-0000-6317-4416-0004-A.mf')

-- DECLARE MODULE TO INSERT
DECLARE @MODULE				varchar(15)			= 'URBAN' ;

UPDATE NC_Calls
SET [City/None_City]= @MODULE
WHERE [Year] in (SELECT * FROM @myYear)
		and [Month] in (SELECT * FROM @myMonth)
		and [Day] in (SELECT * FROM @myDays)
		and (
				@FILTER_FILES like 'N'
				or 
					(	
						@FILTER_FILES like 'Y' and [ASideFileName] collate SQL_Latin1_General_CP1_CI_AS in (SELECT Id FROM @myFILES)
					)
			)

UPDATE NC_Calls_Distinct
SET [City/None_City]= @MODULE
WHERE	[Year] in (SELECT * FROM @myYear)
		and [Month] in (SELECT * FROM @myMonth)
		and [Day] in (SELECT * FROM @myDays)
		and (
				@FILTER_FILES like 'N'
				or 
					(	
						@FILTER_FILES like 'Y' and [ASideFileName] collate SQL_Latin1_General_CP1_CI_AS in (SELECT Id FROM @myFILES)
					)
			)