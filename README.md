# NASMo-TiAM V2: North America Soil Moisture Dataset Derived from Time-Specific Adaptable Machine Learning Models Version 2

NASMo-TiAM is a workflow for generating soil moisture for North America at 250 m resolution using time-specific adaptable Machine Learning (ML) models. It deploys ML models to downscale coarse-resolution soil moisture estimates (0.25 deg) from the [European Space Agency Climate Change Initiative (ESA CCI)](https://climate.esa.int/en/projects/soil-moisture/data/) based on their correlation with a set of static (terrain parameters, bulk density) and dynamic covariates (Normalized Difference Vegetation Index, land surface temperature).

This workflow is composed of five steps.

1. [Input Data:](1_Input_Data/) It uses a combination of coarse-resolution soil moisture and static and dynamic standardized input data.
2. [Data Preprocessing:](2_Data_Preprocessing/) It preprocesses it to allocate the same temporal and spatial characteristics.
3. [Matrices Generation:](3_Matrices_Generation/) It transforms it into an ML training and testing format.
4. [ML Training Prediction:](4_ML_Training_Prediction/) It trains and tests a traditional ML model such as Random Forest to perform soil moisture prediction.
5. [ML Validation:](5_ML_Validation/) It validates the predictions with available high-resolution soil moisture data.

Each step has its directory with the data sources, scripts, and a README file describing in detail the execution steps.   

The current version of NASMo-TiAM uses Random Forest to perform surface Soil Moisture (0-5cm depth) predictions at 250m of spatial resolution on 16-day periods from mid-2002 to December 2024 over North America. The generated data can be found in the [ORNL DAAC](https://www.earthdata.nasa.gov/data/catalog/ornl-cloud-nasmo-tiam-250m-2326-1). 

<p align="center">
    <img src="imgs/NASMo_TiAM_250m_Fig2.jpg" width="800">
    <br>
    <em>Figure 1. The NASMo-TiAM 250 m workflow involved standardizing input data to common spatial and temporal resolutions, integrating static and dynamic covariates, and training a Random Forest model to output fine scaled soil moisture across North America.</em>
</p>

## Motivation
Soil moisture plays a crucial role in the Earth's ecosystems and has substantial implications in different scientific fields such as hydrology (Jackson et al., 1996; Robinson et al., 2008), ecology, and climate science (Davidson et al., 1998; Falloon et al., 2011; Legates et al., 2010; Ward, 2008). A greater understanding of soil moisture processes and their spatial and temporal distribution can lead to improvements in different fields, such as agriculture (Engman, 1991; Hunt, 2015; Pablos et al., 2017), water resources management (Jacobs et al., 2003), natural disasters related to flooding (Tuttle et al., 2017), landslides (Crow, 2019), and drought events (Pablos et al., 2017). 

This NASMo-TiAM 250 m dataset provides a fine spatial resolution soil moisture dataset across the North American region. Other continent-scale datasets have resolutions ranging from 0.25 degrees (O. and Orth, 2021) to 25 km (Skulovich and Gentine, 2023) and 1 km (Han et al., 2023). While the dataset from Vergopolan et al. (2021) has a 30-m resolution, its spatial coverage is limited to the conterminous United States.

## Prerequisites and Dependencies
To run this workflow, you must have [R>4.0](https://www.r-project.org/) and [Python>3.8](https://www.python.org/downloads/). If using Windows/Mac, R code can be run through RStudio and Python through the Python terminal. For Linux, everything can be run through the command line using Rscript and python calls. The dependent R packages are listed in `install/R-dependencies.R` and for Python in `install/Python-dependencies.txt`.

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

If you already have R>4.0 and Python>3.8 installed on your local machine with a different operating system (Linux, Windows, or Mac), you will only need to install the dependencies by running the next commands if R and python are properly configured to path.
```
# Install R libraries
sudo Rscript R-dependencies.R

# Install Python libraries
sudo python3 -m pip install -r Python-dependencies.txt
```

## How to Run
This workflow includes five steps where you will need to access each of the steps to learn more about the execution. **You need to follow the order so all data dependencies are in place.**

1. [Input Data](1_Input_Data/)
2. [Data Preprocessing](2_Data_Preprocessing/) 
3. [Matrices Generation](3_Matrices_Generation/)
4. [ML Training Prediction](4_ML_Training_Prediction/)
5. [ML Validation](5_ML_Validation/)

## Related Publications
Llamas, R., P. Olaya, M. Taufer, and R. Vargas. 2024. North America Soil Moisture Dataset derived from Time-specific Adaptable Machine learning models (NASMo-TiAM 250m). In Preparation for Scientific Data, 2024.

## Copyright and License 
Copyright (c) 2026, Global Computing Lab

NASMo-TiAM is distributed under terms of the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) with LLVM Exceptions.

## Acknowledgments
This study was funded by NASA’s Carbon Monitoring System program (grant 80NSSC21K0964) and the National Science Foundation's Office of Advanced Cyberinfrastructure (grants 2103845, 2103836, and 2334945).
Any opinions, findings, conclusions, or recommendations expressed in this material are those of the author(s) and do not necessarily reflect the views of the National Science Foundation. 

## Contact Information
For any questions, please contact the main developer directly Dr. Ricardo Llamas (rllamas@udel.edu), version 2 developer Gabriel Laboy (gmlaboy015@gmail.com), or the PIs Dr. Michela Taufer (mtaufer@utk.edu) and Dr. Rodrigo Vargas (rvargas@udel.edu).
