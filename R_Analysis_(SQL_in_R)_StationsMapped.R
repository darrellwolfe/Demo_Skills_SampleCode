

# INSTALL PACKAGES
install.packages("DBI")
install.packages("odbc")
install.packages("RODBC")
install.packages("tidyverse")
install.packages("ggplot2")
install.packages("ggmap")
install.packages("sqldf")


# LOAD LIBRARIES
library(DBI)
library(odbc)
library(RODBC)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(scales)
library(sqldf)
library(ggmap)

# ESTABLISH CONNECTION TO MY LOCAL DATABASE

connection <- odbcDriverConnect("driver={SQL Server};server=LAPTOP-76LHVPRQ\\SQLEXPRESS;database=Coursera_Capstone_Project;trusted_connection=true")


# ASSIGN THE DATABASE TABLE AS A DATAFRAME (df) VARIABLE FOR EASIER RECALL

Cyclistic_df <- sqlFetch(connection, "dbo.Cyclistic_divvy_tripdata")


# OPTIONAL: WRITE ONE OR MORE DATA VIEWS AS CSVs
write.csv(Cyclistic_df, "C:/Users/darre/OneDrive/Documents/!Datasets/Cyclistic_divvy_tripdata CSVs/Final Dataset/Cyclistic_df.csv", row.names = FALSE)


# Explore the df: Column Names
colnames(Cyclistic_df)

# Explore the df: Structure
str(Cyclistic_df)

view(Cyclistic_df)



# Explore the df: Column Names
colnames(Cyclistic_df)

## VIEWS ##

# Start Stations

view(sqldf("select
              start_station_name, 
              start_station_id,
              start_lat,
              start_lng,
              member_casual,
              count(start_station_name) as station_stops
           from Cyclistic_df 
           group by
              start_station_name, 
              start_station_id,
              start_lat,
              start_lng,
              member_casual
           order by station_stops desc"))

# Explore the df: Column Names
colnames(Cyclistic_df)

# End Stations

view(sqldf("select
              end_station_name, 
              end_station_id,
              end_lat,
              end_lng,
              member_casual,
              count(start_station_name) as station_stops
           from Cyclistic_df 
           group by
              end_station_name, 
              end_station_id,
              end_lat,
              end_lng,
              member_casual
           order by station_stops desc"))


# cOMBINED 

view(stations_df <- sqldf("select
          start_station_name as station_name, 
          start_station_id as station_id,
          start_lat as lat,
          start_lng as long,
          member_casual,
          count(start_station_name) as station_stops
       from Cyclistic_df 
       group by
          start_station_name, 
          start_station_id,
          start_lat,
          start_lng,
          member_casual

      union

                    select
          end_station_name as station_name, 
          end_station_id as station_id,
          end_lat as lat,
          end_lng as long,
          member_casual,
          count(end_station_name) as station_stops
       from Cyclistic_df 
       group by
          end_station_name, 
          end_station_id,
          end_lat,
          end_lng,
          member_casual
 
      order by station_stops desc"))




## DATAFRAMES ##

# Assign df

# Start Stations

start_locations <- sqldf("select
              start_station_name, 
              start_station_id,
              start_lat,
              start_lng,
              member_casual,
              count(start_station_name) as station_stops
           from Cyclistic_df 
           group by
              start_station_name, 
              start_station_id,
              start_lat,
              start_lng,
              member_casual
           order by station_stops desc")

# OPTIONAL: WRITE ONE OR MORE DATA VIEWS AS CSVs
write.csv(start_locations, "C:/Users/darre/OneDrive/Documents/!Datasets/Cyclistic_divvy_tripdata CSVs/Final Dataset/start_locations.csv", row.names = FALSE)

# End Stations

end_locations <- sqldf("select
              end_station_name, 
              end_station_id,
              end_lat,
              end_lng,
              member_casual,
              count(start_station_name) as station_stops
           from Cyclistic_df 
           group by
              end_station_name, 
              end_station_id,
              end_lat,
              end_lng,
              member_casual
           order by station_stops desc")

# OPTIONAL: WRITE ONE OR MORE DATA VIEWS AS CSVs
write.csv(end_locations, "C:/Users/darre/OneDrive/Documents/!Datasets/Cyclistic_divvy_tripdata CSVs/Final Dataset/end_locations.csv", row.names = FALSE)





# Assign df COMBINED

# Start Stations

stations_df <- sqldf("select
          start_station_name as station_name, 
          start_station_id as station_id,
          start_lat as lat,
          start_lng as long,
          member_casual,
          count(start_station_name) as station_stops
       from Cyclistic_df 
       group by
          start_station_name, 
          start_station_id,
          start_lat,
          start_lng,
          member_casual

      union

                    select
          end_station_name as station_name, 
          end_station_id as station_id,
          end_lat as lat,
          end_lng as long,
          member_casual,
          count(end_station_name) as station_stops
       from Cyclistic_df 
       group by
          end_station_name, 
          end_station_id,
          end_lat,
          end_lng,
          member_casual
 
      order by station_stops desc")

# OPTIONAL: WRITE ONE OR MORE DATA VIEWS AS CSVs
write.csv(stations_df, "C:/Users/darre/OneDrive/Documents/!Datasets/Cyclistic_divvy_tripdata CSVs/Final Dataset/stations_df.csv", row.names = FALSE)



## VOIDED THIS OPTION ##

# Retrieve map

map <- get_map(location = 'United States', zoom = 4)

# Create mapped viz


ggmap(map) +
  geom_point(data = start_locations, aes(x = start_lng, y = start_lat), color = 'red', alpha = 0.5) +
  geom_point(data = end_locations, aes(x = end_lng, y = end_lat), color = 'blue', alpha = 0.5)

> map <- get_map(location = 'United States', zoom = 4)
Error in `get_googlemap()`:
  ! Google now requires an API key; see `ggmap::register_google()`.
Run `rlang::last_trace()` to see where the error occurred.

# After further review, ggmap is not an option without paying for an API key. I'll go through Tableau.

# ggsave("xxxxx")
