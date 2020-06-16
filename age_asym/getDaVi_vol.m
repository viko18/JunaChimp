clc, clear
%%%-------------- 2019 Sam Vickery & Felix Hoffstaedter ----------------%%%
%%% extract average volume from each Davi130 label masked at GM>0.1 using 
%%% GM mask created from GM shooting template 4 from modulted GM maps
%%% and saving the matrix for post hoc analyses using R 

% Dir with Davi130 %
Davi_dir = '~\Juna.Chimp_1mm\';
% Dir with modulated GM maps %
mwp1_dir = '~\mwp1\';
% All modulated GM maps - failed QC images are removed post-hoc %
mwp1_fils = (dir(fullfile(mwp1_dir,'mwp1*.nii')));
% Davi130 parcellation masked by GM>0.1 %
parc = fullfile(Davi_dir, 'Davi130_1mm_GM01.nii');

for subj = 1:numel(mwp1_fils)
    
    vi_string = fullfile(mwp1_dir,mwp1_fils(subj).name);
    % gather file names and read in the volume %
    Vi  = spm_read_vols(spm_vol(vi_string));
    
    % names and volumes for re-aligned and coregsiterd atlas maps %
    label = spm_read_vols(spm_vol(parc));
    label(isnan(label))=0;
   
     
    % loop over ROI's of each subject and take 10% timm mean of ROI %
    for lbl = 1:130
        DaViVol(subj,lbl) = mean(Vi(label==lbl));
    end
    
end

% clean up %
%clear DaViVol_left DaViVol_right left_ind right_ind
% save mat file with avg roi vols and as csv for R  for post hoc stats%
cd(Davi_dir);
save Davi_vol 
% load mat file into workspace and then save as csv file %
x=load('Davi_vol.mat');
csvwrite('Davi_labels_130_mean_GM01.csv', x.DaViVol);


