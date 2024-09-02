

/*
AsTxDBProd
GRM_Main

**PERSONAL PROPERTY QUERY REQUIRES YEARLY UPDATES IN SEVERAL TABLES, REVIEW ALL YEARS
2023 TO 2024, ETC.

*/


--Begins CTE Statements chained within a single WITH statement

WITH
--Pulling in Aumentum Notes
    CTE_Note (lrsn,PPNotes) AS (
    SELECT 
        objectId,
        noteText
    FROM Note
    WHERE noteText LIKE '%2023%'
),

--Looking to ensure no PP accounts have a TAG in the 301 or 345 Taxing Districts
    CTE_TaxAuth301345 ([TaxAuthTAG], [301_345]) AS (
    SELECT
        LTRIM(RTRIM(TagDescr)),
        LTRIM(RTRIM(TaxAuthorityDescr))

    FROM KCv_AumentumEasy_TagTaxAuthorities
    WHERE (TaxAuthorityDescr LIKE '%345%' 
    OR TaxAuthorityDescr LIKE '%301%')
),

--Looking to see what PP accounts have a URD Modifier, to be compared with URD in the legal descriptions
    CTE_ModURD (lrsn, [URD], [URD%], [URD$]) AS (
    SELECT
        lrsn,
        ModifierDescr,
        ModifierPercent,
        OverrideAmount
    FROM TSBv_MODIFIERS
    WHERE ModifierStatus='A'
    AND ModifierDescr LIKE '%URD%'
    AND PINStatus='A'
),

--Looking for the Personal Property 63-602KK $250,000 exemption from Aumentum Modifiers, paying special attention to the shared exemptions
    CTE_63602KK (lrsn,[63-602KK], [63-602KK%],[63-602KK$]) AS (
    SELECT
        lrsn,
        ModifierDescr,
        ModifierPercent,
        OverrideAmount 
    FROM TSBv_MODIFIERS
    WHERE ModifierStatus='A'
    AND ModifierDescr LIKE '%602KK%'
    AND PINStatus='A'
),




--2022 Looking for Cert and Assessed Values (should match) for prior year(s) and current year. However, current year will not show until after Price & Post.
CTE_CertValues2022 (lrsn, PPCertValue2022, LastUpdated, RowNumber) AS (
    SELECT DISTINCT
        lrsn,
        SUM(imp_val) AS [CertValue],
        MAX(last_update) AS [LastUpdated],
ROW_NUMBER() OVER (PARTITION BY lrsn ORDER BY last_update DESC) AS RowNumber

    FROM valuation
    WHERE status='A'
    AND property_class IN ('10','20','21','22','30','32','60','70','80','90')
    AND eff_year BETWEEN 20220101 AND 20221231
--Change year for new Cert Values
    GROUP BY lrsn,last_update
),

--2023 Looking for Cert and Assessed Values (should match) for prior year(s) and current year. However, current year will not show until after Price & Post.
CTE_CertValues2023 (lrsn, PPCertValue2023, LastUpdated, RowNumber) AS (
    SELECT DISTINCT
        lrsn,
        SUM(imp_val) AS [CertValue],
        MAX(last_update) AS [LastUpdated],
ROW_NUMBER() OVER (PARTITION BY lrsn ORDER BY last_update DESC) AS RowNumber

    FROM valuation
    WHERE status='A'
    AND property_class IN ('10','20','21','22','30','32','60','70','80','90')
    AND eff_year BETWEEN 20230101 AND 20231231
--Change year for new Cert Values
    GROUP BY lrsn,last_update
),

--Looking for Aquisition Value and Appraised Value from MPPV, aggragated by lrsn (mPropertyId); rather than by individual asset.
CTE_MPPV (lrsn,[AcquisitionValue_2023],[AppraisedValue_2023]) AS (
    SELECT
      mPropertyId,
      SUM(mAcquisitionValue),
      SUM(mAppraisedValue)
    FROM tPPAsset
    WHERE mEffStatus = 'A' 
      And mbegTaxYear BETWEEN '202300000' AND '202399999'
      And mendTaxYear BETWEEN '202300000' AND '202399999'
    GROUP BY mPropertyId
)


