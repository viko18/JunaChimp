%chimp10_preprocessing. Preprocessing of 10 example datasets with SPM/CAT
% ------------------------------------------------------------------------- 
% This script support the preprocessing of the 10 chimpanzees available at
%  * http://www.chimpanzeebrain.org/mri-datasets-for-direct-download
%
% It further requires: 
%  * SPM12   ( tested on R7771; https://www.fil.ion.ucl.ac.uk/spm/ )
%  * CAT12.7 ( tested on R1609; http://dbm.neuro.uni-jena.de/cat/ )
%  * Juna Chimp template ( http://junachimp.inm7.de ) 
%
% The files of the Juna Chimp template has to be copy into a
% "templates_animals" directory in the CAT directory of SPM:
%   ../spm/toolbox/cat12/templates_animals
% 
% The images are first realigned based on manual information. Next the main
% preprocessing script is called that include a VBM analysis. Finally, this
% script showed a global overview of aging in chimpanzees. 
% You can also open and adapt the "chimp10_preprocessing_batch" directly 
% in the SPM batch editor.
%
% However, the preprocessing of animals is not the main focus of CAT and 
% the ongoing development can lead to problems because primate pre-
% processing is not tested every time. If you have severe problems that 
% you cannot solve or found bugs, please contact us: 
%   robert.dahnke@uni-jena.de
%   christian.gaser@uni-jena.de
%
%
% == Additional images ==
% It is important to check preprocessing quality of each scan. Most 
% problems occur if the affine registration is in optimal and the TPM does
% not fit the data. If you add additional images you have to manually 
% correct their orientation, e.g.by using "SPM Display", 
% "SPM->Utils->Reorient Images" or other functions.
%
%
% == Our analyses described in the paper ==
% In our main analyis we used an manual preparation including (i) manual 
% definition of the orientation, (ii) N3 bias correction, and (iii) a 
% non-local interpolation approach to harmonize the input.  This allows 
% us to use quite "normal" and fast preprocessing parameters but requires 
% further functions.  Therefore, we have now optimized the SPM/CAT 
% parameters of the current SPM/CAT version to deal with the images 
% provided in the chimpanzeebrain.org example dataset. 
%
% ------------------------------------------------------------------------- 
% 202004 Robert Dahnke 


% ### ENTER YOUR OWN DOWNLOAD DIRECTORY HERE - OTHERWISE YOU HAVE TO SELECT IT VIA GUI ### 
global Pdir_cimp; % Pdir_cimp = '/Volumes/WD4TBE2/MRData/Chimp2020/10 sample Chimpanzee 3T for NCBR website test 2';  
Pdir_cimp = '/home/fhoffstaedter/WORK/Sam/manuscript/cat_pipeline/10NCBR';


% check for SPM and CAT12
if ~exist('spm','file')
  error('chimp10_preprocessing:missSPM', 'This script requires SPM available here: %s', ...
    spm_file('https://www.fil.ion.ucl.ac.uk/spm/','link','web(''%s'')') ); 
end
if ~exist('cat12','file')
  error('chimp10_preprocessing:missCAT','This script requires CAT12 available here: %s', ...
    spm_file('http://dbm.neuro.uni-jena.de/cat/','link','web(''%s'')') ); 
end
if ~exist( fullfile(spm('dir'),'toolbox','cat12','templates_animals','chimpanzee_TPM.nii') ,'file' )
  error('chimp10_preprocessing:missTPM','This script requires the Juna chimpanzee template available here: %s', ...
    spm_file('http://junachimp.inm7.de','link','web(''%s'')') ); 
end


% Start SPM and CAT in the chimpanzee mode (expert user) that set some 
% variables required in the preprocessing.
spm fmri, spm_cat12('chimpanzee');


% Add the directory of this script to the MATLAB path.
% Use the global variable to define files in the batch script.
addpath(fullfile(fileparts(which(mfilename))));




%% define main chimp directory 
%  ------------------------------------------------------------------------ 
%  check directoy
if ~exist(Pdir_cimp,'dir')
  Pdir_cimp   = spm_select([1 1],'dir','Select directory with the 10 chimps.');
end
if ~exist(Pdir_cimp, 'dir'), mkdir(Pdir_cimp,'stat'); end


% find input images
Pvols  = [cat_vol_findfiles(Pdir_cimp,'Female*.nii',struct('maxdepth',1));
          cat_vol_findfiles(Pdir_cimp,'Male*.nii'  ,struct('maxdepth',1))];
% if you did not found the files then check if zipped files        
if isempty(Pvols)
  Pvols  = [cat_vol_findfiles(Pdir_cimp,'Female*.nii.gz',struct('maxdepth',1));
            cat_vol_findfiles(Pdir_cimp,'Male*.nii.gz'  ,struct('maxdepth',1))];
  gunzip(Pvols); 
  Pvols  = [cat_vol_findfiles(Pdir_cimp,'Female*.nii',struct('maxdepth',1));
            cat_vol_findfiles(Pdir_cimp,'Male*.nii'  ,struct('maxdepth',1))];
end
% check input - if there not exactly 10 files something went wrong  
if numel(Pvols) ~= 10
  error('cat_batch_chimp10_preprocessing:badFileNumber','10 scans are expected but %d were found:\n  %s',...
    numel(Pvols), char(cat_io_strrep(Pvols,'.nii','.nii  '))' ); 
end




%% update / load orientation 
%  ------------------------------------------------------------------------
%  to run SPM/CAT the images have to be roughly in MNI space and the origin
%  (center point) has to be close to the AC.  Because this is not the case
%  in the downloadable files, we corrected the orientation manually and
%  saved the matrix in the *_orientation.mat files included here.
%  ------------------------------------------------------------------------
Vvols  = spm_vol( char(Pvols) );
Prvols = Pvols;
Pomat  = Pvols; 
try %#ok<TRYNC>
  copyfile('*ale*.mat',Pdir_cimp)
end
for fi = 1:numel(Pvols)
  % filenames
  [pp,ff,ee] = spm_fileparts( Pvols{fi} );
  Pomat{fi}  = fullfile( pp , [ff '_orientation.mat'] ); 
  Prvols{fi} = fullfile(pp,['r' ff ee]);
    
  if ~exist( Prvols{fi} , 'file' )
    if ~exist(Pomat{fi},'file')
    % If no orientation file is available than create it.
    % This is the case on our system with corrected files. 
      fprintf('Create "%s" orientation mat.\n',Pomat{fi});
      nmat = Vvols(fi).mat;
      save( Pomat{fi} , 'nmat' );
      copyfile( Pvols{fi} , Prvols{fi} ); 
      clear nmat
    else
    % This is the case where the original orientation is replaced by our
    % manual definition. 
      fprintf('Load "%s" orientation mat and write realign "r*.nii".\n',Pomat{fi});
      load( Pomat{fi} , 'nmat' ); 
      Y = spm_read_vols( Vvols(fi) ); 
      V = Vvols(fi); V.mat = nmat; 
      V.fname = Prvols{fi}; 
      spm_write_vol(V,Y);
      clear V Y nmat; 
    end
    clear pp ff; 
  end
end




%% main preprocessing batch 
%  ------------------------------------------------------------------------
%  This is the call of the main chimp preprocessing batch for the 10 chimp
%  example. It includes a (i) intensity normalization (the negative values 
%  were in-optimal), (ii) CAT preprocessing, (iii) smoothing, (iv) TIV
%  extraction, (v) definition of the statistical aging model and contrast,
%  and export of the results.
%
%  However, a statistical VBM analysis of only 10 subjects is not optimal  
%  and you will not see much. So we added a global analyses at the end of
%  this file.
%
%  You can also open the "chimp10_preprocessing_batch" batch in the SPM
%  batch editor to modify different settings on the GUI. 
%  ------------------------------------------------------------------------

  % load default batch
  chimp10_preprocessing_batch
  
  % remove old statistical results to avoid user interaction
  tdir = fullfile(Pdir_cimp,'stat'); 
  if exist( tdir , 'dir')
    oldfiles = cat_vol_findfiles( tdir , '*'); 
    for fi=1:numel(oldfiles), delete( oldfiles{fi} ); end
  end
  
  % prepare SPM and call processing
  spm_jobman('initcfg');
  spm_jobman('run',matlabbatch);

  


%% prepare results for some figures
%  ------------------------------------------------------------------------
%  This part prepares a struct with TIV, age, and other information.
%  ------------------------------------------------------------------------
Pxml = cat_vol_findfiles(fullfile(Pdir_cimp,'report'),'cat_*.xml');
xml  = cat_io_xml(Pxml);

Pxls = fullfile(Pdir_cimp,'Chimpanzee-Representative-Sample-t1as10.xls');
[num,txt,csv] =  xlsread(Pxls);
for i = 3:2:20
    csv{i,1}='';
    csv{i,2}='';
    csv{i,3}='';
    csv{i,4}='';
end
sym      = {'b+','ro'}; 
logscale = 0; % loglog scaling and normalization of variables 
for fi=1:numel(xml)
  [pp,ff,ee] = spm_fileparts( Pxml{fi} );
  res.TIV(fi)      = xml(fi).subjectmeasures.vol_TIV;
  res.aGMV(fi)     = xml(fi).subjectmeasures.vol_abs_CGW(2); 
  res.rGMV(fi)     = xml(fi).subjectmeasures.vol_abs_CGW(2) ./ res.TIV(fi);
  res.sname{fi}    = cat_io_strrep(ff,{'cat_intnorm_rFemale_','cat_intnorm_rMale_'},'');
  res.age(fi)      = csv{ find(cellfun('isempty',strfind(csv(2:end,2),res.sname{fi}))==0) + 1 , 3 };
  res.sex(fi)      = csv{ find(cellfun('isempty',strfind(csv(2:end,2),res.sname{fi}))==0) + 1 , 4 }(1)=='f';
  res.symbol(fi)   = sym(res.sex(fi)+1);
end


%  create and label figures 
%  ------------------------------------------------------------------------
val = {'age','rGMV'};
for ti=1:size(val,1)
  msk = ~isnan(res.(val{ti,1})) & ~isnan(res.(val{ti,2})); 
  r   = corrcoef(res.(val{ti,1})(msk),res.(val{ti,2})(msk));
  figure(100 + 2*ti + logscale), clf
  scatter(res.(val{ti,1})(res.sex==1),res.(val{ti,2})(res.sex==1),[],'ro'); hold on
  scatter(res.(val{ti,1})(res.sex==0),res.(val{ti,2})(res.sex==0),[],'b+');
  grid on;
  try
    md1 = fitlm(res.(val{ti,1}),res.(val{ti,2}));
    plot(md1)
  end
  title([val{ti,1} ' vs. ' val{ti,2} sprintf(' (r=%0.2f)',r(2))]); 
  xlabel(val{ti,1}); ylabel(val{ti,2}); 
  box on; 
  legend('female','male')
end
