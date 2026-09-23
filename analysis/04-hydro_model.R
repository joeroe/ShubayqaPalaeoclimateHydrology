# 04-hydro_model.R
# Hydrological model for Shubayqa

# Evaporation from the qa surface (after Linacre 1992; Jones et al. 2007)
# Constants:
shub_altitude <- 735
shub_latitude <- 32.4
# 2008–2012 average wind speed at 10m at Safawi (m/s), from Ammari et al. 2015
safawi_wind_speed <- c(3.45, 4.17, 4.64, 5.2, 4.89, 5.36, 5.15, 4.84, 3.97, 3.4, 2.99, 3.24)
# Solar radiation (mean kWh/m2/day) at Ruwayshid estimated by Jibril 1990
ruwayshed_solar_radiation <- c(6.2, 6.9, 7.6, 8.5, 10.1, 12.2, 12.4, 11.8, 10.7, 8.9, 7.3, 6)

shub_evaporation <- function(
  t_min, t_max, 
  wind_speed = safawi_wind_speed,
  latitude = shub_latitude,
  solar_radiation = ruwayshed_solar_radiation,
  altitude = shub_altitude
) {
  penman(
    Tmin = t_min / 100,
    Tmax = t_max / 100,
    U2 = wind_speed,
    lat = latitude,
    Rs = solar_radiation * 3.6, # kWh to MJ
    z = altitude,
    crop = "short",
    method = "ICID",
    verbose = FALSE
  )
}

# Model monthly evaporation and effective precipitation over Shubayqa
shub_climate_monthly <- shub_climate_monthly |>
  pivot_wider(names_from = variable, values_from = value) |>
  mutate(
    evaporation = shub_evaporation(temperature_min, temperature_max),
    effective_precipitation = precipitation - evaporation,
    .by = time_bp
  ) |>
  pivot_longer(temperature_min:effective_precipitation, names_to = "variable")

# Add mean values to annual palaeoclimatologies
shub_climate <- shub_climate_monthly |>
  summarise(value = mean(value), .by = c(time_bp, variable)) |>
  pivot_wider(names_from = variable, names_prefix = "mean_", values_from = value) |>
  left_join(x = shub_climate, y = _, by = "time_bp")

# Add sum values to annual palaeoclimatologies
shub_climate <- shub_climate_monthly |>
  summarise(value = sum(value), .by = c(time_bp, variable)) |>
  pivot_wider(names_from = variable, names_prefix = "sum_", values_from = value) |>
  left_join(x = shub_climate, y = _, by = "time_bp")

# Aggregate rainfall over Shubayqa basin
shub_climate <- shub_basin_climate$bio12 |>
  global(c("mean", "sum"), na.rm = TRUE) |>
  rename_with(\(x) paste0("basin_prec_", x)) |>
  tibble::rownames_to_column("time_bp") |>
  mutate(
    time_bp = str_remove(time_bp, "bio12_"),
    time_bp = as.numeric(time_bp)
  ) |>
  left_join(x = shub_climate, y = _, by = "time_bp")

# Water balance model (in m3)
# CHELSA-TraCE21k data is at 1 km resolution so 1 mm = 1000 m3 per cell
shub_climate <- shub_climate |>
  mutate(
    qa_inflow = basin_prec_sum * 1000,
    qa_evap = (sum_evaporation * as.numeric(st_area(shubayqa_qa))) / 1000,
    qa_balance = qa_inflow - qa_evap
  )

# Cache model
write_csv(shub_climate, "analysis/data/derived_data/shub_climate.csv")
