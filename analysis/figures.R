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
# TODO: add Soreq for comparison?
# TODO: add climatic and archaeo periods as secondary axis
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
