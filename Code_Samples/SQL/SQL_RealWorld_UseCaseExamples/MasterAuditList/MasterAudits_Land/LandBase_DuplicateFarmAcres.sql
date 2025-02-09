-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/

--Declare @Year int = 2024; -- Set this to the year you're working with

--Declare @CurrentYear varchar(8) = Cast(@Year as varchar) + '0101';
--Declare @LastYear varchar(8) = Cast(@Year - 1 as varchar) + '0101';

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
,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description
,TRIM(pm.TAG) AS TAG
,TRIM(pm.DisplayName) AS Owner
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
AND pm.ClassCD NOT LIKE '070%'
),

DuplicateFinder AS (
    SELECT DISTINCT
        lh.RevObjId,
        ag.AggregateSize AS [LandBase],
        ROW_NUMBER() OVER (PARTITION BY lh.RevObjId ORDER BY ag.AggregateSize DESC) AS rn
    FROM LandHeader AS lh  
    JOIN LBAggregateSize AS ag 
        ON lh.Id=ag.LandHeaderId 
        AND ag.EffStatus='A'
        AND ag.PostingSource='A'
    WHERE lh.EffStatus='A' 
        AND lh.PostingSource='A'
        --AND lh.LandModelId IN (@CurrentYear, @LastYear)
        --AND lh.LandModelId IN ('702023','702024')
)

SELECT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
--,Concat("'", pmd.AIN, "',") AS LookUp
,df.*

FROM DuplicateFinder AS df

JOIN CTE_ParcelMaster AS pmd
    ON df.RevObjId=pmd.lrsn

WHERE rn > 1
ORDER BY District, GEO, PIN;
