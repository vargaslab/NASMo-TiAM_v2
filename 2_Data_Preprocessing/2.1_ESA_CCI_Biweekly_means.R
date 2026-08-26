#NORTH AMERICA SOIL MOISTURE DATASET DERIVED FROM TIME-SPECIFIC ADAPTABLE MODELS

  #2. Data Preprocessing

###2.1 Calculation of ESA-CCI soil moisture v9.2 biweekly means for the North American region

#This part of the process imports the ESA-CCI version 9.2 soil moisture estimates, crops,
#and masks the data to the North American region, then it calculates biweekly means and 
#export them to TIFF format.

##Libraries

library(raster)
library(ncdf4)
library(RColorBrewer)

##Config

# Declare directory for storing temporary files
rasterOptions(tmpdir = "./R_tempdirs/", progress = "text", timer = TRUE)

# Set working directory
setwd("./3_North_America_SM_predictions")

##Main

NorthAmerica_boundary <- shapefile("./0_Input_data/0_NorthAmerica_boundary_and_reference_raster/00_northamerica_region_interest_wgs84.shp")

esa_cci_files <- list.files(path = "./0_Input_data/1_ESA_CCI_v92_2002_2024", full.names = TRUE, recursive = TRUE)

years <- c("/2002/","/2003/","/2004/","/2005/","/2006/","/2007/","/2008/","/2009/","/2010/","/2011/","/2012/","/2013/",
           "/2014/","/2015/","/2016/","/2017/","/2018/","/2019/","/2020/","/2021/","/2022/","/2023/","/2024/")

biweeks <- c("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23")


for (i in 1:length(years)) {
  # Filter to ESA CCI files for specific year
  esa_cci_files_year <- esa_cci_files[grep(years[i], esa_cci_files)]

  for (j in 1:length(biweeks)) {
    # Filter to ESA CCI files for specific biweek
    esa_cci_files_biweek <- esa_cci_files_year[grep(paste0("biweek_", biweeks[j]), esa_cci_files_year)]

    # Load each ESA CCI file and crop to NA extents
    base_raster <- stack(esa_cci_files_biweek[[1]], varname = "sm")
    base_raster <- crop(base_raster, extent(c(-179.1307, -52.66177, 12.53339, 85.11045)))
    for (k in 2:length(esa_cci_files_biweek)) {
      daily_raster <- stack(esa_cci_files_biweek[[k]], varname = "sm")
      daily_raster <- crop(daily_raster, extent(c(-179.1307, -52.66177, 12.53339, 85.11045)))

      # Stack each file in biweek together
      base_raster <- stack(base_raster, daily_raster)

      print(k)
    }

    # Compute mean of all files in biweek and mask to NA boundary
    biweekly_sm <- calc(base_raster, mean, na.rm = TRUE)
    biweekly_sm <- mask(biweekly_sm, NorthAmerica_boundary)

    # Write results to GeoTIFF
    writeRaster(biweekly_sm, filename = paste0("./1_Preprocessed_data/1_ESACCI_SM_v92_biweekly_means/northamerica_esacci_92_", 
                                               substr(years[i],2,5), "_biweek_", biweeks[[j]], ".tif"), overwrite = TRUE)

    print(paste0(substr(years[i],2,5), "  ", biweeks[[j]]))

    # Store biweekly mean data in a plot
    my.palette <- brewer.pal(n = 11, name = "RdYlBu")
    png(paste0("./1_Preprocessed_data/1_ESACCI_SM_v92_biweekly_plots/northamerica_esacci_92_", substr(years[i],2,5), "_biweek_", biweeks[[j]], ".png"))
    plot(biweekly_sm, main = (paste0(substr(years[i],2,5), " biweek ", biweeks[j])), 
         sub = expression(Biweekly ~ Soil ~ Moisture ~ m^3~"/"~m^-3),
         col = my.palette, legend = T)
    plot(NorthAmerica_boundary, lwd = 0.2, add = TRUE)
    dev.off()
  }

  # Temp file cleanup
  gc()
  removeTmpFiles(h=0.01)

  print(substr(years[i],2,5))
}
