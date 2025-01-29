
DECLARE @CurrentDate DATE = GETDATE();

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @Year INT;

--Change this to choose which day in January the program begins reading rolled over assets.
-- This checks if today's date is after January 15 of the current year
IF @CurrentDate < DATEFROMPARTS(@CurrentYear, 12, 1) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/15/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/31/20xx

    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear + 1; -- Before or on January 15, set @Year to the previous year

Declare @YearPrev int = @Year - 1; -- Input the year here

Declare @NCYear varchar(4) = 'NC' + Right(Cast(@Year as varchar), 2); -- This will create 'NC24'

Declare @NCYearPrevious varchar(4) = 'NC' + Right(Cast(@YearPrev as varchar), 2); -- This will create 'NC23'

Declare @YearBuiltNC varchar(4) = '%' + Cast(@YearPrev as varchar) + '%'

Declare @StringYear2Digits varchar(2) = LEFT(@Year, 2)

Declare @StringYear4Digits varchar(4) = @Year



Declare @EffYear0101Previous varchar(8) = Cast(@YearPrev as varchar) + '0101'; -- Generates '20230101' for the previous year

Declare @EffYear0101PreviousLike varchar(8) = Cast(@YearPrev as varchar) + '%'; -- Generates '20230101' for the previous year

Declare @EffYear0101CurrentLike varchar(8) = Cast(@Year as varchar) + '%'; -- Generates '20230101' for the previous year


WITH 

CTE_ParcelMaster AS (
--------------------------------
--ParcelMaster
--------------------------------
Select Distinct
CASE
  WHEN pm.neighborhood >= 9000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 6003 THEN 'District_6'
  WHEN pm.neighborhood = 6002 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood = 6001 THEN 'District_6'
  WHEN pm.neighborhood = 6000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 5003 THEN 'District_5'
  WHEN pm.neighborhood = 5002 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood = 5001 THEN 'District_5'
  WHEN pm.neighborhood = 5000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 4000 THEN 'District_4'
  WHEN pm.neighborhood >= 3000 THEN 'District_3'
  WHEN pm.neighborhood >= 2000 THEN 'District_2'
  WHEN pm.neighborhood >= 1021 THEN 'District_1'
  WHEN pm.neighborhood = 1020 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 1001 THEN 'District_1'
  WHEN pm.neighborhood = 1000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 451 THEN 'Commercial'
  WHEN pm.neighborhood = 450 THEN 'Specialized_Cell_Towers'
  WHEN pm.neighborhood >= 1 THEN 'Commercial'
  WHEN pm.neighborhood = 0 THEN 'N/A_or_Error'
  ELSE NULL
END AS District

-- # District SubClass
,pm.neighborhood AS GEO
,TRIM(pm.NeighborHoodName) AS GEO_Name
,pm.lrsn
,TRIM(pm.pin) AS PIN
,TRIM(pm.AIN) AS AIN
,TRIM(pm.DisplayName) AS Owner
--,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description


From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
),


CTE_Memo_NC_CurrentHeader AS (
Select
lrsn
--,memo_id
,STRING_AGG(memo_text, ' | ') AS NCCurrentHeader
--JOIN Memos, change to current year NC22, NC23
From memos 
--  ON parcel.lrsn=mNC.lrsn 
WHere memo_id = @NCYear 
And memo_line_number = '1'
  And status = 'A'
Group By lrsn
),



CTE_Memo_NC_CurrentText AS (
Select
lrsn
--,memo_id
,STRING_AGG(memo_text, ' | ') AS NCCurrentText
--JOIN Memos, change to current year NC22, NC23
From memos 
--  ON parcel.lrsn=mNC.lrsn 
WHere memo_id = @NCYear 
And memo_line_number > '1'
  And status = 'A'
Group By lrsn
),

