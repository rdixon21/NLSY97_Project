# NOTE to build startup file
# Builds the cleaned NLSY97 Dataset
#vignettes used: colwise, rowwise
#packages installed: here, magrittr, dplyr
library(magrittr)
library(dplyr)
library(readr)
library(here)

#Opens the raw data
read.csv(here("Data/NLSY97_raw.csv")) %>%
  
  # refused responses or already incarcerated -> NA
  # columns starting with 'E' are columns holding data on arrests/month
  mutate(across(starts_with("E"), ~case_when(
    .x < 0   ~ NA_real_,
    .x == 99 ~ NA_real_,
    TRUE     ~ as.numeric(.x)
  ))) %>%

  
  # if you had all NA's, remove from dataset
  filter(if_any(starts_with("E"), ~!is.na(.x))) %>%
  
  # sum across the months using rowwise
  rowwise() %>%
  mutate(total_arrests = sum(c_across(starts_with("E")), na.rm = TRUE)) %>%
  ungroup() %>%
  
  # recode the gender variable
  mutate(gender = if_else(R0536300 == 1, "Male", "Female")) %>%
  
  # recode the race variable
  mutate(race = case_when(
    R1482600 == 1 ~ "Black",
    R1482600 == 2 ~ "Hispanic",
    R1482600 == 3 ~ "Mixed Race (Non-Hispanic)",
    R1482600 == 4 ~ "Non-Black / Non-Hispanic",
  )) %>%
  
  # finally, select the variables that will be used in the analysis
  select(race, gender, total_arrests) %>%
  
  # write to a csv
  write_csv(here("Data/NLSY97_clean.csv"))
  