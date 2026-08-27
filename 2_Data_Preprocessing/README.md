*The section numbers in this document match the numbers of the codes they describe within the preprocessing stage of the NASMo-TiAM 250m workflow.*

# 2 Data Preprocessing
## 2.1 ESA CCI Soil Moisture Data
**Calculation of biweekly means (16-days periods)**

This part of the process imports the ESA-CCI version 9.2 soil moisture estimates, crops, and masks the data to the North American region, then it calculates biweekly means and export them to TIFF format.
* Periods are defined based on the dates of MODIS NDVI products 16-days composites
* File Format = NC
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
* The reference raster file in LAEA and 250 meters is the [Land Cover map of North America 2010](http://www.cec.org/north-american-environmental-atlas/land-cover-2010-modis-250m/), published by the Commission for Environmental Cooperation.
#### 2.2.1.2 DEM Tiles Mosaic
Mosaic of all reprojected tiles into a North American Mosaic.
* All tiles are in Lambert Azimuthal Area projection and 250 meters cell size.
#### 2.2.1.3 Masking to the region of interest
Masking of North American DEM mosaic.
* The output keeps data only within the North America boundary.
* This process was done in ArcGIS using the **"Extract by Mask"** tool for performance.
### 2.2.2 Calculation of Terrain Parameters
#### 2.2.2.1 Calculation of Terrain Parameters
This part of the process calculates 15 terrain parameters using the “Basic Terrain Analysis” tool in the “TA compound analysis” of RSAGA.

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
-	The DEM must be in a projection based on metric units (e.g., LAEA).
-	Once the parameters are calculated, each raster output must be reprojected to WGS84 to be comparable with the ESA-CCI biweekly means created in script 2.1
-	This process takes about 4-5 days to finish in a computer with an Intel(R) Core(TM) i7-10700K CPU @ 3.80GHz 3.79 GHz processor, 16 cores and 64 GB of Installed RAM.
#### 2.2.2.2 Reprojection of Terrain Parameters
This part reprojects all terrain parameters including elevation back to the WGS84 projection and change the file format from SDAT to GeoTIFF.
* The reprojection is done using the proj4string for WGS84.
* This process was done in ArcGIS using the **"Project Raster"** tool for performance and cell size preservation. A reference shapefile with WGS84 projection is used to get projection.
## 2.3 Bulk Density
This section takes all 0-5cm depth Bulk Density global tiles available in the Soil Grids system, creates a global mosaic, crops the data to the North America region, runs a reprojection and resample the data to the same coordinate reference system and cell size as the ESA-CCI preprocessed biweekly means and the preprocessed terrain parameters.
* The global Bulk Density Mosaic is performed using the native SoilGrids Homolosine projection.
* SoilGrids maps are delivered at a cell size of 250 meters.
* Bulk density is expensed in cg/cm³.
* Once the global mosaic is generated in Homolosine projection, it is cropped to the North America region, then reprojected and resampled using the WGS84 reference system and cell size of the preprocessed ESA-CCI biweekly means.
* The crop, mask, and reprojection is done in ArcGIS using the **"Project Raster"** tool for performance. The final preprocessed elevation data in WGS84 projection is used for the projection and cell size, while the NA WGS84 shapefile is used for crop and masking of the data.
## 2.4 NDVI Data Preparation (MOD13Q1 and MYD13Q1)
### 2.4.1 Extraction of NDVI layers from MODIS HDF files and export to TIF format
This section of the process reads the 16-days MOD13Q1 and MYD13Q1 composites in their native HDF format, extracts the layer with the NDVI information and exports it to TIF format.
* MODIS tiles are in sinusoidal projection.
* MODIS NDVI native spatial resolution is ~250 meters.
### 2.4.2 NDVI North America Mosaics
This section of the process takes the MOD13Q1 and MYD13Q1 NDVI tiles in TIF format and assembles a mosaic for the North America region in the native Sinusoidal projection. Then reprojects and resamples the mosaics.
* Reprojection and resampling to transform the mosaics from Sinusoidal projection to LAEA projection with 250 meters cell size.
* Reprojection to LAEA done with ArcGIS using the **Project Raster** and **Clip Raster** tool in ArcGIS.
### 2.4.3 Calculation of NDVI Biweekly layers
This section merges the 8-days lagged MOD13Q1 and MYD13Q1 NDVI layers into combined biweekly NDVI means. The combined layers are thereafter masked to the North America region, reprojected, and resampled to WGS84, setting the same coordinate reference system and cell size as the ESA-CCI preprocessed biweekly means and the preprocessed terrain parameters.
* The values in the output biweekly NDVI layers are transformed into meaningful NDVI value ranges (-1 to 1) using a scale factor of 0.0001 (as indicated in the MOD13Q1 and MYD13Q1 documentation).
* The combined NDVI layers are named MCD13Q1.
* Crop and mask done with ArcGIS using the **Extract by Mask** tool in ArcGIS.
* Reprojection to WSGS84 done with ArcGIS using the **Project Raster** and **Clip Raster** tool in ArcGIS.
## 2.5 Land Surface Temperature Data Preparation (MOD11A2 and MYD11A2)
### 2.5.1 Extraction of LST layers from MODIS HDF files and export to TIF format
This section of the process reads the 8-days MOD11A2 and MYD11A2 composites in their native HDF format, extracts the layer with the LST information and exports it to TIF format.
* MODIS tiles are in sinusoidal projection.
* MODIS LST native spatial resolution is ~1,000 meters.
### 2.5.2 LST North America Mosaics
This section of the process takes the MOD11A2 and MYD11A2 LST tiles in TIF format and assembles a mosaic for the North America region in the native Sinusoidal projection. Then reprojects and resamples the mosaics.
* The values in the output biweekly LST layers are converted to Kelvin degrees using a scale factor of 0.02 (as indicated in the MOD11A2 and MYD11A2 documentation).
* Reprojection and resampling to transform the mosaics from Sinusoidal projection to LAEA projection with 250 meters cell size.
* Reprojection to LAEA done with ArcGIS using the **Project Raster** and **Clip Raster** tool in ArcGIS.
### 2.5.3 Calculation of LST Biweekly layers
This section merges the 8-days MOD11A2 and MYD11A2 LST composites into combined biweekly LST means. The combined layers are thereafter masked to the North America region, reprojected, and resampled to WGS84, setting the same coordinate reference system and cell size as the ESA-CCI preprocessed biweekly means and the preprocessed terrain parameters.
* The combined LST layers are named MCD11A2.
* Crop and mask done with ArcGIS using the **Extract by Mask** tool in ArcGIS.
* Reprojection to WSGS84 done with ArcGIS using the **Project Raster** and **Clip Raster** tool in ArcGIS.
## 2.6 Snow Cover Masks Preparation (MOD10A2 and MYD10A2)
### 2.6.1 Extraction of Snow Cover layers from MODIS HDF files and export to TIF format
This section of the process reads the 8-days MOD10A2 and MYD10A2 composites in their native HDF format, extracts the layer with the Snow Cover information and exports it to TIF format.
* MODIS tiles are in sinusoidal projection.
* MODIS LST native spatial resolution is ~500 meters.
### 2.6.2 Snow Cover North America Mosaics
This section of the process takes the MOD10A2 and MYD10A2 LST tiles in TIF format and assembles a mosaic for the North America region in the native Sinusoidal projection. Then reprojects and resamples the mosaics.
* The values in the output biweekly Snow Cover layers describe different snow, ice, and water coverages.

    0=missing data, 1=no decision, 11=night, 25=no snow, 37=lake, 39=ocean, 50=cloud, 100=lake ice, 200=snow, 254=detector saturated, 255=fill
* Reprojection and resampling to transform the mosaics from Sinusoidal projection to LAEA projection with 250 meters cell size.
* Reprojection to LAEA done with ArcGIS using the **Project Raster** and **Clip Raster** tool in ArcGIS.
### 2.6.3 Calculation of Snow Cover Biweekly layers
This section merges the 8-days MOD10A2 and MYD10A2 Snow Cover composites into combined biweekly Snow Cover means. The values in the combined layers are reclassified to assign 0 to snow areas and 1 to the rest of the areas. The combined layers are thereafter masked to the North America region, reprojected, and resampled to WGS84, setting the same coordinate reference system and cell size as the ESA-CCI preprocessed biweekly means and the preprocessed terrain parameters.
* Snow covered areas are classified as 0
* All no snow-covered areas are classified as 1
* The combined Snow Cover layers are named MCD10A2
* Crop and mask done with ArcGIS using the **Extract by Mask** tool in ArcGIS.
* Reprojection to WSGS84 done with ArcGIS using the **Project Raster** and **Clip Raster** tool in ArcGIS.
## 2.7	ISMN (Ground-Truth) Validation Data
**Calculation of biweekly soil moisture means from the ISMN**

This section of the code takes downloaded soil moisture ground-truth records from the International Soil Moisture Network (ISMN) stations that are distributed across the North America and creates biweekly soil moisture means across each station.
* This first part of the script extracts valid soil moisture entries from station data downloaded from the ISMN.
* The second part of the script computes biweekly means for soil moisture for each unique station. A total of 90,510 biweekly points were generated.
* The last part of the script splits the computed biweekly means into CSV files organized by unique year and biweek.