DateExtraction AS (
Select Distinct
needdate.lrsn,
-- Find and extract the date assuming it might start anywhere in the string
Case

    -- MM/D/YYYY
    When Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText) > 0 Then
        Substring(
            NCCurrentText,
            Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText),
            CHARINDEX(' ', NCCurrentText + ' ', Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText)) 
              - Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText)
        )

    -- MM/DD/YYYY (most specific)
    When Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText) > 0 Then
        Substring(
            NCCurrentText,
            Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText),
            CHARINDEX(' ', NCCurrentText + ' ', Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText)) 
              - Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText)
        )

    -- M/D/YYYY
    When Patindex('%[0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText) > 0 Then
        Substring(
            NCCurrentText,
            Patindex('%[0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText),
            CHARINDEX(' ', NCCurrentText + ' ', Patindex('%[0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText)) 
              - Patindex('%[0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText)
        )

    -- MM/DD/YY
    When Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9]%', NCCurrentText) > 0 Then
        Substring(
            NCCurrentText,
            Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9]%', NCCurrentText),
            CHARINDEX(' ', NCCurrentText + ' ', Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9]%', NCCurrentText)) 
              - Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9]%', NCCurrentText)
        )

    -- MM/D/YY
    When Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9]%', NCCurrentText) > 0 Then
        Substring(
            NCCurrentText,
            Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9]%', NCCurrentText),
            CHARINDEX(' ', NCCurrentText + ' ', Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9]%', NCCurrentText)) 
              - Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9]%', NCCurrentText)
        )

    -- M/D/YY
    When Patindex('%[0-9]/[0-9]/[0-9][0-9]%', NCCurrentText) > 0 Then
        Substring(
            NCCurrentText,
            Patindex('%[0-9]/[0-9]/[0-9][0-9]%', NCCurrentText),
            CHARINDEX(' ', NCCurrentText + ' ', Patindex('%[0-9]/[0-9]/[0-9][0-9]%', NCCurrentText)) 
              - Patindex('%[0-9]/[0-9]/[0-9][0-9]%', NCCurrentText)
        )

    Else
        NULL

End AS ExtractedDate2

FROM CTE_Memo_NC_CurrentText AS needdate

),

--------------------------
-- Pulls in all Special Assessments from most recent posted tax year
--------------------------
CTE_SpecialAssessement AS (
    SELECT
    sh.RevObjId AS lrsn
  , sd.Amount AS SolidWasteIncrement
  , sd.BegEffYear AS SolidWasteTaxYear
--  , sh.BegEffYear AS SDYear
--  , sd.BegEffYear AS SHYear

    FROM SAvalueHeader AS sh
    JOIN SAVALUEDETAIL AS sd ON sh.Id = sd.SAValueHeaderId
      AND sd.EffStatus = 'A'
      AND sd.BegEffYear = @YearPrev
      

   -- JOIN TSBV_PARCELMASTER AS pm ON pm.lrsn=sh.RevObjId -- <For testing only
    --    AND pm.EffStatus = 'A'

  WHERE sh.EffStatus = 'A'
    AND sd.EffStatus = 'A'
    AND sh.SAId IN ('15','38')
    AND sh.BegEffYear = @YearPrev
)


Select  Distinct
--pmd.*,
pmd.lrsn,
pmd.AIN,
swa.SolidWasteIncrement,
swa.SolidWasteTaxYear,
pmd.PIN,
pmd.Owner,
CAST(OCDate.ExtractedDate2 AS DATE) AS Occupancy_Date,
NCYearHead.NCCurrentHeader,
NCYear.NCCurrentText

From CTE_ParcelMaster AS pmd

Join CTE_Memo_NC_CurrentText AS NCYear
    On NCYear.lrsn = pmd.lrsn

Left Join CTE_Memo_NC_CurrentHeader AS NCYearHead
    On NCYear.lrsn = pmd.lrsn

Left Join DateExtraction AS OCDate
    On OCDate.lrsn = pmd.lrsn

Left Join CTE_SpecialAssessement AS swa
    On swa.lrsn = pmd.lrsn


Where NCYear.NCCurrentText IS NOT NULL
And UPPER(TRIM(NCYear.NCCurrentText)) LIKE '%ANNUAL%'

--And pmd.lrsn = 84232

--Order by ExtractedDateFormat







/*

Left Join CTE_ImpValDetail imp
    On imp.lrsn = pmd.lrsn



CTE_ImpValDetail AS (
Select Distinct
vd.lrsn
,vd.extension AS Extension
,vd.imp_type AS ImpType
,vd.improvement_id AS ImpId
,vd.line_number AS ImpLineNum
,i.year_built AS YearBuilt
,i.year_remodeled AS YearRemodel
,vd.eff_year AS EffYear
,vd.group_code AS GroupCode

From val_detail AS vd

Left Join extensions AS e 
  On vd.lrsn=e.lrsn --JOIN extensions between parcel and improvements to filter out voided records
    And e.extension=vd.extension 
    And e.status='A' 

Left Join improvements AS i 
  On e.lrsn=i.lrsn 
    And e.extension=i.extension 
    And vd.extension=i.extension 
    And vd.improvement_id = i.improvement_id
    And i.status='A' 

Where vd.status = 'A'
    And e.status='A' 
    And i.status='A' 

--And vd.eff_year LIKE @EffYear0101CurrentLike
--And vd.eff_year LIKE @EffYear0101PreviousLike
And i.year_built LIKE @YearBuiltNC

And vd.extension NOT LIKE 'L%'
And vd.group_code <> '81'
And vd.assess_val <> 0
And (
  (i.improvement_id IN ('D','M') AND i.year_built = @YearPrev)
  Or (i.improvement_id IN ('C') AND (i.year_built = @YearPrev OR i.year_remodeled = @YearPrev))
    )
),

*/













