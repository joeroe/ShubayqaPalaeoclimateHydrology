# 05-figures.R
# Generate figures for paper

# Define custom scales
scale_calbp <- function() {
  scale_x_reverse(limits = c(15000, 5000), breaks = scales::breaks_width(-1000))
}

scale_colour_sites <- function() {
  brewer_set1 <- scales::brewer_pal(palette = "Set1")(5)
  scale_colour_manual(values = brewer_set1[3:5], name = NULL)
}

# fig_shub_c14: Barcode plot of radiocarbon dates from SHUB1, SHUB3, and SHUB6 
#   (for incorporation into other figures)
fig_shub_c14 <- ggplot(filter(shub_c14, !outlier)) +
  geom_vline(aes(xintercept = cal_point(cal, quiet = TRUE), colour = site_code)) +
  scale_calbp() +
  scale_colour_sites() +
  labs(x = "cal BP", y = bquote(~C^14)) +
  theme_minimal_vgrid() +
  theme(
    legend.position = "bottom",
    legend.justification = "right"
  )

# fig_shub_climate: Reconstructed annual temperature and precipitation over 
#   Shubayqa between 15,000 and 5000 BP.
# TODO: add Soreq for comparison?
fig_shub_temp <- ggplot(shub_climate, aes(-time_bp, bio01)) +
  geom_hline(aes(yintercept = 18.0), color = "grey") +
  geom_line(color = "red") +
  annotate("text", x = 15000, y = 18.1, hjust = 0, vjust = 0, label = "BWh") +
  annotate("text", x = 15000, y = 17.9, hjust = 0, vjust = 1, label = "BWk") +
  scale_calbp() +
  labs(x = NULL, y = "°C") +
  theme_minimal_vgrid() +
  theme(axis.text.x = element_blank())

fig_shub_prec <- ggplot(shub_climate, aes(-time_bp, bio12)) +
  geom_line(color = "blue") +
  scale_calbp() +
  labs(x = NULL, y = "mm") +
  theme_minimal_vgrid() +
  theme(axis.text.x = element_blank())

fig_shub_climate <- fig_shub_temp / fig_shub_prec / fig_shub_c14 +
  plot_layout(heights = c(5, 5, 1))
fig_shub_climate

#ggsave(here("analysis", "figures", "fig_shub_climate.png"), fig_shub_climate,
#       width = 190, height = 100, units = "mm")
