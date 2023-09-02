
# INSTALL PACKAGES
install.packages("DBI")
install.packages("odbc")
install.packages("RODBC")
install.packages("tidyverse")
install.packages("ggplot2")
install.packages("ggmap")
install.packages("sqldf")
install.packages("geosphere")

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
library(geosphere)

# ESTABLISH CONNECTION TO MY LOCAL DATABASE

connection <- odbcDriverConnect("driver={SQL Server};server=LAPTOP-76LHVPRQ\\SQLEXPRESS;database=Coursera_Capstone_Project;trusted_connection=true")


# ASSIGN THE DATABASE TABLE AS A DATAFRAME (df) VARIABLE FOR EASIER RECALL

Cyclistic_df <- sqlFetch(connection, "dbo.Cyclistic_divvy_tripdata")




# Explore the df: Column Names
colnames(Cyclistic_df)

# Explore the df: Structure
str(Cyclistic_df)

# Explore the df: Row Count == How Many ride-id's are there?
total_rides <- nrow(Cyclistic_df)

# Explore the df: What are the mean, median, min, and max?
mean(Cyclistic_df$ride_length)

median(Cyclistic_df$ride_length)

max(Cyclistic_df$ride_length)

?mapply()


# Distance in Meters
# Applying the distance calculation to each row
#Cyclistic_df$distance_traveled_meters <- mapply(function(lat1, lon1, lat2, lon2) {
  # distHaversine(c(lon1, lat1), c(lon2, lat2))
  #}, lat1 = Cyclistic_df$start_lat, lon1 = Cyclistic_df$start_lng, lat2 = Cyclistic_df$end_lat, lon2 = Cyclistic_df$end_lng)
# Now the Cyclistic_df will have a new column 'distance_traveled' with the distances in meters.
# view(Cyclistic_df$distance_traveled_meters)


# Distance in Miles
# Applying the distance calculation to each row and converting to miles
Cyclistic_df$distance_traveled_miles <- mapply(function(lat1, lon1, lat2, lon2) {
  distHaversine(c(lon1, lat1), c(lon2, lat2)) * 0.000621371
}, lat1 = Cyclistic_df$start_lat, lon1 = Cyclistic_df$start_lng, lat2 = Cyclistic_df$end_lat, lon2 = Cyclistic_df$end_lng)
# Now the Cyclistic_df will have a new column 'distance_traveled' with the distances in miles.

view(Cyclistic_df)

str(Cyclistic_df)

summary(Cyclistic_df$start_lat)
summary(Cyclistic_df$start_lng)
summary(Cyclistic_df$end_lat)
summary(Cyclistic_df$end_lng)




# Removing rows with NA values
Cyclistic_df_No_NA <- na.omit(Cyclistic_df)

summary(Cyclistic_df_No_NA$start_lat)
summary(Cyclistic_df_No_NA$start_lng)
summary(Cyclistic_df_No_NA$end_lat)
summary(Cyclistic_df_No_NA$end_lng)


view(sqldf("select *
    from Cyclistic_df_No_NA
    where distance_traveled_miles > 6100"))

view(sqldf("select *
    from Cyclistic_df_No_NA"))

# Removing rows with 0 values in the lat long columns.
Cyclistic_df_No_Zero <- Cyclistic_df_No_NA[Cyclistic_df_No_NA$start_lat != 0 & Cyclistic_df_No_NA$start_lng != 0 & Cyclistic_df_No_NA$end_lat != 0 & Cyclistic_df_No_NA$end_lng != 0,]

summary(Cyclistic_df_No_Zero$start_lat)
summary(Cyclistic_df_No_Zero$start_lng)
summary(Cyclistic_df_No_Zero$end_lat)
summary(Cyclistic_df_No_Zero$end_lng)


view(sqldf("select *
    from Cyclistic_df_No_Zero
    where distance_traveled_miles > 6100"))

view(sqldf("select *
    from Cyclistic_df_No_Zero"))



# Explore the df: What are the mean, median, min, and max?
mean(Cyclistic_df_No_Zero$distance_traveled_miles)

median(Cyclistic_df_No_Zero$distance_traveled_miles)

max(Cyclistic_df_No_Zero$distance_traveled_miles)


write.csv(Cyclistic_df_No_Zero, "C:/Users/darre/OneDrive/Documents/!Datasets/Cyclistic_divvy_tripdata CSVs/Final Dataset/Cyclistic_df_No_Zero.csv", row.names = FALSE)







# OPTIONAL: WRITE ONE OR MORE DATA VIEWS AS CSVs
# write.csv(Cyclistic_df, "C:/Users/darre/OneDrive/Documents/!Datasets/Cyclistic_divvy_tripdata CSVs/Final Dataset/Cyclistic_df.csv", row.names = FALSE)
