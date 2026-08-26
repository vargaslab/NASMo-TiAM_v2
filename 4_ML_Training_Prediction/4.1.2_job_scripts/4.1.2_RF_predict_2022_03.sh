#!/bin/bash

#SBATCH -N 1
#SBATCH -c 1
#SBATCH -t 3-00:00:00
#SBATCH -p public
#SBATCH -q public
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err
#SBATCH --mem=64G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=”%u@asu.edu”

# Specify regions
regions=( "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34" "35" "36" "37" "38" "39" "40" "41" "42" "43" "44" )

# Specify path information
path_prefix="/scratch/glaboy1/nasmo-tiam_v2"

# Load software modules
module load mamba/latest

# Activate Python environment
source activate nasmo-tiam_v2

model_path="$path_prefix/5_NorthAmerica_prediction_outputs_250m_v92/2_RF/Prediction_models/2022"
eval_path="$path_prefix/4_Evaluation_data_csv/2022"
output_path="$path_prefix/5_NorthAmerica_prediction_outputs_250m_v92/2_RF/Prediction_outputs/2022"

for region in ${regions[@]}; do
  file_name="northamerica_rf_v92_250m_output_sm_2022_03_region_$region.csv"
  python 4.1.2_RF_predict.py -m "$model_path/03/" -e "$eval_path/03/northamerica_eval_v92_250m_region_${region}_2022_03.csv" -o "$output_path/03/$file_name"
done

source deactivate

