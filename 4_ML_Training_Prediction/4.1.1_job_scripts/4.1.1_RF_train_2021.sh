#!/bin/bash

#SBATCH -N 1
#SBATCH -c 1
#SBATCH -t 3-00:00:00
#SBATCH -p public
#SBATCH -q public
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err
#SBATCH --mem=128G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=”%u@asu.edu”

# Specify biweeks
biweeks=( "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" )

# Specify path information
path_prefix="/scratch/glaboy1/nasmo-tiam_v2"
train_path="$path_prefix/3_Training_and_Test_data_csv/2_northamerica_train_70pct"
model_path="$path_prefix/5_NorthAmerica_prediction_outputs_250m_v92/2_RF/Prediction_models/2021"

# Load software modules
module load mamba/latest

# Activate Python environment
source activate nasmo-tiam_v2

# Run Python script for each biweek
for biweek in ${biweeks[@]}; do
  python 4.1.1_RF_train.py -t "$train_path/northamerica_train_v92_250m_70pct_2021_$biweek.csv" -m "$model_path/$biweek/"
done

# Deactivate Python environment
source deactivate

