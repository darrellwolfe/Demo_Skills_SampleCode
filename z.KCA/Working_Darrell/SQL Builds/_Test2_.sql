Select 
lrsn,
YEAR(CAST(MIN(last_update) AS DATE)) AS AccountCreationDate
From parcel_base
Group by lrsn



CTE_AccountCreation AS (
Select 
lrsn,
YEAR(CAST(MIN(last_update) AS DATE)) AS AccountCreationDate
From parcel_base
Group by lrsn
)