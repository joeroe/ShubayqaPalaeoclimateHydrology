# 01-data_archaeo.R
# Define study region, period, etc. and import radiocarbon dataset

# Study period
climate_periods <- tibble::tribble(
  ~period,              ~acronym, ~start,  ~end,
  "Heinrich Stadial 1", "HS1",     17000, 14700,
  "Bølling-Allerød",    "BA",      14700, 12900,
  "Younger Dryas",      "YD",      12900, 11700,
  "Early Holocene",     "EH",      11700,  8200,
) |>
  mutate(start = yr(start, "BP"), end = yr(end, "BP"))

# Location of Shubayqa
shub_location <- data.frame(
  name = c("Shubayqa"),
  longitude = 37.25,
  latitude = 32.40
)

# Radiocarbon dates from Shubayqa sites
shub_c14 <- read_csv(
  here("analysis", "data", "raw_data", "shub_c14.csv"),
  col_types = cols(
       site = col_character(),
       lab_id = col_character(),
       material = col_character(),
       taxon = col_character(),
       c14_age = col_double(),
       c14_error = col_double(),
       reference = col_character()
  )
)

shub_c14$cal <- c14_calibrate(shub_c14$c14_age, shub_c14$c14_error)
