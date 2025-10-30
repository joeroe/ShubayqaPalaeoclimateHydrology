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
# Annual mean annual temperature (BIO01) and total precipitation (BIO12) over
# Shubayqa and precipitation over the Shubayqa basin
# TODO: maybe don't bother with MAT, just calculate from monthly below?
#
annual_biovars <- c(temp_mean = "bio01", prec_mean = "bio12")
download_dataset("CHELSA_trace21k_1.0_0.5m_vsi", annual_biovars) # TODO: check if necessary

# Build datasets. Note: very slow if downloads are required!
shub_climate <- location_series(
  shub_location, 
  # TODO: tidy up
  time_bp = palaeoclim_steps,
  bio_variables = annual_biovars,
  dataset = "CHELSA_trace21k_1.0_0.5m_vsi",
)

shubayqa_basin <- st_read(derived_data("basin.shp")) # generated in 03-data-palaeoclim.R
shub_basin_climate <- region_series(
  time_bp = palaeoclim_steps,
  bio_variables = annual_biovars,
  dataset = "CHELSA_trace21k_1.0_0.5m_vsi",
  ext = ext(project(vect(shubayqa_basin), "epsg:4326")),
  crop = project(vect(shubayqa_basin), "epsg:4326")
)

# TODO: cache shub_climate and shub_basin_climate


#
# Monthly temperature (min and max) and precipitation
# Requires patched pastclim, see https://github.com/EvolEcolGroup/pastclim/issues/66
#

monthly_biovars = get_vars_for_dataset("CHELSA_trace21k_1.0_0.5m_vsi", 
                                       annual = FALSE, monthly = TRUE)

if (!file_exists(derived_data("shub_climate_monthly.csv"))) {
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

# Comparison to Soreq
soreq_location <- data.frame(
  name = c("Soreq"),
  longitude = 35.02,
  latitude = 31.76
)

soreq_speleothem <- read_tsv(raw_data("soreq2012d18o-noaa.txt"), skip = 141) |>
  transmute(
    time_bp = -age_yrBP,
    variable = "d18O",
    value = d18O_VPDB,
    error = d18O_VPDB_err
  )

soreq_climate <- location_series(
  soreq_location, 
  # TODO: tidy up
  time_bp = palaeoclim_steps,
  bio_variables = annual_biovars,
  dataset = "CHELSA_trace21k_1.0_0.5m_vsi",
) |>
  pivot_longer(bio01:bio12, names_to = "variable") |>
  bind_rows(soreq_speleothem)
