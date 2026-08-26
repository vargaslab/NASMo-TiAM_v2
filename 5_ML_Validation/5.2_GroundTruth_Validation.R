#NORTH AMERICA SOIL MOISTURE DATASET DERIVED FROM TIME-SPECIFIC ADAPTABLE MODELS

#5.	Validation

###5.2	5.2	Independent Validation with Ground-Truth Data

#This code calculates correlation and root mean square error (RMSE) values based
#on matrices containing the predicted values and reference soil moisture records
#from the North American Soil Moisture Database (NASMD). To obtain reference
#correlation and RMSE values, the code also compares the input ESA-CCI soil
#moisture values with field records from NASMD.

##Libraries

library(raster)
library(Metrics)

##Config

# Declare directory for storing temporary files
rasterOptions(tmpdir = "./R_tempdirs", progress = "text", timer = TRUE)

# Set working directory
setwd("./3_North_America_SM_predictions")

##Main

# Specify years and biweeks
years_file <- c("_2002_","_2003_","_2004_","_2005_","_2006_","_2007_","_2008_","_2009_","_2010_",
                "_2011_","_2012_","_2013_","_2014_","_2015_","_2016_","_2017_","_2018_","_2019_","_2020_",
                ,"_2021_","_2022_","_2023_","_2024_")

biweeks_file <- c("_01.","_02.","_03.","_04.","_05.","_06.","_07.","_08.","_09.","_10.","_11.","_12.",
                  "_13.","_14.","_15.","_16.","_17.","_18.","_19.","_20.","_21.","_22.","_23.")

years <- c("2002","2003","2004","2005","2006","2007","2008","2009","2010",
           "2011","2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","2022","2023","2024")

biweeks <- c("01","02","03","04","05","06","07","08","09","10","11","12",
             "13","14","15","16","17","18","19","20","21","22","23")

# Get ESA CCI rasters and ismn biweekly files
raster_files <- list.files(path = "./2_Covariates/0_esacci_soil_moisture",
                           pattern = ".tif", full.names = TRUE, recursive = TRUE)

ismn_files <- list.files(path = "./1_Preprocessed_data/7_ISMN_validation/3_ismn_biweekly_means_northamerica",
                         pattern = ".csv", full.names = TRUE, recursive = TRUE)

# Configure validation report table
validation_report_final <- matrix(data = NA, nrow = 0, ncol = 8)
validation_report_final <- as.data.frame(validation_report_final)
names(validation_report_final) <- c("Region", "Method", "Resolution", "Year",
                                    "Biweek", "No.Points", "Correl", "RMSE")

