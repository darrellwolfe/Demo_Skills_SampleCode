
-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

CTE_MH_Float_Total_SF.sql


*/

-----------------------
--CTE_MH SF
-----------------------

CTE_MH_SF AS (
Select
lrsn,
SUM(imp_size) AS MH_SF

From improvements AS i
Where status = 'A'
And improvement_id IN ('M','D') 
Group By lrsn
),

CTE_Float_SF AS (
Select Distinct
rf.lrsn,
SUM(rf.finish_living_area) AS Float_SF
--rf.floor_key

  FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
    -- AND e.status = 'A' -- Filter if joining this to another query
  JOIN improvements AS i ON e.lrsn=i.lrsn 
        AND e.extension=i.extension
        AND i.status='A'
        AND i.improvement_id IN ('M','C','D')
      --need codes to get the grade name, vs just the grade code#
      LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
        AND grades.tbl_type_code='grades'
        
  JOIN res_floor AS rf
  ON rf.lrsn=e.lrsn
  AND rf.extension=e.extension
  AND rf.dwelling_number=i.dwelling_number
  AND rf.status = 'A'

WHERE e.status = 'A'
--And rf.lrsn IN ('77068','76627','76661') -- Float Home Examples
--And rf.lrsn IN ('77068')
--,'76627','76661') -- Float Home Examples

Group By rf.lrsn

),

CTE_Total_MH_Float_SF AS (

SELECT DISTINCT
pm.lrsn,
CASE
  WHEN mhsf.MH_SF IS NULL THEN 0
  ELSE mhsf.MH_SF
END AS MH_SF,
CASE
  WHEN flsf.Float_SF IS NULL THEN 0
  ELSE flsf.Float_SF
END AS Float_SF,

FROM CTE_ParcelMasterData AS pmd 
--LEFT JOIN CTE_TransferSales AS tr -- ON tr.lrsn for joins
  --ON tr.lrsn=pmd.lrsn

  LEFT JOIN CTE_MH_SF AS mhsf
    ON mhsf.lrsn=pm.lrsn

-- CTE_Float_SF
  LEFT JOIN CTE_Float_SF AS flsf
    ON flsf.lrsn=pm.lrsn
-- flsf.Float_SF

),




