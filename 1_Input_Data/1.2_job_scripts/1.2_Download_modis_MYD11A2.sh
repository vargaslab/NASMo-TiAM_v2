#!/bin/bash

#SBATCH -N 1
#SBATCH -c 1
#SBATCH -t 0-12:00:00
#SBATCH -p public
#SBATCH -q public
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err
#SBATCH --mem=16G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=”%u@asu.edu”

# Load software
module load mamba/latest

# Activate environment
source activate nasmoTiamDwnldEnv

# Set environment variables
export EARTHDATA_USERNAME=""
export EARTHDATA_PASSWORD=""

# Set path variables
dataset="MYD11A2"
out_dir="/scratch/glaboy1/nasmo-tiam_v2/0_Input_data/5_MODIS_TEMPERATURE/${dataset}_hdf_files"

# Run Python scripts
python 1.2_Download_modis.py -ds $dataset -sd "2002-01-01" -ed "2024-12-31" -d $out_dir -e ".hdf"

unset EARTHDATA_USERNAME
unset EARTHDATA_PASSWORD

# Deactivate environment
source deactivate

