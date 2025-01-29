SELECT DISTINCT
    "extensions"."lrsn",
    "extensions"."extension",
    "extensions"."appraiser",
    "extensions"."appraisal_date",
    "KCv_PARCELMASTER1"."ain",
    "KCv_PARCELMASTER1"."neighborhood",
    "extensions"."data_source_code",
    "KCv_PARCELMASTER1"."EffStatus"
FROM
    "GRM_Main"."dbo"."extensions" "extensions"
INNER JOIN
    "GRM_Main"."dbo"."KCv_PARCELMASTER1" "KCv_PARCELMASTER1"
    ON "extensions"."lrsn" = "KCv_PARCELMASTER1"."lrsn"
WHERE
    ("KCv_PARCELMASTER1"."neighborhood" = 1000
    OR "KCv_PARCELMASTER1"."neighborhood" = 1001
    OR "KCv_PARCELMASTER1"."neighborhood" = 1002
    OR "KCv_PARCELMASTER1"."neighborhood" = 1003
    OR "KCv_PARCELMASTER1"."neighborhood" = 1004
    OR "KCv_PARCELMASTER1"."neighborhood" = 1005
    OR "KCv_PARCELMASTER1"."neighborhood" = 1006
    OR "KCv_PARCELMASTER1"."neighborhood" = 1007
    OR "KCv_PARCELMASTER1"."neighborhood" = 1008
    OR "KCv_PARCELMASTER1"."neighborhood" = 1010
    OR "KCv_PARCELMASTER1"."neighborhood" = 1019
    OR "KCv_PARCELMASTER1"."neighborhood" = 1020
    OR "KCv_PARCELMASTER1"."neighborhood" = 1410
    OR "KCv_PARCELMASTER1"."neighborhood" = 1411
    OR "KCv_PARCELMASTER1"."neighborhood" = 1412
    OR "KCv_PARCELMASTER1"."neighborhood" = 1413
    OR "KCv_PARCELMASTER1"."neighborhood" = 1420
    OR "KCv_PARCELMASTER1"."neighborhood" = 1430
    OR "KCv_PARCELMASTER1"."neighborhood" = 1440
    OR "KCv_PARCELMASTER1"."neighborhood" = 1450
    OR "KCv_PARCELMASTER1"."neighborhood" = 1460
    OR "KCv_PARCELMASTER1"."neighborhood" = 1501
    OR "KCv_PARCELMASTER1"."neighborhood" = 1502
    OR "KCv_PARCELMASTER1"."neighborhood" = 1503
    OR "KCv_PARCELMASTER1"."neighborhood" = 1504
    OR "KCv_PARCELMASTER1"."neighborhood" = 1505
    OR "KCv_PARCELMASTER1"."neighborhood" = 1506
    OR "KCv_PARCELMASTER1"."neighborhood" = 1507
    OR "KCv_PARCELMASTER1"."neighborhood" = 1511
    OR "KCv_PARCELMASTER1"."neighborhood" = 1512
    OR "KCv_PARCELMASTER1"."neighborhood" = 1513
    OR "KCv_PARCELMASTER1"."neighborhood" = 1514
    OR "KCv_PARCELMASTER1"."neighborhood" = 1515
    OR "KCv_PARCELMASTER1"."neighborhood" = 1998
    OR "KCv_PARCELMASTER1"."neighborhood" = 1999
    OR "KCv_PARCELMASTER1"."neighborhood" = 3502
    OR "KCv_PARCELMASTER1"."neighborhood" = 3503
    OR "KCv_PARCELMASTER1"."neighborhood" = 3504
    OR "KCv_PARCELMASTER1"."neighborhood" = 3505
    OR "KCv_PARCELMASTER1"."neighborhood" = 3506
    OR "KCv_PARCELMASTER1"."neighborhood" = 3517
    OR "KCv_PARCELMASTER1"."neighborhood" = 3523
    OR "KCv_PARCELMASTER1"."neighborhood" = 3701
    OR "KCv_PARCELMASTER1"."neighborhood" = 3702
    OR "KCv_PARCELMASTER1"."neighborhood" = 3703
    OR "KCv_PARCELMASTER1"."neighborhood" = 3998
    OR "KCv_PARCELMASTER1"."neighborhood" = 3999
    OR "KCv_PARCELMASTER1"."neighborhood" = 4018
    OR "KCv_PARCELMASTER1"."neighborhood" = 4019
    OR "KCv_PARCELMASTER1"."neighborhood" = 4020
    OR "KCv_PARCELMASTER1"."neighborhood" = 4021
    OR "KCv_PARCELMASTER1"."neighborhood" = 4201
    OR "KCv_PARCELMASTER1"."neighborhood" = 4202
    OR "KCv_PARCELMASTER1"."neighborhood" = 4203
    OR "KCv_PARCELMASTER1"."neighborhood" = 4204
    OR "KCv_PARCELMASTER1"."neighborhood" = 4833
    OR "KCv_PARCELMASTER1"."neighborhood" = 4840
    OR "KCv_PARCELMASTER1"."neighborhood" = 4997
    OR "KCv_PARCELMASTER1"."neighborhood" = 4998
    OR "KCv_PARCELMASTER1"."neighborhood" = 4999)
    AND ("extensions"."appraiser" LIKE 'CLM%'
    OR "extensions"."appraiser" LIKE 'CMCG%'
    OR "extensions"."appraiser" LIKE 'CMDH%'
    OR "extensions"."appraiser" LIKE 'CMG%'
    OR "extensions"."appraiser" LIKE 'CMLB%'
    OR "extensions"."appraiser" LIKE 'CMTH%'
    OR "extensions"."appraiser" LIKE 'DDH%'
    OR "extensions"."appraiser" LIKE 'EHCG%'
    OR "extensions"."appraiser" LIKE 'EHDH%'
    OR "extensions"."appraiser" LIKE 'EHTH%'
    OR "extensions"."appraiser" LIKE 'GKCG%'
    OR "extensions"."appraiser" LIKE 'GKDH%'
    OR "extensions"."appraiser" LIKE 'GKTH%'
    OR "extensions"."appraiser" LIKE 'GRK%'
    OR "extensions"."appraiser" LIKE 'HW%'
    OR "extensions"."appraiser" LIKE 'HWCG%'
    OR "extensions"."appraiser" LIKE 'HWDH%'
    OR "extensions"."appraiser" LIKE 'HWTH%'
    OR "extensions"."appraiser" LIKE 'JLCG%'
    OR "extensions"."appraiser" LIKE 'JLDH%'
    OR "extensions"."appraiser" LIKE 'JLTH%'
    OR "extensions"."appraiser" LIKE 'JPCG%'
    OR "extensions"."appraiser" LIKE 'JPDH%'
    OR "extensions"."appraiser" LIKE 'JPTH%'
    OR "extensions"."appraiser" LIKE 'LBK%'
    OR "extensions"."appraiser" LIKE 'MWCG%'
    OR "extensions"."appraiser" LIKE 'MWDH%'
    OR "extensions"."appraiser" LIKE 'MWTH%'
    OR "extensions"."appraiser" LIKE 'RRCG%'
    OR "extensions"."appraiser" LIKE 'RRDH%'
    OR "extensions"."appraiser" LIKE 'RRTH%'
    OR "extensions"."appraiser" LIKE 'RSCG%'
    OR "extensions"."appraiser" LIKE 'RSDH%'
    OR "extensions"."appraiser" LIKE 'RSTH%'
    OR "extensions"."appraiser" LIKE 'RWR%'
    OR "extensions"."appraiser" LIKE 'SHCG%'
    OR "extensions"."appraiser" LIKE 'SHDW%'
    OR "extensions"."appraiser" LIKE 'SHTH%'
    OR "extensions"."appraiser" LIKE 'SLH%'
    OR "extensions"."appraiser" LIKE 'TSCG%'
    OR "extensions"."appraiser" LIKE 'TSDH%'
    OR "extensions"."appraiser" LIKE 'TSJT%'
    OR "extensions"."appraiser" LIKE 'TSLB%'
    OR "extensions"."appraiser" LIKE 'TSTH%')
    AND "extensions"."extension" = 'L00'
    AND "KCv_PARCELMASTER1"."EffStatus" = 'A'
    AND ("extensions"."appraisal_date" >= {ts '2023-01-01 00:00:00'}
    AND "extensions"."appraisal_date" < {ts '2023-12-31 00:00:01'})
ORDER BY "extensions"."appraiser",
         "KCv_PARCELMASTER1"."neighborhood",
         "extensions"."data_source_code",
         "extensions"."lrsn",
         "extensions"."extension";
