/*
AsTxDBProd
GRM_Main
*/
-- Parcel Master;

SELECT lrsn, pin, ain, ClassCD, neighborhood AS GEO
FROM KCv_PARCELMASTER1
WHERE EffStatus= 'A' AND neighborhood= '0';

