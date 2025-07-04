# 05-hydro_sensitivity.R
# Sensitivity analysis of hydrological model

# TODO:
# - [x] Calculate min and max evaporation
# - [ ] Calculate min(k) for positive water balance for each A in 0..As
# - [ ] Fix k=0.05 and calculate min(A) for positive water balance for each time step

# Water balance function
#   ksum(R) - EA / 1000
water_balance <- function(k, r, e, a) {
  (k * r) - (e * a * 0.001)
}

# Function to find the minimum value of k such that the water balance of the qa
#   is positive
water_balance_min_k <- function(r, e, a) {
  uniroot(water_balance, c(0, 1), r = r, e = e, a = a)$root
}

# min(k) for values of A, using min and max evaporation in study period
shub_min_k <- shub_climate |>
  filter(
    sum_evaporation == min(sum_evaporation) |
    sum_evaporation == max(sum_evaporation)
  ) |>
  mutate(area_coef = list(seq(from = 0, to = 1, by = 0.01))) |>
  unnest(area_coef) |>
  mutate(
    qa_area = as.numeric(st_area(shubayqa_qa)) * area_coef,
    min_k = pmap_dbl(list(r = qa_inflow, e = sum_evaporation, a = qa_area), water_balance_min_k)
  )

# min(A) for k=0.05
water_balance_min_a <- function(k, r, e, max_a = as.numeric(st_area(shubayqa_qa))) {
  uniroot(water_balance, c(0, max_a), k = k, r = r, e = e)$root
}

shub_climate <- shub_climate |>
  mutate(
    min_a = pmap_dbl(list(k = 0.05, r = qa_inflow, e = sum_evaporation), water_balance_min_a),
    min_a_prop = min_a / as.numeric(st_area(shubayqa_qa))
  )
