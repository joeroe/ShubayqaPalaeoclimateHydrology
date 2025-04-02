# Evaporation from the qa surface (after Linacre 1992; Jones et al. 2007)
# TODO: need monthly CHELSA data for temp_min and temp_max
# Constants:
shub_altitude <- NA    # TODO: get from DEM
shub_latitude <- NA    # TODO:
shub_wind_speed <- 3   # TODO: sensitivity analysis, see Jones et al. 2007
shub_dew_point <- NA   # TODO: unsure, check with Matt
shub_climate_monthly |>
  mutate(
    temp_avg = NA, # TODO: mid-point of min and max? surely there's a better way?
    shub_evap = NA, # TODO: check Linacre 1992
  )
