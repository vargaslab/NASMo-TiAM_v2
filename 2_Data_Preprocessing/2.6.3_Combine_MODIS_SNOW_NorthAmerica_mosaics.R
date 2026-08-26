#NORTH AMERICA SOIL MOISTURE DATASET DERIVED FROM TIME-SPECIFIC ADAPTABLE MODELS

  #2. Data Preprocessing

###2.4.3	Merge of Snow Cover weekly composites from MOD10A2 and MYD10A2 into biweekly combined layers

#This section merges the 8-days MOD10A2 and MYD10A2 Snow Cover composites into combined biweekly Snow Cover means.
#The values in the combined layers are reclassified to assign 0 to snow areas and 1 to the rest of the areas.
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

# Get terra and aqua SC files
MOD10A2_files <- list.files(path = paste0("./1_Preprocessed_data/6_NorthAmerica_MODIS_SNOW/MOD10A2/2_8days_Mosaics_LAEA_250m", s_year),
                            pattern = ".tif", recursive = TRUE, full.names = TRUE)

MYD10A2_files <- list.files(path = paste0("./1_Preprocessed_data/6_NorthAmerica_MODIS_SNOW/MYD10A2/2_8days_Mosaics_LAEA_250m", s_year),
                            pattern = ".tif", recursive = TRUE, full.names = TRUE)

# Specify biweeks
biweeks <- c("01","02","03","04","05","06","07","08","09","10","11","12",
             "13","14","15","16","17","18","19","20","21","22","23")

# Specify MODIS weeks
weeks <- c("001_NorthAmerica","009_NorthAmerica","017_NorthAmerica","025_NorthAmerica","033_NorthAmerica","041_NorthAmerica",
           "049_NorthAmerica","057_NorthAmerica","065_NorthAmerica","073_NorthAmerica","081_NorthAmerica","089_NorthAmerica",
           "097_NorthAmerica","105_NorthAmerica","113_NorthAmerica","121_NorthAmerica","129_NorthAmerica","137_NorthAmerica",
           "145_NorthAmerica","153_NorthAmerica","161_NorthAmerica","169_NorthAmerica","177_NorthAmerica","185_NorthAmerica",
           "193_NorthAmerica","201_NorthAmerica","209_NorthAmerica","217_NorthAmerica","225_NorthAmerica","233_NorthAmerica",
           "241_NorthAmerica","249_NorthAmerica","257_NorthAmerica","265_NorthAmerica","273_NorthAmerica","281_NorthAmerica",
           "289_NorthAmerica","297_NorthAmerica","305_NorthAmerica","313_NorthAmerica","321_NorthAmerica","329_NorthAmerica",
           "337_NorthAmerica","345_NorthAmerica","353_NorthAmerica","361_NorthAmerica")

# Reclassification matrix
m <- c(-Inf, 199, 1,  200, 200, 0,  200, Inf, 1)
rclmat <- matrix(m, ncol=3, byrow=TRUE)

