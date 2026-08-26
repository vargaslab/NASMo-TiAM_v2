#NORTH AMERICA SOIL MOISTURE DATASET DERIVED FROM TIME-SPECIFIC ADAPTABLE MODELS

#3. Generation of Biweekly Training and Prediction matrices

###3.1.1 Generation of North America training matrices by predefined sub-regions

#This code creates the training matrices for every biweekly period for 14 sub-regions of interest. 
#The matrices depict the soil moisture values in the centroid coordinates of each coarse resolution 
#ESA-CCI pixel, and the values of the 250 meters pixels spatially matching the same coordinates 
#in the set of dynamic and static covariates.

#The code imports the ESA-CCI Soil Moisture reference data in coarse resolution (0.25 degrees), 
#as well as the dynamic covariates (NDVI and LST), and the dynamic masks (Snow Cover) in fine 
#resolution (250 meters) for ever biweekly period. The set of imported layers are 
#temporarily stored in a raster stack and then masked with the Snow Cover layer to remove snow 
#and ice-covered areas from the output training matrices.

##Libraries

library(raster)

##Config

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)
s_year <- args[1]
biweek <- args[2]

# Declare directory for storing temporary files
rasterOptions(tmpdir = paste0("./R_tempdirs_", s_year, "_", biweek, "/"), progress = "text", timer = TRUE)

# Set working directory
setwd("./3_North_America_SM_predictions")

##Main

# Build path to region shapefiles
regions_list <- c("01", "02", "03", "04", "05", "06", "07",
                  "08", "09", "10", "11", "12", "13", "14")

shp_dir <- "./0_Input_data/0_NorthAmerica_boundary_and_reference_raster/"
region_dir <- paste0(shp_dir, "northamerica_train_fishnet/")

shp_prefix <- "northamerica_train_fishnet_wgs84_"
regions_sections <- as.list(c(paste0(region_dir, shp_prefix, "01.shp"),
                              paste0(region_dir, shp_prefix, "02.shp"),
                              paste0(region_dir, shp_prefix, "03.shp"),
                              paste0(region_dir, shp_prefix, "04.shp"),
                              paste0(region_dir, shp_prefix, "05.shp"),
                              paste0(region_dir, shp_prefix, "06.shp"),
                              paste0(region_dir, shp_prefix, "07.shp"),
                              paste0(region_dir, shp_prefix, "08.shp"),
                              paste0(region_dir, shp_prefix, "09.shp"),
                              paste0(region_dir, shp_prefix, "10.shp"),
                              paste0(region_dir, shp_prefix, "11.shp"),
                              paste0(region_dir, shp_prefix, "12.shp"),
                              paste0(region_dir, shp_prefix, "13.shp"),
                              paste0(region_dir, shp_prefix, "14.shp")))

# Get SM and all covariates data for year and biweek
esacci_file <- paste0("./2_Covariates/0_esacci_soil_moisture/",
                      s_year, "/northamerica_esacci_92_",
                      s_year, "_biweek_", biweek, ".tif")

ndvi_file <- paste0("./2_Covariates/2_dinamyc_covariates/NDVI/",
                    s_year, "/MCD13Q1_NorthAmerica_061_ndvi_wgs84_mosaic_",
                    s_year, "_biweek_", biweek, "_.tif")

lst_file <- paste0("./2_Covariates/2_dinamyc_covariates/LST/",
                   s_year, "/MCD11A2_NorthAmerica_061_lst_wgs84_mosaic_",
                   s_year, "_biweek_", biweek, "_.tif")

sc_file <- paste0("./2_Covariates/3_masks/SNOW/",
                  s_year, "/MCD10A2_NorthAmerica_061_snow_wgs84_mosaic_",
                  s_year, "_biweek_", biweek, "_.tif")

# Note that only the five needed covariates should be in the specified directory
static_covariates <- list.files(path = "./2_Covariates/1_static_covariates/",
                                pattern = "tif", recursive = TRUE, full.names = TRUE)

