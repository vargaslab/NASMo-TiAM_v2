#!/bin/bash

#SBATCH -N 1
#SBATCH -c 1
#SBATCH -t 3-00:00:00
#SBATCH -p public
#SBATCH -q public
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err
#SBATCH --mem=48G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=”%u@asu.edu”

# Load software modules
module load r-4.5.1-gcc-12.1.0
module load r-raster-3.6-23-gcc-12.1.0

# Run R script
Rscript 3.1.1_Training_files_generation_subregions.R "2023" "13"

