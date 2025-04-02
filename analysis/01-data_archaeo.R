# 01-data_archaeo.R
# Define study region, period, etc. and import radiocarbon dataset

# Study region and period
late_epipal_neo <- yr(c(15000, 5000), "BP")

# Location of Shubayqa
shub_location <- data.frame(
  name = c("Shubayqa"),
  longitude = 37.25,
  latitude = 32.40,
  time_bp = -seq(late_epipal_neo[1], late_epipal_neo[2], by = -100)
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
