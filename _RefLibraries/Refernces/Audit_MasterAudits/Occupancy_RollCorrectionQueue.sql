SELECT 
    ce.RevObjId,
    TRIM(p.pin) AS [PIN],
    TRIM(p.AIN) AS [AIN],
    CASE
        WHEN ce.CorrectionEventStatus = '18503' THEN 'Rejected'
        WHEN ce.CorrectionEventStatus = '18501' THEN 'Assessment Review'
    ELSE 'ERROR'
    END AS 'Event_Status',
    CASE
        WHEN ce.ValChangeReason = '1307108' THEN '38-Subsequent Assessment'
        WHEN ce.ValChangeReason = '1307082' THEN '06-Occupancy'
    ELSE 'ERROR'
    END AS 'Posting_Reason'

FROM CorrectionEventAsmtDetail AS ce
    JOIN TSBv_PARCELMASTER AS p ON ce.RevObjId = p.lrsn

WHERE ce.EffYear = '2024'
    AND ce.CorrectionEventStatus <> '18503'

ORDER BY ce.CorrectionEventStatus ASC