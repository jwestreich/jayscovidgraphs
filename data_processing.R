library(tidyverse)
library(locfit)
library(ggplot2)
library(ggpubr)
library(scales)
library(mgcv)
library(nlme)
library(gridExtra)
library(patchwork)
library(Hmisc)
library(dplyr)
library(arrow)

new_data<-"no"

start_date <- as.Date("2020-03-21")
end_date <- as.Date("2023-03-09")
dates <- seq(start_date, end_date, by = "days")
date_strings <- format(as.Date(dates), format = "%m-%d-%Y")
us_states <- c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Puerto Rico", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming")

if (new_data == "yes") {
  import <- data.frame()
  for (date in date_strings) {
    df_date <- read.csv(paste0("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/", date, ".csv"), stringsAsFactors = FALSE)%>%
      mutate(date=as.character(date))
    import <- bind_rows(import, df_date)
  }
  rm(df_date)
  write_parquet(import, "C:\\Users\\jwest\\Documents\\COVID\\R\\import.parquet")
} else {
  import <- read_parquet("C:\\Users\\jwest\\Documents\\COVID\\R\\import.parquet")
}

cleaned <- import %>%
  mutate(state = if_else(is.na(Province_State), Province.State, Province_State)) %>%
  filter(state %in% us_states) %>%
  mutate(date = as.Date(date, format = "%m-%d-%Y")) %>%
  select(state, Confirmed, Deaths, date)

summed <- cleaned %>%
  group_by(state, date) %>%
  summarize_if(is.numeric, sum, na.rm = TRUE)%>%
  rename(total_cases=Confirmed)%>%
  rename(total_deaths=Deaths)

daily <- summed %>%
  group_by(state) %>%
  arrange(date) %>%
  mutate(
    new_cases = ifelse(is.na(total_cases - lag(total_cases)) | (total_cases - lag(total_cases)) < 0, 0, total_cases - lag(total_cases)),
    new_deaths = ifelse(is.na(total_deaths - lag(total_deaths)) | (total_deaths - lag(total_deaths)) < 0, 0, total_deaths - lag(total_deaths))
  )

pop <- read.csv("C:\\Users\\jwest\\Documents\\COVID\\Public\\pop.csv")

daily_pop <- daily %>% 
  inner_join(pop, by = "state") %>% 
  mutate(
    total_cases_per100k = (total_cases / population) * 100000,
    total_deaths_per100k = (total_deaths / population) * 100000,
    new_cases_per100k = replace_na((new_cases / population) * 100000, 0),
    new_deaths_per100k = replace_na((new_deaths / population) * 100000, 0)
  ) %>%
  filter(date > as.Date("2020-03-21")) %>% 
  arrange(state, date)

bwidth <-(50/(nrow(daily_pop)/52))

for (state in us_states) {
  state_data <- daily_pop[daily_pop$state == state, ]
  model <- locfit(new_cases_per100k ~ date, data = state_data, family = "gaussian", alpha=bwidth)
  predictions <- predict(model, state_data$date, se = TRUE)
  state_data$new_cases_per100k_smooth <- predictions$fit
  model <- locfit(new_deaths_per100k ~ date, data = state_data, family = "gaussian", alpha=bwidth)
  predictions <- predict(model, state_data$date, se = TRUE)
  state_data$new_deaths_per100k_smooth <- predictions$fit
  assign(state, state_data)
}

daily_pop_smooth <- data.frame()
for (state in us_states) {
  daily_pop_smooth <- bind_rows(daily_pop_smooth, get(state))
  rm(list = state)
}

daily_pop_smooth <- daily_pop_smooth %>%
  distinct()%>%
  mutate(
    new_cases_per100k_smooth = replace_na(new_cases_per100k_smooth, 0),
    new_cases_per100k_smooth = pmax(new_cases_per100k_smooth, 0),
    new_cases_per100k = pmin(new_cases_per100k, 500),
    new_cases_per100k_smooth = pmin(new_cases_per100k_smooth, 500),
    new_deaths_per100k_smooth = replace_na(new_deaths_per100k_smooth, 0),
    new_deaths_per100k_smooth = pmax(new_deaths_per100k_smooth, 0),
    new_deaths_per100k = pmin(new_deaths_per100k, 6),
    new_deaths_per100k_smooth = pmin(new_deaths_per100k_smooth, 6)
  )

#write daily_pop_smooth as process.csv to your own folder location
write_csv(daily_pop_smooth,~processed.csv)