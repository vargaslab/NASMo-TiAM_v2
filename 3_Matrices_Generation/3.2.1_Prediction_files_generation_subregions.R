#NORTH AMERICA SOIL MOISTURE DATASET DERIVED FROM TIME-SPECIFIC ADAPTABLE MODELS

  #3. Generation of Biweekly Training and Prediction matrices

###3.2.1 Generation of North America prediction matrices by predefined sub-regions

#This code creates the prediction matrices for every biweekly period for 44 sub-regions of interest. 
#The matrices depict the values of the dynamic and static covariates for each biweekly period in 
#the centroid coordinates of all 250 meters pixels within each sub-region.

#The code imports the dynamic covariates (NDVI and LST), and the dynamic masks (Snow Cover) in fine 
#resolution (250 meters) for ever biweekly period. The static covariates (terrain parameters and bulk 
#density) are also imported. The set of imported layers are temporarily stored in a raster stack and 
#then masked with the Snow Cover layer to remove snow and ice-covered areas from the output 
#prediction matrices.

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
regions_list <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11",
                  "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22",
                  "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33",
                  "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44")

shp_dir <- "./0_Input_data/0_NorthAmerica_boundary_and_reference_raster/"
region_dir <- paste0(shp_dir, "northamerica_eval_fishnet/")
shp_prefix <- "northamerica_eval_fishnet_wgs84_"

regions_sections <- as.list(c(paste0(region_dir, shp_prefix, "01.shp"), paste0(region_dir, shp_prefix, "02.shp"),
                              paste0(region_dir, shp_prefix, "03.shp"), paste0(region_dir, shp_prefix, "04.shp"),
                              paste0(region_dir, shp_prefix, "05.shp"), paste0(region_dir, shp_prefix, "06.shp"),
                              paste0(region_dir, shp_prefix, "07.shp"), paste0(region_dir, shp_prefix, "08.shp"),
                              paste0(region_dir, shp_prefix, "09.shp"), paste0(region_dir, shp_prefix, "10.shp"),
                              paste0(region_dir, shp_prefix, "11.shp"), paste0(region_dir, shp_prefix, "12.shp"),
                              paste0(region_dir, shp_prefix, "13.shp"), paste0(region_dir, shp_prefix, "14.shp"),
                              paste0(region_dir, shp_prefix, "15.shp"), paste0(region_dir, shp_prefix, "16.shp"),
                              paste0(region_dir, shp_prefix, "17.shp"), paste0(region_dir, shp_prefix, "18.shp"),
                              paste0(region_dir, shp_prefix, "19.shp"), paste0(region_dir, shp_prefix, "20.shp"),
                              paste0(region_dir, shp_prefix, "21.shp"), paste0(region_dir, shp_prefix, "22.shp"),
                              paste0(region_dir, shp_prefix, "23.shp"), paste0(region_dir, shp_prefix, "24.shp"),
                              paste0(region_dir, shp_prefix, "25.shp"), paste0(region_dir, shp_prefix, "26.shp"),
                              paste0(region_dir, shp_prefix, "27.shp"), paste0(region_dir, shp_prefix, "28.shp"),
                              paste0(region_dir, shp_prefix, "29.shp"), paste0(region_dir, shp_prefix, "30.shp"),
                              paste0(region_dir, shp_prefix, "31.shp"), paste0(region_dir, shp_prefix, "32.shp"),
                              paste0(region_dir, shp_prefix, "33.shp"), paste0(region_dir, shp_prefix, "34.shp"),
                              paste0(region_dir, shp_prefix, "35.shp"), paste0(region_dir, shp_prefix, "36.shp"),
                              paste0(region_dir, shp_prefix, "37.shp"), paste0(region_dir, shp_prefix, "38.shp"),
                              paste0(region_dir, shp_prefix, "39.shp"), paste0(region_dir, shp_prefix, "40.shp"),
                              paste0(region_dir, shp_prefix, "41.shp"), paste0(region_dir, shp_prefix, "42.shp"),
                              paste0(region_dir, shp_prefix, "43.shp"), paste0(region_dir, shp_prefix, "44.shp")))
                              
# Load all covariates for year and biweek
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

# Stack static covariates
aspect <- raster(static_covariates[[1]])
elevation <- raster(static_covariates[[2]])
slope <- raster(static_covariates[[3]])
bulkdensity <- raster(static_covariates[[4]])
twi <- raster(static_covariates[[5]])
static_covariates <- stack(elevation, aspect, slope, twi, bulkdensity)

for (j in 1:length(regions_list)) {
  # Load region shapefile
  temp_boundary <- shapefile(regions_sections[[j]])

  # Initialize new table
  base_table <- matrix(data = NA, nrow = 0, ncol = 9)
  base_table <- as.data.frame(base_table)
  names(base_table) <- c("x", "y", "ndvi", "lst", "elevation",
                         "aspect", "slope", "twi", "bulk_density")

  # Crop static and dynamic covariates to region
  region_static_covariates <- crop(static_covariates, temp_boundary)

  ndvi <- raster(ndvi_file)
  ndvi <- crop(ndvi, temp_boundary)

  lst <- raster(lst_file)
  lst <- crop(lst, temp_boundary)

  snow_mask <- raster(sc_file)
  snow_mask <- crop(snow_mask, temp_boundary)

  # Stack together all covaraites except snow cover
  x <- stack(ndvi, lst, region_static_covariates)

  # Apply snow cover mask
  x <- x * snow_mask

  # If no data in cells after stacking, skip table processing
  empty_frame_check <- cellStats(x, stat = "mean")
  if (mean(empty_frame_check) == "NaN") {
    print(paste0(s_year, " ", biweek, " ", "Empty frame"))
  } else {
    # Convert to spatial pixels data frame
    x <- as(x, "SpatialPixelsDataFrame")

    # Create table labels
    names(x) <- c("ndvi", "lst", "elevation",
                  "aspect", "slope", "twi", "bulk_density")

    # Convert data to table and filter nodata values
    eval_file <- as.data.frame(x)
    eval_file <- na.omit(eval_file)

    # Round all values within table
    eval_file$x <- round(eval_file$x, digits = 5)
    eval_file$y <- round(eval_file$y, digits = 5)
    eval_file$ndvi <- round(eval_file$ndvi, digits = 5)
    eval_file$lst <- round(eval_file$lst, digits = 0)
    eval_file$elevation <- round(eval_file$elevation, digits = 0)
    eval_file$aspect <- round(eval_file$aspect, digits = 5)
    eval_file$slope <- round(eval_file$slope, digits = 5)
    eval_file$twi <- round(eval_file$twi, digits = 5)
    eval_file$bulk_density <- round(eval_file$bulk_density, digits = 0)

    # Reorder data frame column
    eval_file <- data.frame(eval_file[,8:9], eval_file[,1:7])

    # Remove points from table where values had snow cover
    eval_file <- subset(eval_file, eval_file$ndvi != 0 & eval_file$lst != 0 & eval_file$elevation != 0 & eval_file$aspect != 0 & eval_file$slope != 0 & eval_file$twi != 0 & eval_file$bulk_density != 0)

    # Write final processed table to CSV
    write.csv(eval_file, paste0("./4_Evaluation_data_csv/", s_year, "/", biweek, "/northamerica_eval_v92_250m_region_",
                                regions_list[j], "_", s_year, "_", biweek, ".csv"), row.names = FALSE)

    # Temporary file cleanup
    gc()
    removeTmpFiles(h = 0.01)

    print(regions_list[j])
    print(paste0("Biweek ", s_year, " ", biweek))
    print(head(eval_file))
  }
}
