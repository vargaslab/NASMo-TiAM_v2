#NORTH AMERICA SOIL MOISTURE DATASET DERIVED FROM TIME-SPECIFIC ADAPTABLE MODELS

  #2. Data Preprocessing

###2.6.2	Snow Cover North America Mosaics

#This section of the process takes the MOD10A2 and MYD10A2 LST tiles in TIF format and 
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

# Specify MODIS SC weeks
weeks <- c("001","009","017","025","033","041","049","057","065",
           "073","081","089","097","105","113","121","129","137",
           "145","153","161","169","177","185","193","201","209",
           "217","225","233","241","249","257","265","273","281",
           "289","297","305","313","321","329","337","345","353","361")

# Mosaic process for MOD10A2 files
for (j in 1:length(weeks)) {
  # Get SC files for specific year and week
  snow_tif_files <- list.files(path = paste0("./1_Preprocessed_data/6_NorthAmerica_MODIS_SNOW/MOD10A2/0_8days_tif_tiles/",
                                            s_year, "/Tiles_", weeks[j]),
                               pattern = ".tif", full.names = TRUE, recursive = TRUE)
  
  # Ensure at least three SC files exist for week
  if(length(snow_tif_files) <= 2){
    print(paste0(s_year, "  ", weeks[j], "  Week with no files"))   
  } else {
    # Mosaic together all week files
    snow_tif_files <- lapply(snow_tif_files, raster)
    base_raster <- snow_tif_files[[1]]
    
    for (k in 2:length(snow_tif_files)) {
      temp_raster <- snow_tif_files[[k]]
      base_raster <- mosaic(base_raster, temp_raster, fun = mean)
      
      print(paste0(s_year, "  ", weeks[j], "  ", k))  
    }
    
    # Write mosaic data to GeoTIFF
    writeRaster(base_raster, filename = paste0("./1_Preprocessed_data/6_NorthAmerica_MODIS_SNOW/MOD10A2/1_8days_Mosaics_sinusoidal/",
                                               s_year, "/MOD10A2_", s_year, weeks[j], "_NorthAmerica_061_snow_mosaic.tif"), 
                datatype='INT4S', overwrite = TRUE)
    
    # Temporary file cleanup
    gc()
    removeTmpFiles(h=0.01)
  }
}


# Mosaic process for MYD10A2 files
for (j in 1:length(weeks)) {
  # Get SC files for specific year and week
  snow_tif_files <- list.files(path = paste0("./1_Preprocessed_data/6_NorthAmerica_MODIS_SNOW/MYD10A2/0_8days_tif_tiles/",
                                            s_year, "/Tiles_", weeks[j]), pattern = ".tif", full.names = T, recursive = T)
  
  # Ensure at least three SC files exist for week
  if(length(snow_tif_files) <= 2){
    print(paste0(s_year, "  ", weeks[j], "  Week with no files"))   
  } else {
    # Mosaic together all week files
    snow_tif_files <- lapply(snow_tif_files, raster)
    base_raster <- snow_tif_files[[1]]
    
    for (k in 2:length(snow_tif_files)) {
      temp_raster <- snow_tif_files[[k]]
      base_raster <- mosaic(base_raster, temp_raster, fun = mean)
      
      print(paste0(s_year, "  ", weeks[j], "  ", k))
    }
    
    # Write mosaic data to GeoTIFF
    writeRaster(base_raster, filename = paste0("./1_Preprocessed_data/6_NorthAmerica_MODIS_SNOW/MYD10A2/1_8days_Mosaics_sinusoidal/",
                                               s_year, "/MYD10A2_", s_year, weeks[j], "_NorthAmerica_061_snow_mosaic.tif"), 
                datatype='INT4S', overwrite = TRUE)
    
    # Temporary file cleanup
    gc()
    removeTmpFiles(h=0.01)
  }
}



# Reprojection and resampling of North America Snow Cover mosaics from Sinusoidal projection to LAEA projection and 250 meters cell size  
# This process works in R but takes a long time, so it was performed in Arc Pro.

# # Load in reference raster
# reference_raster <- raster("./0_Input_data/0_NorthAmerica_boundary_and_reference_raster/NA_LandCover_2010_V2_25haMMU.tif")

# # Get MOD10A2 mosaics
# NorthAmerica_SNOW_files <- list.files(path = "./1_Preprocessed_data/6_NorthAmerica_MODIS_SNOW/MOD10A2/1_8days_Mosaics_sinusoidal", 
#                                      pattern = paste0("MOD10A2_", s_year), full.names = TRUE, recursive = TRUE)

# for (i in 1:length(NorthAmerica_SNOW_files)) {
#   # Load in raster
#   temp_rast <- raster(NorthAmerica_SNOW_files[i])
  
#   # Extract unique filename from path
#   file_name <- substr(basename(temp_rast), 1, 32)
  
#   # Reproject raster to reference
#   temp_rast <- projectRaster(temp_rast, reference_raster)
  
#   # Write results to raster
#   writeRaster(temp_rast, filename = paste0("./1_Preprocessed_data/6_NorthAmerica_MODIS_SNOW/MOD10A2/2_8days_Mosaics_LAEA_250m/",
#                                            s_year, "/", file_name, "_snow_mosaic_laea.tif"),
#               datatype='INT4S', overwrite = TRUE)
  
#   # Temporary file cleanup
#   gc()
#   removeTmpFiles(h=0.01)
# }

# # Get MYD10A2 mosaics
# NorthAmerica_SNOW_files <- list.files(path = "./1_Preprocessed_data/6_NorthAmerica_MODIS_SNOW/MYD10A2/1_8days_Mosaics_sinusoidal", 
#                                      pattern = paste0("MYD10A2_", s_year), full.names = TRUE, recursive = TRUE)

# for (i in 1:length(NorthAmerica_SNOW_files)) {
#   # Load in raster
#   temp_rast <- raster(NorthAmerica_SNOW_files[i])
  
#   # Extract unique filename from path
#   file_name <- substr(basename(temp_rast), 1, 32)
  
#   # Reproject raster to reference
#   temp_rast <- projectRaster(temp_rast, reference_raster)
  
#   # Write results to raster
#   writeRaster(temp_rast, filename = paste0("./1_Preprocessed_data/6_NorthAmerica_MODIS_SNOW/MYD10A2/2_8days_Mosaics_LAEA_250m/",
#                                            s_year, "/", file_name, "_snow_mosaic_laea.tif"),
#               datatype='INT4S', overwrite = TRUE)
  
#   # Temporary file cleanup
#   gc()
#   removeTmpFiles(h=0.01)
# } 