--Begins Primary Query

SELECT 
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
c22.PPCertValue2022,-- CTE
mppv.AcquisitionValue_2023,-- CTE
c23.PPCertValue2023,-- CTE
mppv.AppraisedValue_2023,-- CTE
kk.[63-602KK$],-- CTE
--Calculated Column
(mppv.AppraisedValue_2023-kk.[63-602KK$]) AS [NetTaxable],--Calculated
--Notes
--Demographics
LTRIM(RTRIM(parcel.DisplayName)) AS [Owner], 
LTRIM(RTRIM(n.PPNotes)) AS [Notes],
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],
--Mailing
LTRIM(RTRIM(parcel.AttentionLine)) AS [Attn],
LTRIM(RTRIM(parcel.MailingAddress)) AS [MailingAddress],
LTRIM(RTRIM(parcel.MailingCityStZip)) AS [Mailing CSZ],

--Other Audits
kk.[63-602KK], -- CTE
kk.[63-602KK%],-- CTE
LTRIM(RTRIM(parcel.TAG)) AS [TAG], -- CTE
ta.[301_345],--Should be zero at all times, if not, change the tag to a tag ending in 500
mURD.[URD%],-- CTE
mURD.[URD$],-- CTE
mURD.[URD],-- CTE
LTRIM(RTRIM(parcel.DisplayDescr)) AS [LegalDescription]--------

--Tables
FROM KCv_PARCELMASTER1 AS parcel
LEFT JOIN CTE_Note AS n ON parcel.lrsn=n.lrsn
LEFT JOIN CTE_TaxAuth301345 AS ta ON parcel.TAG=ta.TaxAuthTAG
LEFT JOIN CTE_ModURD AS mURD ON parcel.lrsn=mURD.lrsn
LEFT JOIN CTE_63602KK AS kk ON parcel.lrsn=kk.lrsn
LEFT JOIN CTE_MPPV AS mppv ON parcel.lrsn=mppv.lrsn
LEFT JOIN CTE_CertValues2022 AS c22 ON parcel.lrsn=c22.lrsn
  AND c22.RowNumber=1
LEFT JOIN CTE_CertValues2023 AS c23 ON parcel.lrsn=c23.lrsn
  AND c23.RowNumber=1

--Conditions
WHERE parcel.EffStatus= 'A'
AND parcel.ClassCD 
  IN ('020 Commercial','021 Commercial 1','022 Commercial 2','030 Industrial','032 Industrial 2','070 Commercial - Late','010 Operating Property','090 Exempt PPV')

ORDER BY 
[Owner],
[ClassCD],
[PIN];




/*

--c19.PPCertValue2019,
--c20.PPCertValue2020,
--c21.PPCertValue2021,

**This did not work because by including the date it seperated values by change date/times, 
which automatically considers individual asset changes, it has to be total values for active assets. 
--Looking for Aquisition Value and Appraised Value from MPPV, aggragated by lrsn (mPropertyId); rather than by individual asset.
CTE_MPPV (lrsn,[MostRecentAprslDate],[AcquisitionValue_2023],[AppraisedValue_2023],RowNumber) AS (
    SELECT
        mPropertyId,
        --mChangeTimeStamp,
        --SUM(mAcquisitionValue),
        SUM(mAppraisedValue)
--ROW_NUMBER() OVER (PARTITION BY mPropertyId ORDER BY mChangeTimeStamp DESC) AS RowNumber

    FROM tPPAsset
    WHERE mEffStatus = 'A' 
      And mbegTaxYear BETWEEN '202300000' AND '202399999'
      And mendTaxYear BETWEEN '202300000' AND '202399999'
--Change each year for current values (after MPPV has been rolled over
    GROUP BY mPropertyId




*/