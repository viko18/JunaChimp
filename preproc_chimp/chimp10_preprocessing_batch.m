%-----------------------------------------------------------------------
% Job saved on 25-Apr-2020 11:25:08 by cfg_util (rev $Rev: 7345 $)
% cfg_basicio BasicIO - Unknown
% spm SPM - SPM12 (7771)
%-----------------------------------------------------------------------

%  ------------------------------------------------------------------------
%  Chimpanzee batch options that can be changed in the GUI or here directly
%  ------------------------------------------------------------------------

global Pdir_cimp

try
  numcores = max(cat_get_defaults('extopts.nproc'),1);
catch
  numcores = 0;
end

cattempdir = fullfile(spm('dir'),'toolbox','cat12','templates_animals');

if ~isempty(Pdir_cimp) && exist(fullfile(Pdir_cimp,'rFemale_Brandy.nii'),'file')
  FILES = {
    fullfile(Pdir_cimp,'rFemale_Brandy.nii,1')
    fullfile(Pdir_cimp,'rFemale_Christa.nii,1')
    fullfile(Pdir_cimp,'rFemale_Dara.nii,1')
    fullfile(Pdir_cimp,'rFemale_Frannie.nii,1')
    fullfile(Pdir_cimp,'rFemale_Melinda.nii,1')
    fullfile(Pdir_cimp,'rMale_Fritz.nii,1')
    fullfile(Pdir_cimp,'rMale_Iyk.nii,1')
    fullfile(Pdir_cimp,'rMale_Jarred.nii,1')
    fullfile(Pdir_cimp,'rMale_Justin.nii,1')
    fullfile(Pdir_cimp,'rMale_Steward.nii,1')
  };
else
  Pdir_cimp = pwd;
  if ~exist(fullfile(Pdir_cimp,'stat'),'dir'), mkdir(fullfile(Pdir_cimp,'stat')); end
  FILES = '<UNDEFINED>';
end


%% intensity normalization  
%  ------------------------------------------------------------------------
%  Although we try to remove all problems due to negative values there are 
%  still differences and we need to get some useful intensity range first. 
%  This step is not included in the main preprocessing because we keep the 
%  original values (or quite similar)
%  ------------------------------------------------------------------------
mi = 1;
matlabbatch{mi}.spm.tools.cat.tools.spmtype.data                           = FILES;  
matlabbatch{mi}.spm.tools.cat.tools.spmtype.ctype                          = 16;          % single datatype
matlabbatch{mi}.spm.tools.cat.tools.spmtype.prefix                         = 'intnorm_';
matlabbatch{mi}.spm.tools.cat.tools.spmtype.suffix                         = '';
matlabbatch{mi}.spm.tools.cat.tools.spmtype.range                          = 99.99;       % also remove severe outlier
matlabbatch{mi}.spm.tools.cat.tools.spmtype.intscale                       = 2;           % range 0 - 255 
matlabbatch{mi}.spm.tools.cat.tools.spmtype.lazy                           = 1;           % do not reprocess data
%  ------------------------------------------------------------------------


