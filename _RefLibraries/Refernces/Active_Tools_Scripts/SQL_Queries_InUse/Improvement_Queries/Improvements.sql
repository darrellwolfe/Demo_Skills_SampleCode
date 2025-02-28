DECLARE @CurrentDate DATE = GETDATE();
DECLARE @CurrentYear INT = YEAR(GETDATE());
DECLARE @Year INT;
IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 5, 1) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/01/20xx

    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year

Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrevPrev int = @Year - 2; -- Input the year here
Declare @MemoLastUpdatedNoEarlierThan date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
Declare @PrimaryTransferDateFROM date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
Declare @PrimaryTransferDateTO date = CAST(CAST(@Year as varchar) + '-12-31' AS DATE); -- Generates '2023-01-01' for the current year
Declare @CertValueDateFROM varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @CertValueDateTO varchar(8) = Cast(@Year as varchar) + '1231'; -- Generates '20230101' for the previous year
Declare @LandModelId varchar(6) = '70' + Cast(@Year+1 as varchar); -- Generates '702023' for the previous year
Declare @MemoText1 varchar(6) = '%/' + Cast(@Year as varchar) + ' %'; -- Generates '702023' for the previous year
Declare @MemoText2 varchar(6) = '%/' + RIGHT(@Year,2) + ' %'; -- Generates '702023' for the previous year


WITH

CTE_ParcelMaster AS (
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
,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity
,pm.LegalAcres
,pm.WorkValue_Land
,pm.WorkValue_Impv
,pm.WorkValue_Total
,pm.CostingMethod
,pm.Improvement_Status -- <Improved vs Vacant
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'
--And pm.pin NOT LIKE 'E%'
--And pm.pin NOT LIKE 'G%'
--And pm.pin NOT LIKE 'UP%'
AND pm.ClassCD NOT LIKE '070%'
),

CTE_Improvements AS (
Select Distinct
e.lrsn,
e.extension,
i.imp_type,
cu.use_code AS Comm_use_codes,
--STRING_AGG(cu.use_code, ',') AS Comm_use_codes,
i.year_built,
i.eff_year_built,
i.year_remodeled,
i.condition,
i.grade AS [GradeCode], -- is this a code that needs a key?
grades.tbl_element_desc AS [GradeType],
dw.mkt_house_type AS [HouseTypeNum],
htyp.tbl_element_desc  AS [HouseTypeName],
--STRING_AGG(dw.mkt_house_type, ' | ') AS [HouseType#],
--STRING_AGG(htyp.tbl_element_desc, ' | ')  AS [HouseTypeName],
dw.mkt_rdf AS [RDF], -- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation
mh.mh_make AS [MHMake#],
make.tbl_element_desc AS [MH_Make],
mh.mh_model AS [MHModel#],
model.tbl_element_desc AS [MH_Model],
mh.mh_serial_num AS [VIN],
mh.mhpark_code,
park.tbl_element_desc AS [MH_Park],
ROW_NUMBER() OVER (PARTITION BY e.lrsn ORDER BY e.extension ASC) AS RowNum


FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query

JOIN improvements AS i ON e.lrsn=i.lrsn 
    AND e.extension=i.extension
    AND i.status='A'
--    AND i.improvement_id IN ('M','C','D')

    LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
    AND grades.tbl_type_code='grades'

LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
    AND dw.status='A'
    AND i.extension=dw.extension
    LEFT JOIN codes_table AS htyp 
        ON dw.mkt_house_type = htyp.tbl_element 
        AND htyp.tbl_type_code='htyp'  
        AND htyp.code_status = 'A'
        
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
    AND i.extension=mh.extension
    AND mh.status='A'
    LEFT JOIN codes_table AS make 
        ON mh.mh_make=make.tbl_element 
        AND make.tbl_type_code='mhmake'
            AND make.code_status = 'A'
    LEFT JOIN codes_table AS model 
        ON mh.mh_model=model.tbl_element 
        AND model.tbl_type_code='mhmodel'
            AND model.code_status = 'A'
    LEFT JOIN codes_table AS park 
        ON mh.mhpark_code=park.tbl_element 
        AND park.tbl_type_code='mhpark'
        AND park.code_status = 'A'

LEFT JOIN comm_bldg AS cb 
    ON i.lrsn=cb.lrsn 
    AND i.extension=cb.extension
    AND cb.status='A'
    LEFT JOIN comm_uses AS cu 
        ON cb.lrsn=cu.lrsn
        AND cb.extension = cu.extension
        AND cu.status='A'

  --Conditions
  WHERE e.status = 'A'
    --AND i.improvement_id IN ('M','C','D')

)


Select Distinct
pmd.District,
pmd.GEO,
pmd.GEO_Name,
pmd.lrsn,
pmd.AIN,
pmd.PIN,
imp.*

From CTE_ParcelMaster AS pmd
--    On pmd.lrsn = xxx.lrsn

Left Join CTE_Improvements AS imp
    On pmd.lrsn = imp.lrsn
--    And imp.RowNum = 1


--Where imp.HouseTypeName LIKE '%Town%'

