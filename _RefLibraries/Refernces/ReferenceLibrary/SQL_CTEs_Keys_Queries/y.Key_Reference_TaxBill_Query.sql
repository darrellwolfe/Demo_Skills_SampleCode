SELECT DISTINCT
CONCAT(CAST(tb.TaxYear AS VARCHAR(10)), '-', tb.BillNumber) AS [TaxBill#],
tb.AssessmentYear AS [AssessmentYear],
tbn.RevObjId AS [LRSN],
tbv.ValueTypeId AS [ValueTypeId],
vt.Descr AS [ValueType],
tbv.ValueAmount AS [TaxBillAmount]

FROM TaxBill AS tb
INNER JOIN TaxBillTran AS tbn ON tb.Id = tbn.TaxBillId
INNER JOIN TaxBillValue AS tbv ON tbn.Id = tbv.TaxBillTranId
INNER JOIN ValueType AS vt ON tbv.ValueTypeId=vt.Id

ORDER BY
tbn.RevObjId,
[TaxBill#];
