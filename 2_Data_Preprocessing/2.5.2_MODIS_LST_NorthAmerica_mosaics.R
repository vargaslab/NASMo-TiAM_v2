#NORTH AMERICA SOIL MOISTURE DATASET DERIVED FROM TIME-SPECIFIC ADAPTABLE MODELS

  #2. Data Preprocessing

###2.5.2	Land Surface Temperature North America Mosaics

#This section of the process takes the MOD11A2 and MYD11A2 LST tiles in TIF format and 
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

# Specify MODIS LST weeks
weeks <- c("001","009","017","025","033","041","049","057","065",
           "073","081","089","097","105","113","121","129","137",
           "145","153","161","169","177","185","193","201","209",
           "217","225","233","241","249","257","265","273","281",
           "289","297","305","313","321","329","337","345","353","361")

# Mosaic process for MOD11A2 files
for (j in 1:length(weeks)) {
  # Get LST files for specific year and week
  lst_tif_files <- list.files(path = paste0("./1_Preprocessed_data/5_NorthAmerica_MODIS_LST/MOD11A2/0_8days_tif_tiles/",
                                            s_year, "/Tiles_", weeks[j]),
                              pattern = ".tif", full.names = TRUE, recursive = TRUE)
  
  # Ensure at least three LST files exist for week
  if(length(lst_tif_files) <= 2){
    print(paste0(s_year, "  ", weeks[j], "  Week with no files"))       
  } else {
    # Mosaic together all week files
    lst_tif_files <- lapply(lst_tif_files, raster)
    base_raster <- lst_tif_files[[1]]
    
    for (k in 2:length(lst_tif_files)) {
      temp_raster <- lst_tif_files[[k]]
      base_raster <- mosaic(base_raster, temp_raster, fun = mean)
      
      print(paste0(s_year, "  ", weeks[j], "  ", k))
    }
    
    # Modify values of mosaic data
    base_raster <- base_raster*0.02
    
    # Write mosaic data to GeoTIFF
    writeRaster(base_raster, filename = paste0("./1_Preprocessed_data/5_NorthAmerica_MODIS_LST/MOD11A2/1_8days_Mosaics_sinusoidal/",
                                                s_year, "/MOD11A2_", s_year, weeks[j], "_NorthAmerica_061_lst_mosaic.tif"), 
                datatype='INT4S', overwrite = TRUE)
    
    # Temporary file cleanup
    gc()
    removeTmpFiles(h=0.01)
  }
}


# Mosaic process for MYD11A2 files
for (j in 1:length(weeks)) {
  # Get LST files for specific year and week
  lst_tif_files <- list.files(path = paste0("./1_Preprocessed_data/5_NorthAmerica_MODIS_LST/MYD11A2/0_8days_tif_tiles/",
                                            s_year, "/Tiles_", weeks[j]),
                              pattern = ".tif", full.names = TRUE, recursive = TRUE)
  
  # Ensure at least three LST files exist for week
  if(length(lst_tif_files) <= 2){
    print(paste0(s_year, "  ", weeks[j], "  Week with no files"))   
  } else {
    # Mosaic together all week files
    lst_tif_files <- lapply(lst_tif_files, raster)
    base_raster <- lst_tif_files[[1]]
    
    for (k in 2:length(lst_tif_files)) {
      temp_raster <- lst_tif_files[[k]]
      base_raster <- mosaic(base_raster, temp_raster, fun = mean)
      
      print(paste0(s_year, "  ", weeks[j], "  ", k))
    }
    
    # Modify values of mosaic data
    base_raster <- base_raster*0.02
    
    # Write mosaic data to GeoTIFF
    writeRaster(base_raster, filename = paste0("./1_Preprocessed_data/5_NorthAmerica_MODIS_LST/MYD11A2/1_8days_Mosaics_sinusoidal/",
                                                s_year, "/MYD11A2_", s_year, weeks[j], "_NorthAmerica_061_lst_mosaic.tif"), 
                datatype='INT4S', overwrite = TRUE)
    
    # Temporary file cleanup
    gc()
    removeTmpFiles(h=0.01)
  }
}



# Reprojection and resampling of North America LST mosaics from Sinusoidal projection to LAEA projection and 250 meters cell size  
# This process works in R but takes a long time, so it was performed in ArcPro.

# # Load in reference raster
# reference_raster <- raster("./0_Input_data/0_NorthAmerica_boundary_and_reference_raster/NA_LandCover_2010_V2_25haMMU.tif")

# # Get MOD11A2 mosaics
# NorthAmerica_LST_files <- list.files(path = "./1_Preprocessed_data/5_NorthAmerica_MODIS_LST/MOD11A2/1_8days_Mosaics_sinusoidal", 
#                                       pattern = paste0("MOD11A2_", s_year), full.names = T, recursive = T)

# for (i in 1:length(NorthAmerica_LST_files)) {
#   # Load in raster
#   temp_rast <- raster(NorthAmerica_LST_files[i])
  
#   # Extract unique filename from path
#   file_name <- substr(basename(temp_rast), 1, 32) 
  
#   # Reproject raster to reference
#   temp_rast <- projectRaster(temp_rast, reference_raster)
  
#   # Write results to raster
#   writeRaster(temp_rast, filename = paste0("./1_Preprocessed_data/5_NorthAmerica_MODIS_LST/MOD11A2/2_8days_Mosaics_LAEA_250m/",
#                                            s_year, "/", file_name, "_lst_mosaic_laea.tif"),
#               datatype='INT4S', overwrite = TRUE)
  
#   # Temporary file cleanup
#   gc()
#   removeTmpFiles(h=0.01)
# }


# # Get MYD11A2 mosaics
# NorthAmerica_LST_files <- list.files(path = "./1_Preprocessed_data/5_NorthAmerica_MODIS_LST/MYD11A2/1_8days_Mosaics_sinusoidal", 
#                                      pattern = paste0("MYD11A2_", s_year), full.names = TRUE, recursive = TRUE)

# for (i in 1:length(NorthAmerica_LST_files)) {
#   # Load in raster
#   temp_rast <- raster(NorthAmerica_LST_files[i])
  
#   # Extract unique filename from path
#   file_name <- substr(basename(temp_rast), 1, 32) 
  
#   # Reproject raster to reference
#   temp_rast <- projectRaster(temp_rast, reference_raster)
  
#   # Write results to raster
#   writeRaster(temp_rast, filename = paste0("./1_Preprocessed_data/5_NorthAmerica_MODIS_LST/MYD11A2/2_8days_Mosaics_LAEA_250m/",
#                                            s_year, "/", file_name, "_lst_mosaic_laea.tif"),
#               datatype='INT4S', overwrite = TRUE)
  
#   # Temporary file cleanup
#   gc()
#   removeTmpFiles(h=0.01)
# } 
