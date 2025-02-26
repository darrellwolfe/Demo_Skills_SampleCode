
DECLARE @CurrentDate DATE = GETDATE();

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @Year INT;

--Change this to choose which day in January the program begins reading rolled over assets.
-- This checks if today's date is after January 15 of the current year
IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 1) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/01/20xx

    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year

-- DECLARE @Year INT = 2024; -- Input year
--Declare @Year int = 2024; -- Input THIS year here

Declare @YearPrev10 int = @Year - 10; -- Input the year here


SELECT
cv.AssessmentYear
, cv.CadRollId
, cv.CadRollDescr
, cv.CadInvId
, cv.CadLevelId
, cv.RevObjId
, cv.PIN
, cv.AIN
, cv.ClassCd AS ClassCd_Type
,  LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD_Description]
, cv.TAGId
, TRIM(cv.TAGDescr) AS TAG
,  pm.neighborhood AS [GEO]
,  LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name]
,  LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress]
,  LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity]
,  pm.LegalAcres
,  pm.Improvement_Status
,  pm.WorkValue_Land
,  pm.WorkValue_Impv
,  pm.WorkValue_Total
,  cv.ValueAmount AS [Cadastre_Value]
,  cv.ValueTypeShortDescr
,  cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv
JOIN TSBv_PARCELMASTER AS pm ON pm.lrsn=cv.RevObjId
  AND pm.EffStatus = 'A'


--WHERE cv.AssessmentYear BETWEEN '2013' AND '2023'
WHERE cv.AssessmentYear BETWEEN @YearPrev10 AND @Year
  AND cv.ValueTypeShortDescr = 'Total Value'


