*The section numbers in this document match the numbers of the scripts they describe within the preprocessing stage of the NASMo-TiAM v2 250m workflow.*

# 2 Data Preprocessing
In this stage, all input data are standardized to the same spatial and temporal characteristics: a 250 m cell size and 16-day (biweekly) time steps aligned with the MODIS Terra NDVI (MOD13Q1) composite schedule, which begins on January 1 each year and yields 23 biweekly periods per year. Between June 26, 2002, and December 31, 2024, this results in 518 biweekly periods. Static covariates are processed in the Lambert Azimuthal Equal Area (LAEA) projection. Once resolution and projection are standardized, all preprocessed layers are reprojected to the ESA CCI coordinate reference system (WGS84) before model training.

## 2.1 ESA CCI Soil Moisture Data
**Calculation of biweekly means (16-days periods)**

This part of the process imports the ESA-CCI version 09.2 combined (active-passive) daily soil moisture estimates, crops, and masks the data to the North American region, then it calculates biweekly means and export them to TIFF format.
* Periods are defined based on the dates of MODIS NDVI (MOD13Q1) products 16-days composites (starting on January 1)
* File Format = NetCDF (.nc)
* Input spatial resolution = 0.25 degrees
* Output spatial resolution = 0.25 degrees
* Input projection = WGS84
* Output projection = WGS84

