#NORTH AMERICA SOIL MOISTURE DATASET DERIVED FROM TIME-SPECIFIC ADAPTABLE MODELS

  #4.	Prediction of Soil Moisture biweekly layers for North America

###4.2.2	Mosaic of predicted North America Soil Moisture raster files

#This section of the process takes all the raster files of the predicted soil moisture 
#over the 44 sub-regions of interest and assembles a mosaic for North America.

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

# Mosaic together all the GeoTIFF region files for each biweek
# This process takes a long time, so it can alternatively be done in ArcGIS for performance
# If using ArcGIS, ensure GeoTIFF metadata is properly preserved

biweeks <- c("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23")

for (j in 1:length(biweeks)) {
  # Load in all region files for biweek
  sm_regions_tif <- list.files(path = paste0("./5_NorthAmerica_prediction_outputs_250m_v92/2_RF/Prediction_outputs_tif/1_Regions/",
					                                   s_year,"/", biweeks[j]), pattern = ".tif", full.names = T, recursive = T)

  if (length(sm_regions_tif) > 0) {
    # Skip file if it already exists
    output_file <- paste0("./5_NorthAmerica_prediction_outputs_250m_v92/2_RF/Prediction_outputs_tif/2_NA_mosaics/",
                          s_year, "/northamerica_rf_v92_250m_output_sm_", s_year, "_", biweeks[j],".tif")
    if (file.exists(output_file)) {
      print(paste(output_file, "already exists. Skipping."))
      next
    }

    # Load in first raster
    sm_regions_tif <- lapply(sm_regions_tif, raster)
    base_raster <- sm_regions_tif[[1]]

    # Mosaic together all regions
    for (k in 2:length(sm_regions_tif)) {
      temp_raster <- sm_regions_tif[[k]]
      base_raster <- mosaic(base_raster, temp_raster, fun = mean)

      print(paste0(s_year, "  ", biweeks[j], "  ", k))
    }

    # Write file mosaic to file
    writeRaster(base_raster, filename = output_file, overwrite = T)

    # Temporary file cleanup
    gc()
    removeTmpFiles(h=0.01)
  }
}
