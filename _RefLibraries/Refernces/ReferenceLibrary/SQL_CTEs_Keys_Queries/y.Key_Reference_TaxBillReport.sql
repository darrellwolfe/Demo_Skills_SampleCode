
/*
AsTxDBProd
GRM_Main
TaxBill Lookup
Starting to figure out what tables and fields are needed to produce an accurate tax bill report (total due with penalties)
*/

SELECT 
tx.Id, tx.TaxYear, tx.BillNumber, 
tr.Id, tr.TaxBillId, tr.Status, tr.RollType, tr.TAGId, tr.RevObjId, tr.AcctId, tr.TaxType,
tv.Id, tv.TaxBillTranId, tv.ValueTypeId, tv.ValueAmount
FROM TaxBill tx
INNER JOIN TaxBillTran tr ON tx.Id = tr.TaxBillId
INNER JOIN TaxBillValue tv ON tr.Id = tv.TaxBillTranId
