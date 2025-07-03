# 02-basin_model.R
# Calculate extent of Shubayqa's hydrological basin

# Initialise WhiteboxTools (NB. must be on path or installed with 
# whitebox::install_whitebox())
wbt_init()

# DATA -----------------------------------------------------------------------

# Define projection systems
crs_unproj <- 4326
crs_proj <- 32637

# Read qa polygon and derive centroid
st_read(raw_data("badia_qa.gpkg"), layer = "badia_qa") |>
  st_transform(qa, crs = crs_proj) |>
  filter(qa == "Shubayqa") |>
  mutate(centroid = st_centroid(geometry)) ->
  shubayqa_qa

# DEM PROCESSING -------------------------------------------------------------

# Extract NASADEM
dem_archives <- dir_ls(raw_data("nasadem"), glob = "*.zip")
dem_tmp <- path_temp("dem")
walk(dem_archives, unzip, exdir = dem_tmp)

# Read and merge tiles
dir_create(derived_data("nasadem_badia"))
dem <- st_mosaic(
  dir_ls(dem_tmp, glob = "*.hgt"),
  dst = derived_data("nasadem_badia", ext = "tif")
) |>
  read_stars()

# Reproject
dem_frame <- st_sf(st_as_sfc(st_bbox(dem)), crs = crs_unproj)
dem <- st_warp(dem, crs = crs_proj)
dem_frame <- st_transform(dem_frame, crs = crs_proj)
write_stars(dem, path(dem_tmp, "dem0_projected.tif"))

# Smooth
wbt_feature_preserving_smoothing(
  path(dem_tmp, "dem0_projected.tif"),
  path(dem_tmp, "dem1_smoothed.tif")
)

# Breach and fill depressions
wbt_fill_depressions(
  path(dem_tmp, "dem1_smoothed.tif"),
  path(dem_tmp, "dem2_filled.tif")
)

# Flatten qa'en
qa_shp <- file_temp(ext = "shp")
write_sf(shubayqa_qa, qa_shp)
wbt_flatten_lakes(
  dem = path(dem_tmp, "dem2_filled.tif"),
  lakes = qa_shp,
  output = derived_data("nasadem_badia_processed.tif")
)

# BASIN DELINEATION ----------------------------------------------------------
basin_tmp <- dir_create(path_temp("basin"))

# Prepare qa raster
wbt_vector_polygons_to_raster(
  input = qa_shp,
  output = path(basin_tmp, "qa.tif"),
  field = "qa",
  base = derived_data("nasadem_badia_processed.tif")
)

# Calculate flow direction
wbt_d8_pointer(
  dem = derived_data("nasadem_badia_processed.tif"),
  output = path(basin_tmp, "d8.tif")
)

# Calculate watersheds
wbt_watershed(
  d8_pntr = path(basin_tmp, "d8.tif"),
  pour_pts = path(basin_tmp, "qa.tif"),
  output = derived_data("basin.tif")
)

# Vectorise
wbt_raster_to_vector_polygons(
  derived_data("basin.tif"),
  derived_data("basin.shp")
)

# Read delineated basin
shubayqa_basin <- st_read(derived_data("basin.shp"))
