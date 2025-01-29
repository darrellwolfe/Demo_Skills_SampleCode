/*
AsTxDBProd
GRM_Main

TaxBill Lookup
*/

SELECT *
FROM TaxBill
INNER JOIN TaxBillTran ON TaxBill.Id = TaxBillTran.TaxBillId
INNER JOIN TaxBillValue ON TaxBillTran.Id = TaxBillValue.TaxBillTranId;
