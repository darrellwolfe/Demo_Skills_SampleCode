-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
Allocations Check
Compare parcels with allocations against an allocations key
I can't figure out how to use SQL to pull in the key without Python Pandos installed, and IT won't give us that yet. 
So I'm using 
(1) Power Query to pull in the Key as "connection only".
(2) then SQL to pull in the Allocations with PINs, but loading it to "connection only".
Finally, (3) Inside Power Query, Merge these two as new, matching on PCC and ImpGroupCode, loading 

AsTxDBProd
GRM_Main
*/
WITH

CTE_Allocations AS (
SELECT 
a.lrsn
,TRIM(a.group_code) AS Imp_GroupCode
,a.property_class AS Property_ClassCode_PCC
,a.extension
,a.improvement_id
,a.land_line_number
,a.cost_value
,a.market_value
,CONVERT(VARCHAR, a.last_update, 101) AS LastUpdate

FROM allocations AS a 
--ON parcel.lrsn=a.lrsn AND a.status='A'
WHERE a.status='A'
),



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
,CASE
    --Commercial # Income properties use regular template, for now. 
    --  May build something. Set up just in case. DGW 08/02/2023.
      WHEN pm.neighborhood BETWEEN '1' AND '27' THEN 'Comm_Sales'
      WHEN pm.neighborhood = '28' THEN 'Comm_Sales' -- < -- Income properties but use regular template, for now. 08/02/2023
      WHEN pm.neighborhood BETWEEN '29' AND '41' THEN 'Comm_Sales'
      WHEN pm.neighborhood = '41' THEN 'Comm_Sales'
      WHEN pm.neighborhood = '42' THEN 'Section42_Workbooks'
      WHEN pm.neighborhood = '43' THEN 'Comm_Sales'
      WHEN pm.neighborhood = '44' THEN 'Comm_Sales' -- < -- Income properties but use regular template, for now. 08/02/2023
      WHEN pm.neighborhood BETWEEN '45' AND '99' THEN 'Comm_Sales'
      WHEN pm.neighborhood BETWEEN '100' AND '199' THEN 'Comm_Waterfront'
      WHEN pm.neighborhood BETWEEN '200' AND '899' THEN 'Comm_Sales'
    --D1
      WHEN pm.neighborhood IN ('1008','1010','1410','1420','1430','1430','1440','1450','1501','1502','1503','1505','1506','1507') THEN 'Res_Waterfront'
      WHEN pm.neighborhood IN ('1998','1999') THEN 'Res_MultiFamily'
    --D2
      WHEN pm.neighborhood IN ('2105','2115','2125','2135','2145','2155') THEN 'Res_Waterfront'
      WHEN pm.neighborhood IN ('2996','2997','2998','2999') THEN 'Res_MultiFamily'
    --D3
      WHEN pm.neighborhood IN ('3502','3503','3504','3505','3506') THEN 'Res_Waterfront'
      WHEN pm.neighborhood IN ('3998','3999') THEN 'Res_MultiFamily'
    --D4
      WHEN pm.neighborhood IN ('4201','4202','4203','4204','1430','1430','1440','1450','1501','1502','1503','1505','1506','1507') THEN 'Res_Waterfront'
      WHEN pm.neighborhood IN ('4833','4840','4997','4998','4999') THEN 'Res_MultiFamily'
    --D5
      WHEN pm.neighborhood IN ('5001','5004','5009','5010','5012','5015','5018','5020','5021','5024','5030','5033','5036','5039',
                                '5042','5045','5048','5051','5053','5054','5056','5057','5060','5063','5066','5069','5072','5075','5078',
                                '5081','5750','5753','5756','5759','5762','5765','5850','5853','5856') THEN 'Res_Waterfront'
      -- WHEN pm.neighborhood IN ('','') THEN 'Res_MutliFamily' -- No MultiFamily in D5 as of 08/02/2023
    --D6
      WHEN pm.neighborhood BETWEEN '6100' AND '6123' THEN 'Res_Waterfront'
      -- WHEN pm.neighborhood IN ('','') THEN 'Res_MutliFamily' -- No MultiFamily in D6 as of 08/02/2023
    -- MH Sales Worksheet Type
      WHEN pm.neighborhood = '1000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '1000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'

      WHEN pm.neighborhood = '1020' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '1020' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      
      
      WHEN pm.neighborhood = '5000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '5000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      
      
      WHEN pm.neighborhood = '5002' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '5002' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      
      
      WHEN pm.neighborhood = '6000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '6000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'         
      
      WHEN pm.neighborhood = '6002' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '6002' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'  
      
      WHEN pm.neighborhood = '9103' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '9103' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      

      WHEN pm.neighborhood >= '9000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood >= '9000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'         
      
    --Else
      ELSE 'Res_Sales'
  END AS District_SubClass
