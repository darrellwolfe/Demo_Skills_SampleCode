
DECLARE @CurrentDate DATE = GETDATE();

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @Year INT;
--Declare @Year int = 2025; -- Input THIS year here
--DECLARE @TaxYear INT;
--SET @TaxYear = YEAR(GETDATE());

IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 5, 1) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/01/20xx

    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year

Declare @LandModelId varchar(6) = '70' + Cast(@Year+1 as varchar); -- Generates '702023' for the previous year


DECLARE @TaxYear INT = @Year+1;


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
  WHEN pm.neighborhood = 0 THEN 'Other (PP, OP, NA, Error)'
  ELSE NULL
END AS District

-- # District SubClass
,pm.neighborhood AS GEO
,TRIM(pm.NeighborHoodName) AS GEO_Name
,pm.lrsn
,TRIM(pm.pin) AS PIN
,TRIM(pm.AIN) AS AIN

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
),

CTE_GeoFactors AS (
SELECT
nf.neighborhood AS GEO_Res
--For MA Worksheets
, CASE
    WHEN nf.value_mod_default = 0
    THEN 1.00
    ELSE CAST(nf.value_mod_default AS DECIMAL(10,2)) / 100 
  END AS [Worksheet_ResFactor]

--For Database
, CASE
    WHEN nf.value_mod_other  = 0
    THEN 100
    ELSE nf.value_mod_other 
  END AS [Database_ResFactor]

,nfc.neighborhood AS GEO_Comm
--com_model_serial
--,nfc.com_other_mod
--,nfc.cbf_model_number
--,nfc.commercial_mod
--,nfc.industrial_mod
, CASE
    WHEN nfc.commercial_mod = 0
    THEN 1.00
    ELSE CAST(nfc.commercial_mod AS DECIMAL(10,2)) / 100 
  END AS [Worksheet_CommFactor]
--For Database
, CASE
    WHEN nfc.commercial_mod = 0
    THEN 100
    ELSE nfc.commercial_mod
  END AS [Database_CommFactor]


FROM neigh_res_impr as nf -- Nieghborhood Factor

FULL OUTER JOIN neigh_com_impr AS nfc
  ON nf.neighborhood = nfc.neighborhood
    AND nfc.status='A'
    AND nfc.inactivate_date='99991231'
    AND nfc.com_model_serial='9998'

WHERE nf.status='A'
AND nf.inactivate_date='99991231'
--AND nf.res_model_serial='2024'
AND nf.res_model_serial=@TaxYear

)


SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,cgf.Worksheet_ResFactor
,cgf.Database_ResFactor
,cgf.Worksheet_CommFactor
,cgf.Database_CommFactor


FROM CTE_ParcelMaster AS pmd

LEFT JOIN CTE_GeoFactors AS cgf
  On pmd.GEO = cgf.GEO_Res

Order By District,GEO;