# Stack together static covaraites
aspect <- raster(static_covariates[[1]])
elevation <- raster(static_covariates[[2]])
slope <- raster(static_covariates[[3]])
bulkdensity <- raster(static_covariates[[4]])
twi <- raster(static_covariates[[5]])
static_covariates <- stack(elevation, aspect, slope, twi, bulkdensity)

for (j in 1:length(regions_list)) {
  # Load in region shapefile
  temp_boundary <- shapefile(regions_sections[[j]])

  # Initialize new table
  base_table <- matrix(data = NA, nrow = 0, ncol = 10)
  base_table <- as.data.frame(base_table)
  names(base_table) <- c("x", "y", "z", "ndvi", "lst", "elevation",
                         "aspect", "slope", "twi", "bulk_density")

  # Load biweekly ESA-CCI soil moisture layer
  r <- raster(esacci_file)

  # Skip existing files
  out_file <- paste0("./3_Training_and_Test_data_csv/0_regions/region_",
                     regions_list[j], "/Train_matrix_region_", regions_list[j],
                     "_v92_250m_", s_year, "_", biweek, ".csv")
  if (file.exists(out_file)) {
    next
  }

  # Define lat long projection
  proj4string(r) <- CRS("+proj=longlat +datum=WGS84 +no_defs")
  # Convert to spatial pixels data frame
  r <- as(r, "SpatialPixelsDataFrame")
  # Convert to data frame
  df = as.data.frame(r, xy = T)
  # Remove no data values
  df = na.omit(df)
  # Define column coordinates
  coordinates(df) = ~x + y
  # Add lat long projection system
  proj4string(df) <- CRS("+proj=longlat +datum=WGS84 +no_defs")

  # Crop static and dynamic covariates to subregion
  region_static_covariates <- crop(static_covariates, temp_boundary)

  # Crop all dynamic covariate
  ndvi <- raster(ndvi_file)
  ndvi <- crop(ndvi, temp_boundary)

  lst <- raster(lst_file)
  lst <- crop(lst, temp_boundary)

  snow_mask <- raster(sc_file)
  snow_mask <- crop(snow_mask, temp_boundary)

  # Stack all covaraites except snow cover
  x <- stack(ndvi, lst, region_static_covariates)

  # Apply snow mask
  x <- x * snow_mask

  # Convert to spatial pixels data frame
  x <- as(x, "SpatialPixelsDataFrame")

  # Overlay soil moisture centroids and prediction covariates (x)
  ov = over(df, x)
  # Generate a data frame
  d = as.data.frame(df)
  # Combine extracted values
  y = cbind(d,  ov)
  # Remove no data values
  y = na.omit(y)
  # Training set year i
  z = data.frame(y[, 2:3], z = y[, 1],  y[, 4:10])

  # Add table labels
  names(z) <- c("x", "y", "z", "ndvi", "lst", "elevation",
                "aspect", "slope", "twi", "bulk_density")

  # Round all values within table
  base_table <- rbind(base_table, z)
  base_table$x <- round(base_table$x, digits = 5)
  base_table$y <- round(base_table$y, digits = 5)
  base_table$z <- round(base_table$z, digits = 5)
  base_table$ndvi <- round(base_table$ndvi, digits = 5)
  base_table$lst <- round(base_table$lst, digits = 0)
  base_table$elevation <- round(base_table$elevation, digits = 0)
  base_table$aspect <- round(base_table$aspect, digits = 5)
  base_table$slope <- round(base_table$slope, digits = 5)
  base_table$twi <- round(base_table$twi, digits = 5)
  base_table$bulk_density <- round(base_table$bulk_density, digits = 0)

  # Filter values to ensure snow cover isn't present
  base_table <- subset(base_table, base_table$ndvi != 0 & base_table$lst != 0 & base_table$elevation != 0 & base_table$aspect != 0 & base_table$slope != 0 & base_table$twi != 0 & base_table$bulk_density != 0)

  # Write final table to CSV
  write.csv(base_table, out_file, row.names = FALSE)

  # Temporary file cleanup
  gc()
  removeTmpFiles(h = 0.01)

  print(paste0("region  ", regions_list[j]))
  print(paste0(s_year, "  ", biweek))
  print(head(base_table))
}
