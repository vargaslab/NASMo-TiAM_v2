#NORTH AMERICA SOIL MOISTURE DATASET DERIVED FROM TIME-SPECIFIC ADAPTABLE MODELS

  #2. Data Preprocessing

###2.4.2	NDVI North America Mosaics

#This section of the process takes the MOD13Q1 and MYD13Q1 NDVI tiles in TIF format and 
#assembles a mosaic for the North America region in the native Sinusoidal projection. 
#Then reprojects and resamples the mosaics.

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

# Specify MODIS NDVI biweeks for MOD13Q1
biweeks <- c("001","017","033","049","065","081","097","113",
             "129","145","161","177","193","209","225","241",
             "257","273","289","305","321","337","353")

for (j in 1:length(biweeks)) {
  # Get NDVI files for specific year and biweek
  ndvi_tif_files <- list.files(path = paste0("./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/MOD13Q1/0_16days_tif_tiles/",
                                             s_year, "/Tiles_", biweeks[j]),
                                pattern = ".tif", full.names = TRUE, recursive = TRUE)
  
  # Ensure at least three NDVI files exist for biweek
  if(length(ndvi_tif_files) <= 2){
    print(paste0(s_year, "  ", biweeks[j], "  Biweek with no files"))   
  } else {
    # Mosaic together all biweek files
    ndvi_tif_files <- lapply(ndvi_tif_files, raster)
    base_raster <- ndvi_tif_files[[1]]

    for (k in 2:length(ndvi_tif_files)) {
      temp_raster <- ndvi_tif_files[[k]]
      base_raster <- mosaic(base_raster, temp_raster, fun = mean)
      
      print(paste0(s_year, "  ", biweeks[j], "  ", k))
    }
    
    # Write mosaic data to GeoTIFF
    writeRaster(base_raster, filename = paste0("./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/MOD13Q1/1_16days_Mosaics_sinusoidal/",
                                               s_year, "/MOD13Q1_", s_year, biweeks[j], "_NorthAmerica_061_ndvi_mosaic.tif"), 
                datatype='INT4S', overwrite = TRUE)
    
    # Temporary file cleanup
    gc()
    removeTmpFiles(h=0.01)
  }
}



# Specify MODIS NDVI biweeks for MYD13Q1 
biweeks <- c("009","025","041","057","073","089","105","121",
             "137","153","169","185","201","217","233","249",
             "265","281","297","313","329","345","361")

for (j in 1:length(biweeks)) {
  # Get NDVI files for specific year and biweek
  ndvi_tif_files <- list.files(path = paste0("./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/MYD13Q1/0_16days_tif_tiles/",
                                             s_year, "/Tiles_", biweeks[j]), pattern = ".tif", full.names = T, recursive = T)
  
  # Ensure at least three NDVI files exist for biweek
  if(length(ndvi_tif_files) <= 2){
    print(paste0(s_year, "  ", biweeks[j], "  Biweek with no files"))   
  } else {
    # Mosaic together all biweek files
    ndvi_tif_files <- lapply(ndvi_tif_files, raster)
    base_raster <- ndvi_tif_files[[1]]
    
    for (k in 2:length(ndvi_tif_files)) {
      temp_raster <- ndvi_tif_files[[k]]
      base_raster <- mosaic(base_raster, temp_raster, fun = mean)
      
      print(paste0(s_year, "  ", biweeks[j], "  ", k))
    }
    
    # Write mosaic data to GeoTIFF
    writeRaster(base_raster, filename = paste0("./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/MYD13Q1/1_16days_Mosaics_sinusoidal/",
                                               s_year, "/MYD13Q1_", s_year, biweeks[j], "_NorthAmerica_061_ndvi_mosaic.tif"), 
                datatype='INT4S', overwrite = T)
    
    # Temporary file cleanup
    gc()
    removeTmpFiles(h=0.01)
  }
}


        
# Reprojection and resampling of North America NDVI mosaics from Sinusoidal projection to LAEA projection and 250 meters cell size. 
# This process works in R but takes a long time, so it was performed in ArcPro.

# # Load in reference raster
# reference_raster <- raster("./0_Input_data/0_NorthAmerica_boundary_and_reference_raster/NA_LandCover_2010_V2_25haMMU.tif")

# # Get MOD13Q1 mosaics
# NorthAmerica_NDVI_files <- list.files(path = "./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/MOD13Q1/1_16days_Mosaics_sinusoidal", 
#                                       pattern = paste0("MOD13Q1_", s_year), full.names = TRUE, recursive = TRUE)

# for (i in 1:length(NorthAmerica_NDVI_files)) {
#   # Load in raster
#   temp_rast <- raster(NorthAmerica_NDVI_files[i])
  
#   # Extract unique filename from path
#   file_name <- substr(basename(temp_rast), 1, 32) 

#   # Reproject raster to reference
#   temp_rast <- projectRaster(temp_rast, reference_raster)
  
#   # Write results to raster
#   writeRaster(temp_rast, filename = paste0("./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/MOD13Q1/2_16days_Mosaics_LAEA_250m/",
#                                            s_year, "/", file_name, "_ndvi_mosaic_laea.tif"), datatype='INT4S', overwrite = TRUE)
  
#   # Temporary file cleanup
#   gc()
#   removeTmpFiles(h=0.01)
# }

# # Get MYD13Q1 mosaics
# NorthAmerica_NDVI_files <- list.files(path = "./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/MYD13Q1/1_16days_Mosaics_sinusoidal", 
#                                       pattern = paste0("MYD13Q1_", s_year), full.names = TRUE, recursive = TRUE)

# for (i in 1:length(NorthAmerica_NDVI_files)) {
#   # Load in raster
#   temp_rast <- raster(NorthAmerica_NDVI_files[i])
  
#   # Extract unique filename from path
#   file_name <- substr(basename(temp_rast), 1, 32) 
  
#   # Reproject raster to reference
#   temp_rast <- projectRaster(temp_rast, reference_raster)
  
#   # Write results to raster
#   writeRaster(temp_rast, filename = paste0("./1_Preprocessed_data/4_NorthAmerica_MODIS_NDVI/MYD13Q1/2_16days_Mosaics_LAEA_250m/",
#                                            s_year, "/", file_name, "_ndvi_mosaic_laea.tif"), datatype='INT4S', overwrite = TRUE)
  
#   # Temporary file cleanup
#   gc()
#   removeTmpFiles(h=0.01)
# } 
