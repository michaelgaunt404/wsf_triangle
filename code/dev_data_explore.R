#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# This is script [[insert brief readme here]]
#
# By: mike gaunt, michael.gaunt@wsp.com
#
# README: [[insert brief readme here]]
#-------- [[insert brief readme here]]
#
# *please use 80 character margins
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#library set-up=================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#content in this section should be removed if in production - ok for dev
library(tidyverse)
library(magrittr)
library(gauntlet)

readr::read_csv(file = "data/Cathlamet.20240412.20240711.txt")

#path set-up====================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#content in this section should be removed if in production - ok for de
  data_wsf = list.files(
  "data"
  ,full.names = T) %>%
  map_df(~{
    temp_df = data.table::fread(file = .x) %>%
      set_names(c('Vessel', 'Departing', 'Arriving'
                  ,'Scheduled_Depart', 'Actual_Depart', 'Est_Arrival'
                  ,'Date', 'RM'))
  }) %>%
  # head() %>%
  janitor::clean_names() %>%
  mutate(across(c(scheduled_depart, actual_depart,est_arrival)
                , ~paste(date, as.character(.x)) %>%
                  parse_date_time("mdY HM"))) %>%
  mutate(depart_diff = as.numeric(actual_depart - scheduled_depart, units = "mins")) %>%
  mutate(scheduled_depart_hr = hour(scheduled_depart)
         ,day_of_week = wday(scheduled_depart, label = T))

data_wsf %>%
  pull(departing) %>%
  unique() %>%
  sort()

data_tri = data_wsf %>%
  filter((departing %in% c("Fauntleroy", "Vashon", "Southworth")) |
           (arriving %in% c("Fauntleroy", "Vashon", "Southworth")) )


#source helpers/utilities=======================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#content in this section should be removed if in production - ok for dev

#source data====================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#content in this section should be removed if in production - ok for dev
#area to upload data with and to perform initial munging
#please add test data here so that others may use/unit test these scripts


#main header====================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
data_tri %>%
count(departing, arriving, sort = T)

grp_var = "departing"
grp_var = c("departing", "arriving")
grp_var = "scheduled_depart_hr"
grp_var = "day_of_week"

data_tri %>%
  group_by(across({{grp_var}})) %>%
  filter(depart_diff >= 0) %>%
  summarise(
    count = n()
    ,mean = mean(depart_diff)
    ,median = median(depart_diff)
    ,q95 = DescTools::Quantile(depart_diff, probs = .95)
    ,min = min(depart_diff)
    ,max = max(depart_diff)
    ,sd = sd(depart_diff)) %>%
  ggplot() +
  geom_col(aes(.data[[grp_var]], sd)) +
  coord_cartesian(c(0, NA))

data_tri %>%
  filter(depart_diff >= 0) %>%
  ggplot() +
  geom_boxplot(aes(as.factor(.data[[grp_var]]), depart_diff)) +
  coord_cartesian(ylim = c(0, 75))


grp_facet = "departing"
grp_var = "scheduled_depart_hr"
grp_var = "day_of_week"

data_tri %>%
  filter(depart_diff >= 0) %>%
  ggplot() +
  geom_boxplot(aes(as.factor(.data[[grp_var]]), depart_diff)) +
  facet_grid(rows = vars(!!as.symbol(grp_facet))) +
  coord_cartesian(ylim = c(0, 40))



##sub header 1==================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

##sub header 2==================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#script end=====================================================================











































