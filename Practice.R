library(readr)
library(dplyr)
library(ggplot2)

# data cleaning
polling_places <- read_csv("data/polling_places.csv")
View(polling_places)
colnames(polling_places)
summary(is.na(polling_places))
polling_places$county_name[is.na(polling_places$county_name)] <- "Unknown"
polling_places$election_date <- as.Date(polling_places$election_date, format = "%Y-%m-%d")
polling_places <- unique(polling_places)
View(polling_places)
polling_places$year <- lubridate::year(polling_places$election_date)
# It is already a cleaned data 


# Question 1
polling_places_count <- polling_places %>%
  group_by(year) %>%
  summarise(num_polling_places = n_distinct(polling_place_id))

ggplot(polling_places_count, aes(x = year, y = num_polling_places)) +
  geom_line() +
  labs(x = "Year", y = "Number of Polling Places", title = "Trends in Polling Places Over Time")



# Question 2
polling_places$area_type <- ifelse(grepl("urban", tolower(polling_places$location_type)), "Urban", "Rural")
polling_places_area <- polling_places %>%
  group_by(area_type, state, election_date) %>%
  summarise(num_polling_places = n_distinct(polling_place_id))

ggplot(polling_places_area, aes(x = area_type, y = num_polling_places, fill = area_type)) +
  geom_bar(stat = "identity") +
  facet_wrap(~state, scales = "free_y") +
  labs(x = "Area Type", y = "Number of Polling Places", title = "Distribution of Polling Places by Area Type")


