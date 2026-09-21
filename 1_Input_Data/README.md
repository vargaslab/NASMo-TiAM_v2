# 1 Input Data Collection
In the first stage of the workflow, we collect satellite-derived soil moisture reference data and static and dynamic ancillary data to build the set of prediction covariates for NASMo-TiAM v2 250 m. The table below summarizes all data sources.
| Input Type | Data Source | Data Type | Input Spatial Resolution | Input Temporal Resolution | Time Frame |
|---|---|---|---|---|---|
| Reference Data | ESA CCI Soil Moisture | Soil Moisture | 0.25° (~27 km) | Daily | 2002–2024 |
| Static Covariates | GMTED2010 | DEM | 7.5 arc-second (~231 m) | — | — |
| | SoilGrids | Bulk Density | 250 m | — | — |
| Dynamic Covariates | MODIS Terra | NDVI (MOD13Q1) | 250 m | 16-day | 2002–2024 |
| | | LST (MOD11A2) | 1,000 m | 8-day | 2002–2024 |
| | MODIS Aqua | NDVI (MYD13Q1) | 250 m | 16-day | 2002–2024 |
| | | LST (MYD11A2) | 1,000 m | 8-day | 2002–2024 |
| Dynamic Masks | MODIS Terra | Snow Cover (MOD10A2) | 500 m | 8-day | 2002–2024 |
| | MODIS Aqua | Snow Cover (MYD10A2) | 500 m | 8-day | 2002–2024 |
| Validation Data | ISMN | Ground-Truth Soil Moisture | Point Records | Hourly | 2002–2024 |
## 1.1 Soil Moisture Reference Data
[European Space Agency Climate Change Initiative (ESA CCI)](https://climate.esa.int/en/projects/soil-moisture/data/) soil moisture, version 09.2
* Combined (active and passive) soil moisture daily estimates
* Spatial Resolution = 0.25 degrees (~27 km)
* File Format = NetCDF (.nc)
* Projection = WGS84
* Time frame = June 26, 2002, to December 31, 2024 (8,225 daily estimates)
## 1.2 Prediction Covariates
### 1.2.1 Static Covariates
#### 1.2.1.1 Elevation Data
[Global Multi-resolution Terrain Elevation Data (GMTED2010)](https://www.usgs.gov/centers/eros/science/usgs-eros-archive-digital-elevation-global-multi-resolution-terrain-elevation#overview)
* 19 tiles of mean elevation (the tiles folders contain other elevation values such as maximum elevation, minimum, median, standard deviation) covering North America
* Spatial Resolution = 7.5 arc-second (~231 m)
* File Format = TIF
* Projection = WGS84
* Units (elevation) = meters
#### 1.2.1.2 Bulk Density Data
[Soil Grids global Bulk Density](https://data.isric.org/geonetwork/srv/api/records/713396f9-1687-11ea-a7c0-a0481ca9e724)
* 1,128 tiles for global coverage
* 0-5 cm depth bulk density modeled values
* Spatial Resolution = 250 m
* File Format = TIF
* Projection = Interrupted Goode Homolosine
* Units = cg/cm3
### 1.2.2 Dynamic Covariates
Data from the NASA EOSDIS Land Processes Distributed Active Archive Center (LP DAAC).
#### 1.2.2.1 Normalized Difference Vegetation Index (NDVI)
[MOD13Q1 (Modis Terra NDVI)](https://www.earthdata.nasa.gov/data/catalog/lpcloud-mod13q1-061)
* Repository = NASA Earthdata Search (LP DAAC)
* Data available since 2000
* 23 16-days composites per year (starting on January 1)
* Up to 52 tiles covering the North American region. Not all the tiles have data for every 16-days composites, data are scarce in arctic regions during winter periods.
* 25,250 files collected from 2000 to 2024
* Tile dimensions = 1,200 x 1,200 km
* Version = 6.1
* Spatial Resolution = 250 m
* File Format = HDF (Hierarchical Data Format)
* Projection = Sinusoidal
[MYD13Q1 (Modis Aqua NDVI)](https://www.earthdata.nasa.gov/data/catalog/lpcloud-myd13q1-061)
* Repository = NASA Earthdata Search (LP DAAC)
* Data available since mid-2002
* 23 16-days composites per year (starting on January 9)
* Up to 52 tiles covering the North American region. Not all the tiles have data for every 16-days composites, data are scarce in arctic regions during winter periods.
* 23,627 files collected from 2002 to 2024
* Tile dimensions = 1,200 x 1,200 km
* Version = 6.1
* Spatial Resolution = 250 m
* File Format = HDF (Hierarchical Data Format)
* Projection = Sinusoidal
#### 1.2.2.2 Land Surface Temperature (LST)
[MOD11A2 (Modis Terra LST)](https://www.earthdata.nasa.gov/data/catalog/lpcloud-mod11a2-061)
* Repository = NASA Earthdata Search (LP DAAC)
* Data available since 2000
* 46 8-days composites per year (starting on January 1)
* Up to 52 tiles covering the North American region. Not all the tiles have data for every 8-days composites, data are scarce in arctic regions during winter periods.
* 51,375 files collected from 2000 to 2024
* Tile dimensions = 1,200 x 1,200 km
* Version = 6.1
* Spatial Resolution = 1,000 m
* File Format = HDF (Hierarchical Data Format)
* Projection = Sinusoidal
[MYD11A2 (Modis Aqua LST)](https://www.earthdata.nasa.gov/data/catalog/lpcloud-myd11a2-061)
* Repository = NASA Earthdata Search (LP DAAC)
* Data available since mid-2002
* 46 8-days composites per year (starting on January 1)
* Up to 52 tiles covering the North American region. Not all the tiles have data for every 8-days composites, data are scarce in arctic regions during winter periods.
* 46,530 files collected from 2002 to 2024
* Tile dimensions = 1,200 x 1,200 km
* Version = 6.1
* Spatial Resolution = 1,000 m
* File Format = HDF (Hierarchical Data Format)
* Projection = Sinusoidal
### 1.2.3 Dynamic Masks
#### 1.2.3.1 Snow Cover Extent
[MOD10A2 (Modis Terra Snow Cover)](https://www.earthdata.nasa.gov/data/catalog/nsidc-cprd-mod10a2-61)
* Repository = NASA Earthdata Search (NSIDC DAAC)
* Data available since 2000
* 46 8-days composites per year (starting on January 1)
* Up to 52 tiles covering the North American region. Not all the tiles have data for every 8-days composites, data are scarce in arctic regions during winter periods.
* 50,148 files collected from 2000 to 2024
* Tile dimensions = 10 x 10 degrees
* Version = 6.1
* Spatial Resolution = 500 m
* File Format = HDF (Hierarchical Data Format)
* Projection = Sinusoidal
[MYD10A2 (Modis Aqua Snow Cover)](https://www.earthdata.nasa.gov/data/catalog/nsidc-cprd-myd10a2-61)
* Repository = NASA Earthdata Search (NSIDC DAAC)
* Data available since mid-2002
* 46 8-days composites per year (starting on January 1)
* Up to 52 tiles covering the North American region. Not all the tiles have data for every 8-days composites, data are scarce in arctic regions during winter periods.
* 45,440 files collected from 2002 to 2024
* Tile dimensions = 10 x 10 degrees
* Version = 6.1
* Spatial Resolution = 500 m
* File Format = HDF (Hierarchical Data Format)
* Projection = Sinusoidal
## 1.3 Soil Moisture Ground Truth Data
[International Soil Moisture Network (ISMN)](https://ismn.earth/en/)
* Internationally available soil moisture data from a variety of station networks
* Data available since 1950
* Temporal resolution variable by network/station
* Soil depth variable by network/station (from 0-255cm)
* Spatial Resolution = Point (Coordinate)
* File Format = CSV (Comma-Separated Values)
* Only data tagged as "Good" (G) utilized
* For validation, records are filtered to stations measuring soil moisture at 0–5 cm depth from 2002 to 2024, resulting in up to 653 stations used for ground-truth validation
* ISMN data are used only to validate the final product, not for model training

## Download Scripts
### Download ESA CCI Soil Moisture Data
**Download daily soil moisture values from ESA CCI**

This code downloads soil moisture data on a year to year basis from properly formatted JSON files. The JSON files can be created by heading to the [ESA CCI Download Page](https://data.ceda.ac.uk/neodc/esacci/soil_moisture/data/daily_files/COMBINED/v09.2) and following these steps:
* Select a year of data to download
* Click the shopping cart ("View bulk download information") in the top right
* Click the <u>json listing</u> hyperlink from the pop up
* In the new page, use *Ctrl+A* then *Ctrl+C* to copy the text to a new file, then save to a text file with the *.json* extension

### Download MODIS Covariate and Mask Data
**Download MODIS data from NASA Earthdata**

This script downloads the MODIS data described in [1.2.2 Dynamic Covariates](https://github.com/vargaslab/NASMo-TiAM_v2/tree/main/1_Input_Data#122-dynamic-covariates) and [1.2.3 Dynamic Masks](https://github.com/vargaslab/NASMo-TiAM_v2/tree/main/1_Input_Data#123-dynamic-masks). It requires:

* A [NASA Earthdata account](https://urs.earthdata.nasa.gov/)
* A Python environment with the [earthaccess](https://earthaccess.readthedocs.io/en/stable/) package installed
* If you use the Sol Supercomputer, you can set your Earthdata credentials in the environment variables of the job scripts

### Download ISMN Ground-Truth Data
ISMN data are downloaded manually from the [ISMN data viewer](https://ismn.earth/en/) (free registration required) by selecting the North American networks for the 2002–2024 period.
