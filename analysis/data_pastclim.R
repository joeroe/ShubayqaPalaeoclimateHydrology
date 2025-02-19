# data_pastclim.R
# Obtain CHELSA-Trace21k data via pastclim

library(era)
library(here)
library(pastclim) # requires >v2.1.0, see https://github.com/EvolEcolGroup/pastclim/issues/59

# Cache downloaded data
pastclim::set_data_path(here("analysis", "data", "derived_data"), ask = FALSE, write_config = FALSE)

# Define study region and period
late_epipal_neo <- yr(c(15000, 5000), "BP")

shub_locations <- data.frame(
  name = c("Shubayqa"),
  longitude = 37.25,
  latitude = 32.40,
  time_bp = -seq(late_epipal_neo[1], late_epipal_neo[2], by = -100)
)

# Annual reconstructions:
# - Temperature mean (BIO01), max (BIO05), and min (BIO06)
# - Precipitation mean (BIO12), max (BIO13) and min (BIO14)
biovars <- c(temp_mean = "bio01", temp_max = "bio05", temp_min = "bio06", 
             prec_mean = "bio12", prec_max = "bio13", prec_min = "bio14")

download_dataset("CHELSA_trace21k_1.0_0.5m_vsi", biovars)
shub_climate <- location_series(
  shub_locations, 
  bio_variables = biovars,
  dataset = "CHELSA_trace21k_1.0_0.5m_vsi"
)
