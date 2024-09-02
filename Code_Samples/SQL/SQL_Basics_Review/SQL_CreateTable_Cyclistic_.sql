-- !preview conn=conn
--  PRIMARY KEY became an issue while importing data, removing Primary Key component for now.

CREATE TABLE [dbo].[Cyclistic_divvy_tripdata] (
    ride_id VARCHAR(60), 
    rideable_type VARCHAR(MAX),
    started_at DATETIME,
    ended_at DATETIME,
    start_station_name VARCHAR(MAX),
    start_station_id VARCHAR(MAX),
    end_station_name VARCHAR(MAX),
    end_station_id VARCHAR(MAX),
    start_lat DECIMAL(22, 20),
    start_lng DECIMAL(22, 20),
    end_lat DECIMAL(22, 20),
    end_lng DECIMAL(22, 20),    
    member_casual VARCHAR(MAX)
);



