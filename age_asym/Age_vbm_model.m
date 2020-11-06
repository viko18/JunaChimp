clear, clc
%%% unsmoothed images for vbm model %%%
dat_dir = '~\mwp1\';
%%% location of dir for SPM %%%
model_dir = '~\VBM_models\';
mkdir(model_dir);


%%% smoothed images for vbm model %%%
vbm_fils = (dir(fullfile(dat_dir,'s4*.nii')));
%%% covariates txt files for model %%%
age_tiv = ...
    {'~\chimp_meta_data\total_VBM_age_tiv.txt'};
sex_scanner = ...
    {'~\chimp_meta_data\total_VBM_sex_scanner.txt'};
rearing = ...
    {'~\chimp_meta_data\total_VBM_rearing.txt'};
%%% GM mask %%%
gm_mask = ...
    {'~\masks\GM_mask_04.nii,1'};
 

for subj = 1:numel(vbm_fils)
   matlabbatch{1}.spm.stats.factorial_design.des.t1.scans(subj,1) = ...
        {[fullfile(dat_dir,vbm_fils(subj).name) ',1']};
end

%%% Batch to create vbm model %%%
% matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = vbm_cell;
matlabbatch{1}.spm.stats.factorial_design.cov = ...
    struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov(1).files = age_tiv;
matlabbatch{1}.spm.stats.factorial_design.multi_cov(1).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov(1).iCC = 5;
matlabbatch{1}.spm.stats.factorial_design.multi_cov(2).files = sex_scanner;
matlabbatch{1}.spm.stats.factorial_design.multi_cov(2).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov(2).iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov(2).files = rearing;
matlabbatch{1}.spm.stats.factorial_design.multi_cov(2).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov(2).iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = gm_mask;
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.tools.cat.tools.check_SPM.spmmat(1) = ...
    cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.tools.cat.tools.check_SPM.check_SPM_cov.do_check_cov.use_unsmoothed_data = 1;
matlabbatch{2}.spm.tools.cat.tools.check_SPM.check_SPM_cov.do_check_cov.adjust_data = 1;
matlabbatch{2}.spm.tools.cat.tools.check_SPM.check_SPM_ortho = 1;

spm_jobman('run', matlabbatch);
%%% Clean up %%%
clear matlbbatch