## 2.2 Terrain Parameters Calculation
### 2.2.1 Assembly of Digital Elevation Model (DEM) for North America
This part of the process imports the mean elevation layers from the GMTED2010 DEM tiles at 7.5 arc-second (WGS84), reprojects the tiles to Lambert Azimuthal Equal Area (LAEA) projection at 250 meters, and creates a mosaic cropped and masked to the North American region.
#### 2.2.1.1 DEM Tiles reprojection
Reprojection from WGS84 (geographic coordinates) to LAEA (metric coordinates).
* This step is necessary to calculate terrain parameters in RSAGA.
* The reference raster file in LAEA and 250 meters is the [Land Cover map of North America 2010](http://www.cec.org/north-american-environmental-atlas/land-cover-2010-modis-250m/) map, published by the Commission for Environmental Cooperation.
#### 2.2.1.2 DEM Tiles Mosaic
Mosaic of all reprojected tiles into a single North American Mosaic.
* All tiles are in the LAEA projection with a 250 meters cell size.
#### 2.2.1.3 Masking to the region of interest
Masking of North American DEM mosaic.
* The output keeps data only within the North America boundary.
* This process was done in ArcGIS using the **"Extract by Mask"** tool for performance.
### 2.2.2 Calculation of Terrain Parameters
#### 2.2.2.1 Calculation of Terrain Parameters
This part of the process calculates 15 terrain parameters using the “Basic Terrain Analysis” tool in the “TA compound analysis” module of RSAGA, which implements SAGA GIS in R.

Terrain parameters calculated.
1.	Analytical Hillshading
2.	Aspect
3.	Channel Network Base Level
4.	Vertical Distance to Channel Network
5.	Flow Accumulation
6.	Convergence Index
7.	Elevation
8.	Length-Slope Factor
9.	Longitudinal Curvature
10.	Cross Sectional Curvature
11.	Relative Slope Position
12.	Slope
13.	Topographic Wetness Index
14.	Catchment Area
15.	Valley Depth
    
-	The DEM must be in a projection with metric units (e.g., LAEA).
-	Once the parameters are calculated, each output raster must be reprojected to WGS84 to match the ESA-CCI biweekly means created in script 2.1
-	This process takes about 4-5 days to finish in a computer with an Intel(R) Core(TM) i7-10700K CPU @ 3.80GHz 3.79 GHz processor, 16 cores and 64 GB of Installed RAM.

#### 2.2.2.2 Reprojection of Terrain Parameters
This section reprojects all terrain parameters, including elevation, back to the WGS84 and conversts the file format from SDAT to GeoTIFF.
* The reprojection uses the proj4string for WGS84.
* This process was done in ArcGIS Pro using the **Project Raster** tool for performance and to preserve the cell size. A reference shapefile in WGS84 is used to define the output projection.
## 2.3 Bulk Density
This section takes all 0–5 cm depth bulk density global tiles available from SoilGrids, creates a global mosaic, crops it to the North American region, and reprojects and resamples the data to the same coordinate reference system and cell size as the preprocessed terrain parameters.
* The global Bulk Density mosaic is assembled in the native SoilGrids Interrupted Goode Homolosine projection.
* SoilGrids maps are delivered at a 250 m cell size.
* Bulk density is expensed in cg/cm³.
* Once the global mosaic is generated, it is cropped to the North American region, then reprojected and resampled to WGS84 using the cell size of the preprocessed terrain parameters.
* The crop, mask, and reprojection are done in ArcGIS Pro using the **Project Raster** tool for performance. The final preprocessed elevation layer in WGS84 is used as the reference for projection and cell size, while the North America WGS84 shapefile is used to crop and mask the data.
## 2.4 NDVI Data Preparation (MOD13Q1 and MYD13Q1)
### 2.4.1 Extraction of NDVI layers from MODIS HDF files and export to TIF format
This section reads the 16-days MOD13Q1 and MYD13Q1 composites in their native HDF format, extracts the NDVI layer, and exports it to TIF format.
* MODIS tiles are in sinusoidal projection.
* MODIS NDVI native spatial resolution is ~250 meters.
### 2.4.2 NDVI North America Mosaics
This section takes the MOD13Q1 and MYD13Q1 NDVI tiles in TIF format and assembles North American mosaics in the  native Sinusoidal projection. It then reprojects and resamples the mosaics.
* Mosaics are reprojected from the Sinusoidal projection to LAEA with a 250 m cell size.
* Reprojection to LAEA is done in ArcGIS Pro using the **Project Raster** and **Clip Raster** tools.
### 2.4.3 Calculation of NDVI Biweekly layers
This section merges the MOD13Q1 (Terra, starting January 1) and MYD13Q1 (Aqua, starting January 9) NDVI layers, which are offset by 8 days, into combined biweekly NDVI means aligned with the MOD13Q1 dates. The combined layers are then masked to the North American region and reprojected and resampled to WGS84 using the same cell size as the preprocessed terrain parameters.
* Output = 518 biweekly NDVI layers (23 per year) from June 2002 to December 2024.
* Output values are converted to the valid NDVI range (-1 to 1) using a scale factor of 0.0001, as indicated in the MOD13Q1 and MYD13Q1 documentation.
* The combined NDVI layers are named MCD13Q1.
* Crop and mask are done in ArcGIS Pro using the **Extract by Mask** tool.
* Reprojection to WSGS84 is done in ArcGIS using the **Project Raster** and **Clip Raster** tools.
## 2.5 Land Surface Temperature Data Preparation (MOD11A2 and MYD11A2)
### 2.5.1 Extraction of LST layers from MODIS HDF files and export to TIF format
This section reads the 8-day MOD11A2 and MYD11A2 composites in their native HDF format, extracts the LST layer, and exports it to TIF format.
* MODIS tiles are in sinusoidal projection.
* MODIS LST native spatial resolution is ~1,000 m.
### 2.5.2 LST North America Mosaics
This section takes the MOD11A2 and MYD11A2 LST tiles in TIF format and assembles North American mosaics in the native Sinusoidal projection. It then reprojects and resamples the mosaics.
* LST values are converted to Kelvin using a scale factor of 0.02, as indicated in the MOD11A2 and MYD11A2 documentation.
* Mosaics are reprojected from the Sinusoidal projection to LAEA and resampled from ~1,000 m to a 250 m cell size.
* Reprojection to LAEA is done in ArcGIS Pro using the **Project Raster** and **Clip Raster** tools.
### 2.5.3 Calculation of LST Biweekly layers
This section merges the 8-day MOD11A2 and MYD11A2 LST mosaics into combined biweekly LST means. For each 16-day period, four 8-day layers (two Terra and two Aqua) are averaged to match the dates of the MOD13Q1 NDVI composites. The combined layers are then masked to the North American region and reprojected and resampled to WGS84 using the same cell size as the preprocessed terrain parameters.
* Output = 518 biweekly LST layers (23 per year) from June 2002 to December 2024.
* The combined LST layers are named MCD11A2.
* Crop and mask are done in ArcGIS using the **Extract by Mask** tool in ArcGIS.
* Reprojection to WSGS84 is done in ArcGIS Pro using the **Project Raster** and **Clip Raster** tools.
## 2.6 Snow Cover Masks Preparation (MOD10A2 and MYD10A2)
Snow cover masks are used to exclude areas where snow, ice, or frozen soil make ESA CCI soil moisture estimates highly uncertain. This prevents model training and predictions over those areas for each 16-day period.
### 2.6.1 Extraction of Snow Cover layers from MODIS HDF files and export to TIF format
This section reads the 8-day MOD10A2 and MYD10A2 composites in their native HDF format, extracts the snow cover layer, and exports it to TIF format.
* MODIS tiles are in sinusoidal projection.
* MODIS snow cover native spatial resolution is ~500 m.
### 2.6.2 Snow Cover North America Mosaics
This section takes the MOD10A2 and MYD10A2 snow cover tiles in TIF format and assembles North American mosaics in the native Sinusoidal projection. It then reprojects and resamples the mosaics.
* Pixel values in the 8-day snow cover mosaics describe different snow, ice, and water conditions:
    0=missing data, 1=no decision, 11=night, 25=no snow, 37=lake, 39=ocean, 50=cloud, 100=lake ice, 200=snow, 254=detector saturated, 255=fill
* Mosaics are reprojected from the Sinusoidal projection to LAEA and resampled from ~500 m to a 250 m cell size.
* Reprojection to LAEA is done in ArcGIS Pro using the **Project Raster** and **Clip Raster** tools.
### 2.6.3 Calculation of Snow Cover Biweekly layers
This section merges the 8-day MOD10A2 and MYD10A2 snow cover mosaics into combined 16-day snow cover layers matching the dates of the NDVI and LST biweekly layers. The combined layers are reclassified into two-class masks, where snow- and ice-covered areas are masked out and all other areas remain as valid data. The masks are then cropped to the North American region and reprojected and resampled to WGS84 using the same cell size as the preprocessed terrain parameters.
* Snow&ice-covered areas are classified as 0 (masked).
* All other areas are classified as 1 (valid data).
* Output = 518 biweekly snow cover masks from June 2002 to December 2024.
* The combined snow cover layers are named MCD10A2
* Crop and mask are done in ArcGIS Pro using the **Extract by Mask** tool.
* Reprojection to WGS84 is done in ArcGIS Pro using the **Project Raster** and **Clip Raster** tools.
## 2.7	ISMN (Ground-Truth) Validation Data
**Calculation of biweekly soil moisture means from the ISMN**
This section takes the soil moisture ground-truth records downloaded from International Soil Moisture Network (ISMN) stations across North America and calculates biweekly soil moisture means for each station. These data are used only to validate the final product, not for model training.
* The first part of the script extracts valid soil moisture entries (flagged as "Good") from the ISMN station data, keeping only records at 0–5 cm depth from 2002 to 2024.
* The second part computes biweekly soil moisture means for each station as the arithmetic mean of hourly records within each 16-day period, using the same dates as the preprocessed prediction covariates. A total of 90,510 biweekly points are generated across up to 653 stations.
* The last part splits the biweekly means into CSV files organized by year and biweekly period (518 files in total).
