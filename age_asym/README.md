These scripts were used for the analysis of hemispheric asymmetry (Davi_Asymm.R) and aging effect on gray matter volume (Age_vbm_model.m & Davi_Age_reg.R).

Explanation of the different analyses:

Age-Related Changes in Gray Matter Using Davi130 Parcellation

The Davi130 parcellation was applied to the modulated GM maps to conduct region-wise morphometry analysis. First, the Davi130 regions were masked with a 0.1 GM mask to remove all non-GM portions of the regions. Subsequently, the average GM intensity of each region for all QC-passed chimpanzees was calculated. A multiple regression model was conducted for the labels from both hemispheres, whereby, the dependent variable was GM volume and the predictor variables were age, sex, TIV, and scanner. Significant age-related GM decline was established for a Davi130 label with a p ≤ 0.05, after correcting for multiple comparisons using FWE (Holm 1979).

Voxel-Based Morphometry

VBM analysis was conducted using CAT12 to determine the effect of aging on local GM volume. The modulated and spatially normalized GM segments from each subject were spatially smoothed with a 4 mm FWHM (full width half maximum) kernel prior to analyses. To restrict the overall volume of interest, an implicit 0.4 GM mask was employed. As MRI field strength is known to influence image quality, and conse-quently, tissue classification, we included scanner strength in our VBM model as a co-variate. The dependent variable in the model was age, with covariates of TIV, sex, and scanner. The VBM model was corrected for multiple comparisons using TFCE with 5000 permutations (Smith and Nichols 2009). Significant clusters were determined at p ≤ 0.05, after correcting for multiple comparisons using FWE.  

Hemispheric Asymmetry

As for the age regression analysis, all Davi130 parcels were masked with a 0.1 GM mask to remove non-GM portions within regions. Cortical hemispheric asymmetry of Davi130 labels was determined using the formula Asym = (L - R) / (L + R) * 0.5 (Kurth et al. 2015; Hopkins et al. 2017), whereby L and R represent the average GM volume for each region in the left and right hemisphere, respectively. Therefore, the bi-hemispheric Davi130 regions were converted into single Asym labels (n=65) with posi-tive Asym values indicating a leftward asymmetry, and negative values, a rightward bias. One-sample t-tests were conducted for each region under the null hypothesis of Asym = 0, and significant leftward or rightward asymmetry was determined with a p ≤ 0.05, after correcting for multiple comparisons using FWE (Holm 1979).
