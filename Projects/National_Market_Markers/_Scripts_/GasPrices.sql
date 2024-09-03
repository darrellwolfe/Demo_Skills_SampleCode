CREATE TABLE GasPrices (
    Data_Status VARCHAR(10),
    State VARCHAR(2),
    MSN VARCHAR(10),
    [1970] DECIMAL(5, 2),
    [1971] DECIMAL(5, 2),
    [1972] DECIMAL(5, 2),
    [1973] DECIMAL(5, 2),
    [1974] DECIMAL(5, 2),
    [1975] DECIMAL(5, 2),
    [1976] DECIMAL(5, 2),
    [1977] DECIMAL(5, 2),
    [1978] DECIMAL(5, 2),
    -- Continue for each year through 2022
    [2011] DECIMAL(5, 2),
    [2012] DECIMAL(5, 2),
    [2013] DECIMAL(5, 2),
    [2014] DECIMAL(5, 2),
    [2015] DECIMAL(5, 2),
    [2016] DECIMAL(5, 2),
    [2017] DECIMAL(5, 2),
    [2018] DECIMAL(5, 2),
    [2019] DECIMAL(5, 2),
    [2020] DECIMAL(5, 2),
    [2021] DECIMAL(5, 2),
    [2022] DECIMAL(5, 2)
);

BULK INSERT GasPrices
FROM 'C:/Users/dwolfe/Documents/Demo_Skills_SampleCode/Projects/National_Market_Markers/_dataframes/GasPrices_eia_prices_1970_2022.csv'
WITH
(
    FIELDTERMINATOR = ',',  -- CSV field delimiter
    ROWTERMINATOR = '\n',   -- Row terminator
    FIRSTROW = 2            -- Assuming the first row contains headers
);

SELECT *
FROM GasPrices
WHERE State = 'AK';
