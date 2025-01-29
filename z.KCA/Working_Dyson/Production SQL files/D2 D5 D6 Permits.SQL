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
    INNER JOIN GRM_Main.dbo.KCv_PARCELMASTER1 AS KCv_PARCELMASTER1
        ON permits.lrsn = KCv_PARCELMASTER1.lrsn
WHERE
    (field_visit.field_person LIKE 'EHJP%'
    OR field_visit.field_person LIKE 'EVH%'
    OR field_visit.field_person LIKE 'GRK%'
    OR field_visit.field_person LIKE 'JCL%'
    OR field_visit.field_person LIKE 'JCW%'
    OR field_visit.field_person LIKE 'JGP%'
    OR field_visit.field_person LIKE 'JLCM%'
    OR field_visit.field_person LIKE 'JRT%'
    OR field_visit.field_person LIKE 'MPW%'
    OR field_visit.field_person LIKE 'RFS%'
    OR field_visit.field_person LIKE 'RSJT%'
    OR field_visit.field_person LIKE 'TKS%')
    AND field_visit.status = 'A'
    AND (permits.status = 'A' OR permits.status = 'I')
    AND KCv_PARCELMASTER1.EffStatus = 'A'
    AND field_visit.date_completed >= '2023-01-01 00:00:00'
    AND field_visit.date_completed < '2023-12-31 00:00:01'ORDER BY
    field_visit.field_person,
    permits.permit_type
