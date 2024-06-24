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


unique_jurisdiction_types <- unique(original_dataset$jurisdiction_type)

unique_area_types <- unique(original_dataset$area_type)


print(unique_area_types)

print(unique_jurisdiction_types)

original_dataset$area_type <- ifelse(original_dataset$jurisdiction_type %in% c("borough", "city", "municipality"),
                                     "urban",
                                     ifelse(original_dataset$jurisdiction_type %in% c("county", "town", "parish", "county_municipality"),
                                            "rural", 
                                            NA)) 
original_dataset$area_type <- ifelse(original_dataset$jurisdiction_type %in% c("borough", "city", "municipality"),
                                     "urban",
                                     ifelse(original_dataset$jurisdiction_type %in% c("county", "town", "parish", "county_municipality"),
                                            "rural", 
                                            NA))
head(original_dataset)

unique_area_types <- unique(original_dataset$area_type)


print(unique_area_types)






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



original_dataset$election_date <- as.Date(original_dataset$election_date, format = "%Y-%m-%d")

View(original_dataset)

summary(is.na(original_dataset))
colnames(original_dataset)


# Working with area/type (rural/urban)
unique(original_dataset$area_type)
head(original_dataset[, c("address", "county_name", "precinct_name")])

library(stringr)

original_dataset <- original_dataset %>%
  mutate(city_state = str_extract(address, ", [^,]+, [A-Z]{2}"))

head(original_dataset$city_state)

unique_city_state <- unique(original_dataset$city_state)

print(unique_city_state)

original_dataset <- original_dataset %>%
  mutate(zip_code = str_extract(address, "\\b\\d{5}(?:-\\d{4})?\\b"))

head(original_dataset$zip_code)

unique_zip_code <- unique(original_dataset$zip_code)

print(unique_zip_code)



#Question 1


original_dataset$year <- format(as.Date(original_dataset$election_date, format="%Y-%m-%d"), "%Y")


polling_places_trends <- original_dataset %>%
  group_by(year, state) %>%
  summarise(number_of_polling_places = n_distinct(precinct_name))


ggplot(polling_places_trends, aes(x=year, y=number_of_polling_places)) +
  geom_line() +
  ggtitle("Number of Polling Places Over Time (National)") +
  xlab("Year") +
  ylab("Number of Polling Places")


ggplot(polling_places_trends, aes(x=year, y=number_of_polling_places, color=state)) +
  geom_line() +
  facet_wrap(~state) +
  ggtitle("Number of Polling Places Over Time (By State)") +
  xlab("Year") +
  ylab("Number of Polling Places")



#Question 2

polling_places_area_type <- original_dataset %>%
  group_by(area_type, state, year) %>%
  summarise(number_of_polling_places = n_distinct(precinct_name))

ggplot(polling_places_area_type, aes(x=area_type, y=number_of_polling_places, fill=area_type)) +
  geom_bar(stat="identity", position="dodge") +
  facet_wrap(~year) +
  ggtitle("Distribution of Polling Places (Urban vs Rural)") +
  xlab("Area Type") +
  ylab("Number of Polling Places")

voter_turnout_comparison <- original_dataset %>%
  group_by(area_type) %>%
  summarise(average_turnout = mean(voter_turnout_rate, na.rm=TRUE))

ggplot(voter_turnout_comparison, aes(x=area_type, y=average_turnout, fill=area_type)) +
  geom_bar(stat="identity", position="dodge") +
  ggtitle("Voter Turnout Rate Comparison (Urban vs Rural)") +
  xlab("Area Type") +
  ylab("Average Voter Turnout Rate")



