#NORTH AMERICA SOIL MOISTURE DATASET DERIVED FROM TIME-SPECIFIC ADAPTABLE MODELS

  #2. Data Preprocessing

###2.4.3	Merge of NDVI Biweekly means from MOD13Q1 and MYD13Q1 into combined layers

#This section merges the 8-days lagged MOD13Q1 and MYD13Q1 NDVI layers into combined biweekly NDVI means. 
#The combined layers are thereafter masked to the North America region, reprojected, and resampled to WGS84, 
#setting the same coordinate reference system and cell size as the ESA-CCI preprocessed biweekly 
#means and the preprocessed terrain parameters.

##Libraries

library(raster)

##Config

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)
s_year <- args[1]

# Declare directory for storing temporary files
rasterOptions(tmpdir = paste0("./R_tempdirs_", s_year, "/"), progress = "text", timer = TRUE)

# Set working directory
setwd("./3_North_America_SM_predictions")

##Main

# Get terra and aqua NDVI files
MOD13Q1_files <- list.files(path = paste0("./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/MOD13Q1/2_16days_Mosaics_LAEA_250m/", s_year),
                            pattern = ".tif", full.names = TRUE, recursive = TRUE)

MYD13Q1_files <- list.files(path = paste0("./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/MYD13Q1/2_16days_Mosaics_LAEA_250m/", s_year),
                            pattern = ".tif", full.names = TRUE, recursive = TRUE)

# Specify terra and aqua NDVI biweeks
MOD_biweeks <- c("001_NorthAmerica","017_NorthAmerica","033_NorthAmerica","049_NorthAmerica","065_NorthAmerica","081_NorthAmerica",
                 "097_NorthAmerica","113_NorthAmerica","129_NorthAmerica","145_NorthAmerica","161_NorthAmerica","177_NorthAmerica",
                 "193_NorthAmerica","209_NorthAmerica","225_NorthAmerica","241_NorthAmerica","257_NorthAmerica","273_NorthAmerica",
                 "289_NorthAmerica","305_NorthAmerica","321_NorthAmerica","337_NorthAmerica","353_NorthAmerica")

MYD_biweeks <- c("009_NorthAmerica","025_NorthAmerica","041_NorthAmerica","057_NorthAmerica","073_NorthAmerica","089_NorthAmerica",
                 "105_NorthAmerica","121_NorthAmerica","137_NorthAmerica","153_NorthAmerica","169_NorthAmerica","185_NorthAmerica",
                 "201_NorthAmerica","217_NorthAmerica","233_NorthAmerica","249_NorthAmerica","265_NorthAmerica","281_NorthAmerica",
                 "297_NorthAmerica","313_NorthAmerica","329_NorthAmerica","345_NorthAmerica","361_NorthAmerica")

for (j in 1:length(MOD_biweeks)) {
  # Filter files to specific biweek
  MOD_ndvi <- MOD13Q1_files[grep(MOD_biweeks[j], MOD13Q1_files)]
  MYD_ndvi <- MYD13Q1_files[grep(MYD_biweeks[j], MYD13Q1_files)]
  
  # Only merge if there are two files
  MCD_ndvi_files <- c(MOD_ndvi, MYD_ndvi)
  if (length(MCD_ndvi_files) < 2) {
    print(paste0(s_year, " ", j, " No files"))
  } else {
    # Load and stack rasters
    MOD_ndvi <- stack(MOD_ndvi)
    MYD_ndvi <- stack(MYD_ndvi)
    
    # Validate extents match
    if (extent(MOD_ndvi) == extent(MYD_ndvi)) {
      # Stack terra and aqua
      mean_ndvi <- stack(MOD_ndvi, MYD_ndvi)  
      
      print(paste0(s_year, " ", j, " processing"))
      
      # Compute mean of terra and aqua 
      mean_ndvi <- calc(mean_ndvi, mean, na.rm = TRUE)
      mean_ndvi <- mean_ndvi * 0.0001
      
      # Write results to raster
      writeRaster(mean_ndvi, paste0("./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/NorthAmerica_biweekly_MCD13Q1/1_LAEA/",
                                    s_year, "/MCD13Q1_NorthAmerica_061_ndvi_laea_mosaic_", s_year, "_biweek_", sprintf("%05d", j), ".tif"), 
                  overwrite = TRUE)  
      
      # Temporary file cleanup
      gc()
      removeTmpFiles(h=0.01)
      
      print(paste0(s_year, " ", j, " finished"))
    }
  }
}



# Masking of North America combined NDVI layers with North America Boundary.
# This process works in R but takes a long time, so it was performed in ArcPro.

# # Load reference shapefile
# reference_boundary <- shapefile("./0_Input_data/0_NorthAmerica_boundary_and_reference_raster/NA_LandCover_Boundary_2010_250m.shp")

# # Get merged NDVI files
# ndvi_files <- list.files(path = paste0("./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/NorthAmerica_biweekly_MCD13Q1/1_LAEA/", s_year),
#                          pattern = ".tif", full.names = T, recursive = T)

# for (i in 1:length(ndvi_files)) {
#   # Load raster
#   temp_rast <- raster(ndvi_files[i])
  
#   # Extract biweek number
#   biweek <- substr(names(temp_rast), 55, 56)
    
#   # Crop and mask data
#   temp_rast <- crop(temp_rast, reference_boundary)
#   temp_rast <- mask(temp_rast, reference_boundary)
    
#   # Write results to raster
#   writeRaster(temp_rast, paste0("./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/NorthAmerica_biweekly_MCD13Q1/1_LAEA/", s_year,
#                                 "/MCD13Q1_NorthAmerica_061_ndvi_laea_mosaic_", s_year, "_biweek_", biweek, "_.tif"), overwrite = TRUE)

#   # Temporary file cleanup
#   gc()
#   removeTmpFiles(h=0.01)
# }



# Reprojection from LAEA to WGS84 and masking with the North American region boundary
# This process works in R but takes a long time and does not accurately preserves pixels shape, so it was performed in ArcPro.

# # Load reference raster
# reference_raster <- raster("./1_Preprocessed_data/2_NA_GMTED2010_terrain_parameters/3_RSAGA_NorthAmerica_terrain_parameters/2_WGS84/NorthAmerica_WGS84_250m_elevation.tif")
  
# # Load reference shapefile
# reference_boundary <- shapefile("./0_Input_data/0_NorthAmerica_boundary_and_reference_raster/00_northamerica_region_interest_wgs84.shp")

# # Get masked NDVI files
# ndvi_files <- list.files(path = paste0("./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/NorthAmerica_biweekly_MCD13Q1/1_LAEA/", s_year),
#                          pattern = "_.tif", full.names = TRUE, recursive = TRUE)

# for (i in 1:length(ndvi_files)) {
#   # Load raster
#   temp_rast <- raster(ndvi_files[i])
  
#   # Extract biweek from file name
#   biweek <- substr(names(temp_rast), 55, 56)
  
#   # Reproject and mask data
#   temp_rast <- projectRaster(temp_rast, reference_raster)
#   temp_rast <- mask(temp_rast, reference_boundary)
  
#   # Write result to file
#   writeRaster(temp_rast, paste0("./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/NorthAmerica_biweekly_MCD13Q1/2_WGS84/", s_year,
#                                 "/MCD13Q1_NorthAmerica_061_ndvi_wgs84_mosaic_", s_year, "_biweek_", biweek, ".tif"), overwrite = TRUE)
  
#   # Temporary file cleanup
#   gc()
#   removeTmpFiles(h=0.01)
# }