, pm.neighborhood AS GEO
, TRIM(pm.NeighborHoodName) AS GEO_Name
, pm.lrsn
, TRIM(pm.pin) AS PIN
, TRIM(pm.AIN) AS AIN
, pm.ClassCD
, TRIM(pm.PropClassDescr) AS Property_Class_Type
, CASE 
    WHEN pm.ClassCD IN ('010', '020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
    WHEN pm.ClassCD IN ('314', '317', '322', '336', '339', '343', '413', '416', '421', '435', '438', '442', '451', '527','461') THEN 'Commercial_Industrial'
    WHEN pm.ClassCD IN ('411', '512', '515', '520', '534', '537', '541', '546', '548', '549', '550', '555', '565','526','561') THEN 'Residential'
    WHEN pm.ClassCD IN ('441', '525', '690') THEN 'Mixed_Use_Residential_Commercial'
    WHEN pm.ClassCD IN ('101','103','105','106','107','110','118') THEN 'Timber_Ag_Land'
    WHEN pm.ClassCD = '667' THEN 'Operating_Property'
    WHEN pm.ClassCD = '681' THEN 'Exempt_Property'
    WHEN pm.ClassCD = 'Unasigned' THEN 'Unasigned_or_OldInactiveParcel'
    ELSE 'Unasigned_or_OldInactiveParcel'
  END AS Property_Type_Class
, TRIM(pm.TAG) AS TAG
, TRIM(pm.DisplayName) AS Owner
, TRIM(pm.SitusAddress) AS SitusAddress
, TRIM(pm.SitusCity) AS SitusCity
, TRIM(pm.SitusState) AS SitusState
, TRIM(pm.SitusZip) AS SitusZip

, TRIM(pm.AttentionLine) AS AttentionLine
, TRIM(pm.MailingAddress) AS MailingAddress
, TRIM(pm.AddlAddrLine) AS AddlAddrLine
, TRIM(pm.MailingCityStZip) AS MailingCityStZip
, TRIM(pm.MailingCity) AS MailingCity
, TRIM(pm.MailingState) AS MailingState
, TRIM(pm.MailingZip) AS MailingZip

, TRIM(pm.CountyNumber) AS CountyNumber
, CASE
    WHEN pm.CountyNumber = '28' THEN 'Kootenai_County'
    ELSE NULL
  END AS County_Name
,  pm.LegalAcres
,  pm.Improvement_Status -- <Improved vs Vacant


  From TSBv_PARCELMASTER AS pm
  
  Where pm.EffStatus = 'A'
    --AND pm.ClassCD NOT LIKE '010%'
    --AND pm.ClassCD NOT LIKE '020%'
    --AND pm.ClassCD NOT LIKE '021%'
    --AND pm.ClassCD NOT LIKE '022%'
    --AND pm.ClassCD NOT LIKE '030%'
    --AND pm.ClassCD NOT LIKE '031%'
    --AND pm.ClassCD NOT LIKE '032%'
    --AND pm.ClassCD NOT LIKE '060%'
    --AND pm.ClassCD NOT LIKE '070%'
    --AND pm.ClassCD NOT LIKE '090%'
      
  Group By
  pm.lrsn
, pm.pin
, pm.PINforGIS
, pm.AIN
, pm.ClassCD
, pm.PropClassDescr
, pm.neighborhood
, pm.NeighborHoodName
, pm.TAG
, pm.DisplayName
, pm.SitusAddress
, pm.SitusCity
, pm.SitusState
, pm.SitusZip
, pm.AttentionLine
, pm.MailingAddress
, pm.AddlAddrLine
, pm.MailingCityStZip
, pm.MailingCity
, pm.MailingState
, pm.MailingZip
, pm.CountyNumber
, pm.LegalAcres
, pm.Improvement_Status

--Order By District,GEO;
)

SELECT DISTINCT
pmd.District
, pmd.District_SubClass
, pmd.GEO
, pmd.GEO_Name
, pmd.lrsn
, pmd.PIN
, pmd.AIN
, pmd.ClassCD AS PMD_ClassCD
,al.Imp_GroupCode
,al.Property_ClassCode_PCC
,al.extension
,al.improvement_id
,al.land_line_number
,al.cost_value
,al.market_value
,al.LastUpdate
, pmd.Property_Class_Type
, pmd.Property_Type_Class
, pmd.TAG
, pmd.Owner
, pmd.SitusAddress
, pmd.SitusCity
, pmd.SitusState
, pmd.SitusZip
, pmd.AttentionLine
, pmd.MailingAddress
, pmd.MailingCityStZip
, pmd.MailingCity
, pmd.MailingState
, pmd.MailingZip


FROM CTE_Allocations AS al
JOIN CTE_ParcelMaster AS pmd
  ON al.lrsn = pmd.lrsn

/*
AND parcel.neighborhood <> 0
AND parcel.neighborhood IS NOT NULL
AND (TRIM(a.group_code) NOT LIKE '81%'
    AND TRIM(a.group_code) NOT LIKE '81L%'
    AND TRIM(a.group_code) NOT LIKE '98%'
    AND TRIM(a.group_code) NOT LIKE '99%')
-- We are auditing for 99 and 98 seperately
-- 81 and 81L are a special class to be handled sperately
*/

ORDER BY Owner, District, GEO, PIN;





























