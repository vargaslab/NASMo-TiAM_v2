*The section numbers in this document match the numbers of the scripts they describe within the matrices generation stage of the NASMo-TiAM v2 250 m workflow.*

# 3 Generation of Biweekly Training and Prediction Matrices
This section transforms the preprocessed input data into matrices for model training and prediction. Training matrices are generated for 14 predefined subregions and then combined into 518 North American training matrices (one per 16-day period). Prediction matrices are generated for 44 predefined subregions of North America. In both cases, snow&ice-covered areas are removed using the biweekly snow cover masks.
## 3.1 Training Matrices
### 3.1.1 Training Matrices by predefined subregions
This script creates training matrices for every biweekly period in each of the 14 subregions. The matrices contain the soil moisture value at the centroid coordinates of each coarse-resolution (0.25°) ESA CCI pixel, along with the values of the 250 m pixels at the same coordinates in each static and dynamic covariate layer.
* Subregions are used to make processing manageable, given the large number of 250 m pixels in the covariate layers across North America.
* For every biweekly period, the script imports the ESA CCI soil moisture reference data (0.25°), the dynamic covariates (NDVI and LST), and the dynamic snow cover masks (250 m).
* The static covariates (terrain parameters and bulk density) are also imported.
* The imported layers are temporarily stored in a raster stack and then masked with the snow cover layer to remove snow&ice-covered areas from the output training matrices.
* The output training matrices are CSV files.
### 3.1.2	Union of Subregions Training Matrices into North America matrices
This script takes the CSV training matrices of the 14 subregions for each biweekly period and combines them into North American training matrices.
* Output = 518 North American training matrices, one per biweekly period, from June 2002 to December 2024.
### 3.1.3	North America biweekly training matrices split
This script randomly splits each North American training matrix into two subsets: 70% for model training and 30% for cross-validation.
* The 30% subset is set aside during model training and is later used in the cross-validation step of [5 ML Validation](https://github.com/vargaslab/NASMo-TiAM_v2/tree/main/5_ML_Validation).
## 3.2 Prediction Matrices
### 3.2.1	Prediction matrices by predefined subregions
This script creates prediction matrices for every biweekly period in each of the 44 subregions. The matrices contain the values of the static and dynamic covariates at the centroid coordinates of every 250 m pixel within each subregion.
* Subregions are used to make processing manageable, given the large number of 250 m pixels in the covariate layers across North America. 
* Unlike the training matrices, whose number of records is set by the number of coarse-resolution ESA CCI pixels, prediction matrices hold one record for every 250 m pixel in each subregion. For this reason, prediction matrices use smaller subregions (44) than training matrices (14).
* For every biweekly period, the script imports the dynamic covariates (NDVI and LST) and the dynamic snow cover masks (250 m).
* The static covariates (terrain parameters and bulk density) are also imported.
* The imported layers are temporarily stored in a raster stack and then masked with the snow cover layer to remove snow&ice-covered areas from the output prediction matrices.
* The output prediction matrices are CSV files.
