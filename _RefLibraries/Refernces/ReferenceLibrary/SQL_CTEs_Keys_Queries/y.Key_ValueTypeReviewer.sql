DECLARE @TaxYear INT = 2024;





Select Distinct
tr.RateValueType,
tr.TaxRate,
vt.Id,
vt.ShortDescr,
vt.Descr

From TafRate AS tr

Join ValueType AS vt
    On vt.Id = tr.RateValueType


WHERE tr.TaxYear = @TaxYear
AND tr.RateValueType IN (455, 456, 459, 460) -- Net Tax Value
--405, 455, 307, 