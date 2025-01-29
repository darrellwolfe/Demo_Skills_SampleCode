SELECT V1.RevObjId, v1.PIN, v1.AIN, v1.Owner, pm.ClassCd, v1.Valueamount as PerPropAssessed,
v2.valueamount as Exemption, v3.valueamount as NetTaxable
FROM KCv_PPAnnualCadExport18a V1
LEFT OUTER JOIN KCv_PPAnnualCadExport18a V2 ON V1.REVOBJID=V2.REVOBJID AND V2.VALUETYPEID=320
LEFT OUTER JOIN KCv_PPAnnualCadExport18a V3 ON V1.REVOBJID=V3.REVOBJID AND V3.VALUETYPEID=455
left outer join kcv_parcelmaster_short pm on pm.lrsn=v1.revobjid
WHERE V1.VALUETYPEID=105
ORDER BY PIN--, VALUETYPEID
