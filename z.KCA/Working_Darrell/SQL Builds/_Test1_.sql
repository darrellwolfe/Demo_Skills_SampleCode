

Select Distinct Top 1
TRIM(pm.SitusCity) AS SitusCity,
LEN(TRIM(pm.SitusCity)) AS Length
From TSBv_PARCELMASTER AS pm

Where LEN(TRIM(pm.SitusCity)) > 0

Order by LEN(TRIM(pm.SitusCity)) ASC
