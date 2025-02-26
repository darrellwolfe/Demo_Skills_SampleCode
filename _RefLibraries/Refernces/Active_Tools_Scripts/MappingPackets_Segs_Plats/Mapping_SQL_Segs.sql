

--query = """
Select Distinct 
map.RevObjId AS lrsn,
TRIM(map.PIN) AS PIN, 
TRIM(map.AIN) AS AIN, 
CAST(LEFT(map.Prop_Class_Descr,3) AS INT) AS PCC,
TRIM(map.Prop_Class_Descr) AS Prop_Class_Descr,
lh.TotalMktAcreage,
lh.TotalUseAcreage,
map.Acres, 
map.Cat19AC, 
CASE  
    WHEN (map.Acres - Cat19AC) > 1 THEN 1 
    ELSE (map.Acres - Cat19AC)
END AS SITE,
CASE
    WHEN (map.Acres - Cat19AC) > 1 THEN map.Acres - 1 - Cat19AC
    ELSE 0
END AS REMACRES
From KC_MAP_PlatReportBase_v AS map
Left Join LandHeader AS lh
    On lh.RevObjId = map.RevObjId
    And lh.EffStatus='A'
    And lh.PostingSource='A'
Where map.AIN IN ({','.join(['?' for _ in AINLIST])})


--Where map.EffStatus = 'A' 
--AND map.AIN IN ({','.join(AINLIST)}) 
--"""
--WHERE map.AIN = '302083'
--And lh.TotalMktAcreage = 0
