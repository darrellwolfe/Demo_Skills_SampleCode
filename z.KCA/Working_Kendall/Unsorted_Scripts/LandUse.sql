SELECT DISTINCT
    m.lrsn AS [LRSN],
    TRIM(m.ain) AS [AIN],
    m.pin AS [PIN],
    CASE
        WHEN ldp.LandType IN ('61','MB') THEN 'Timber'
        WHEN ldp.LandType IN ('52','4') THEN 'Agriculture'
        ELSE 'Do Not Replace'
    END AS [Replace With]

FROM TSBv_MODIFIERS AS m
    JOIN LandHeader AS lh ON lh.RevObjId = m.lrsn
        AND lh.PostingSource = 'A'
        AND lh.EffStatus = 'A'
    JOIN LandDetail AS ld ON ld.LandHeaderId = lh.Id
        AND ld.PostingSource = 'A'
        AND ld.EffStatus = 'A'
    LEFT JOIN LandDetail AS ldp ON ldp.LandHeaderId = lh.Id
        AND (ldp.PrimaryUse = 'P' OR ldp.LandType IN ('52','4'))
        AND ldp.PostingSource = 'A'
        AND ldp.EffStatus = 'A'

WHERE m.ModifierShortDescr = 'LandUse'
    AND m.ModifierStatus = 'A'
    AND m.PINStatus = 'A'
    AND m.ExpirationYear > 2024

ORDER BY PIN