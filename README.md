# NASMo-TiAM V2: North America Soil Moisture Dataset Derived from Time-Specific Adaptable Machine Learning Models, Version 2

NASMo-TiAM is a workflow for generating soil moisture for North America at 250 m resolution using time-specific adaptable Machine Learning (ML) models. It deploys ML models to downscale coarse-resolution soil moisture estimates (0.25 deg) from the [European Space Agency Climate Change Initiative (ESA CCI)](https://climate.esa.int/en/projects/soil-moisture/data/) based on their correlation with a set of static (terrain parameters, bulk density) and dynamic covariates (Normalized Difference Vegetation Index, land surface temperature). It also applies time-specific snow and ice cover masks to prevent model training and predictions over snow-covered or frozen areas, where ESA CCI soil moisture estimates carry high uncertainty.

This workflow is composed of five steps.

1. [Input Data:](1_Input_Data/) It uses a combination of coarse-resolution soil moisture and static and dynamic standardized input data.
2. [Data Preprocessing:](2_Data_Preprocessing/) It preprocesses the input data to share the same spatial (250 m) and temporal (16-day) characteristics.
3. [Matrices Generation:](3_Matrices_Generation/) It transforms the data into ML training and prediction matrices.
4. [ML Training Prediction:](4_ML_Training_Prediction/) It trains and tests a traditional ML model such as Random Forest for each 16-day time step and uses it to predict soil moisture across North America.
5. [ML Validation:](5_ML_Validation/) It validates the predictions through cross-validation with withheld ESA CCI data and against in situ measurements from the International Soil Moisture Network (ISMN).

Each step has its own directory with the data sources, scripts, and a README file describing the execution steps in detail.

The current version of NASMo-TiAM (v2) uses Random Forest to predict surface soil moisture (0–5 cm depth) at 250 m spatial resolution for 16-day periods from June 2002 to December 2024 over North America (Canada, United States, Mexico). Each 16-day prediction comes from an independent model trained exclusively on data from that time step (518 time-specific models in total). The generated data can be found in the [ORNL DAAC](https://www.earthdata.nasa.gov/data/catalog/ornl-cloud-nasmo-tiam-250m-2326-1).

<p align="center">
    <img src="imgs/NASMo_TiAM_250m_Fig2.jpg" width="800">
    <br>
    <em>Figure 1. The NASMo-TiAM v2 250 m workflow involves standardizing input data to common spatial and temporal resolutions, integrating static and dynamic covariates, masking snow&ice-covered areas, and training time-specific Random Forest models to output fine-scale soil moisture across North America.</em>
</p>

## Motivation
Soil moisture plays a crucial role in the Earth's ecosystems and has substantial implications in different scientific fields such as hydrology (Jackson et al., 1996; Robinson et al., 2008), ecology (Robinson et al., 2008), and climate science (Davidson et al., 1998; Falloon et al., 2011; Legates et al., 2010; Ward, 2008). A greater understanding of soil moisture processes and their spatial and temporal distribution can lead to improvements in different sectors, such as agriculture (Engman, 1991; Hunt, 2015; Pablos et al., 2017), water resources management (Jacobs et al., 2003), and natural disasters related to flooding (Tuttle et al., 2017), landslides (Crow, 2019), and drought events (Pablos et al., 2017).

The NASMo-TiAM v2 250 m dataset provides fine spatial resolution soil moisture across North America. Other large-scale soil moisture datasets have spatial resolutions of 36 km (Yao et al., 2023), 0.25° (O and Orth, 2021), 25 km (Skulovich and Gentine, 2023), 9 km (Feng et al., 2026), 0.05° (Wei et al., 2026), and 1 km (Han et al., 2023; Zhang et al., 2023). While SMAP-HydroBlocks (Vergopolan et al., 2021) has a 30 m resolution, its spatial coverage is limited to the conterminous United States.

## Prerequisites and Dependencies
To run this workflow, you must have [R>4.0](https://www.r-project.org/) and [Python>3.8](https://www.python.org/downloads/). If using Windows/Mac, R code can be run through RStudio and Python through the Python terminal. On Linux, everything can be run through the command line using Rscript and python calls. The dependent R packages are listed in `install/R-dependencies.R` and for Python in `install/Python-dependencies.txt`.

It is important to note that some R scripts will take a significant amount of time to run due to the nature of the computation. Many scripts were run on the [Sol Supercomputer](https://docs.rc.asu.edu/supercomputer-hardware/) located at Arizona State University, so many of the scripts uploaded to this GitHub not only include the R scripts but bash scripts used to run the job on Sol.

For performance reasons, specific parts of the workflow were run in ArcGIS Pro, but R-equivalent code is found within the supplied R scripts. Additional details within section READMEs explain how ArcGIS was used.

## Installation
Currently, the installation scripts are supported on Debian, and Debian-based Linux distributions. This script installs all the necessary packages (R>4, R libraries, pip, Python libraries) for your local computer.
Requirement: Debian-based Linux distributions.
```
git clone --recursive https://github.com/vargaslab/NASMo-TiAM_v2
cd NASMo-TiAM_v2/install
./install.sh
```

If you already have R>4.0 and Python>3.8 installed on your local machine with a different operating system (Linux, Windows, or Mac), you only need to install the dependencies by running the next commands if R and python are properly configured to path.
```
# Install R libraries
sudo Rscript R-dependencies.R

# Install Python libraries
sudo python3 -m pip install -r Python-dependencies.txt
```

## How to Run
This workflow includes five steps. Open each step's directory to learn more about its execution. **You need to follow the order so all data dependencies are in place.**

1. [Input Data](1_Input_Data/)
2. [Data Preprocessing](2_Data_Preprocessing/) 
3. [Matrices Generation](3_Matrices_Generation/)
4. [ML Training Prediction](4_ML_Training_Prediction/)
5. [ML Validation](5_ML_Validation/)

## Related Publications
Llamas, R., P. Olaya, M. Taufer, and R. Vargas. 2024. North America Soil Moisture Dataset derived from Time-specific Adaptable Machine learning models (NASMo-TiAM 250m). In Preparation for Scientific Data, 2024.

## Related Datasets
- **NASMo-TiAM v2 250 m (2002–2024):** Llamas, R. M., P. Olaya, G. Laboy, M. Taufer, and R. Vargas. 2026. NASMo-TiAM v2 250m 16-day North America Surface Soil Moisture Dataset. ORNL DAAC, Oak Ridge, Tennessee, USA. https://doi.org/10.3334/ORNLDAAC/2527
- **NASMo-TiAM 250 m (v1):** Llamas, R. M., P. Olaya, M. Taufer, and R. Vargas. 2024. NASMo-TiAM 250m 16-day North America Surface Soil Moisture Dataset. ORNL DAAC, Oak Ridge, Tennessee, USA. https://doi.org/10.3334/ORNLDAAC/2326

## Copyright and License 
Copyright (c) 2026, Global Computing Lab

NASMo-TiAM is distributed under terms of the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) with LLVM Exceptions.

## Acknowledgments
This study was funded by NASA's Carbon Monitoring System program (grant 80NSSC21K0964) and the National Science Foundation's Office of Advanced Cyberinfrastructure (grants 2103845, 2103836, and 2334945). Any opinions, findings, conclusions, or recommendations expressed in this material are those of the author(s) and do not necessarily reflect the views of the National Science Foundation.

## Contact Information
For any questions, please contact the main developer directly Dr. Ricardo Llamas (rllamas@udel.edu), the version 2 developer Gabriel Laboy (gmlaboy015@gmail.com), or the PIs Dr. Michela Taufer (mtaufer@utk.edu) and Dr. Rodrigo Vargas (rvargas@udel.edu).
