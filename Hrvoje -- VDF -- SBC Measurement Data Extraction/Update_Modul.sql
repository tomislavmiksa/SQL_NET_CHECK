-- MODUL for Hrvoje Purpose Update
declare @myYear                                         table (Id int)
declare @myMonth										table (Id int)
declare @myDays                                         table (Id int)
declare @myFILES										table (Id varchar(100 ))

-- FILTER DATES
insert into @myYear										values (2016 )                                          -- Year 2016
insert into @myMonth									values (7 )                                             -- Month 6
insert into @myDays										values (21)                                             -- Day  15, multiple values would be "insert into @myList values (1), (2), (5), (7), (10)"

DECLARE @FILTER_FILES									varchar(1 )                  = 'N' ;					-- DO YOU WANT TO FILTER FILES???
INSERT INTO @myFILES									values                       ('2016-06-15-15-39-47-0000-6317-5801-0004-A.mf')

DECLARE @MODUL											varchar(3)                  = 'STATIC' ;				-- Modul Update (STATIC, CITY, BAB)

UPDATE NC_Calls
SET [City/None_City] = @MODUL
WHERE  [Year] in (SELECT * from @myYear)  and
       [Month]        in ( SELECT * from @myMonth )and
       [Day]   in ( SELECT * from @myDays ) and
          (@FILTER_FILES like 'N' or ( @FILTER_FILES like 'Y' and [ASideFileName] collate SQL_Latin1_General_CP1_CI_AS in (SELECT * from @myFILES)))

UPDATE NC_Calls_Distinct
SET [City/None_City] = @MODUL
WHERE  [Year] in (SELECT * from @myYear)  and
       [Month]        in ( SELECT * from @myMonth )and
       [Day]   in ( SELECT * from @myDays ) and
          (@FILTER_FILES like 'N' or ( @FILTER_FILES like 'Y' and [ASideFileName] collate SQL_Latin1_General_CP1_CI_AS in (SELECT * from @myFILES)))
