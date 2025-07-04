# 06-figures.R
# Generate figures for paper

# TODO:
# - [ ] Location map
# - [ ] Comparison of modelled prec/temp with regional palaeoclimate proxies
# - [ ] Prec. seasonality through time

# Define custom scales
scale_calbp <- function() {
  scale_x_reverse(limits = c(17000, 8200), breaks = scales::breaks_width(1000))
}

# fig_shub_c14: Barcode plot of radiocarbon dates from SHUB1, SHUB3, and SHUB6 
#   (for incorporation into other figures)
fig_shub_c14 <- ggplot(shub_c14) +
  geom_vline(aes(xintercept = cal_point(cal, quiet = TRUE), colour = site)) +
  scale_calbp() +
  scale_colour_brewer(palette = "Set1") +
  #labs(x = "cal BP", y = bquote(~C^14)) +
  labs(x = "cal BP", y = NULL) +
  theme_minimal_vgrid(font_size = 9) +
  theme(
    legend.position = "bottom",
    legend.justification = "right"
  )

# fig_soreq_climate: Simulated palaeoclimate at Soreq cave according to
#   CHELSA-TraCE21k compared with the speleothem record

fig_soreq_climate <- soreq_climate |>
  mutate(variable = case_match(
    variable,
    "bio01" ~ "CHELSA-TraCE21k\nmean annual temp. (°C)",
    "bio12" ~ "CHELSA-TraCE21k\n annual prec. (mm)",
    "d18O" ~ "Speleothem\nδ18O VPDB",
    .default = variable
  )) |>
  ggplot(aes(-time_bp, value)) +
  facet_wrap(vars(variable), scales = "free_y", ncol = 1, strip.position = "right") +
  geom_ribbon(aes(ymin = value - error, ymax = value + error), alpha = 0.25) +
  geom_line() +
  scale_calbp() +
  labs(x = "cal BP", y = NULL) +
  theme_minimal_vgrid(font_size = 9)

ggsave(here("analysis", "figures", "fig_soreq_climate.png"), fig_soreq_climate,
       width = 190, height = 120, units = "mm")

# fig_shub_climate: Simulated temperature at Shubayqa and precipitation over the
#   Shubayqa basin
# TODO: Add hot/cold desert line
fig_shub_climate <- shub_climate |>
  pivot_longer(bio01:basin_prec_sum, names_to = "variable") |>
  filter(variable %in% c("bio01", "basin_prec_mean")) |>
  mutate(variable = case_match(
    variable,
    "bio01" ~ "mean annual temp. (°C)",
    "basin_prec_mean" ~ "mean annual prec. (mm)",
    .default = variable
  )) |>
  ggplot(aes(-time_bp, value)) +
  facet_wrap(vars(variable), scales = "free_y", ncol = 1, strip.position = "right") +
  geom_line() +
  scale_calbp() +
  labs(x = "cal BP", y = NULL) +
  theme_minimal_vgrid(font_size = 9)

ggsave(here("analysis", "figures", "fig_shub_climate.png"), fig_shub_climate,
       width = 190, height = 80, units = "mm")

# fig_shub_min_k: sensitivity analysis of min(k) over a
fig_shub_min_k <- ggplot(shub_min_k, aes(x = area_coef, y = min_k, group = sum_evaporation)) +
  geom_ribbon(aes(ymin = 0.03, ymax = 0.05), alpha = 0.25) +
  geom_line() +
  geom_text(
    aes(label = ifelse(
      area_coef == 1, 
      paste0("E=", round(sum_evaporation), " mm yr⁻¹"), 
      NA)
    ),
    size = 9 * 0.36,
    hjust = 1
  ) +
  scale_x_continuous(labels = scales::percent, breaks = scales::breaks_width(0.2)) +
  theme_minimal_grid(font_size = 9) +
  labs(x = "Proportion of qa flooded", y = "min(k)")

ggsave(here("analysis", "figures", "fig_shub_min_k.png"), fig_shub_min_k,
       width = 80, height = 80, units = "mm")

# fig_shub_hydro: Modelled palaeohydrology of the Shubayqa qa
# TODO: cleanup axes
fig_shub_hydro <- shub_climate |>
  pivot_longer(-c(name, longitude, latitude, time_bp), names_to = "variable") |>
  filter(variable %in% c("qa_inflow", "qa_evap", "min_a_prop")) |>
  mutate(
    variable = factor(
      variable, 
      c("qa_inflow", "qa_evap", "min_a_prop"),
      labels = c(
        "Potential inflow m³ yr⁻¹",
        "Potential evaporation mm yr⁻¹",
        "Max. proportion of qa flooded"
      )
    )
  ) |>
  ggplot(aes(-time_bp, value)) +
  facet_wrap(vars(variable), scales = "free_y", ncol = 1, strip.position = "right") +
  geom_line() +
  scale_calbp() +
  labs(x = NULL, y = NULL) +
  theme_minimal_vgrid(font_size = 9) +
  theme(axis.text.x = element_blank())

# fig_shub_hydro_c14
# TODO: add birds
fig_shub_hydro_c14 <- fig_shub_hydro / fig_shub_c14 +
  plot_layout(heights = c(23, 1))

ggsave(here("analysis", "figures", "fig_shub_hydro.png"), fig_shub_hydro_c14,
       width = 190, height = 160, units = "mm")

# fig_shub_climate_monthly: Monthly modelled precipitation and temperature
rig_shub_climate_monthly <- shub_climate_monthly |>
  pivot_wider(names_from = "variable") |>
  mutate(temperature = map2_dbl(temperature_min, temperature_max, mean) / 100) |>
  select(time_bp, month, temperature, precipitation) |> 
  pivot_longer(c(temperature, precipitation), names_to = "variable") |>
  mutate(
    month = factor(month, labels = month.abb),
    variable = case_match(
      variable,
      "precipitation" ~ "precipitation (mm)",
      "temperature" ~ "mean temperature (°C)"
    )
  ) |>
  ggplot(aes(month, value, group = time_bp)) +
  coord_polar() +
  facet_wrap(vars(variable), ncol = 1, scales = "free_y", strip.position = "right") +
  geom_line(alpha = 0.1) +
  scale_x_discrete() +
  labs(x = NULL, y = NULL) +
  theme_minimal_grid(font_size = 9)

ggsave(here("analysis", "figures", "fig_shub_climate_monthly.png"), 
       fig_shub_climate_monthly, width = 80, height = 160, units = "mm")
