
-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

group_code
tbl_element_desc AS Imp_GroupCode_Desc


SELECT * FROM information_schema.columns 
WHERE column_name LIKE '%Acres%';


        TRIM(parcel.ain) AS [AIN],
    FROM KCv_PARCELMASTER1 AS parcel
    ON parcel.lrsn=lh.RevObjId

    WHERE parcel.EffStatus= 'A'

*/

WITH DuplicateFinder AS (
    SELECT DISTINCT
        lh.RevObjId
,        ag.AggregateSize AS [LandBase]
,        ROW_NUMBER() OVER (PARTITION BY lh.RevObjId ORDER BY ag.AggregateSize DESC) AS rn
    
    FROM LandHeader AS lh  
    
    JOIN LBAggregateSize AS ag ON lh.Id=ag.LandHeaderId 
      AND ag.EffStatus='A'
      AND ag.PostingSource='A'

    WHERE lh.EffStatus='A' 
      AND lh.PostingSource='A'
      AND lh.LandModelId='702023'
)

SELECT
TRIM(pm.ain) AS AIN
, CONCAT(TRIM(pm.ain),',') AS LookUp
, df.*

FROM DuplicateFinder AS df
JOIN TSBv_PARCELMASTER AS pm ON df.RevObjId=pm.lrsn

WHERE rn > 1
ORDER BY RevObjId