%% CAT preprocessing 
%  ------------------------------------------------------------------------
mi = mi + 1; mi_pp = mi; 
matlabbatch{2}.spm.tools.cat.estwrite.data(1)                              = ...
   cfg_dep('Image data type converter: Converted Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '()',{':'}));
% CAT preprocessing expert options
% SPM parameter
matlabbatch{mi}.spm.tools.cat.estwrite.data_wmh                            = {''};
matlabbatch{mi}.spm.tools.cat.estwrite.nproc                               = numcores;
matlabbatch{mi}.spm.tools.cat.estwrite.opts.tpm                            = {fullfile(cattempdir,'chimpanzee_TPM.nii')}; % Juna chimp TPM 
matlabbatch{mi}.spm.tools.cat.estwrite.opts.affreg                         = 'none';
matlabbatch{mi}.spm.tools.cat.estwrite.opts.ngaus                          = [1 1 2 3 4 2];
matlabbatch{mi}.spm.tools.cat.estwrite.opts.warpreg                        = [0 0.001 0.5 0.05 0.2];
matlabbatch{mi}.spm.tools.cat.estwrite.opts.bias.spm.biasfwhm              = 30;      % small values are important to remove the bias but 30 mm is more or less the limit
matlabbatch{mi}.spm.tools.cat.estwrite.opts.bias.spm.biasreg               = 0.001;   % 
matlabbatch{mi}.spm.tools.cat.estwrite.opts.acc.spm.samp                   = 1.5;     % ############# higher resolutions helps but takes much more time (e.g., 1.5 about 4 hours), so 1.0 to 1.5 mm seems to be adequate  
matlabbatch{mi}.spm.tools.cat.estwrite.opts.acc.spm.tol                    = 1e-06;   % smaller values are better and important to remove the bias in some image
matlabbatch{mi}.spm.tools.cat.estwrite.opts.redspmres                      = 0;
% segmentation options
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.segmentation.APP            = 1070;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.segmentation.NCstr          = -Inf;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.segmentation.spm_kamap      = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.segmentation.LASstr         = 1.0;   % this was also increased to allow stronger local corrections in these smaller brains
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.segmentation.gcutstr        = 2;     
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.segmentation.cleanupstr     = 0.5;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.segmentation.BVCstr         = 0.5;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.segmentation.WMHC           = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.segmentation.SLC            = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.segmentation.mrf            = 1;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.segmentation.restypes.best  = [0.5 0.3]; % ############# fast test:  .fixed = [1.2 0]; default: .best  = [0.5 0.3];
% registration options
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.registration.T1             = {fullfile(cattempdir,'chimpanzee_T1.nii')};              % Juna chimp T1
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.registration.brainmask      = {fullfile(cattempdir,'chimpanzee_brainmask.nii')};       % Juna chimp brainmask
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.registration.cat12atlas     = {fullfile(cattempdir,'chimpanzee_cat.nii')};             % Juna chimp cat atlas
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.registration.darteltpm      = {fullfile(cattempdir,'chimpanzee_Template_1.nii')};      % there is no Juna chimp Dartel template as shooting is much better
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.registration.shootingtpm    = {fullfile(cattempdir,'chimpanzee_Template_0_GS.nii')};   % Juna chimp shooting template
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.registration.regstr         = 0.5; % ############# fast test: 0.1; default: 0.5; 
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.vox                         = 1.0; % you can try higher resolution with TFCE but here we want to keep it simple and if you use 4 mm smoothing 0.5 mm just needs more memory
% surface options
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.surface.pbtres              = 0.5;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.surface.pbtmethod           = 'pbt2x';
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.surface.pbtlas              = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.surface.collcorr            = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.surface.reduce_mesh         = 1;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.surface.vdist               = 1.33333333333333;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.surface.scale_cortex        = 0.7;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.surface.add_parahipp        = 0.1;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.surface.close_parahipp      = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.admin.experimental          = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.admin.new_release           = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.admin.lazy                  = 0; % ############## avoid reprocessing 
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.admin.ignoreErrors          = 1;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.admin.verb                  = 2;
matlabbatch{mi}.spm.tools.cat.estwrite.extopts.admin.print                 = 2;
% output options
matlabbatch{mi}.spm.tools.cat.estwrite.output.surface                      = 0;    % surface reconstruction - not yet optimised for non-human primates 
matlabbatch{mi}.spm.tools.cat.estwrite.output.surf_measures                = 3;
% volume atlas maps
matlabbatch{mi}.spm.tools.cat.estwrite.output.ROImenu.atlases.chimpanzee_atlas_davi = 1;
matlabbatch{mi}.spm.tools.cat.estwrite.output.ROImenu.atlases.ownatlas     = {''}; % you can add own atlas maps but they have to be in the same orientation as the other template files especially the final GS template
% surface atlas maps
matlabbatch{mi}.spm.tools.cat.estwrite.output.sROImenu.satlases.Desikan    = 0;    % the major structures are similar enough that surface-based registration works quite well over larger primates 
matlabbatch{mi}.spm.tools.cat.estwrite.output.sROImenu.satlases.Destrieux  = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.sROImenu.satlases.HCP        = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.sROImenu.satlases.Schaefer2018_100P_17N = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.sROImenu.satlases.Schaefer2018_200P_17N = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.sROImenu.satlases.Schaefer2018_400P_17N = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.sROImenu.satlases.Schaefer2018_600P_17N = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.sROImenu.satlases.ownatlas   = {''};
% volume output
matlabbatch{mi}.spm.tools.cat.estwrite.output.GM.native                    = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.GM.warped                    = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.GM.mod                       = 1; % needed for VBM 
matlabbatch{mi}.spm.tools.cat.estwrite.output.GM.dartel                    = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.WM.native                    = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.WM.warped                    = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.WM.mod                       = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.WM.dartel                    = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.CSF.native                   = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.CSF.warped                   = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.CSF.mod                      = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.CSF.dartel                   = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.bias.native                  = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.bias.warped                  = 1;
matlabbatch{mi}.spm.tools.cat.estwrite.output.bias.dartel                  = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.jacobianwarped               = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.warps                        = [0 0];
% special maps (do not use)
matlabbatch{mi}.spm.tools.cat.estwrite.output.ct.native                    = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.ct.warped                    = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.ct.dartel                    = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.pp.native                    = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.pp.warped                    = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.pp.dartel                    = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.WMH.native                   = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.WMH.warped                   = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.WMH.mod                      = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.WMH.dartel                   = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.SL.native                    = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.SL.warped                    = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.SL.mod                       = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.SL.dartel                    = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.TPMC.native                  = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.TPMC.warped                  = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.TPMC.mod                     = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.TPMC.dartel                  = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.atlas.native                 = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.atlas.warped                 = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.atlas.dartel                 = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.label.native                 = 1;
matlabbatch{mi}.spm.tools.cat.estwrite.output.label.warped                 = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.label.dartel                 = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.las.native                   = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.las.warped                   = 0;
matlabbatch{mi}.spm.tools.cat.estwrite.output.las.dartel                   = 0;
%  ------------------------------------------------------------------------



%% smoothing
%  ------------------------------------------------------------------------
mi = mi + 1; mi_smoothing = mi;
matlabbatch{mi}.spm.spatial.smooth.data(1)                                 = ...
  cfg_dep('CAT12: Segmentation: mwp1 Image', substruct('.','val', '{}',{mi_pp}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','mwp', '()',{':'}));
matlabbatch{mi}.spm.spatial.smooth.fwhm                                    = repmat(4,1,3);  % smoothing filter size
matlabbatch{mi}.spm.spatial.smooth.dtype                                   = 0;
matlabbatch{mi}.spm.spatial.smooth.im                                      = 0;
matlabbatch{mi}.spm.spatial.smooth.prefix                                  = 's';
%  ------------------------------------------------------------------------




%% TIV extraction
%  ------------------------------------------------------------------------
mi = mi + 1; mi_tiv = mi; 
matlabbatch{mi}.spm.tools.cat.tools.calcvol.data_xml(1)                    = ...
  cfg_dep('CAT12: Segmentation: CAT log-file', substruct('.','val', '{}',{mi_pp}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','catxml', '()',{':'}));
matlabbatch{mi}.spm.tools.cat.tools.calcvol.calcvol_TIV                    = 1;
matlabbatch{mi}.spm.tools.cat.tools.calcvol.calcvol_name                   = 'TIV.txt';
%  ------------------------------------------------------------------------






%% statistic design
%  ------------------------------------------------------------------------
%  we use age, sex, and fieldstrength as main confounds 
%  ------------------------------------------------------------------------
mi = mi + 1; mi_design = mi;
matlabbatch{mi}.spm.stats.factorial_design.dir                             = {fullfile(Pdir_cimp,'stat')};
matlabbatch{mi}.spm.stats.factorial_design.des.mreg.scans(1)               = ...
  cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{mi_smoothing}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{mi}.spm.stats.factorial_design.des.mreg.mcov(1).c = [23
                                                                13
                                                                19
                                                                15
                                                                25
                                                                21
                                                                43
                                                                19
                                                                20
                                                                18];
matlabbatch{mi}.spm.stats.factorial_design.des.mreg.mcov(1).cname          = 'age';
matlabbatch{mi}.spm.stats.factorial_design.des.mreg.mcov(1).iCC            = 5; % do not center
matlabbatch{mi}.spm.stats.factorial_design.des.mreg.incint                 = 1;
matlabbatch{mi}.spm.stats.factorial_design.cov(1).c                        = ...
    cfg_dep('Estimate TIV and global tissue volumes: TIV', substruct('.','val', '{}',{mi_tiv}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','calcvol', '()',{':'}));
matlabbatch{mi}.spm.stats.factorial_design.cov(1).cname                    = 'TIV';
matlabbatch{mi}.spm.stats.factorial_design.cov(1).iCFI                     = 1;
matlabbatch{mi}.spm.stats.factorial_design.cov(1).iCC                      = 1;
matlabbatch{mi}.spm.stats.factorial_design.cov(2).c                        = [1 1 1 1 1 0 0 0 0 0];
matlabbatch{mi}.spm.stats.factorial_design.cov(2).cname                    = 'sex';
matlabbatch{mi}.spm.stats.factorial_design.cov(2).iCFI                     = 2;
matlabbatch{mi}.spm.stats.factorial_design.cov(2).iCC                      = 1;
matlabbatch{mi}.spm.stats.factorial_design.multi_cov                       = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{mi}.spm.stats.factorial_design.masking.tm.tm_none              = 1;
matlabbatch{mi}.spm.stats.factorial_design.masking.im                      = 1;
matlabbatch{5}.spm.stats.factorial_design.masking.em                       = {fullfile(cattempdir,'chimpanzee_brainmask.nii,1')};
matlabbatch{mi}.spm.stats.factorial_design.globalc.g_omit                  = 1;
matlabbatch{mi}.spm.stats.factorial_design.globalm.gmsca.gmsca_no          = 1;
matlabbatch{mi}.spm.stats.factorial_design.globalm.glonorm                 = 1;
%  ------------------------------------------------------------------------


%% specify design
%  ------------------------------------------------------------------------
mi = mi + 1; 
matlabbatch{mi}.spm.stats.fmri_est.spmmat(1)                               = ...
  cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{mi_design}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{mi}.spm.stats.fmri_est.write_residuals                         = 0;
matlabbatch{mi}.spm.stats.fmri_est.method.Classical                        = 1;
%  ------------------------------------------------------------------------




%% specify design
%  ------------------------------------------------------------------------
%  Simple GM atrophy contrast.
%  ------------------------------------------------------------------------
mi = mi + 1; 
matlabbatch{mi}.spm.stats.con.spmmat(1)                                    = ...
  cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{mi-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{mi}.spm.stats.con.consess{1}.tcon.name                         = 'aging';
matlabbatch{mi}.spm.stats.con.consess{1}.tcon.weights                      = [0 0 0 -1]; % GM atrophy [mn TIV sex-female age]
matlabbatch{mi}.spm.stats.con.consess{1}.tcon.sessrep                      = 'none';
matlabbatch{mi}.spm.stats.con.delete                                       = 1;
%  ------------------------------------------------------------------------




%% render results
%  ------------------------------------------------------------------------
%  We use a low threshold without correction as far as we only have 10 
%  subjects and just want to show the basic idea.
%  Render the contrast as ps and png.
%  ------------------------------------------------------------------------
mi = mi + 1; 
matlabbatch{mi}.spm.stats.results.spmmat(1)                                = ...
  cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{mi-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{mi}.spm.stats.results.conspec.titlestr                         = '';
matlabbatch{mi}.spm.stats.results.conspec.contrasts                        = 1;
matlabbatch{mi}.spm.stats.results.conspec.threshdesc                       = 'none';
matlabbatch{mi}.spm.stats.results.conspec.thresh                           = 0.001;
matlabbatch{mi}.spm.stats.results.conspec.extent                           = 5;
atlabbatch{mi}.spm.stats.results.conspec.conjunction                       = 1;
matlabbatch{mi}.spm.stats.results.conspec.mask.none                        = 1;
matlabbatch{mi}.spm.stats.results.units                                    = 1;
matlabbatch{mi}.spm.stats.results.export{1}.ps                             = true;
matlabbatch{mi}.spm.stats.results.export{2}.png                            = true;
%  ------------------------------------------------------------------------
