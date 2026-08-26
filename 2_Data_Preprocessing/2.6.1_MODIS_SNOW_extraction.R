#NORTH AMERICA SOIL MOISTURE DATASET DERIVED FROM TIME-SPECIFIC ADAPTABLE MODELS

  #2. Data Preprocessing

###2.6.1 Extraction of Snow Cover layers from MODIS HDF files and export to TIF format

#This section of the process reads the 8-days MOD10A2 and MYD10A2 composites in their native HDF format, 
#extracts the layer with the Snow Cover information and exports it to TIF format.

##Libraries

library(raster)
library(ncdf4)

##Config

# Declare directory for storing temporary files
rasterOptions(tmpdir = "./R_tempdirs/", progress = "text", timer = TRUE)

# Set working directory
setwd("./3_North_America_SM_predictions")

##Main

# Convert HDF files to GeoTIFF for MOD10A2 files
hdf_files <- list.files(path = "./0_Input_data/6_SNOW_cover_masks/MOD10A2_hdf_files",
                        pattern = ".hdf", full.names = T, recursive = T)  

for (hdf_file in hdf_files) {
  # Extract file name info
  composite_name <- substr(basename(hdf_file), 1, 27)
  year <- substr(composite_name, 10, 13)
  biweek <- substr(composite_name, 14, 16)
  
  # Extract first layer with SC
  sds <- raster(hdf_file)
  sc <- sds[[1]]
  
  # Create output directory and save as GeoTIFF
  output_dir <- paste0("./1_Preprocessed_data/6_SNOW_cover_masks/MOD10A2/0_8days_tif_tiles/",
                       year, "/", "Tiles_", biweek, "/")
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  writeRaster(sc, filename = paste0(output_dir, composite_name, "_sc.tif"), overwrite = TRUE)
  
  print(composite_name)
}

# Convert HDF files to GeoTIFF for MYD10A2 files
hdf_files <- list.files(path = "./0_Input_data/6_SNOW_cover_masks/MYD10A2_hdf_files",
                        pattern = ".hdf", full.names = T, recursive = T)  

for (hdf_file in hdf_files) {
  # Extract file name info
  composite_name <- substr(basename(hdf_file), 1, 27)
  year <- substr(composite_name, 10, 13)
  biweek <- substr(composite_name, 14, 16)
  
  # Extract first layer with SC
  sds <- raster(hdf_file)
  sc <- sds[[1]]
  
  # Create output directory and save as GeoTIFF
  output_dir <- paste0("./1_Preprocessed_data/6_SNOW_cover_masks/MYD10A2/0_8days_tif_tiles/",
                       year, "/", "Tiles_", biweek, "/")
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  writeRaster(sc, filename = paste0(output_dir, composite_name, "_sc.tif"), overwrite = TRUE)

  print(composite_name)
}
