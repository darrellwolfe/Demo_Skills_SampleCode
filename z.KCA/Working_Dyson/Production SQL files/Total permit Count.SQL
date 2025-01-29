SELECT
    parcel.neighborhood,
    c.tbl_element_desc AS permit_type_desc,
    COUNT(*) AS permit_count
FROM
    KCv_PARCELMASTER1 AS parcel
    JOIN permits AS p ON parcel.lrsn = p.lrsn
    JOIN field_visit AS f ON p.lrsn = f.lrsn AND p.field_number = f.field_number
    JOIN codes_table AS c ON p.permit_type = c.tbl_element
WHERE
    parcel.EffStatus = 'A'
    AND p.status = 'A'
    AND c.tbl_type_code = 'permits'
    AND c.code_status = 'A'
GROUP BY
    parcel.neighborhood,
    c.tbl_element_desc
ORDER BY
    parcel.neighborhood,
    permit_type_desc;
