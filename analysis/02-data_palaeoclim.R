# 03-data_palaeoclim.R
# Obtain CHELSA-Trace21k data via pastclim

# Define time steps to retrieve
palaeoclim_steps <- -as.numeric(seq(
  from = max(climate_periods$start),
  to   = min(climate_periods$end),
  by = -100
))

# Set pastclim cache directory
pastclim::set_data_path(derived_data("pastclim"), 
                        ask = FALSE, write_config = FALSE) |> invisible()


#
# Annual mean annual temperature (BIO01) and total precipitation (BIO12)
# TODO: replace point precipitation data with mean/sum over the Shubayqa basin
#   (with region_series)
# TODO: maybe don't bother with MAT, just calculate from monthly below?
#
annual_biovars <- c(temp_mean = "bio01", prec_mean = "bio12")
download_dataset("CHELSA_trace21k_1.0_0.5m_vsi", annual_biovars) # TODO: check if necessary

# Build dataset. Note: very slow if downloads are required!
shub_climate <- location_series(
  shub_location, 
  # TODO: tidy up
  time_bp = palaeoclim_steps,
  bio_variables = annual_biovars,
  dataset = "CHELSA_trace21k_1.0_0.5m_vsi",
)

# TODO: cache shub_climate


#
# Monthly temperature (min and max) and precipitation
# Requires patched pastclim, see https://github.com/EvolEcolGroup/pastclim/issues/66
#

monthly_biovars = get_vars_for_dataset("CHELSA_trace21k_1.0_0.5m_vsi", 
                                       annual = FALSE, monthly = TRUE)

if (!file_exists(derived_data("shub_climate_monthly.csv")) {
  # Fetch files to download
  download_dataset("CHELSA_trace21k_1.0_0.5m_vsi", annual = FALSE, monthly = TRUE) # TODO: check if necessary?

  # Download & build dataset. Note: very slow if downloads are required!
  shub_climate_monthly <- location_series(
    shub_location, 
    # TODO: tidy up
    time_bp = palaeoclim_steps,
    bio_variables = monthly_biovars,
    dataset = "CHELSA_trace21k_1.0_0.5m_vsi", 
  )

  # Tidy
  shub_climate_monthly <- shub_climate_monthly |>
    select(-name, -longitude, -latitude) |>
    pivot_longer(temperature_min_01:precipitation_12) |>
    distinct() |>
    separate(name, c("variable", "month"), -2, convert = TRUE) |>
    mutate(variable = str_sub(variable, end = -2))

  # Cache
  write_csv(shub_climate_monthly, derived_data("shub_climate_monthly.csv"))
}
shub_climate_monthly <- read_csv(
  derived_data("shub_climate_monthly.csv"),
  col_types = cols(
    time_bp = col_double(),
    variable = col_character(),
    month = col_double(),
    value = col_double()
  )
)
