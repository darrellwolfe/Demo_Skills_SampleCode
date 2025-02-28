


SELECT DISTINCT
v.lrsn
, v.property_class AS PCC_ClassCode
, v.land_assess AS AssesedValue_Land
, v.imp_assess AS AssesedValue_Improvement
, v.last_update
, LEFT(v.eff_year,4) AS Year
, CONCAT(LEFT(v.eff_year,4),'-01-01') AS Assessment_Date

FROM valuation AS v