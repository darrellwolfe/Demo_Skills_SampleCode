-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/
/*
SELECT *
From valuation AS v
Where v.status = 'A'
And v.eff_year LIKE '2023%'
*/


Declare @Year int = 2024; -- Input THIS year here

Declare @YearPrev int = @Year - 1; -- Input the year here

--NOTE: For HOEX from Cadaster, it will only pull fro a locked roll
  --If the current year roll is locked, and you use @Year no values will populate
  --If the @YearPrev is used, you will pull last year's cadasters not this years

Declare @NCYear varchar(4) = 'NC' + Right(Cast(@Year as varchar), 2); -- This will create 'NC24'

Declare @NCYearPrevious varchar(4) = 'NC' + Right(Cast(@YearPrev as varchar), 2); -- This will create 'NC23'

Declare @EffYear0101Previous varchar(8) = Cast(@YearPrev as varchar) + '0101'; -- Generates '20230101' for the previous year

Declare @EffYear0101PreviousLike varchar(8) = Cast(@YearPrev as varchar) + '%'; -- Generates '20230101' for the previous year

Declare @EffYear0101CurrentLike varchar(8) = Cast(@Year as varchar) + '%'; -- Generates '20230101' for the previous year


WITH

CTE_Valuation AS (
SELECT
v.lrsn
,v.last_update
,v.imp_assess
,v.land_assess
,v.land_market_val
,(v.imp_assess + v.land_market_val) AS TotalAppraisedMarket
,(v.imp_assess + v.land_market_val) AS TotalAssessed
,v.land_use_val
,v.eff_year
,CAST(CONVERT(char(8), v.eff_year) AS DATE) AS OccupancyDate
,YEAR(CAST(CONVERT(char(8), v.eff_year) AS DATE)) AS OccYear
,MONTH(CAST(CONVERT(char(8), v.eff_year) AS DATE)) AS OccMonthNum
,DATENAME(MONTH,CAST(CONVERT(char(8), v.eff_year) AS DATE)) AS OccMonth
,v.valuation_comment
,v.update_user_id

From valuation AS v
Where v.status = 'A'
And v.eff_year LIKE @EffYear0101PreviousLike
)

Select Distinct
cv.*
--valuation_comment
From CTE_Valuation AS cv

Where valuation_comment LIKE '06%'
--And v.lrsn = 2

--valuation_comment
--01- Reval/Market Adj.
--06- Occupancy
--10- Cancellation
--38- Subsequent Assessment
--43- Assessment Roll


--Order by lrsn


/*
Worksheet/Certified 2024
lrsn = 2
In ProVal:
ProVal Cert 2024 Land Market 438,458 = 2024 v.land_market_val 438,458

ProVal Cert 2024 Land Assessed 271,495 = 2024 v.land_assess 271,495

ProVal Cert 2024 Land Use 1,495 = 2024 v.land_use_val 1,495

(allocations)
Homesite 10H $270,000  + 07 Bare Forest $1,495
  = $271,495

ProVal uses Either Or with land. 
  Either the 91 Remaining Acres OR the 61 Timberland
  Dependin on "use", but both land lines have to have the timber allocation
    either 06 or 07 to make that function work

--,(v.land_assess - v.land_use_val) AS AssesedLand
Assessed minus use equals the missing allocation Homesite

ProVal Cert 2024 Imp Market 347,150 = 2024 v.imp_assess 347,510
6:45 pm
8.15 pm

*/