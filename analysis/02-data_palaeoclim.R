# 03-data_palaeoclim.R
# Obtain CHELSA-Trace21k data via pastclim

# TODO: replace point precipitation data with mean/sum over the Shubayqa basin
#   (with region_series)

# Cache downloaded data
pastclim::set_data_path(here("analysis", "data", "derived_data"), 
                        ask = FALSE, write_config = FALSE)

# Mean annual temperature (BIO01) and precipitation (BIO12)
annual_biovars <- c(temp_mean = "bio01", prec_mean = "bio12")
download_dataset("CHELSA_trace21k_1.0_0.5m_vsi", annual_biovars)
shub_climate <- location_series(
  shub_location, 
  # TODO: tidy up
  time_bp = -as.numeric(seq(late_epipal_neo[1], late_epipal_neo[2], by = -100)),
  bio_variables = annual_biovars,
  dataset = "CHELSA_trace21k_1.0_0.5m_vsi",
)

# Monthly temperature (min and max) and precipitation
monthly_biovars = get_vars_for_dataset("CHELSA_trace21k_1.0_0.5m_vsi", 
                                       annual = FALSE, monthly = TRUE)

# Requires patched pastclim, see https://github.com/EvolEcolGroup/pastclim/issues/66
download_dataset("CHELSA_trace21k_1.0_0.5m_vsi", annual = FALSE, monthly = TRUE)

# Note: very slow
shub_climate_monthly <- location_series(
  shub_location, 
  # TODO: tidy up
  time_bp = -as.numeric(seq(late_epipal_neo[1], late_epipal_neo[2], by = -100)),
  bio_variables = monthly_biovars,
  dataset = "CHELSA_trace21k_1.0_0.5m_vsi", 
)

# TODO: cache shub_climate and shub_climate_monthly
