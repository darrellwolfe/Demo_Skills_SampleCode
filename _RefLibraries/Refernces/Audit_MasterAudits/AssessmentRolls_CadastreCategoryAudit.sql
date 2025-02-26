SELECT
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

WHERE r.AssessmentYear = '2024'
    AND c.TypeCode = 'AssessedByCat'
    AND (c.FullGroupCode IN ('67','67L','98','99') OR (c.FullGroupCode = '19' AND c.ValueAmount > 0))