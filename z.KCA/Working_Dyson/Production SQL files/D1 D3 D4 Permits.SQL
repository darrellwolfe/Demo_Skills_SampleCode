SELECT
    permits.permit_ref,
    permits.permit_desc,
    permits.status,
    permits.permit_type,
    field_visit.status,
    permits.callback,
    field_visit.date_completed,
    field_visit.field_person,
    permits.phone_number,
    permits.filing_date,
    field_visit.field_out,
    field_visit.field_in,
    permits.permit_source,
    field_visit.visit_type,
    field_visit.need_to_visit,
    permits.cert_for_occ,
    permits.cost_estimate,
    permits.sq_ft,
    KCv_PARCELMASTER1.EffStatus,
    KCv_PARCELMASTER1.ain,
    KCv_PARCELMASTER1.neighborhood
FROM
    GRM_Main.dbo.permits AS permits
    INNER JOIN GRM_Main.dbo.field_visit AS field_visit
        ON permits.field_number = field_visit.field_number
        AND permits.lrsn = field_visit.lrsn
    INNER JOIN GRM_Main.dbo.KCv_PARCELMASTER1 AS KCv_PARCELMASTER1
        ON permits.lrsn = KCv_PARCELMASTER1.lrsn
WHERE
    (
        field_visit.field_person LIKE 'CLM%'
        OR field_visit.field_person LIKE 'CMCG%'
        OR field_visit.field_person LIKE 'CMDH%'
        OR field_visit.field_person LIKE 'CMG%'
        OR field_visit.field_person LIKE 'CMLB%'
        OR field_visit.field_person LIKE 'CMTH%'
        OR field_visit.field_person LIKE 'DDH%'
        OR field_visit.field_person LIKE 'EHCG%'
        OR field_visit.field_person LIKE 'EHDH%'
        OR field_visit.field_person LIKE 'EHTH%'
        OR field_visit.field_person LIKE 'GKCG%'
        OR field_visit.field_person LIKE 'GKDH%'
        OR field_visit.field_person LIKE 'GKTH%'
        OR field_visit.field_person LIKE 'GRK%'
        OR field_visit.field_person LIKE 'HW%'
        OR field_visit.field_person LIKE 'HWCG%'
        OR field_visit.field_person LIKE 'HWDH%'
        OR field_visit.field_person LIKE 'HWTH%'
        OR field_visit.field_person LIKE 'JLCG%'
        OR field_visit.field_person LIKE 'JLDH%'
        OR field_visit.field_person LIKE 'JLTH%'
        OR field_visit.field_person LIKE 'JPCG%'
        OR field_visit.field_person LIKE 'JPDH%'
        OR field_visit.field_person LIKE 'JPTH%'
        OR field_visit.field_person LIKE 'LBK%'
        OR field_visit.field_person LIKE 'MWCG%'
        OR field_visit.field_person LIKE 'MWDH%'
        OR field_visit.field_person LIKE 'MWTH%'
        OR field_visit.field_person LIKE 'RRCG%'
        OR field_visit.field_person LIKE 'RRDH%'
        OR field_visit.field_person LIKE 'RRTH%'
        OR field_visit.field_person LIKE 'RSCG%'
        OR field_visit.field_person LIKE 'RSDH%'
        OR field_visit.field_person LIKE 'RSTH%'
        OR field_visit.field_person LIKE 'RWR%'
        OR field_visit.field_person LIKE 'SHCG%'
        OR field_visit.field_person LIKE 'SHDW%'
        OR field_visit.field_person LIKE 'SHTH%'
        OR field_visit.field_person LIKE 'SLH%'
        OR field_visit.field_person LIKE 'TSCG%'
        OR field_visit.field_person LIKE 'TSDH%'
        OR field_visit.field_person LIKE 'TSJT%'
        OR field_visit.field_person LIKE 'TSLB%'
        OR field_visit.field_person LIKE 'TSTH%'
    )
    AND field_visit.status = 'A'
    AND (permits.status = 'A' OR permits.status = 'I')
    AND KCv_PARCELMASTER1.EffStatus = 'A'
    AND field_visit.date_completed >= '2023-01-01 00:00:00'
    AND field_visit.date_completed < '2023-12-31 00:00:01'
    ORDER BY
    field_visit.field_person,
    permits.permit_type
