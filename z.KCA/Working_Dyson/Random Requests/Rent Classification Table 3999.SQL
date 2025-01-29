SELECT p.AIN, i.Income_year, i.rent_class, i.neighborhood
FROM income_computation AS i
Inner Join KCv_Parcelmaster1 as p ON i.lrsn = p.lrsn
Where i.Income_year = '2022' AND i.neighborhood = '3999' AND i.rent_class = '2'
