# 04-figures.R
# Generate figures for paper

# Define custom scales
scale_calbp <- function() {
  scale_x_reverse(limits = c(17000, 8200), breaks = scales::breaks_width(-1000))
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

# fig_shub_climate: Reconstructed palaeoclimatic and hydrological variables
# TODO: add Soreq for comparison?
fig_shub_climate <- shub_climate |>
  pivot_longer(bio01:effective_precipitation, names_to = "variable") |>
  filter(variable %in% c("bio01", "bio12", "effective_precipitation", "evaporation")) |> 
  mutate(variable = case_match(
    variable,
    "bio01" ~ "mean annual temp.",
    "bio12" ~ "annual prec.",
    "effective_precipitation" ~ "effective prec.",
    "evaporation" ~ "potential evaporation",
    .default = variable
  )) |>
  ggplot(aes(-time_bp, value)) +
  facet_wrap(vars(variable), scales = "free_y", ncol = 1, strip.position = "right") +
  geom_line() +
  scale_calbp() +
  labs(x = NULL, y = NULL) +
  theme_minimal_vgrid(font_size = 9) +
  theme(axis.text.x = element_blank())

#fig_shub_temp <- ggplot(shub_climate, aes(-time_bp, bio01)) +
#  geom_hline(aes(yintercept = 18.0), color = "grey") +
#  geom_line() +
#  annotate("text", x = 18000, y = 18.1, hjust = 0, vjust = 0, label = "↑ BWh") +
#  annotate("text", x = 18000, y = 17.9, hjust = 0, vjust = 1, label = "↓ BWk") +
#  scale_calbp() +
#  labs(x = NULL, y = "°C") +
#  theme_minimal_vgrid() +
#  theme(axis.text.x = element_blank())
#
#fig_shub_prec <- ggplot(shub_climate, aes(-time_bp, bio12)) +
#  geom_line() +
#  scale_calbp() +
#  labs(x = NULL, y = "mm") +
#  theme_minimal_vgrid() +
#  theme(axis.text.x = element_blank())

fig_shub_climate_c14 <- fig_shub_climate / fig_shub_c14 +
  plot_layout(heights = c(23, 1))

#fig_shub_climate_c14
ggsave(here("analysis", "figures", "fig_shub_climate.png"), fig_shub_climate_c14,
       width = 190, height = 160, units = "mm")
