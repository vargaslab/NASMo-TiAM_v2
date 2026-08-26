#NORTH AMERICA SOIL MOISTURE DATASET DERIVED FROM TIME-SPECIFIC ADAPTABLE MODELS

  #4. Prediction of Soil Moisture biweekly layers for North America

###4.2.1	Mosaic of predicted North America Soil Moisture raster files

#This code transforms the outputs of the Random Forest predictions from points to pixels in 
#raster format. The code uses the preprocessed North America elevation raster file as reference 
#and creates raster files in TIF format with the same coordinate reference system and pixel 
#size as the reference. -	The outputs are up to 44 raster files per biweekly period, 
#coinciding with the 44 predefined regions in the creation of the prediction matrices.

##Libraries

library(raster)

##Config

args <- commandArgs(trailingOnly = TRUE)
s_year <- args[1]

# Declare directory for storing temporary files
rasterOptions(tmpdir = paste0("./R_tempdirs_", s_year, "/"), progress = "text", timer = TRUE)

# Set working directory
setwd("./3_North_America_SM_predictions")

##Main

# Get all CSV region predicition files
predicted_files <- list.files(paste0("./5_NorthAmerica_prediction_outputs_250m_v92/2_RF/Prediction_outputs/", s_year), 
                              pattern = ".csv", full.names = T, recursive = T)

# Get the preprocessed elevation data to use as a reference for rasterization
ref_250m <- raster("./2_Covariates/1_static_covariates/NorthAmerica_wgs84_250m_elevation.tif")

# Iterate over each biweek
biweeks <- c("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23")

for (j in 1:length(biweeks)) {
  # Filter CSV predicition files to a biweek
  predicted_files_biweek <- predicted_files[grep(paste0("/", biweeks[j], "/"), predicted_files)]

  if (length(predicted_files_biweek) > 0) {
    for (k in 1:length(predicted_files_biweek)) {
      # Extract region number from CSV file name
      region <- substr(basename(predicted_files_biweek[k]), 44, 52)

      # If output file already exists skip file
      output_file <- paste0("./5_NorthAmerica_prediction_outputs_250m_v92/2_RF/Prediction_outputs_tif/1_Regions/",
			                      s_year,"/",biweeks[j],"/northamerica_rf_v92_250m_output_sm_",s_year,"_",biweeks[j],"_",region,".tif")
      if (file.exists(output_file)) {
        print(paste(output_file, "already exists. Skipping."))
        next
      }

      # Read the region CSV file
      predicted_file <- read.csv(predicted_files_biweek[k], header = T)

      # Convert CSV data to spatial data frame and specify CRS
      r <- SpatialPointsDataFrame(predicted_file[,1:2],predicted_file)
      crs(r) <- "+proj=longlat +datum=WGS84 +no_defs"

      # Rasterize the CSV data
      r <- rasterize(r, ref_250m, field=r$sm, fun=mean, background=NA)

      # Write rasterization to GeoTIFF
      writeRaster(r, filename = output_file, overwrite = TRUE)

      # Temporary file cleanup
      gc()
      removeTmpFiles(h=0.01)

      print(paste0(s_year, "  ", biweeks[j], "  ", region))
    }
  }
}
