/*
AsTxDBProd
GRM_Main

TaxBill Lookup
*/

SELECT *
FROM TaxBill tx
INNER JOIN TaxBillTran tr 
ON tx.Id = tr.TaxBillId
INNER JOIN TaxBillValue tv 
ON tr.Id = tv.TaxBillTranId
WHERE tx.BillNumber= '284191';
