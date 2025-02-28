/*
AsTxDBProd
GRM_Main
As a test, the LRSN/AIN that DeeAnn and I used was:
LRSN 49006
AIN 186888s
*/

-----------------------------------
--START HERE
-----------------------------------

--Begins CTEs
WITH 
------------
-- Only most recent description header. 
-- For an unknown reason, there are sometimes two active headers.
------------
CTE_DescrHeader AS (
    SELECT
        dh.Id,
        dh.BegEffDate,
        dh.TranId,
        dh.RevObjId,
        dh.DescrHeaderType,
        dh.DisplayDescr,
        ROW_NUMBER() OVER (PARTITION BY dh.RevObjId ORDER BY dh.BegEffDate DESC) AS RowNum
    FROM DescrHeader AS dh
    WHERE dh.EffStatus = 'A'
),

CTE_MFDetails AS (
  Select
    e.lrsn,
    --Year, Vin, Make, if applicable
    i.year_built AS [YearBuilt],
    LTRIM(RTRIM(mh.mh_serial_num)) AS [VIN],
    LTRIM(RTRIM(ct.tbl_element_desc)) AS [Make]
  
  --Extensions always comes first
  From extensions AS e --ON kcv.lrsn=e.lrsn
  
  --Extensions linkes to improvements on lrsn AND extension
  JOIN improvements AS i ON e.lrsn=i.lrsn 
        AND e.extension=i.extension
        AND i.status='A'
        AND i.improvement_id='M'
  --manuf_housing, comm_bldg, dwellings all must be after e and i
  LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
        AND i.extension=mh.extension
        AND mh.status='A'
    Join codes_table AS ct ON mh.mh_make=ct.tbl_element 
      AND ct.tbl_type_code='mhmake'
  
  Where e.status = 'A'
  
),

CTE_FncDetails AS (
--Summary by Year Level, but off ten cents
  SELECT
      RevObjId,
      TaxBillId,
      TaxYear,
      CAST(SUM(TaxAmount) AS decimal(18, 2)) AS [NetTax],
      CAST(SUM(IntAmount) AS decimal(18, 2)) AS [Interest],
      CAST(SUM(PenAmount) AS decimal(18, 2)) AS [Penalty],
      CAST(SUM(FeeAmount) AS decimal(18, 2)) AS [Fees],
      CAST(SUM(TaxAmount + PenAmount + IntAmount + FeeAmount + DiscAmount) AS decimal(18, 2)) AS [Total]
  FROM eGovFD_T
  --WHERE RevObjId = '49006' -- Test parcel LRSN 49006 AIN 186888
  GROUP BY
      RevObjId,
      TaxBillId,
      TaxYear
  --ORDER BY TaxYear DESC      
)


----Main Query Starts Here with Select

SELECT DISTINCT
  --Demographics
  LTRIM(RTRIM(kcv.ain)) AS [AIN], 
  LTRIM(RTRIM(kcv.pin)) AS [PIN], 
  LTRIM(RTRIM(pb.OwnerName1)) AS [Owner],
  LTRIM(RTRIM(pb.OwnerName2)) AS [AltOwner],
  LTRIM(RTRIM(kcv.AttentionLine)) AS [Comm_Attn],
  LTRIM(RTRIM(kcv.MailingAddress)) AS [MailingAddress],
  LTRIM(RTRIM(kcv.MailingCityStZip)) AS [Mailing_CSZ],
  LTRIM(RTRIM(pb.OwnerCountry)) AS [OwnerCountry],
  LTRIM(RTRIM(kcv.SitusAddress)) AS [SitusAddress],
--  LTRIM(RTRIM(kcv.DisplayDescr)) AS [LegalDescription],
  dd.DisplayDescr AS [ParcelBase_LegalDesc],

--CTE Amounts (incomplete, still searching for these figures)
  fndl.TaxBillId,
  fndl.TaxYear,
  fndl.[NetTax],
  fndl.[Interest],
  fndl.[Penalty],
  fndl.[Fees],
  fndl.[Total],

--CTE --Year, Vin, Make, if applicable
  mfd.[YearBuilt],
  mfd.[VIN],
  mfd.[Make]


--From Tables and CTEs

FROM KCv_PARCELMASTER1 AS kcv 
JOIN parcel_base_data AS pb ON kcv.lrsn=pb.lrsn
  AND pb.status='A'
LEFT JOIN CTE_DescrHeader AS dd ON pb.lrsn=dd.RevObjId
  AND dd.RowNum = 1
LEFT JOIN CTE_MFDetails AS mfd ON kcv.lrsn=mfd.lrsn
LEFT JOIN CTE_FncDetails AS fndl ON kcv.lrsn=fndl.RevObjId
  AND fndl.[Total] > '0'
--Begin WHERE Clauses for Primary From Table

WHERE kcv.EffStatus='A'
AND kcv.pin NOT LIKE 'GENERAL PARCEL'
AND kcv.pin LIKE 'M%'
    OR kcv.pin LIKE 'L%'
    OR kcv.pin LIKE 'G%'
    OR kcv.pin LIKE 'E%'
    OR (kcv.pin LIKE 'R%' AND kcv.DisplayDescr LIKE '%Golden Spike%')
    OR (kcv.pin LIKE 'U%' AND kcv.ClassCD='010 Operating Property')
    OR (kcv.pin LIKE '%' AND kcv.DisplayDescr LIKE '%PP On Real%')
  
--End with Order By
ORDER BY [PIN];

--DGW