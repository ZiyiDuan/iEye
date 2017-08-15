function ii_preproc(edf_fn)
% Generic script for pre-processing memory-guided saccade data. This script
% assumes the data is already imported in iEye. It addresses the following
% issues: The Y channel is inverted to its correct orientation, the data is
% then blink-corrected and slightly smoothed. Finally, the data is scaled
% and re-calibrated.

% edited TCS & GH 8/25/2016


if nargin < 1
    edf_fn = 'examples/exdata1.edf';
end



% initialize iEye - make sure paths are correct, etc
ii_init;



% import data
[ii_data,ii_cfg] = ii_import_edf(edf_fn,'examples/p_1000hz.ifg',[edf_fn(1:end-3) 'mat']);

% Show only the channels we care about at the moment
%ii_view_channels('X,Y,TarX,TarY,XDAT');

% rescale X, Y based on screen info
[ii_data,ii_cfg] = ii_rescale(ii_data,ii_cfg,{'X','Y'},[1280 1024],34.1445);



% Invert Y channel (the eye-tracker spits out flipped Y values)
[ii_data,ii_cfg] = ii_invert(ii_data,ii_cfg,'Y');

% Correct for blinks

[ii_data, ii_cfg] = ii_blinkcorrect(ii_data,ii_cfg,{'X','Y'},'Pupil',1500,50,50); % maybe 50, 50? %altering this 6/1/2017 from 1800 in both x/y 


% split into individual trials (so that individual-trial corrections can be
% applied)
[ii_data,ii_cfg] = ii_definetrial(ii_data,ii_cfg,'XDAT',1,'XDAT',8); % CHECK THIS!



% Smooth data
[ii_data,ii_cfg] = ii_smooth(ii_data,ii_cfg,{'X','Y'},'Gaussian',5);


% compute velocity using the smoothed data
[ii_data,ii_cfg] = ii_velocity(ii_data,ii_cfg,'X_smooth','Y_smooth');


% look for saccades
[ii_data,ii_cfg] = ii_findsaccades(ii_data,ii_cfg,'X_smooth','Y_smooth',30,.030,1.5); 



% find fixation epochs (between saccades and blinks)
% [create X_fix, Y_fix channels? these could be overlaid with 'raw' data as
% 'stable' eye positions




% find saccade start/endpoints - these are different from fixations, which
% are quantified via mean/median over entire non-saccade interval, but
% ignore fixational eye movements. these may be more useful for MGS
% scoring, while fixation average positions (above) may be more useful for
% adjusting for drift, etc.




% % Make initial selections for calibration (Corrective saccade)
% ii_selectbyvalue('TarX',2,0);
% ii_selectstretch(-400,0);
% 
% % Hold these 
% ii_selecthold;

% Select fixations
ii_selectbyvalue('XDAT',1,1);
%ii_selectstretch(-250,-250); % SAMPLES, NOT MS!!!!! (for now)
ii_selectstretch(-125,-125); % SAMPLES, NOT MS!!!!! (for now)

% Hold these 
ii_selecthold;

% Make initial selections for calibration (Corrective saccade)
ii_selectbyvalue('XDAT',1,5);
%ii_selectstretch(-400,0);
ii_selectstretch(-200,0);

% Merge fixation selections with corrective saccades
ii_selectmerge;

%%%%%%%%%%%%%%%
%% IMPORTANT!! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%
%
% At this point it is vital to manually check that the selections are
% correct before calibration. It is likelY theY are not 100% accurate due
% to differences in individual subject behavior.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make sure TarX, TarY are 0 at XDAT = 1:
% TarX(XDAT==1) = 0;TarY(XDAT==1)=0;

% Once selections are finalized, we calibrate.
ii_calibrateto('X','TarX',3);
ii_calibrateto('Y','TarY',3);

% Empty selections
ii_selectempty;

% Get and store eye-movement velocity
ii_velocity('X','Y');

disp ('save me!');

% Now save me!
end