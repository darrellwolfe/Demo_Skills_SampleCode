SELECT DISTINCT
    extensions.lrsn,
    extensions.extension,
    extensions.status,
    KCv_PARCELMASTER1.ain,
    KCv_PARCELMASTER1.neighborhood,
    extensions.data_collector,
    extensions.collection_date,
    extensions.data_source_code,
    KCv_PARCELMASTER1.pin
FROM
    GRM_Main.dbo.extensions AS extensions
    INNER JOIN GRM_Main.dbo.KCv_PARCELMASTER1 AS KCv_PARCELMASTER1
        ON extensions.lrsn = KCv_PARCELMASTER1.lrsn
WHERE
    (
        extensions.data_collector = 'EHJP'
        OR extensions.data_collector = 'EVH'
        OR extensions.data_collector = 'JCL'
        OR extensions.data_collector = 'JCW'
        OR extensions.data_collector = 'JGP'
        OR extensions.data_collector = 'JRT'
        OR extensions.data_collector = 'MPW'
        OR extensions.data_collector = 'RFS'
        OR extensions.data_collector = 'RFSAB'
        OR extensions.data_collector = 'RSAB'
        OR extensions.data_collector = 'RSJT'
        OR extensions.data_collector = 'SRH'
        OR extensions.data_collector = 'TKS'
    )
    AND (
        KCv_PARCELMASTER1.neighborhood IN (
            0, 2001, 2010, 2015, 2105, 2115, 2125, 2135, 2145, 2155, 2201, 2202, 2203, 2205, 2206, 2207, 2210, 2211, 2212, 2215, 2216, 2540, 2996, 2997, 2998, 2999, 5000, 5001, 5002, 5004, 5009, 5010, 5012, 5015, 5018, 5020, 5021, 5024, 5030, 5033, 5036, 5039, 5042, 5045, 5048, 5051, 5053, 5054, 5056, 5057, 5060, 5063, 5066, 5069, 5072, 5075, 5078, 5081, 5703, 5750, 5753, 5756, 5759, 5762, 5765, 5850, 5853, 5856, 6000, 6002, 6036, 6100, 6101, 6102, 6103, 6104, 6105, 6106, 6107, 6108, 6109, 6110, 6111, 6112, 6113, 6114, 6115, 6116, 6117, 6118, 6119, 6120, 6121, 6122, 6123, 6130)
    )
    AND extensions.status = 'A'
    AND extensions.extension = 'L00'
    AND extensions.collection_date >= '2023-01-01 00:00:00'
    AND extensions.collection_date < '2023-12-31 12:00:01'
ORDER BY
    extensions.data_collector,
    KCv_PARCELMASTER1.neighborhood,
    extensions.lrsn,
    extensions.extension
