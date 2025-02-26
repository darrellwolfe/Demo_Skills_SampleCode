
-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
--Descriptions - PCC
Left Join codes_table AS pcc ON pcc.tbl_element = a.property_class
  AND pcc.code_status='A'
  AND pcc.tbl_type_code = 'pcc'
*/


WITH 

CTE_Allocations AS (
SELECT 
a.lrsn
, a.extension
, a.improvement_id
, a.group_code
, impgroup.tbl_element_desc AS ImpGroup_Descr
, market_value
, cost_value

FROM allocations AS a 

LEFT JOIN codes_table AS impgroup ON impgroup.tbl_element=a.group_code
  AND impgroup.code_status='A'
  AND impgroup.tbl_type_code = 'impgroup'

WHERE a.status='A' 
  --AND a.group_code IN ('01','03','04','05')
  AND a.group_code IN ('01','03','04','05','06','07','09')
  --AND a.group_code IN ('06','07') 
),


CTE_LandDetails AS (
SELECT DISTINCT 
lh.RevObjId AS lrsn
,lh.TotalMktAcreage
,lh.TotalMktValue
,ld.LandType
,lt.land_type_desc
,ld.AppdValue
,ld.ActualFrontage
,ld.LDAcres
,ld.SoilIdent

--Land Header
FROM LandHeader AS lh
--AS lh ON lh.RevObjId=a.lrsn 

--Land Detail
LEFT JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
  AND ld.EffStatus='A' 
  AND ld.PostingSource='A'
 -- AND ld.LandType IN ('4','41','45','52','6','61','62','73','75','8')
  --Land Types
LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type

  WHERE lh.EffStatus= 'A' 
  AND lh.PostingSource='A'
  AND lh.LastUpdate > '2023-01-01'
  AND lh.LandModelId = '702023'
)

  --------------------------------
  --ParcelMaster
  --------------------------------
  Select Distinct
  pm.lrsn
, CASE
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
, pm.neighborhood AS GEO
, TRIM(pm.NeighborHoodName) AS GEO_Name
,  TRIM(pm.pin) AS PIN
,  TRIM(pm.AIN) AS AIN

, cal.group_code
, cal.ImpGroup_Descr
,cld.LandType
,cld.land_type_desc
,cld.AppdValue

,cal.market_value
,cal.cost_value

,cld.TotalMktAcreage
,cld.TotalMktValue
,cld.ActualFrontage
,cld.LDAcres
,cld.SoilIdent

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
--,  TRIM(pm.DisplayName)) AS Owner
, TRIM(pm.SitusAddress) AS SitusAddress
, TRIM(pm.SitusCity) AS SitusCity
, TRIM(pm.SitusState) AS SitusState
, TRIM(pm.SitusZip) AS SitusZip
, TRIM(pm.CountyNumber) AS CountyNumber
, CASE
    WHEN pm.CountyNumber = '28' THEN 'Kootenai_County'
    ELSE NULL
  END AS County_Name
,  pm.LegalAcres
,  pm.Improvement_Status -- <Improved vs Vacant



FROM TSBv_PARCELMASTER AS pm

LEFT JOIN CTE_LandDetails AS cld ON cld.lrsn=pm.lrsn

LEFT JOIN CTE_Allocations AS cal ON cal.lrsn=pm.lrsn


Where pm.EffStatus = 'A'
  AND pm.ClassCD NOT LIKE '060%'
  AND pm.ClassCD NOT LIKE '070%'
  AND pm.ClassCD NOT LIKE '090%'

AND pm.ain = '198234'


