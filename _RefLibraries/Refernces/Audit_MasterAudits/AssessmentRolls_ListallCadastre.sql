SELECT
    c.PIN,
    c.CadRollId,
    c.RollCaste,
    c.RollType,
    c.TaxYear,
    c.AIN,
    c.FullGroupCode,
    c.TypeCode,
    c.ValueAmount,
    c.ValueType

FROM CadRoll AS r
    JOIN CadLevel AS l ON r.Id = l.CadRollId
    JOIN CadInv AS i ON l.Id = i.CadLevelId
    JOIN tsbv_cadastre AS c ON c.CadRollId = r.Id
        AND c.CadInvId = i.Id

WHERE c.CadRollId = '569'
    AND c.ValueType = '455' /*Net Taxable Value*/

ORDER BY PIN