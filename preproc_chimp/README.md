To illustrate the structural processing pipeline, we have created exemplar MATLAB SPM batch scripts that utilizes the Juna.Chimp templates in CAT12’s preprocessing workflow to conduct segmentation, spatial registration, and finally some basic age analysis on an openly available direct-to-download chimpanzee sample (http://www.chimpanzeebrain.org/mri-datasets-for-direct-download). 

These scripts require the appropriate templates which can be downloaded from the Juna.Chimp web viewer (http://junachimp.inm7.de/?templateSelected=Chimpanzee+T1&parcellationSelected=Davi+Chimpanzee+Atlas - SPM/CAT.zip) and then placed into the SPM Toolbox directory of the latest version of CAT12 (CAT12.7 r1609). The processing parameters are similar to those conducted in this study (https://elifesciences.org/articles/60136), although different DICOM conversions and denoising were conducted. Further information regarding each parameter can be viewed when opening the script in the SPM batch as well as the provided comments and README file. Along with processing the small chimpanzee sample, we also provide an example VBM and global GM volume model analyzing the effect of aging as shown in our study. 

The /cat_updates directory contains updated CAT12 functions that are needed to be added to the CAT12 directory for the workflow to function correctly.

Steps to use example workflow:
1. Download data and unzip
2. Get latest versions of CAT and SPM
3. Get Juna.Chimp templates for SPM
4. overwrite files in CAT12 directory with /cat_updates
5. Unzip meta_data_orientation to chimapnzee data directory
6. Run chimp10_modelling.m
