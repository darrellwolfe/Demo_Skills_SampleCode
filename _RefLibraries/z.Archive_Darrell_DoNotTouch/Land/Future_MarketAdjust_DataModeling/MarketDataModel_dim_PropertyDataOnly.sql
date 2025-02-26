
Declare @Year int = 2024; -- Input THIS year here
--DECLARE @TaxYear INT;
--SET @TaxYear = YEAR(GETDATE());

Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrevPrev int = @Year - 2; -- Input the year here


Declare @MemoLastUpdatedNoEarlierThan date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
--Declare @MemoLastUpdatedNoEarlierThan DATE = '2024-01-01';
--1/1 of the earliest year requested. 
-- If you need sales back to 10/01/2022, use 01/01/2022

Declare @PrimaryTransferDateFROM date = CAST(CAST(@Year-1 as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
Declare @PrimaryTransferDateTO date = CAST(CAST(@Year as varchar) + '-12-31' AS DATE); -- Generates '2023-01-01' for the current year
--Declare @PrimaryTransferDateFROM DATE = '2024-01-01';
--Declare @PrimaryTransferDateTO DATE = '2024-12-31';
--pxfer_date
--AND tr.pxfer_date BETWEEN '2023-01-01' AND '2023-12-31'

Declare @CertValueDateFROM varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @CertValueDateTO varchar(8) = Cast(@Year as varchar) + '1231'; -- Generates '20230101' for the previous year
--Declare @CertValueDateFROM INT = '20240101';
--Declare @CertValueDateTO INT = '20241231';
--v.eff_year
---WHERE v.eff_year BETWEEN 20230101 AND 20231231


Declare @LandModelId varchar(6) = '70' + Cast(@Year as varchar); -- Generates '702023' for the previous year
    --AND lh.LandModelId='702023'
    --AND ld.LandModelId='702023'
    --AND lh.LandModelId= @LandModelId
    --AND ld.LandModelId= @LandModelId 

-------------------------------------
-- CTEs will drive this report and combine in the main query
-------------------------------------
WITH

-------------------------------------
-- Combined CTE for Improvements
-------------------------------------
CTE_Improvements AS (
  Select Distinct
    -- Extensions Table
    e.lrsn,
    e.extension,
    e.ext_description,
    e.data_collector,
    e.collection_date,
    e.appraiser,
    e.appraisal_date,
    
    -- Improvements Table
    i.imp_type,
    i.year_built,
    i.eff_year_built,
    i.year_remodeled,
    i.condition,
    i.grade AS GradeCode, 
    grades.tbl_element_desc AS GradeType,
    
    -- Residential Dwellings dw
    STRING_AGG(dw.mkt_house_type, ' | ') AS HouseTypeNum,
    STRING_AGG(htyp.tbl_element_desc, ' | ') AS HouseTypeName,
    dw.mkt_rdf AS [RDF],
    
    -- Commercial
    STRING_AGG(cu.use_code, ',') AS use_codes,
    
    -- Manufactured Housing
    mh.mh_make AS [MHMake#],
    make.tbl_element_desc AS [MH_Make],
    mh.mh_model AS [MHModel#],
    model.tbl_element_desc AS [MH_Model],
    mh.mh_serial_num AS [VIN],
    mh.mhpark_code,
    park.tbl_element_desc AS [MH_Park],
    
    ROW_NUMBER() OVER (PARTITION BY e.lrsn ORDER BY e.extension ASC) AS RowNum
    
  -- Extensions always comes first
  From extensions AS e
  JOIN improvements AS i ON e.lrsn = i.lrsn 
    And e.extension = i.extension
    And i.status = 'A'
    And i.improvement_id IN ('M', 'C', 'D')

    LEFT JOIN codes_table AS grades 
        ON i.grade = grades.tbl_element
        And grades.tbl_type_code = 'grades'
        And grades.code_status = 'A' 

  -- Residential Dwellings
  LEFT JOIN dwellings AS dw ON i.lrsn = dw.lrsn
    And dw.status = 'A'
    And i.extension = dw.extension

    LEFT JOIN codes_table AS htyp 
        ON dw.mkt_house_type = htyp.tbl_element 
        And htyp.tbl_type_code = 'htyp'
        And htyp.code_status = 'A' 

  -- Commercial
  LEFT JOIN comm_bldg AS cb ON i.lrsn = cb.lrsn 
    And i.extension = cb.extension
    And cb.status = 'A'
    LEFT JOIN comm_uses AS cu ON cb.lrsn = cu.lrsn
        And cb.extension = cu.extension
        And cu.status = 'A'
    
  -- Manufactured Housing
  LEFT JOIN manuf_housing AS mh ON i.lrsn = mh.lrsn 
    And i.extension = mh.extension
    And mh.status = 'A'
    LEFT JOIN codes_table AS make 
    ON mh.mh_make = make.tbl_element 
        And make.tbl_type_code = 'mhmake'
        And make.code_status = 'A' 

    LEFT JOIN codes_table AS model 
    ON mh.mh_model = model.tbl_element 
        And model.tbl_type_code = 'mhmodel'
        And model.code_status = 'A' 

    LEFT JOIN codes_table AS park 
    ON mh.mhpark_code = park.tbl_element 
        And park.tbl_type_code = 'mhpark'
        And park.code_status = 'A' 

    
  Where e.status = 'A'
  And (
    --Res Dwellings
      (i.improvement_id IN ('D')
    And (e.ext_description LIKE '%H1%'
      OR e.ext_description LIKE '%H-1%'
      OR e.ext_description LIKE '%ALU%')
      )
    Or
    -- MH Homes
      (i.improvement_id IN ('M')
    And (e.ext_description LIKE '%NREV%'
      OR e.ext_description LIKE '%FLOAT%'
      OR e.ext_description LIKE '%BOAT%')
      )
    Or
    --Commercial Buildings
      (i.improvement_id IN ('C'))
      )
  
  GROUP BY
    e.lrsn,
    e.extension,
    e.ext_description,
    e.data_collector,
    e.collection_date,
    e.appraiser,
    e.appraisal_date,
    i.imp_type,
    i.year_built,
    i.eff_year_built,
    i.year_remodeled,
    i.condition,
    i.grade,
    grades.tbl_element_desc,
    dw.mkt_rdf,
    cu.use_code,
    mh.mh_make,
    make.tbl_element_desc,
    mh.mh_model,
    model.tbl_element_desc,
    mh.mh_serial_num,
    mh.mhpark_code,
    park.tbl_element_desc
)

Select Distinct *
From CTE_Improvements