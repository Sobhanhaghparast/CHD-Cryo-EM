## CHD-Cryo-EM

CHD-Cryo-EM is a MATLAB-based toolkit designed for the analysis of cryo-electron microscopy (cryo-EM) data, focusing on conformational heterogeneity detection (CHD). This suite of scripts facilitates the processing and interpretation of cryo-EM datasets to uncover structural variations within macromolecular complexes.​


## 🛠️ Requirements
MATLAB R2020a or later

Statistics and Machine Learning Toolbox

Image Processing Toolbox​

Dimensinoality reduction toolbox (third party)

## 🚀 Getting Started
Clone the repository:

      ```bash  
      git clone https://github.com/Sobhanhaghparast/CHD-Cryo-EM.git
      cd CHD-Cryo-EM

Extract the dataset:

Ensure that Pdata.zip is extracted in the working directory. Run the main analysis script:

Open MATLAB and execute:

matlab

Run_Sorted
This will initiate the analysis pipeline on the provided dataset.

## 📊 Output
The analysis will generate:​

Figures illustrating conformational variability.

Metrics quantifying structural differences.

Processed data files for further interpretation.​

## 📁 Repository Contents

Loadim.m: Loads and preprocesses cryo-EM images.

Loadmds.m: Handles multidimensional scaling (MDS) data loading.

MDS_out.m: Processes MDS output for further analysis.

PCMDS.m: Performs principal coordinate analysis on MDS data.

Run_Sorted.m: Main script to execute the sorted analysis pipeline.

apply_flipsm.m: Applies flip operations to the dataset.

calculate_figure_of_meritm.m: Computes the figure of merit for reconstructions.

evaluatePairSwap.m: Evaluates the impact of particle pair swapping.

final.m: Finalizes the analysis and generates output results.

genrule.m: Generates rules for data classification.

pcpolswap.m & polswap.m: Handle polarity swapping in datasets.

regen_polm.m: Regenerates polarity matrices.

Pdata.zip: Compressed dataset incl saved MDS spaces.​



## 👨‍🔬 Authors
Sobhan Haghparast & Maarten joosten
Affiliation: department of imaging physics, Delft, Netherlands
​



## 📫 Acknowledgments
We acknowledge the contributions of the cryo-EM community and the developers of MATLAB toolboxes utilized in this project.
