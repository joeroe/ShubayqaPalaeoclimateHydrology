# 00-setup.R
# Load required libraries etc.
library("c14")
library("cowplot")
library("dplyr")
library("era")
library("fs")
library("ggh4x")
library("ggplot2")
library("here")
library("pastclim") # > v2.2.0, see https://github.com/EvolEcolGroup/pastclim/issues/66
library("patchwork")
library("purrr")
library("readr")
library("sf")
library("SPEI")
library("stars")
library("stringr")
library("tidyr")
library("whitebox")

# Define file paths for compendium
raw_data <- function(...) {
  here("analysis", "data", "raw_data", ...)
}

derived_data <- function(...) {
  here("analysis", "data", "derived_data", ...)
}
