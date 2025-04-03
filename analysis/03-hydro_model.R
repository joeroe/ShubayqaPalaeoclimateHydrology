# Evaporation from the qa surface (after Linacre 1992; Jones et al. 2007)
# Constants:
shub_altitude <- 735
shub_latitude <- 32.4
# 2008–2012 average wind speed at 10m at Safawi (m/s), from Ammari et al. 2015
safawi_wind_speed <- c(3.45, 4.17, 4.64, 5.2, 4.89, 5.36, 5.15, 4.84, 3.97, 3.4, 2.99, 3.24)
# Solar radiation (mean kWh/m2/day) at Ruwayshid estimated by Jibril 1990
ruwayshed_solar_radiation <- c(6.2, 6.9, 7.6, 8.5, 10.1, 12.2, 12.4, 11.8, 10.7, 8.9, 7.3, 6)

# Model monthly evaporation and effective precipitation
shub_climate_monthly <- shub_climate_monthly |>
  pivot_wider(names_from = variable, values_from = value) |>
  mutate(
    evaporation = penman(
      Tmin = temperature_min / 100,
      Tmax = temperature_max / 100,
      U2 = safawi_wind_speed,
      lat = shub_latitude,
      Rs = ruwayshed_solar_radiation * 3.6, # kWh to MJ
      z = shub_altitude,
      crop = "short",
      method = "ICID",
      #verbose = FALSE
    ),
    effective_precipitation = precipitation - evaporation,
    .by = time_bp
  ) |>
  pivot_longer(temperature_min:effective_precipitation, names_to = "variable")

# Add mean values to annual palaeoclimatologies
shub_climate <- shub_climate_monthly |>
  summarise(value = mean(value), .by = c(time_bp, variable)) |>
  pivot_wider(names_from = variable, values_from = value) |>
  left_join(x = shub_climate, y = _, by = "time_bp")