for (i in 1:length(years)) {
  # Filter raster and ISMN files to year
  raster_files_year <- raster_files[grep(years_file[i], raster_files)]
  ismn_files_year <- ismn_files[grep(years_file[i], ismn_files)]

  for (j in 1:length(biweeks)) {
    # Filter raster and ISMN files to biweeks
    raster_file_biweek <- raster_files_year[grep(biweeks_file[j], raster_files_year)]
    raster_file_biweek <- as.list(raster_file_biweek)
    ismn_file_biweek <- ismn_files_year[grep(biweeks_file[j], ismn_files_year)]
    ismn_file_biweek <- as.list(ismn_file_biweek)

    if (length(raster_file_biweek) > 0 && length(ismn_file_biweek) > 0) {
      # Load in biweek raster
      x <- raster(raster_file_biweek[[1]])

      # Configure validation table with data
      validation_data <- read.csv(ismn_file_biweek[[1]],
                                  header = TRUE, dec = ".")
      validation_data <- as.data.frame(cbind(validation_data$Longitude,
                                             validation_data$Latitude,
                                             validation_data$mean_sm_depth_5cm))
      validation_data$Year <- years[i]
      validation_data$Biweek <- biweeks[j]
      validation_data$Region <- "North America"
      validation_data$Method <- "ESACCI_reference"
      validation_data$Resolution <- "0.25 deg"
      names(validation_data) <- c("X", "Y", "NASMD_SM", "Year", "Biweek",
                                  "Region", "Method", "Resolution")

      # Extract x and y columns
      validation_data <- as.data.frame(validation_data, xy=TRUE)
      xy_ <- validation_data[, c(1, 2)]

      # Extract validation data into a spatial dataframe
      crs_proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
      validation_data <- SpatialPointsDataFrame(coords = xy_,
                                                data = validation_data,
                                                proj4string = CRS(crs_proj))

      validation_output <- extract(x, validation_data)

      # Convert validation data to a dataframe
      validation_data_table <- as.data.frame(validation_data)
      validation_data_table <- cbind(validation_data_table, validation_output)
      validation_data_table <- as.data.frame(validation_data_table)
      validation_data_table <- na.omit(validation_data_table)

      # Format final validation report
      final_validation_file <- as.data.frame(cbind(validation_data_table$X,
                                                   validation_data_table$Y,
                                                   validation_data_table$Year,
                                                   validation_data_table$Biweek,
                                                   validation_data_table$NASMD_SM,
                                                   validation_data_table$validation_output,
                                                   validation_data_table$Region,
                                                   validation_data_table$Method,
                                                   validation_data_table$Resolution))

      names(final_validation_file) <- c("X", "Y", "Year", "Biweek", "NASMD_ref",
                                        "ESACCI_SM", "Region", "Method", "Resolution")

      final_validation_file$NASMD_ref <- as.numeric(as.character(final_validation_file$NASMD_ref))
      final_validation_file$ESACCI_SM <- as.numeric(as.character(final_validation_file$ESACCI_SM))

      # Save validation report to CSV
      csv_file <- paste0("./5_NorthAmerica_prediction_outputs_250m_v92/3_Validation_reports/2_Ground_truth_validation/1_ESACCI_reference/",
                         years[i], "/northamerica_esacci_v92_250m_groundtruth_validation_",
                         years[i], "_", biweeks[j], ".csv")
      write.csv(final_validation_file, file = csv_file)

      # Add biweekly validation report to summary report
      validation_report_temp <- matrix(data = NA, nrow = 0, ncol = 8)
      validation_report_temp <- as.data.frame(validation_report_temp)
      names(validation_report_temp) <- c("Region", "Method", "Resolution", "Year",
                                         "Biweek", "No.Points", "Correl", "RMSE")

      validation_report_temp[1, 1] <- "North America"
      validation_report_temp[1, 2] <- "ESACCI_reference"
      validation_report_temp[1, 3] <- "0.25 deg"
      validation_report_temp[1, 4] <- years[i]
      validation_report_temp[1, 5] <- biweeks[j]
      validation_report_temp[1, 6] <- length(final_validation_file$Year)
      validation_report_temp[1, 7] <- cor(final_validation_file$NASMD_ref,
                                          final_validation_file$ESACCI_SM,
                                          use = "pairwise.complete.obs")
      validation_report_temp[1, 8] <- rmse(final_validation_file$NASMD_ref,
                                           final_validation_file$ESACCI_SM)

      validation_report_final <- rbind(validation_report_final,
                                       validation_report_temp)

      print(paste0(years[i], "  ", biweeks[j]))
    }
  }
}

# Save summary report to CSV
report_file <- "./5_NorthAmerica_prediction_outputs_250m_v92/3_Validation_reports/2_Ground_truth_validation/1_ESACCI_reference/northamerica_esacci_v92_250m_groundtruth_validation.csv"
write.csv(validation_report_final, file = report_file)



# Get biweekly soil moisture files and IMSN biweekly files
raster_files <- list.files(path = "./2_NA_mosaics",
                           pattern = ".tif", full.names = TRUE,
                           recursive = TRUE)

ismn_files <- list.files(path = "./1_Preprocessed_data/7_ISMN_validation/3_ismn_biweekly_means_northamerica",
                         pattern = ".csv", full.names = TRUE, recursive = TRUE)

# Initialize summary report table
validation_report_final <- matrix(data = NA, nrow = 0, ncol = 8)
validation_report_final <- as.data.frame(validation_report_final)
names(validation_report_final) <- c("Region", "Method", "Resolution", "Year",
                                    "Biweek", "No.Points", "Correl", "RMSE")

