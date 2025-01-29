SELECT
    parcel.neighborhood,
    COUNT(*) AS permits_closed_count
FROM
    permits AS p2
Left JOIN
    KCv_PARCELMASTER1 AS parcel ON p2.lrsn = parcel.lrsn
WHERE
    p2.inactivedate >= '2023-05-01 00:00:00'
    AND p2.inactivedate < '2023-06-01 00:00:00'
    AND p2.status = 'I'
GROUP BY
    parcel.neighborhood;
