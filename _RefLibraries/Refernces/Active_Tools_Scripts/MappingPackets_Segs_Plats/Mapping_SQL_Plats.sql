--Select TOP 10
Select Distinct 
    RevObjId AS lrsn,
    TRIM(PIN) AS PIN, 
    TRIM(AIN) AS AIN, 
    CAST(LEFT(Prop_Class_Descr,3) AS INT) AS PCC,
    TRIM(Prop_Class_Descr) AS Prop_Class_Descr,
    Acres, 
    Cat19AC, 
    CASE  
        WHEN (Acres - Cat19AC) > 1 THEN 1 
        ELSE (Acres - Cat19AC)
    END AS SITE,

    CASE
        WHEN (Acres - Cat19AC) > 1 THEN Acres - 1 - Cat19AC
        ELSE 0
    END AS REMACRES

From KC_MAP_PlatReportBase_v 
Where EffStatus = 'A' 
AND PIN like ?
--And Acres > 1
--And Cat19AC > 0