for (j in seq(1,46,by=2)) {  
  # Filter files to specific weeks
  MOD_snow_a <- MOD10A2_files[grep(weeks[j], MOD10A2_files)]
  MOD_snow_b <- MOD10A2_files[grep(weeks[j+1], MOD10A2_files)]
  MYD_snow_a <- MYD10A2_files[grep(weeks[j], MYD10A2_files)]
  MYD_snow_b <- MYD10A2_files[grep(weeks[j+1], MYD10A2_files)]

  # Only merge if there are four files
  MCD_snow_files <- c(MOD_snow_a,MOD_snow_b,MYD_snow_a,MYD_snow_b)
  if(length(MCD_snow_files) < 4) {
    print(paste0(s_year, " ", weeks[j], " No files"))
  } else {
    # Extract extents of each file and make sure they match
    MOD_snow_a <- stack(MOD_snow_a)
    ext_mod_snow_a <- extent(MOD_snow_a)
    
    MOD_snow_b <- stack(MOD_snow_b)
    ext_mod_snow_b <- extent(MOD_snow_b)
    
    MYD_snow_a <- stack(MYD_snow_a)
    ext_myd_snow_a <- extent(MYD_snow_a)
    
    MYD_snow_b <- stack(MYD_snow_b)
    ext_myd_snow_b <- extent(MYD_snow_b)
  
    if((ext_mod_snow_a == ext_mod_snow_b) && (ext_mod_snow_a == ext_myd_snow_a) && (ext_mod_snow_a == ext_myd_snow_b)) {
      # Stack terra and aqua
      mean_snow <- stack(MOD_snow_a, MOD_snow_b, MYD_snow_a, MYD_snow_b)  
      
      # Compute mean of terra and aqua and reclassify data
      mean_snow <- calc(mean_snow, mean, na.rm = TRUE)
      mean_snow <- reclassify(mean_snow, rclmat)
    
      mean_snow[mean_snow == 200] <- 0
    
      print(paste0(s_year, " ", weeks[j], " processing"))
      
      # Write results to raster
      writeRaster(mean_snow, paste0("./1_Preprocessed_data/6_NorthAmerica_MODIS_SNOW/NorthAmerica_biweekly_MCD10A2/1_LAEA/", 
                                    s_year, "/MCD10A2_NorthAmerica_061_snow_laea_mosaic_", s_year, "_biweek_", biweeks[(j+1)/2], ".tif"), 
                  datatype='INT1U', overwrite = TRUE)  
      
      # Temporary file cleanup
      gc()
      removeTmpFiles(h=0.01)
      
      print(paste0(s_year, " ", weeks[j], " finished")) 
    }
  }
}



# Masking of North America combined LST layers with North America Boundary.
# This process works in R but takes a long time, so it was performed in ArcPro.

# # Load reference shapefile
# reference_boundary <- shapefile("./0_Input_data/0_NorthAmerica_boundary_and_reference_raster/NA_LandCover_Boundary_2010_250m.shp")

# # Get merged snow files
# snow_files <- list.files(path = paste0("./1_Preprocessed_data/6_NorthAmerica_MODIS_SNOW/NorthAmerica_biweekly_MCD10A2/1_LAEA/", s_year),
#                         pattern = ".tif", full.names = T, recursive = T)

# for (i in 1:length(snow_files)) {
#   # Load raster
#   temp_rast <- raster(snow_files[i])
  
#   # Extract biweek number
#   biweek <- substr(names(temp_rast), 55, 56)
  
#   # Crop and mask data
#   temp_rast <- crop(temp_rast, reference_boundary)
#   temp_rast <- mask(temp_rast, reference_boundary)
  
#   # Write results to raster
#   writeRaster(temp_rast, paste0("./1_Preprocessed_data/6_NorthAmerica_MODIS_SNOW/NorthAmerica_biweekly_MCD10A2/1_LAEA/", s_year,
#                                 "/MCD10A2_NorthAmerica_061_snow_laea_mosaic_", s_year, "_biweek_", biweek,"_.tif"), overwrite = TRUE)
  
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

# # Get masked snow files
# snow_files <- list.files(path = paste0("./1_Preprocessed_data/6_NorthAmerica_MODIS_SNOW/NorthAmerica_biweekly_MCD10A2/1_LAEA/", s_year),
#                         pattern = "_.tif", full.names = T, recursive = T)

# for (i in 1:length(snow_files)) {
#   # Load raster
#   temp_rast <- raster(snow_files[i])

#   # Extract biweek from file name
#   biweek <- substr(names(temp_rast), 55, 56)
  
#   # Reproject and mask data
#   temp_rast <- projectRaster(temp_rast, reference_raster)
#   temp_rast <- mask(temp_rast, reference_boundary)
  
#   # Write result to file
#   writeRaster(temp_rast, paste0("./1_Preprocessed_data/6_NorthAmerica_MODIS_SNOW/NorthAmerica_biweekly_MCD10A2/2_WGS84/", s_year,
#                                 "/MCD10A2_NorthAmerica_061_snow_wgs84_mosaic_", s_year, "_biweek_", biweek, ".tif"), overwrite = TRUE)
  
#   # Temporary file cleanup
#   gc()
#   removeTmpFiles(h=0.01)
# }
