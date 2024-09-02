-- !preview conn=con


-- Land_SiteValue_1AcrePlus

/*
AsTxDBProd
GRM_Main

--Change to Plat desired:
AND pm.pin LIKE 'PL774%'

--Change land model to the desired year, usually current year, but will filter out any that have not been priced yet (due to being new)
AND lh.LandModelId='702023'

-- Or search by GEO range
AND pm.neighborhood  BETWEEN '2000' AND '2999'
*/

WITH

CTE_LandLegends AS (

  SELECT DISTINCT
  --Demographics
  pm.lrsn,
  TRIM(pm.pin) AS [PIN],
  TRIM(pm.AIN) AS [AIN],
  pm.neighborhood AS [GEO],
  TRIM(pm.NeighborHoodName) AS [GEO_Name],
  TRIM(pm.PropClassDescr) AS [ClassCD],
  ex.extension AS [Land_Imp],
  --Acres
  pm.LegalAcres,
  lh.TotalMktAcreage,
  ld.LDAcres,
  ld.ActualFrontage,
  --Land Details
  ld.LandLineNumber,
  --Land Type
  ld.LandType AS [LandType#],
  lt.land_type_desc AS [LandType_Descr],
  --Land LCM
  ld.lcm AS [LCM#],
  ctlcm.tbl_element_desc AS [LCM_Descr],
  --Land Site Rating
  ld.SiteRating AS [LegendType#],
  ctsr.tbl_element_desc AS [LegendType_Descr],
  --Rates
  ld.BaseRate AS [BaseRate],
  ld.SoilIdent,
  ld.ExcessLandFlag,
  --Other Information
  TRIM(pm.TAG) AS [TAG],
  TRIM(pm.DisplayName) AS [Owner],
  TRIM(pm.SitusAddress) AS [SitusAddress],
  TRIM(pm.SitusCity) AS [SitusCity],
  lh.NbhdWhenPriced,
  lh.LastUpdate,
  lh.LandModelId

  --Units Columns
  
  FROM TSBv_PARCELMASTER AS pm
  LEFT JOIN LandHeader AS lh ON pm.lrsn=lh.RevObjId
    AND lh.EffStatus='A'
  LEFT JOIN LandDetail AS ld ON lh.Id=ld.LandHeaderId AND lh.LandModelId=ld.LandModelId
    AND ld.EffStatus='A'
  LEFT JOIN codes_table AS ctlcm ON (ld.lcm=ctlcm.tbl_element AND tbl_type_code='lcmshortdesc')
    AND ctlcm.code_status= 'A'
  LEFT JOIN codes_table AS ctsr ON (ld.SiteRating=ctsr.tbl_element AND ctsr.tbl_type_code='siterating')
    AND ctsr.code_status= 'A'
  LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type
  LEFT JOIN extensions AS ex ON (pm.lrsn=ex.lrsn AND ex.extension LIKE 'L%')
  
  
  WHERE pm.EffStatus='A' 
  -- AND pm.neighborhood  BETWEEN '2000' AND '2999'
)

SELECT DISTINCT *
FROM CTE_LandLegends

WHERE LDAcres > 1
 AND LCM_Descr LIKE '%Site Value%'
 
--LandType# IN ('9','9V','31','32','90','94') 
/*
(LCM_Descr LIKE '%Site%'
 OR LegendType_Descr LIKE '%Site%')
*/

ORDER BY
GEO, PIN, LandType#, LCM#;

/*
LandType# LandType_Descr
-- Site Value
9 Homesite                      
9V View Homesite                 
32 Urban Land                    
31 Rural Land                    
90 WF Homesite                   
94 WF Vacant Buildable           

-- Not Site Value
73 Flood Land                    
91 Remaining Acreage             
93 WF Recreation Lot             
CA Common Areas-Condos           
MV Market Value                  
NA NA
3 Rural Open Land or Undefined  
46 Irrigated Cropland - Type 2   
52 Grazing Land                  
6 Woodland                      
62 Woodland Cutover              
81 Exempt                        

C  CAREA                         
FL Lake Front                    
12 Comm/Ind. Secondary           
13 Undeveloped Usable C/I Land   
33 Non-Buildable                 
4  Agricultural Land             
41 Tillable Flooded Occasionally 
45 Irrigated Cropland - Type 1   
75 Seasonally Wetland            
8  Agricultural Support Land     
95 WF Vacant Non-Buildable       
11 Commercial/Industrial         
61 Timberland                    
82 Waste                         
MB Mineral         
*/ 


