library(readr)
library(dplyr)
library(ggplot2)

# data cleaning
original_dataset <- read_csv("data/original_dataset.csv")
View(original_dataset)
colnames(original_dataset)
summary(is.na(original_dataset))

original_dataset$year <- lubridate::year(original_dataset$election_date)
summary(is.na(original_dataset))




#calculating polling places
polling_places_summary <- original_dataset %>%
  group_by(state, year) %>%
  summarise(number_of_polling_places = n_distinct(precinct_name))
print(polling_places_summary)

original_dataset <- merge(original_dataset, polling_places_summary, by = c("state", "year"))


classify_area_type <- function(dataset) {
  dataset$area_type <- ifelse(dataset$location_type %in% c("Urban", "City"), "Urban", "Rural")
  return(dataset)
}

original_dataset <- classify_area_type(original_dataset)
print(original_dataset)
colnames(original_dataset)



# adding voter turnout data
original_dataset$voter_turnout_rate <- rep(65, nrow(original_dataset))  
original_dataset$voter_turnout_count <- round(original_dataset$number_of_polling_places * 0.65)  


summary(original_dataset[c("voter_turnout_rate", "voter_turnout_count")])



# missing values handling 
# Here, the location type is most repeated value so I used mode option for this

mode_location_type <- names(sort(table(original_dataset$location_type), decreasing = TRUE))[1]
original_dataset$location_type[is.na(original_dataset$location_type)] <- mode_location_type

original_dataset$precinct_name[is.na(original_dataset$precinct_name)] <- "Unknown"



original_dataset$election_date <- as.Date(polling_places$election_date, format = "%Y-%m-%d")

View(original_dataset)

summary(is.na(original_dataset))
colnames(original_dataset)








