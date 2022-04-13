#input library

library("tidyverse")
library("ggplot2")
library("lubridate")
install.packages(geosphere)
library("geosphere")
install.packages(gridExtra)
library("gridExtra") 
install.packages(ggmap)
library("ggmap")

#set working directory & input data
getwd()
setwd("C:/Users/win10pro/Downloads/casestudy1/raw_data/divvy_tripdata")
trip_2021_01 <- read.csv("202101-divvy-tripdata.csv")
trip_2021_02 <- read.csv("202102-divvy-tripdata.csv")
trip_2021_03 <- read.csv("202103-divvy-tripdata.csv")
trip_2021_04 <- read.csv("202104-divvy-tripdata.csv")
trip_2021_05 <- read.csv("202105-divvy-tripdata.csv")
trip_2021_06 <- read.csv("202106-divvy-tripdata.csv")
trip_2021_07 <- read.csv("202107-divvy-tripdata.csv")
trip_2021_08 <- read.csv("202108-divvy-tripdata.csv")
trip_2021_09 <- read.csv("202109-divvy-tripdata.csv")
trip_2021_10 <- read.csv("202110-divvy-tripdata.csv")
trip_2021_11 <- read.csv("202111-divvy-tripdata.csv")
trip_2021_12 <- read.csv("202112-divvy-tripdata.csv")
trip_2022_01 <- read.csv("202201-divvy-tripdata.csv")
trip_2022_02 <- read.csv("202202-divvy-tripdata.csv")
trip_2022_03 <- read.csv("202203-divvy-tripdata.csv")
head(trip_2022_03)
head(trip_2021_08)
str(trip_2021_08)
str(trip_2022_03)

trip_2021 <- bind_rows(trip_2021_01, trip_2021_02, trip_2021_03, trip_2021_04, trip_2021_05, trip_2021_06, trip_2021_07, trip_2021_08, trip_2021_09, trip_2021_10, trip_2021_11, trip_2021_12)
trip_2021 <- mutate(trip_2021, start_station_id = as.character(start_station_id), end_station_id = as.character(end_station_id))

str(trip_2021)

trip_2022_q1 <- bind_rows(trip_2022_01, trip_2022_02, trip_2022_03)
all_trip <- bind_rows(trip_2021, trip_2022_q1)

print(all_trip)

#Clean data

all_trip_clean <- drop_na(all_trip)

# seperate date into day, month, year

memory.limit(size = 20000)

all_trip_clean$date <- as.Date(all_trip_clean$started_at) 
all_trip_clean$month <- format(as.Date(all_trip_clean$date), "%m")
all_trip_clean$day <- format(as.Date(all_trip_clean$date), "%d")
all_trip_clean$year <- format(as.Date(all_trip_clean$date), "%Y")
all_trip_clean$day_of_week <- format(as.Date(all_trip_clean$date), "%A")

#First the ride lenght in seconds:
all_trip_clean$ride_length <- difftime(all_trip_clean$ended_at,all_trip_clean$started_at)

#Then the ride distance traveled in km
all_trip_clean$ride_distance <- distGeo(matrix(c(all_trip_clean$start_lng, all_trip_clean$start_lat), ncol = 2), matrix(c(all_trip_clean$end_lng, all_trip_clean$end_lat), ncol = 2))
all_trip_clean$ride_distance <- all_trip_clean$ride_distance/1000

#At last the speed in Km/h
all_trip_clean$ride_speed = c(all_trip_clean$ride_distance)/as.numeric(c(all_trip_clean$ride_length), units="hours")

all_trip_clean <- all_trip_clean[!(all_trip_clean$start_station_name == "HQ QR" | all_trip_clean$ride_length<0),]

#Fist we calculate the average distance, distance for both the casual and member type users:

userType_means <- all_trip_clean %>% group_by(member_casual) %>% summarise(mean_time = mean(ride_length),mean_distance = mean(ride_distance))

view(userType_means)

membervstime <- ggplot(userType_means) + 
  geom_col(mapping=aes(x=member_casual,y=mean_time,fill=member_casual), show.legend = FALSE)+
  labs(title = "Mean travel time by User type",x="User Type",y="Mean time in sec")

