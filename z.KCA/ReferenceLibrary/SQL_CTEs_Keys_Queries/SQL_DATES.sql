
DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @CurrentDate DATE = GETDATE();




Declare @TaxYear int;


--LevyRates will change every 11/15
-- Dynamically set the TaxYear based on the current date
If GetDate() < DateFromParts(Year(GetDate()), 11, 15)
    Set @TaxYear = Year(GetDate()) - 1; -- Last year until November 15
Else
    Set @TaxYear = Year(GetDate()); -- Current year after November 15


-- Declare @LandModelYear dynamically
Declare @LandModelYear int;
--DECLARE @LandModelYear INT = '702024';

-- Dynamically set the @LandModelYear based on the current date 
-- Land Model will change every 04/01
If GetDate() < DateFromParts(Year(GetDate()), 4, 1)
    Set @LandModelYear = 700000 + Year(GetDate()) - 1; -- Last year's value until April 1
Else
    Set @LandModelYear = 700000 + Year(GetDate()); -- Current year's value after April 1




CASE
    WHEN GETDATE() < DATEFROMPARTS(YEAR(GETDATE()), 10, 1)
        THEN DATEFROMPARTS(YEAR(GETDATE()), 10, 1)
    ELSE DATEFROMPARTS(YEAR(GETDATE()) + 1, 10, 1)
END AS CallBack


,CAST(@CurrentDate AS DATE) AS Today,

,CAST(GETDATE() AS DATE) AS Today,

,f.date_completed AS DateCompleted
,YEAR(f.date_completed) AS Compl_Year
,MONTH(f.date_completed) AS Compl_Month
,DAY(f.date_completed) AS Compl_Day
,DATENAME(MONTH, f.date_completed) AS Compl_MonthName

CONVERT(varchar, b.ExpireDt, 101) AS [ExpireDt],
CONVERT(varchar, b.FinalDt, 101) AS [FinalDt],
CONVERT(varchar, b.UpdateDt, 101) AS [UpdateDt],