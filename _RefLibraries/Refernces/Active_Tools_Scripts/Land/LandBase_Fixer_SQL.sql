WITH CTE_ParcelMaster AS (
Select Distinct
pm.lrsn,
TRIM(pm.AIN) AS AIN,
pm.LegalAcres
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'
),

CTE_LandBaseChecker AS (
Select Distinct
lh.RevObjId AS lrsn,
--ag.AggregateSize,
ag.AggregateType,
COUNT(lh.RevObjId) AS Instances
FROM LandHeader AS lh  
JOIN LBAggregateSize AS ag 
    ON lh.Id=ag.LandHeaderId 
    AND ag.EffStatus='A'
    AND ag.PostingSource='A'
WHERE lh.EffStatus='A' 
    AND lh.PostingSource='A'
    --CTE ParcelMaster already filtered for 'A'
GROUP BY ag.AggregateType, lh.RevObjId
)


SELECT DISTINCT
pmd.lrsn
,pmd.AIN
,pmd.LegalAcres
,ag.AggregateSize
,ag.AggregateType

FROM CTE_ParcelMaster AS pmd

LEFT JOIN LandHeader AS lh  
    ON lh.RevObjId=pmd.lrsn

    LEFT JOIN LBAggregateSize AS ag 
        ON lh.Id=ag.LandHeaderId 
        AND ag.EffStatus='A'
        AND ag.PostingSource='A'

LEFT JOIN CTE_LandBaseChecker AS checker
    ON checker.lrsn = pmd.lrsn


WHERE lh.EffStatus='A' 
    AND lh.PostingSource='A'
    --CTE ParcelMaster already filtered for 'A'
    AND ((ag.AggregateSize = 0
        OR ag.AggregateSize IS NULL)
        OR pmd.LegalAcres <> ag.AggregateSize)
    AND pmd.LegalAcres <> 0
    AND checker.Instances IS NULL

ORDER BY ag.AggregateSize DESC, pmd.LegalAcres DESC;