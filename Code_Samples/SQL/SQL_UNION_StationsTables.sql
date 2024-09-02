
-- Combined

select
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

order by station_stops desc




-- Start Stations

select
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
order by station_stops desc


-- end stations
select
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
order by station_stops desc


