#NORTH AMERICA SOIL MOISTURE DATASET DERIVED FROM TIME-SPECIFIC ADAPTABLE MODELS

  #2. Data Preprocessing

###2.4.1 Extraction of NDVI layers from MODIS HDF files and export to TIF format

#This section of the process reads the 16-days MOD13Q1 and MYD13Q1 composites in their native HDF format, 
#extracts the layer with the NDVI information and exports it to TIF format.

##Libraries

library(raster)
library(ncdf4)

##Config

# Declare directory for storing temporary files
rasterOptions(tmpdir = "./R_tempdirs/", progress = "text", timer = TRUE)

# Set working directory
setwd("./3_North_America_SM_predictions")

##Main

# Convert HDF files to GeoTIFF for MOD13Q1 files
hdf_files <- list.files(path = "./0_Input_data/4_MODIS_NDVI/MOD13Q1_hdf_files", 
                        pattern = ".hdf", full.names = T, recursive = T)  

for (hdf_file in hdf_files) {
  # Extract file name info
  composite_name <- substr(basename(hdf_file), 1, 27)
  year <- substr(composite_name, 10, 13)
  biweek <- substr(composite_name, 14, 16)
  
  # Extract first layer with NDVI
  sds <- raster(hdf_file)
  ndvi <- sds[[1]]

  # Create output directory and save as GeoTIFF
  output_dir <- paste0("./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/MOD13Q1/0_16days_tif_tiles/",
                       year, "/", "Tiles_", biweek, "/")
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  writeRaster(ndvi, filename = paste0(output_dir, composite_name, "_ndvi.tif"), overwrite = TRUE)
  
  print(composite_name)
}

# Convert HDF files to GeoTIFF for MYD13Q1 files
hdf_files <- list.files(path = "./0_Input_data/4_MODIS_NDVI/MYD13Q1_hdf_files", 
                        pattern = ".hdf", full.names = T, recursive = T)    

for (hdf_file in hdf_files) {
  # Extract file name info
  composite_name <- substr(basename(hdf_file), 1, 27)
  year <- substr(composite_name, 10, 13)
  biweek <- substr(composite_name, 14, 16)
  
  # Extract first layer with NDVI
  sds <- raster(hdf_file)
  ndvi <- sds[[1]]

  # Create directory and save as GeoTIFF
  output_dir <- paste0("./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/MYD13Q1/0_16days_tif_tiles/",
                       year, "/", "Tiles_", biweek, "/")
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  writeRaster(ndvi, filename = paste0(output_dir, composite_name, "_ndvi.tif"), overwrite = TRUE)
  
  print(composite_name)
}
