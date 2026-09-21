*The section numbers in this document match the numbers of the scripts they describe within validation stage of the NASMo-TiAM v2 250 m workflow.*

# 5 Validation
The soil moisture predictions for each biweekly period are evaluated with two time-specific validation approaches: a cross-validation with the reference satellite-derived soil moisture data (ESA CCI) set aside during the generation of the training matrices and not used to build the models, and an independent ground-truth validation with in situ soil moisture records from the International Soil Moisture Network (ISMN).
## 5.1 Cross-Validation with Reference Satellite-Derived Soil Moisture Data
This script calculates correlation and root mean square error (RMSE) values from matrices containing the predicted values and the reference ESA CCI soil moisture values. The input data correspond to the 30% of sampling points set aside when the training matrices were split (see [3.1.3](https://github.com/vargaslab/NASMo-TiAM_v2/tree/main/3_Matrices_Generation#313-split-of-north-american-biweekly-training-matrices)).
* Each predicted soil moisture pixel at 250 m is compared with the reference satellite-derived soil moisture value at its original spatial resolution (0.25°).
* Residuals are calculated as the ESA CCI reference value minus the RF predicted value.
* The script produces a set of tables showing the observed and predicted values for each biweekly period.
* The script also creates a summary table with the correlation and RMSE values for every biweekly period, along with the number of points used in each calculation.
## 5.2 Independent Validation with Ground-Truth Data
This script calculates correlation and RMSE values from matrices containing the predicted values and the biweekly soil moisture means from ISMN stations prepared in [2.7](https://github.com/vargaslab/NASMo-TiAM_v2/tree/main/2_Data_Preprocessing#27-ismn-ground-truth-validation-data). To obtain reference correlation and RMSE values, the script also compares the input ESA CCI soil moisture values with the same ISMN records.
* Each predicted soil moisture pixel at 250 m is compared with the available ISMN field records (0–5 cm depth) at the same location across North America from 2002 to 2024.
* Up to 653 stations from 14 ISMN networks are used in this validation approach.
* The script produces a set of tables showing the observed and predicted values for each biweekly period.
* The script also creates a summary table with the correlation and RMSE values for every biweekly period, along with the number of points used in each calculation.
* ISMN data are used only for validation and are never used to train the models.