membervsdistance <- ggplot(userType_means) + 
  geom_col(mapping=aes(x=member_casual,y=mean_distance,fill=member_casual), show.legend = FALSE)+
  labs(title = "Mean travel distance by User type",x="User Type",y="Mean distance In Km",caption = "Data by Motivate International Inc")

membervsdistance
grid.arrange(membervstime, membervsdistance, ncol = 2)  

#The we check  the number of rides diferences by weekday:
all_trip_clean %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length),.groups = 'drop') %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title = "Number of rides by User type during the week",x="Days of the week",y="Number of rides",caption = "Data by Motivate International Inc", fill="User type") +
  theme(legend.position="top")

#Create a new data frame with only the rows with info in the "bike type" column:

with_bike_type <- all_trip_clean %>% filter(rideable_type=="classic_bike" | rideable_type=="electric_bike")

#Then lets check the bike type usage by user type:

with_bike_type %>%
  group_by(member_casual,rideable_type) %>%
  summarise(totals=n(), .groups="drop")  %>%
  
  ggplot()+
  geom_col(aes(x=member_casual,y=totals,fill=rideable_type), position = "dodge") + 
  labs(title = "Bike type usage by user type",x="User type",y=NULL, fill="Bike type") +
  scale_fill_manual(values = c("classic_bike" = "#746F72","electric_bike" = "#FFB100")) +
  theme_minimal() +
  theme(legend.position="top")

#And their usage by both user types during a week:

with_bike_type %>%
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual,rideable_type,weekday) %>%
  summarise(totals=n(), .groups="drop") %>%
  
  ggplot(aes(x=weekday,y=totals, fill=rideable_type)) +
  geom_col(, position = "dodge") + 
  facet_wrap(~member_casual) +
  labs(title = "Bike type usage by user type during a week",x="User type",y=NULL,caption = "Data by Motivate International Inc") +
  scale_fill_manual(values = c("classic_bike" = "#746F72","electric_bike" = "#FFB100")) +
  theme_minimal() +
  theme(legend.position="none")

#First we create a table only for the most popular routes (>250 times)
coordinates_table <- all_trip_clean %>% 
  filter(start_lng != end_lng & start_lat != end_lat) %>%
  group_by(start_lng, start_lat, end_lng, end_lat, member_casual, rideable_type) %>%
  summarise(total = n(),.groups="drop") %>%
  filter(total > 250)

head(coordinates_table)

#Then we create two sub tables for each user type
casual <- coordinates_table %>% filter(member_casual == "casual")
member <- coordinates_table %>% filter(member_casual == "member")

#Lets store bounding box coordinates for ggmap:
chi_bb <- c(
  left = -87.700424,
  bottom = 41.790769,
  right = -87.554855,
  top = 41.990119
)

#Here we store the stamen map of Chicago
chicago_stamen <- get_stamenmap(
  bbox = chi_bb,
  zoom = 12,
  maptype = "toner"
)
#Then we plot the data on the map
ggmap(chicago_stamen,darken = c(0.8, "white")) +
   geom_curve(casual, mapping = aes(x = start_lng, y = start_lat, xend = end_lng, yend = end_lat, alpha= total, color=rideable_type), size = 0.5, curvature = .2,arrow = arrow(length=unit(0.2,"cm"), ends="first", type = "closed")) +
    coord_cartesian() +
    labs(title = "Most popular routes by casual users",x=NULL,y=NULL, color="User type", caption = "Data by Motivate International Inc") +
    theme(legend.position="none")

ggmap(chicago_stamen,darken = c(0.8, "white")) +
    geom_curve(member, mapping = aes(x = start_lng, y = start_lat, xend = end_lng, yend = end_lat, alpha= total, color=rideable_type), size = 0.5, curvature = .2,arrow = arrow(length=unit(0.2,"cm"), ends="first", type = "closed")) +  
    coord_cartesian() +
    labs(title = "Most popular routes by annual members",x=NULL,y=NULL, caption = "Data by Motivate International Inc") +
    theme(legend.position="none")








