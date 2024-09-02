/*
-- !preview conn=conn
*/

/*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())
*/

/*
Land Reports
Crystal Settings
{?CountyName} <> '' and
{land_val_element.neighborhood} in {?NeighborhoodStart} to {?NeighborhoodEnd} and
{land_val_element.model_ser_numb} = {?ModelNumber} and
{neigh_control.inactivate_date} = 99991231
--  AND nc.county_number NOT IN ('28','028') <- Do not use count_number as a factor, it isn't set right in our system for some GEOs
*/

/*
Note: In Power Query, we needed a seperate table per type. Rather than write different queries for a single filter, 
we just use this query and apply a single filter in Power Query. Once we kick the appraisers out of the worksheets,
and start doing REAL data analytics in Python, R, Tableau, and/or other tools, we won't need any of that.
Until then, we need to do it this way.

*/


DECLARE @LandModel INT = '702024';


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

From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
)


--------------------------------
--GEO Land Legends, Remainng Acres, Carea, Etc.
--------------------------------

SELECT DISTINCT
lve.model_ser_numb AS [Land Model],
pmd.District,
lve.neighborhood AS [GEO],
lve.lcm AS [LCM#],
lm.method_desc AS [Land Method],
lve.land_type AS [LandType#],
TRIM(lt.land_type_desc) AS [LandType],

lve.df1,
lve.df2,
lve.df3,
lve.df4,
lve.df5,
lve.df6,
lve.df7,
lve.df8,
lve.df9,
lve.df10,
lve.df11,
lve.df12,
lve.df13,
lve.df14,
lve.df15,
lve.df16,
lve.df17,
lve.df18,
lve.df19,
lve.df20,
lve.df21,
lve.df22,
lve.df23,
lve.df24,
lve.df25,
lve.df26,
lve.df27,
lve.df28,
lve.df29,
lve.df30

FROM neigh_control AS nc 
--ON lve.neighborhood=nc.neighborhood

JOIN land_val_element AS lve 
  ON lve.neighborhood=nc.neighborhood
  --TRIM(lve.neighborhood)=TRIM(nc.neighborhood)
  --CAST(lve.neighborhood AS INT)=CAST(nc.neighborhood AS INT)
  --nc.neighborhood
  --CAST(nc.neighborhood AS INT)
    AND lve.land_ve_status='A'
    AND lve.neighborhood<>0
    AND lve.model_ser_numb=@LandModel
----------------------------------------------------------------------
--Model is 70YYYY of the desired year, 2023 is 702023
----------------------------------------------------------------------
    -- AND lve.neighborhood = '4150' -- <- Use as test to ensure table is working.
    
JOIN land_methods AS lm
  ON lm.method_number=lve.lcm
    AND lm.method_status='A'

JOIN land_types AS lt 
  ON lve.land_type=lt.land_type

LEFT JOIN CTE_ParcelMaster AS pmd
  On pmd.GEO = lve.neighborhood

WHERE nc.inactivate_date=99991231

--AND lve.neighborhood = 3204


Order By [GEO] , [LCM#] ,[LandType#];

