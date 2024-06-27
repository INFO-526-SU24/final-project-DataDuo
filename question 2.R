library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)

original_dataset <- read_csv("data/original_dataset.csv")

summary(is.na(original_dataset))

head(original_dataset)

original_dataset <- original_dataset %>%
  mutate(year = year(election_date))

#calculating polling places
polling_places_summary <- original_dataset %>%
  group_by(state, year) %>%
  summarise(number_of_polling_places = n_distinct(precinct_name))
print(polling_places_summary)

original_dataset <- merge(original_dataset, polling_places_summary, by = c("state", "year"))

na_indices <- which(is.na(original_dataset$jurisdiction_type))

for (i in na_indices) {
  cat("NA:", original_dataset$jurisdiction_type[i], "\n")
  if (i < nrow(original_dataset)) {
    cat("Following jurisdiction:", original_dataset$jurisdiction[i + 1], "\n\n")
  } else {
    cat("No following jurisdiction (end of dataset)\n\n")
  }
}

original_dataset$jurisdiction_type <- trimws(original_dataset$jurisdiction_type)


patterns <- c("Calumet | Town of Harrison", "Marinette | Village of Wausaukee", 
              "Outagamie | City of Seymour", "Taylor | Town of Medford", 
              "Adams | Town Of Adams", "Dodge | Village of Lomira", 
              "Dunn | Town of Tainter", "Eau Claire | Town of Bridge Creek", 
              "Eau Claire | City of Augusta", "Eau Claire | City of Altoona", 
              "Iowa | Town of Brigham", "Lafayette | City of Darlington", 
              "Oneida | Town of Hazelhurst", "Washburn | City of Shell Lake", 
              "Adams | CITY OF ADAMS")

replacements <- c("town", "village", "city", "town", "town", "village", 
                  "town", "town", "city", "city", "town", "city", "town", 
                  "city", "city")

for (i in seq_along(patterns)) {
  original_dataset$jurisdiction_type[grepl(patterns[i], original_dataset$jurisdiction)] <- replacements[i]
}

print(unique(original_dataset$jurisdiction_type))


original_dataset$area_type <- ifelse(original_dataset$jurisdiction_type %in% c("borough", "city", "municipality"),
                                     "urban",
                                     ifelse(original_dataset$jurisdiction_type %in% c("county", "town", "parish", "county_municipality", "village"),
                                            "rural", 
                                            NA ))

print(unique(original_dataset$area_type))

summary(is.na(original_dataset))


original_dataset$voter_turnout_rate <- rep(65, nrow(original_dataset))
original_dataset$voter_turnout_count <- round(original_dataset$number_of_polling_places * 0.65)


summary(original_dataset[c("voter_turnout_rate", "voter_turnout_count")])


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
