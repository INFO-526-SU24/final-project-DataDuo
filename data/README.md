# Data
-   **US Polling Places 2012-2020**: The [dataset](https://github.com/PublicI/us-polling-places) comes from [The Center for Public Integrity](https://publicintegrity.org/).
You can read more about the data and how it was collected in their September 2020 article ["National data release sheds light on past polling place changes"](https://publicintegrity.org/politics/elections/ballotboxbarriers/data-release-sheds-light-on-past-polling-place-changes/).

# Codebook for [chosen] Dataset

### Data Dictionary

# `polling_places.csv`

|variable          |class     |description       |
|:-----------------|:---------|:-----------------|
|election_date     |date      |date of the election as YYYY-MM-DD |
|state             |character |2-letter abbreviation of the state |
|county_name       |character |county name, if available |
|jurisdiction      |character |jurisdiction, if available |
|jurisdiction_type |character |type of jurisdiction, if available; one of "county", "borough", "town", "municipality", "city", "parish", or "county_municipality" |
|precinct_id       |character |unique ID of the precinct, if available |
|precinct_name     |character |name of the precinct, if available |
|polling_place_id  |character |unique ID of the polling place, if available |
|location_type     |character |type of polling location, if available; one of "early_vote", "early_vote_site", "election_day", "polling_location", "polling_place", or "vote_center" |
|name              |character |name of the polling place, if available |
|address           |character |address of the polling place, if available |
|notes             |character |optional notes about the polling place |
|source            |character |source of the polling place data; one of "ORR", "VIP", "website", or "scraper" |
|source_date       |date      |date that the source was compiled |
|source_notes      |character |optional notes about the source |


