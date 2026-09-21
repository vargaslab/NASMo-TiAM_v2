*The section numbers in this document match the numbers of the scripts they describe within the model training and prediction stage of the NASMo-TiAM v2 250 m workflow.*

# 4 Prediction of Soil Moisture Biweekly Layers for North America
## 4.1 Models’ Generation and Soil Moisture Prediction
In this stage of the workflow, we use Random Forest (RF), a traditional machine learning method, to predict soil moisture values. RF builds many decision trees at training time and provides a prediction by applying the model to a new data point at inference time. It is suitable for areas with sparse data, as it does not assume any particular geometry or functional form of the model.

NASMo-TiAM v2 uses **time-specific models**: an independent RF model is trained for each 16-day period using only the data from that period, resulting in 518 models from June 2002 to December 2024. Each model is then used to predict soil moisture at 250 m for the same period.

All RF training and predictions were run on the [Sol Supercomputer](https://docs.rc.asu.edu/supercomputer-hardware/) at Arizona State University.

### 4.1.1 Random Forest Model Training
This script creates the ensemble of decision trees from the training matrices. It uses [scikit-learn](https://scikit-learn.org/), a free machine learning library for Python.

The inputs of this script are: 
* The 70% training subsets of the training matrices generated in [3.1 Training Matrices](https://github.com/vargaslab/NASMo-TiAM_v2/tree/main/3_Matrices_Generation#31-training-matrices), in CSV format. 
* The maximum number of trees to consider when creating the model. 
* The seed, for reproducibility of the random processs in the script.
* The path where the trained model will be stored. 

The script reads one training matrix at a time and standardizes it with [StandardScaler](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.StandardScaler.html), which removes the mean and scales to unit variance (also known as the z-score).

The script fits and transforms the training data and saves the scaler in pickle format (`scaler.pkl`), so it can be applied to the prediction matrices of the same period in the next step.

The code defines a [RandomForestRegressor](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestRegressor.html), and performs a randomized hyperparameter search with cross-validation [(RandomizedSearchCV)](https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.RandomizedSearchCV.html). In this step, the script selects the optimal number of decision trees, tree depth, number of leaves per node, and other parameters based on the best performance on the training matrix. 

The script saves the trained model with the optimal parameters in  pickle format (model.pkl), so it can be applied to the predictions in the next step. 

The outputs of the script, for each biweekly period, are:
* The scaler used to standarize the data (`scaler.pkl`). 
* The trained RF model (`model.pkl`). 

### 4.1.2 Random Forest Soil Moisture Prediction
This script applies the trained RF model of each biweekly period to the prediction matrices of the same period to obtain soil moisture predictions at 250 m.

The inputs of this script are:
* The prediction matrices generated in [3.2 Prediction Matrices](https://github.com/vargaslab/NASMo-TiAM_v2/tree/main/3_Matrices_Generation#32-prediction-matrices), in CSV format. 
* The path to the scaler (`scaler.pkl`), so the prediction matrices are standardized the same way as the training matrices.
* The path to the trained RF model (`model.pkl`), so it can be applied to the prediction matrices.

The script reads the prediction matrices, loads `scaler.pkl`, and applies it so the matrices are standardized based on the training matrix of the same period.

The script then loads the trained RF model (`model.pkl`) and predicts a soil moisture value for each point in the prediction matrices.

The output of this script is the soil moisture predictions for each prediction matrix, in CSV format.

## 4.2 Assemble of North America Soil Moisture Predictions Mosaics
### 4.2.1	Conversion of CSV predictions into raster files 
This script converts the RF predictions from points to pixels in raster format. It uses the preprocessed North American elevation raster as the reference and creates TIF raster files with the same coordinate reference system and pixel size (0.002548°, ~250 m).
* The outputs are up to 44 raster files per biweekly period, one for each predefined regions used to create the prediction matrices.
### 4.2.2	Mosaic of Predicted North America Soil Moisture raster files
This script takes the predicted soil moisture rasters for the 44 subregions and assembles a North American mosaic for each biweekly period.
* Output = 518 North American soil moisture layers (surface soil moisture, 0–5 cm depth, in m³/m³) from June 26, 2002, to December 31, 2024.
* These layers are the core data of the NASMo-TiAM v2 250 m dataset. They follow the naming convention `northamerica_ssm_250m_rf_esacci92_<year>_<biweekly_period>.tif`.
