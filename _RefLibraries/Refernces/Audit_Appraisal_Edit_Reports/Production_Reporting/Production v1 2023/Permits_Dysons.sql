-- !preview conn=con
SELECT
    p1.neighborhood,
    p1.permit_type_desc,
    p1.permit_count,
    COALESCE(p2.permits_closed_count, 0) AS permits_closed_count,
    COALESCE(p1.field_visits_count, 0) AS field_visits_count,
    COALESCE(p3.permits_inactive_current_year_count, 0) AS permits_inactive_current_year_count
FROM
    (
        SELECT
            parcel.neighborhood,
            c.tbl_element_desc AS permit_type_desc,
            COUNT(*) AS permit_count,
            SUM(CASE WHEN f.field_in = '2023-12-31' THEN 1 ELSE 0 END) AS field_visits_count
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
    ) AS p1
LEFT JOIN
    (
        SELECT
            parcel.neighborhood,
            c.tbl_element_desc AS permit_type_desc,
            COUNT(*) AS permits_closed_count
        FROM
            permits AS p2
            LEFT JOIN KCv_PARCELMASTER1 AS parcel ON p2.lrsn = parcel.lrsn
            JOIN codes_table AS c ON p2.permit_type = c.tbl_element
        WHERE
            p2.inactivedate >= '2023-08-01 00:00:00'
            AND p2.inactivedate < '2023-09-01 00:00:00'
            AND p2.status = 'I'
        GROUP BY
            parcel.neighborhood,
            c.tbl_element_desc
    ) AS p2 ON p1.neighborhood = p2.neighborhood AND p1.permit_type_desc = p2.permit_type_desc
LEFT JOIN
    (
        SELECT
            parcel.neighborhood,
            c.tbl_element_desc AS permit_type_desc,
            COUNT(*) AS permits_inactive_current_year_count
        FROM
            permits AS p
            LEFT JOIN KCv_PARCELMASTER1 AS parcel ON p.lrsn = parcel.lrsn
            JOIN codes_table AS c ON p.permit_type = c.tbl_element
        WHERE
            p.inactivedate >= '2023-01-01 00:00:00'
            AND p.inactivedate <= CURRENT_TIMESTAMP
            AND p.status = 'I'
        GROUP BY
            parcel.neighborhood,
            c.tbl_element_desc
    ) AS p3 ON p1.neighborhood = p3.neighborhood AND p1.permit_type_desc = p3.permit_type_desc
ORDER BY
    p1.neighborhood,
    p1.permit_type_desc;
