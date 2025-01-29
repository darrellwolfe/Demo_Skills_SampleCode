SELECT DISTINCT
    "extensions"."lrsn",
    "extensions"."extension",
    "extensions"."appraiser",
    "extensions"."appraisal_date",
    "extensions"."status",
    "KCv_PARCELMASTER1"."ain",
    "KCv_PARCELMASTER1"."neighborhood",
    "extensions"."data_source_code",
    "KCv_PARCELMASTER1"."pin"
FROM
    "GRM_Main"."dbo"."extensions" "extensions"
INNER JOIN
    "GRM_Main"."dbo"."KCv_PARCELMASTER1" "KCv_PARCELMASTER1"
ON
    "extensions"."lrsn" = "KCv_PARCELMASTER1"."lrsn"
WHERE
    "extensions"."status" = 'A'
    AND (
        "extensions"."appraiser" LIKE 'EVH%'
        OR "extensions"."appraiser" LIKE 'JCL%'
        OR "extensions"."appraiser" LIKE 'JCW%'
        OR "extensions"."appraiser" LIKE 'JGP%'
        OR "extensions"."appraiser" LIKE 'JRT%'
        OR "extensions"."appraiser" LIKE 'MPW%'
        OR "extensions"."appraiser" LIKE 'RFS%'
        OR "extensions"."appraiser" LIKE 'RFSAB%'
        OR "extensions"."appraiser" LIKE 'RMT%'
        OR "extensions"."appraiser" LIKE 'RSAB%'
        OR "extensions"."appraiser" LIKE 'RSJT%'
        OR "extensions"."appraiser" LIKE 'SRH%'
        OR "extensions"."appraiser" LIKE 'TKS%'
    )
    AND "extensions"."extension" = 'L00'
    AND (
        "KCv_PARCELMASTER1"."neighborhood" = 0
        OR "KCv_PARCELMASTER1"."neighborhood" = 2001
        OR "KCv_PARCELMASTER1"."neighborhood" = 2010
        OR "KCv_PARCELMASTER1"."neighborhood" = 2015
        OR "KCv_PARCELMASTER1"."neighborhood" = 2105
        OR "KCv_PARCELMASTER1"."neighborhood" = 2115
        OR "KCv_PARCELMASTER1"."neighborhood" = 2125
        OR "KCv_PARCELMASTER1"."neighborhood" = 2135
        OR "KCv_PARCELMASTER1"."neighborhood" = 2145
        OR "KCv_PARCELMASTER1"."neighborhood" = 2155
        OR "KCv_PARCELMASTER1"."neighborhood" = 2201
        OR "KCv_PARCELMASTER1"."neighborhood" = 2202
        OR "KCv_PARCELMASTER1"."neighborhood" = 2203
        OR "KCv_PARCELMASTER1"."neighborhood" = 2205
        OR "KCv_PARCELMASTER1"."neighborhood" = 2206
        OR "KCv_PARCELMASTER1"."neighborhood" = 2207
        OR "KCv_PARCELMASTER1"."neighborhood" = 2210
        OR "KCv_PARCELMASTER1"."neighborhood" = 2211
        OR "KCv_PARCELMASTER1"."neighborhood" = 2212
        OR "KCv_PARCELMASTER1"."neighborhood" = 2215
        OR "KCv_PARCELMASTER1"."neighborhood" = 2216
        OR "KCv_PARCELMASTER1"."neighborhood" = 2540
        OR "KCv_PARCELMASTER1"."neighborhood" = 2996
        OR "KCv_PARCELMASTER1"."neighborhood" = 2997
        OR "KCv_PARCELMASTER1"."neighborhood" = 2998
        OR "KCv_PARCELMASTER1"."neighborhood" = 2999
        OR "KCv_PARCELMASTER1"."neighborhood" = 5000
        OR "KCv_PARCELMASTER1"."neighborhood" = 5001
        OR "KCv_PARCELMASTER1"."neighborhood" = 5002
        OR "KCv_PARCELMASTER1"."neighborhood" = 5004
        OR "KCv_PARCELMASTER1"."neighborhood" = 5009
        OR "KCv_PARCELMASTER1"."neighborhood" = 5010
        OR "KCv_PARCELMASTER1"."neighborhood" = 5012
        OR "KCv_PARCELMASTER1"."neighborhood" = 5015
        OR "KCv_PARCELMASTER1"."neighborhood" = 5018
        OR "KCv_PARCELMASTER1"."neighborhood" = 5020
        OR "KCv_PARCELMASTER1"."neighborhood" = 5021
        OR "KCv_PARCELMASTER1"."neighborhood" = 5024
        OR "KCv_PARCELMASTER1"."neighborhood" = 5030
        OR "KCv_PARCELMASTER1"."neighborhood" = 5033
        OR "KCv_PARCELMASTER1"."neighborhood" = 5036
        OR "KCv_PARCELMASTER1"."neighborhood" = 5039
        OR "KCv_PARCELMASTER1"."neighborhood" = 5042
        OR "KCv_PARCELMASTER1"."neighborhood" = 5045
        OR "KCv_PARCELMASTER1"."neighborhood" = 5048
        OR "KCv_PARCELMASTER1"."neighborhood" = 5051
        OR "KCv_PARCELMASTER1"."neighborhood" = 5053
        OR "KCv_PARCELMASTER1"."neighborhood" = 5054
        OR "KCv_PARCELMASTER1"."neighborhood" = 5056
        OR "KCv_PARCELMASTER1"."neighborhood" = 5057
        OR "KCv_PARCELMASTER1"."neighborhood" = 5060
        OR "KCv_PARCELMASTER1"."neighborhood" = 5063
        OR "KCv_PARCELMASTER1"."neighborhood" = 5066
        OR "KCv_PARCELMASTER1"."neighborhood" = 5069
        OR "KCv_PARCELMASTER1"."neighborhood" = 5072
        OR "KCv_PARCELMASTER1"."neighborhood" = 5075
        OR "KCv_PARCELMASTER1"."neighborhood" = 5078
        OR "KCv_PARCELMASTER1"."neighborhood" = 5081
        OR "KCv_PARCELMASTER1"."neighborhood" = 5703
        OR "KCv_PARCELMASTER1"."neighborhood" = 5750
        OR "KCv_PARCELMASTER1"."neighborhood" = 5753
        OR "KCv_PARCELMASTER1"."neighborhood" = 5756
        OR "KCv_PARCELMASTER1"."neighborhood" = 5759
        OR "KCv_PARCELMASTER1"."neighborhood" = 5762
        OR "KCv_PARCELMASTER1"."neighborhood" = 5765
        OR "KCv_PARCELMASTER1"."neighborhood" = 5850
        OR "KCv_PARCELMASTER1"."neighborhood" = 5853
        OR "KCv_PARCELMASTER1"."neighborhood" = 5856
        OR "KCv_PARCELMASTER1"."neighborhood" = 6000
        OR "KCv_PARCELMASTER1"."neighborhood" = 6002
        OR "KCv_PARCELMASTER1"."neighborhood" = 6036
        OR "KCv_PARCELMASTER1"."neighborhood" = 6100
        OR "KCv_PARCELMASTER1"."neighborhood" = 6101
        OR "KCv_PARCELMASTER1"."neighborhood" = 6102
        OR "KCv_PARCELMASTER1"."neighborhood" = 6103
        OR "KCv_PARCELMASTER1"."neighborhood" = 6104
        OR "KCv_PARCELMASTER1"."neighborhood" = 6105
        OR "KCv_PARCELMASTER1"."neighborhood" = 6106
        OR "KCv_PARCELMASTER1"."neighborhood" = 6107
        OR "KCv_PARCELMASTER1"."neighborhood" = 6108
        OR "KCv_PARCELMASTER1"."neighborhood" = 6109
        OR "KCv_PARCELMASTER1"."neighborhood" = 6110
        OR "KCv_PARCELMASTER1"."neighborhood" = 6111
        OR "KCv_PARCELMASTER1"."neighborhood" = 6112
        OR "KCv_PARCELMASTER1"."neighborhood" = 6113
        OR "KCv_PARCELMASTER1"."neighborhood" = 6114
        OR "KCv_PARCELMASTER1"."neighborhood" = 6115
        OR "KCv_PARCELMASTER1"."neighborhood" = 6116
        OR "KCv_PARCELMASTER1"."neighborhood" = 6117
        OR "KCv_PARCELMASTER1"."neighborhood" = 6118
        OR "KCv_PARCELMASTER1"."neighborhood" = 6119
        OR "KCv_PARCELMASTER1"."neighborhood" = 6120
        OR "KCv_PARCELMASTER1"."neighborhood" = 6121
        OR "KCv_PARCELMASTER1"."neighborhood" = 6122
        OR "KCv_PARCELMASTER1"."neighborhood" = 6123
        OR "KCv_PARCELMASTER1"."neighborhood" = 6130)
        AND ("extensions"."appraisal_date" >= {ts '2023-01-01 00:00:00'}
        AND "extensions"."appraisal_date" < {ts '2023-12-31 12:00:01'})
ORDER BY
    "extensions"."appraiser",
    "KCv_PARCELMASTER1"."neighborhood",
    "extensions"."data_source_code",
    "extensions"."lrsn",
    "extensions"."extension"
