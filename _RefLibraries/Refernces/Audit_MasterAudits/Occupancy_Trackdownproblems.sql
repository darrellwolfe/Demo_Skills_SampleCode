SELECT 
    ce.RevObjId,
    TRIM(p.pin) AS [PIN],
    TRIM(p.AIN) AS [AIN],
    p.neighborhood,
    CASE
        WHEN ce.CorrectionEventStatus = '18503' THEN 'Rejected'
        WHEN ce.CorrectionEventStatus = '18501' THEN 'Assessment Review'
    ELSE 'ERROR'
    END AS 'Event_Status',
    CASE
        WHEN ce.ValChangeReason = '1307108' THEN '38-Subsequent Assessment'
        WHEN ce.ValChangeReason = '1307082' THEN '06-Occupancy'
    ELSE 'ERROR'
    END AS 'Posting_Reason',
    p.DisplayDescr
--    m.ModifierShortDescr,
--    m.OverrideAmount

FROM CorrectionEventAsmtDetail AS ce
    JOIN TSBv_PARCELMASTER AS p ON ce.RevObjId = p.lrsn
--    JOIN TSBv_MODIFIERS AS m ON p.lrsn = m.lrsn
--        AND m.ModifierShortDescr LIKE '%URD%'
--        AND m.ModifierStatus = 'A'
--        AND m.PINStatus = 'A'

WHERE ce.EffYear = '2024'
    AND ce.CorrectionEventStatus <> '18503'
    AND ce.ValChangeReason IN ('1307082','1307108')
--    AND ce.ValChangeReason = '1307082'
--    AND ce.ValChangeReason = '1307108'
--    AND p.DisplayDescr LIKE '%URD%'

ORDER BY PIN ASC