for (i in 1:length(years)) {
  # Filter rasters and CSVs to year
  raster_files_year <- raster_files[grep(years_file[i], raster_files)]
  ismn_files_year <- ismn_files[grep(years_file[i], ismn_files)]

  for (j in 1:length(biweeks)) {
    # Filter rasters and CSVs to biweek
    raster_file_biweek <- raster_files_year[grep(biweeks_file[j], raster_files_year)]
    raster_file_biweek <- as.list(raster_file_biweek)
    ismn_file_biweek <- ismn_files_year[grep(biweeks_file[j], ismn_files_year)]
    ismn_file_biweek <- as.list(ismn_file_biweek)

    if (length(raster_file_biweek) > 0 && length(ismn_file_biweek) > 0) {
      # Load biweekly raster
      x <- raster(raster_file_biweek[[1]])

      # Format validation data frame
      validation_data <- read.csv(ismn_file_biweek[[1]],
                                  header = TRUE, dec = ".")
      validation_data <- as.data.frame(cbind(validation_data$Longitude,
                                             validation_data$Latitude,
                                             validation_data$mean_sm_depth_5cm))
      validation_data$Year <- years[i]
      validation_data$Biweek <- biweeks[j]
      validation_data$Region <- "North America"
      validation_data$Method <- "RF"
      validation_data$Resolution <- "250m"
      names(validation_data) <- c("X", "Y", "NASMD_SM", "Year", "Biweek",
                                  "Region", "Method", "Resolution")

      # Extract coordinate columns from data
      validation_data <- as.data.frame(validation_data, xy = TRUE)
      xy_ <- validation_data[, c(1, 2)]

      # Convert validation data to spatial data
      crs_proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
      validation_data <- SpatialPointsDataFrame(coords = xy_, data = validation_data,
                                                proj4string = CRS(crs_proj))

      validation_output <- extract(x, validation_data)

      # Format validation data to a data frame
      validation_data_table <- as.data.frame(validation_data)
      validation_data_table <- cbind(validation_data_table, validation_output)
      validation_data_table <- as.data.frame(validation_data_table)
      validation_data_table <- na.omit(validation_data_table)

      final_validation_file <- as.data.frame(cbind(validation_data_table$X,
                                                   validation_data_table$Y,
                                                   validation_data_table$Year,
                                                   validation_data_table$Biweek,
                                                   validation_data_table$NASMD_SM,
                                                   validation_data_table$validation_output,
                                                   validation_data_table$Region,
                                                   validation_data_table$Method,
                                                   validation_data_table$Resolution))

      names(final_validation_file) <- c("X", "Y", "Year", "Biweek", "NASMD_ref",
                                        "SoilMoist_Pred", "Region", "Method", "Resolution")

      final_validation_file$NASMD_ref <- as.numeric(as.character(final_validation_file$NASMD_ref))
      final_validation_file$SoilMoist_Pred <- as.numeric(as.character(final_validation_file$SoilMoist_Pred))

      # Write validation report to CSV
      csv_file <- paste0("./5_NorthAmerica_prediction_outputs_250m_v92/3_Validation_reports/2_Ground_truth_validation/2_RandomForest_predictions/",
                         years[i], "/northamerica_rf_v92_250m_groundtruth_validation_",
                         years[i], "_", biweeks[j], ".csv")
      write.csv(final_validation_file, file = csv_file)

      # Add biweekly report to summary report
      validation_report_temp <- matrix(data = NA, nrow = 0, ncol = 8)
      validation_report_temp <- as.data.frame(validation_report_temp)
      names(validation_report_temp) <- c("Region", "Method", "Resolution", "Year",
                                         "Biweek", "No.Points", "Correl", "RMSE")

      validation_report_temp[1, 1] <- "North America"
      validation_report_temp[1, 2] <- "RF"
      validation_report_temp[1, 3] <- "250m"
      validation_report_temp[1, 4] <- years[i]
      validation_report_temp[1, 5] <- biweeks[j]
      validation_report_temp[1, 6] <- length(final_validation_file$Year)
      validation_report_temp[1, 7] <- cor(final_validation_file$NASMD_ref,
                                          final_validation_file$SoilMoist_Pred,
                                          use = "pairwise.complete.obs")
      validation_report_temp[1, 8] <- rmse(final_validation_file$NASMD_ref,
                                           final_validation_file$SoilMoist_Pred)

      validation_report_final <- rbind(validation_report_final,
                                       validation_report_temp)

      print(paste0(years[i], "  ", biweeks[j]))
    }
  }
}

# Save summary report to CSV
report_file <- "./5_NorthAmerica_prediction_outputs_250m_v92/3_Validation_reports/2_Ground_truth_validation/2_RandomForest_predictions/northamerica_rf_v92_250m_groundtruth_validation.csv"
write.csv(validation_report_final, file = report_file)
