



Select Distinct 
    --lrsn,
    TRIM(PIN) AS PIN, 
    TRIM(AIN) AS AIN, 
    Acres, 
    Cat19AC, 
    CASE WHEN ACRES >= 1 THEN 1 ELSE ACRES - Cat19Ac END AS SITE, 
    CASE WHEN ACRES > 1 THEN ACRES - 1 - CAT19AC ELSE 0 END AS REMACRES 
From 
    KC_MAP_PlatReportBase_v 
Where 
    EffStatus = 'A' 
    --AND PIN like ? 

    AND PIN NOT LIKE '0%'
    AND PIN NOT LIKE '5%'
    AND PIN NOT LIKE '4%'

    AND PIN LIKE 'AL719%'

    --AND Cat19AC > 0

Order by 
    PIN ASC




