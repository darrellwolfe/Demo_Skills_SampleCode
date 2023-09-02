
/*
Personal Property Asset AUDIT for a specific asset type

'%test here%'
'%BILLBOARD%'

*/


SELECT
RTRIM(LTRIM(p.mDescription)) AS tPP_mDescription,
RTRIM(LTRIM(p.mNote)) AS tPP_mNote,
kcv.pin,
kcv.ain,
p.mAssetCategory,
p.mPropertyId,
p.mAssetId,
p.mChangeTimeStamp,
p.mbegTaxYear


FROM tPPAsset AS p
JOIN KCv_PARCELMASTER1 AS kcv ON p.mPropertyId=kcv.lrsn

WHERE mEffStatus='A'
AND kcv.EffStatus='A'
AND mDescription LIKE '%BILLBOARD%';
