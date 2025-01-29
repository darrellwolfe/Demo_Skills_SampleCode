SELECT DISTINCT
    extensions.lrsn,
    extensions.extension,
    extensions.status,
    KCv_PARCELMASTER1.ain,
    KCv_PARCELMASTER1.neighborhood,
    extensions.data_collector,
    extensions.collection_date,
    extensions.data_source_code,
    KCv_PARCELMASTER1.EffStatus
FROM
    GRM_Main.dbo.extensions AS extensions
    INNER JOIN GRM_Main.dbo.KCv_PARCELMASTER1 AS KCv_PARCELMASTER1
        ON extensions.lrsn = KCv_PARCELMASTER1.lrsn
WHERE
    (
        KCv_PARCELMASTER1.neighborhood IN (1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1010, 1019, 1020, 1410, 1411, 1412, 1413, 1420, 1430, 1440, 1450, 1460, 1501, 1502, 1503, 1504, 1505, 1506, 1507, 1511, 1512, 1513, 1514, 1515, 1998, 1999, 3502, 3503, 3504, 3505, 3506, 3517, 3523, 3701, 3702, 3703, 3998, 3999, 4018, 4019, 4020, 4021, 4201, 4202, 4203, 4204, 4833, 4840, 4997, 4998, 4999)
    )
    AND extensions.status = 'A'
    AND extensions.extension = 'L00'
    AND KCv_PARCELMASTER1.EffStatus = 'A'
    AND (
        extensions.data_collector LIKE 'CLM%'
        OR extensions.data_collector LIKE 'CMCG%'
        OR extensions.data_collector LIKE 'CMDH%'
        OR extensions.data_collector LIKE 'CMG%'
        OR extensions.data_collector LIKE 'CMLB%'
        OR extensions.data_collector LIKE 'CMTH%'
        OR extensions.data_collector LIKE 'DDH%'
        OR extensions.data_collector LIKE 'EHCG%'
        OR extensions.data_collector LIKE 'EHDH%'
        OR extensions.data_collector LIKE 'EHTH%'
        OR extensions.data_collector LIKE 'GKCG%'
        OR extensions.data_collector LIKE 'GKDH%'
        OR extensions.data_collector LIKE 'GKTH%'
        OR extensions.data_collector LIKE 'GRK%'
        OR extensions.data_collector LIKE 'HW%'
        OR extensions.data_collector LIKE 'HWCG%'
        OR extensions.data_collector LIKE 'HWDH%'
        OR extensions.data_collector LIKE 'HWTH%'
        OR extensions.data_collector LIKE 'JLCG%'
        OR extensions.data_collector LIKE 'JLDH%'
        OR extensions.data_collector LIKE 'JLTH%'
        OR extensions.data_collector LIKE 'JPCG%'
        OR extensions.data_collector LIKE 'JPDH%'
        OR extensions.data_collector LIKE 'JPTH%'
        OR extensions.data_collector LIKE 'LBK%'
        OR extensions.data_collector LIKE 'MWCG%'
        OR extensions.data_collector LIKE 'MWDH%'
        OR extensions.data_collector LIKE 'MWTH%'
        OR extensions.data_collector LIKE 'RRCG%'
        OR extensions.data_collector LIKE 'RRDH%'
        OR extensions.data_collector LIKE 'RRTH%'
        OR extensions.data_collector LIKE 'RSCG%'
        OR extensions.data_collector LIKE 'RSDH%'
        OR extensions.data_collector LIKE 'RSTH%'
        OR extensions.data_collector LIKE 'RWR%'
        OR extensions.data_collector LIKE 'SHCG%'
        OR extensions.data_collector LIKE 'SHDW%'
        OR extensions.data_collector LIKE 'SHTH%'
        OR extensions.data_collector LIKE 'SLH%'
        OR extensions.data_collector LIKE 'TSCG%'
        OR extensions.data_collector LIKE 'TSDH%'
        OR extensions.data_collector LIKE 'TSJT%'
        OR extensions.data_collector LIKE 'TSLB%'
        OR extensions.data_collector LIKE 'TSTH%'
    )
    AND (
        extensions.collection_date >= '2023-01-01 00:00:00'
        AND extensions.collection_date < '2023-12-31 00:00:01'
    )
ORDER BY
    extensions.data_collector,
    KCv_PARCELMASTER1.neighborhood,
    extensions.lrsn,
    extensions.extension
