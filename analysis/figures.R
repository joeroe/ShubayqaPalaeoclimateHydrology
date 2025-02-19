library("cowplot")
library("dplyr")
library("ggplot2")
library("here")
library("patchwork")
library("tidyr")

source(here("analysis", "data_pastclim.R"))

# fig_shub_chronology: Chronology of Epipalaeolithic and Pre-Pottery Neolithic 
#   settlement at Shubayqa
# TODO: dates or just a summary?

# fig_shub_climate: Reconstructed annual temperature and precipitation over 
#   Shubayqa between 15,000 and 5000 BP.
# shub_climate |>
#   pivot_longer(starts_with("bio"), names_to = "biovar") |>
#   ggplot(aes(-time_bp, value)) +
#   facet_wrap(vars(biovar), ncol = 1, scales = "free_y") +
#   geom_line() +
#   scale_x_reverse(limits = c(15000, 5000), breaks = scales::breaks_width(-1000))
fig_shub_temp <- ggplot(shub_climate, aes(-time_bp, bio01)) +
  geom_line(color = "red") +
  scale_x_reverse(limits = c(15000, 5000), breaks = scales::breaks_width(-1000)) +
  labs(x = "cal BP", y = "°C") +
  theme_minimal_vgrid()

fig_shub_prec <- ggplot(shub_climate, aes(-time_bp, bio12)) +
  geom_line(color = "blue") +
  scale_x_reverse(limits = c(15000, 5000), breaks = scales::breaks_width(-1000)) +
  labs(x = "cal BP", y = "mm") +
  theme_minimal_vgrid()

fig_shub_climate <- fig_shub_temp / fig_shub_prec
ggsave(here("analysis", "figures", "fig_shub_climate.png"), fig_shub_climate)