/*

SELECT
land_type
, land_type_desc

FROM land_types 
-- AS lt ON ld.LandType=lt.land_type


AsTxDBProd
GRM_Main

land_type	land_type_desc
4	Agricultural Land
6	Woodland
8	Agricultural Support Land
41	Tillable Flooded Occasionally
45	Irrigated Cropland - Type 1
52	Grazing Land
61	Timberland
62	Woodland Cutover
73	Flood Land
75	Seasonally Wetland


  land_type,
  CASE
    WHEN land_type = '4' THEN 'Agricultural_Land'
    WHEN land_type = '6' THEN 'Woodland'
    WHEN land_type = '8' THEN 'Agricultural_Support_Land'
    WHEN land_type = '41' THEN 'Tillable_Flooded_Occasionally'
    WHEN land_type = '45' THEN 'Irrigated_Cropland_Type_1'
    WHEN land_type = '52' THEN 'Grazing_Land'
    WHEN land_type = '61' THEN 'Timberland'
    WHEN land_type = '62' THEN 'Woodland_Cutover'
    WHEN land_type = '73' THEN 'Flood_Land'
    WHEN land_type = '75' THEN 'Seasonally_Wetland'
    ELSE 'TBD'
  END AS LandTypes_Timber_Ag
  
  land_type	land_type_desc
4 	Agricultural Land             
8 	Agricultural Support Land     
54	Arid Land                     
FB	Bay Front                     
C 	CAREA                         
FC	Canal Front Navigable         
FE	Canal Front Unnavigable       
55	Cemeteries                    
21	Classified Forest             
2 	Classified Land               
12	Comm/Ind. Secondary           
11	Commercial/Industrial         
CA	Common Areas-Condos           
27	Conservation Easement         
FK	Creek Front Navigable         
FT	Creek Front Unnavigable       
57	Dam Site                      
59	Desert                        
DV	Developable Acreage           
88	Drainage Easement             
85	Easement                      
56	Erosion Area                  
81	Exempt                        
72	Farm Ponds                    
43	Farmed Wetlands               
25	Filter Strip                  
73	Flood Land                    
FD	Front Delta                   
F 	Front Lot                     
FN	Front Nabla                   
GC	Golf Course                   
52	Grazing Land                  
26	Green Space Buffer            
9 	Homesite                      
45	Irrigated Cropland - Type 1   
46	Irrigated Cropland - Type 2   
47	Irrigated Cropland - Type 3   
74	Lake                          
FL	Lake Front                    
71	Land Used by Farm Buildings   
LF	Landfill                      
LS	Lot Site - At Grade           
LH	Lot Site - High               
LL	Lot Site - Low                
MV	Market Value                  
MI	Mineral                       
MB	Mineral                       
MN	Mineral - Not Being Extracted 
92	Mountain Homesite             
53	Mountain land                 
33	Non-Buildable                 
5 	Non-tillable Land             
FO	Ocean Front                   
66	Orchard Non-producing         
65	Orchard Producing             
7 	Other Farmland                
51	Permanent Pasture             
PE	Petroleum                     
84	Pipelines                     
58	Ravine                        
R 	Rear Lot                      
91	Remaining Acreage             
28	Resource Protection Area      
23	Riparian Land                 
FR	Riverfront Navigable          
FU	Riverfront Unnavigable        
31	Rural Land                    
3 	Rural Open Land or Undefined  
75	Seasonally Wetland            
29	Senic Easement                
76	Swamp                         
41	Tillable Flooded Occasionally 
42	Tillable Flooded Severely     
61	Timberland                    
UD	Undevelopable Acreage         
14	Undeveloped Unusable C/I Land 
13	Undeveloped Usable C/I Land   
32	Urban Land                    
86	Utility Easement              
83	Utility Towers                
9V	View Homesite                 
FV	View Lot                      
68	Vinyard Non-producing         
67	Vinyard Producing             
90	WF Homesite                   
93	WF Recreation Lot             
94	WF Vacant Buildable           
95	WF Vacant Non-Buildable       
82	Waste                         
FW	Water Front Lot               
22	Wildlife Habitat              
24	Windbreak                     
6 	Woodland                      
62	Woodland Cutover              
63	Woodland Cutover Replanted    

  
*/

