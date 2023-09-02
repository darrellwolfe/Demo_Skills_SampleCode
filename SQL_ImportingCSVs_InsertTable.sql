-- !preview conn=conn


BULK INSERT Cyclistic_divvy_tripdata
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202307-divvy-tripdata.csv'

WITH (
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   FIRSTROW = 2
);


/*
--2022 FULL YEAR
I replaced the line with the new CSV for each of the months Jan 2022 through Aug 2023
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202201-divvy-tripdata.csv'
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202202-divvy-tripdata.csv'
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202203-divvy-tripdata.csv'
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202204-divvy-tripdata.csv'
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202205-divvy-tripdata.csv'
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202206-divvy-tripdata.csv'
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202207-divvy-tripdata.csv'
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202208-divvy-tripdata.csv'
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202209-divvy-tripdata.csv'
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202210-divvy-tripdata.csv'
--10 resulted in invalid character error, could not find anything wrong in the CSV.
--Copied formatting from 09 to 10 and it worked.
-- I ended up having to do this with the rest of the CSV files.
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202211-divvy-tripdata.csv'
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202212-divvy-tripdata.csv'
--2023 YTD
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202301-divvy-tripdata.csv'
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202302-divvy-tripdata.csv'
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202303-divvy-tripdata.csv'
-- I had to manually set 202303 to m/d/yyy h:mm custom formatting
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202304-divvy-tripdata.csv'
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202304-divvy-tripdata.csv'
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202306-divvy-tripdata.csv'
-- Manually changed 202306 to m/d/yyyy h:mm
FROM 'C:\Users\darre\OneDrive\Documents\!Datasets\Cyclistic_divvy_tripdata CSVs\CSVs\202307-divvy-tripdata.csv'
*/






