% EEGLAB version v2022.2

%% Part A: Pre-processing
%% STEP 1: SET UP THE APPROPRIATE PATH STRUCTURE AND DEFINITIONS - GO
% analysing Go/NoGo data, you might need to concatinate two datasets
clc;clear all;close all

% Define subject in the CW folder under the data folder before running the
% following commands!

addpath('/Users/alband/Desktop/Uni Yr2/Term 2/Electrophysiology/EEGLAB/eeglab/')

datafolder = './data/CW/eeg/';
datafolder2 = './data/processed/'; %folder for saved data

% Input the subject number
subject = 'S01';

%Below we process the datasets from all conditions
dataset1 = [datafolder subject '_go.bdf'];

% Initializing eeglab
[ALLEEG, EEG, CURRENTSET,ALLCOM]=eeglab;

%loading and transforming dataset1 from bdf to set
EEG = pop_biosig([dataset1], 'ref',[69 70] ,'refoptions',{'keepref','off'});
EEG.setname=[subject '__go.set'];

[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);

%Update the GUI Interface and verify if the data is displayed correctly

eeglab redraw

%Plot the dataset to inspect the signal, 
%Remove DC offset (Display tab) and change scale to 100mV bottom

pop_eegplot( EEG, 1, 1, 1);

EEG = pop_mergeset( ALLEEG, [1 2], 1);

% Add triggers 
EEG = adjusttriggers(EEG) 

%Saving the file
EEG = pop_editset(EEG, 'setname', [subject '_go.set']);
EEG = pop_saveset( EEG, 'filename',[subject '_go.set'],'filepath', [datafolder2]);


%% # STEP 2: Downsampling
% Downsample and save the new dataset

EEG = pop_resample( EEG, 256);

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off');

EEG = pop_editset(EEG, 'setname', [datafolder subject '_ds.set']);
EEG = pop_saveset( EEG, 'filename',[datafolder2 subject '_ds.set']);

eeglab redraw

%% # STEP 3: Channel locations
% Check the channel locations for each ptp
% Go into the GUI, select edit and check the channel locations. 
% Are coordinates there? If not, run the following command.

EEG=pop_chanedit(EEG, 'lookup','Standard-10-5-Cap385_witheog.elp');

EEG = eeg_checkset( EEG );

% Create bipolar VEOG and bipolar HEOG channel and add them to the dataset.

EEG = pop_eegchanoperator( EEG, {'ch34=ch31-ch32 label Hbipo' 'ch35=ch33-ch16 label Vbipo'});

[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%signal is the difference between 2 electrodes.
% Thus their should be one bipolar channel for 2 electrodes.
% Plot the dataset to inspect the signal

pop_eegplot( EEG, 1, 1, 1);

%Check and remove bad/non-required channels. 
% Check for flat channels, channels loosing touch and drifting or very noisy channels
% Change the channels with the code below if any are noisy

EEG = pop_select( EEG, 'nochannel',{'EXG7','EXG8'});

[ALLEEG, EEG] = eeg_store( ALLEEG, EEG, CURRENTSET );

% plot the dataset to inspect the signal

pop_eegplot( EEG, 1, 1, 1);

% re-reference to the average. 
% Change 69 and 70 for all participants as the refferance, instead of 30 32

EEG = pop_reref( EEG, [],'exclude',[65 66 67 68 69 70] );

% plot the dataset to inspect the signal

pop_eegplot( EEG, 1, 1, 1);

%Applying a HPF (high - pass filter) to remove low FQ
% leave high pass filter as 0.1 Hz, backed up by research

EEG = pop_basicfilter( EEG, 1:68, 'Cutoff', 0.1, 'Design',...
'butter', 'Filter', 'highpass', 'Order', 2, 'RemoveDC','on' );

[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%save the dataset
EEG = pop_editset(EEG, 'setname', [subject '_ch.set']);
EEG = pop_saveset( EEG, 'filename',[datafolder2 subject '_ch.set']);


% update the GUI Interface
eeglab redraw
pop_eegplot( EEG, 1, 1, 1);

%% STEP 4: CREATING EVENTLISTS

% 1. EVENTLIST with just numeric data
% Creating an eventlist, add it to the current EEG structure and save a
% text file (elist.txt). 
 
% Create a new text file, I named it GoNogo_BDF.txt and change the
% condtions to Go and No go. 
% For the Go it goes from 101, used 200-750 times for the condtions.

EEG = pop_creabasiceventlist( EEG , 'Eventlist', [subject '_elist.txt'], ...
'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Warning', 'on' );

[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

EEG = pop_binlister(EEG, 'BDF', './data/CW/eeg/GoNogo_BDF.txt', ...
'ExportEL', 'Go_elist.txt', ...
'ImportEL', 'no', 'Saveas', 'off', 'SendEL2', 'EEG&Text', 'Warning', 'on');

% Save new EEG set
EEG = pop_editset(EEG, 'setname', [subject '_bin.set']);
EEG = pop_saveset( EEG, 'filename',[datafolder2 subject '_bin.set']);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

% update the GUI Interface
eeglab redraw

%% STEP 5: Creating Bin-based epochs
% Divide the continous EEG into a set of fixed-length epochs,
% each of which is time-locked to the event given in the BIN
% Extracts bin-based epoch from -500 ms to +1000 ms

EEG = pop_epochbin( EEG , [-500.0 1000.0], 'pre')

%cd("./data/processed/")
% load the new data set in your GUI

eeglab redraw

% verify that the new data set is active. What changed?

pop_eegplot(EEG,1,1,1);

%LowPass filtering the epoched data for ICA. 
% Accoridng to lit, changed low pass filter to 16 Hz 
EEG = pop_eegfiltnew( EEG, 0, 30);

%Second epoching of the dataset
EEG = pop_epochbin( EEG, [-200 800], 'pre');

[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%Using mean whole epoch as baseline, remove baseline from whole epoch.

EEG = pop_rmbase( EEG, []);
[ALLEEG EEG ] = eeg_store(ALLEEG, EEG, CURRENTSET);

% Save new EEG set
EEG = pop_editset(EEG, 'setname', [subject '_ep.set']);
%cd('../../../')
EEG = pop_saveset( EEG, 'filename',[datafolder2 subject '_ep.set']);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

%EXPLORE DATASET
pop_eegplot(EEG, 1,1,1,1)

%% STEP 6: Check for gross artefacts
% Test period [-200 798]. Voltage threshold 400uV
% Movin window width: 200 ms. Window step: 50. Channels 1:32
% Mark flags 1 and 2 (you must always mark flag 1). Check afterwards the
% elist file and see if you can find the flags.

EEG = pop_artmwppth( EEG , 'Channel', 1:64, 'Flag', [1 2], 'Review', 'on', ...
'Threshold', 400, 'Twindow', [ -200 798], 'Windowsize', 200, 'Windowstep', 50 );

% save the marked set
EEG = pop_editset(EEG, 'setname', [subject '_ar.set']);
EEG = pop_saveset( EEG, 'filename',[datafolder2 subject '_ar.set']);



%% Part B: ICA Indipendant component analysis 
%% STEP 1: SET UP THE APPROPRIATE PATH STRUCTURE AND DEFINITIONS

% clear your command window and your workspace
clc;clear all;close all

datafolder = './data/CW/eeg/';
datafolder = './data/processed/'; %folder for saved data

subject = 'S02';
datafile = '_ar.set';

%Open EEGLAB and ERPLAB Toolboxes
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

% Loading an existing data set - Creates a new ALLEEG dataset 1
% Load the raw continuous EEG data file in .set EEGLAB file format

EEG = pop_loadset( 'filename', [subject datafile]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', [subject datafile], 'gui', 'off');

%% # STEP 2: run ICA  
EEG = pop_runica(EEG, 'extended',1,'chanind',[1:(length(EEG.chanlocs)-4)], ...
        'concatenate', 'off');               

% SAVE THE FILE WITH THE ICA WEIGHTS
ICADataset = [subject '_ica.set'];
EEG = pop_saveset( EEG, 'filename',ICADataset);

%plot the outcome. 
pop_eegplot( EEG, 0, 0, 0);

%% Step 3: Exploring components. 
% Check the following webpage for refferaence 
% https://labeling.ucsd.edu/tutorial

pop_selectcomps(EEG, [1:(length(EEG.chanlocs)-4)] );
pop_topoplot(EEG, 0, [1:(length(EEG.chanlocs)-4)] ,'.//data//CW//eeg////1_ICA.set',[5 6] ,0,'electrodes','on');

% % save the erp image of component 1
 figure; pop_erpimage(EEG,0, [1],[[]],'Comp. 1',6,2,{},[],'' ...
     ,'yerplabel','','erp','on','cbar','on','topo', ...
     { mean(EEG.icawinv(:,[1]),2) EEG.chanlocs EEG.chaninfo } );
 
 %Save the erp image of component 2
 figure; pop_erpimage(EEG,0, [2],[[]],'Comp. 2',6,1,{},[],'' ...
     ,'yerplabel','','erp','on','cbar','on','topo', ...
     { mean(EEG.icawinv(:,[2]),2) EEG.chanlocs EEG.chaninfo } );
 
 %Save a pdf of the topographic maps of the ICA weights for later review
     set(groot,'DefaultFigureColormap',jet)
     pop_topoplot(EEG, 0, [1:(length(EEG.chanlocs)-4)],[subject '_ica.set'], [6 6] ,0,'electrodes','on');
     save2pdf([subject '_ICA_Weights.pdf']);

%Step 4: ICLabel 
 Go to the GUI, select the File Tab and manage eeglab extensions.
 Install ICLabel and run afterwards the following commands. Explore the
 components again
     EEG = pop_iclabel(EEG, 'default');
     pop_selectcomps(EEG, [1:(length(EEG.chanlocs)-4)]);

%Flag the component  identified as eye-blink. 
% Components with ICLabel - Flag components as artefacts
     EEG = pop_icflag(EEG, [NaN NaN;NaN NaN;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);

%% Step 5: Remove the component(s) you identify as eye-blinks
% First use the GUI and select Tools - Remove Components - Select yes - and then Plot ERPs. 
% Check the two timecourses (before ICA and cleaned)
     
% Change the number to the component you want to remove if you are not using the GUI
    EEG = pop_subcomp( EEG, [1], 0); 
     
% Save the new set    
     EEG.setname='./data/CW/eeg/1_icapr.set pruned with ICA';
     EEG = pop_saveset( EEG, 'filename',[subject '_clean.set']);

% Check the topoplots and the time course (adjust channel number!)
     pop_topoplot(EEG, 0, [1:29] ,'.//data//CW//eeg/1_icapr.set pruned with ICA',[5 6] ,0,'electrodes','on');
     pop_eegplot(EEG,1,1,1);

[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

eeglab redraw

EEG = pop_exporteegeventlist(EEG, [subject '_Export_EEG_EL.txt']);

%% Part C: ERP analysis
%% STEP 1: SET UP THE APPROPRIATE PATH STRUCTURE AND DEFINITIONS
% clear your command window and your workspace
clc;clear all;close all

eeglab redraw

file = './All Clean Data/Final ERP/LTA/';
subject = 'S03';
ptp.no = '3_'
datafile = '_clean.set';

%Open EEGLAB and ERPLAB Toolboxes
% Loading an existing data set
EEG = pop_loadset( 'filename', [file subject datafile]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', [file subject datafile], 'gui', 'off');

% plot the dataset to inspect the signal
pop_eegplot( EEG, 1, 1, 1);

%% Step 1 preparing for averaging
% deleting bipolar channels
EEG = pop_select( EEG, 'nochannel',{'Hbipo','Vbipo'}); 
[ALLEEG, EEG] = eeg_store( ALLEEG, EEG, CURRENTSET );

% synchronizing EEG.reject and EEG.EVENTLIST.eventinfo. If this command
% does not run, then use the GUI: ERPLab - Artefact detection in epoched
% data - synch artifacts - choose option 3
%EEG = pop_syncroartifacts(EEG, 3);
%EEG.setname='./data/wk8/5_sync.set';

% updating GUI
eeglab redraw

%% Step 2 Averaging ERPs
% To average the data use the following:
ERP = pop_averager( ALLEEG , 'Criterion', 1, 'DSindex',  1, 'SEM', 'on');

% In all of these examples, the 'Criterion' argument specifies how artifacts should be treated:
%             1 Exclude trials with artifacts (as in these example)
%             0 Include all trials (ignore artifact flags)
%             2 Include ONLY trials with artifacts 
 
% How many trials were rejected per bin (%)?
 EEG = pop_summary_AR_eeg_detection(EEG,[file subject '_summary.set']);

% Save  averaged ERPs in a new set
ERP = pop_savemyerp(ERP, 'erpname', [file ptp.no subject '_ERP'],'filename', [file ptp.no subject '_ERP.erp'], ...
                   'Warning', 'on');
erplab redraw

%% Step 3: Plotting average ERP waveforms
% ### explore the figure (in the toolbar you have several options). You can also save a pdf file of it

%Long command to plot ERPs
pop_ploterps( ERP, [ 1, 2],1:30 , 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], ...
            'BinNum', 'on', 'Blc', 'pre', 'Box', [ 6 5], 'ChLabel', 'on', ...
            'FontSizeChan',10, 'FontSizeLeg',10 , 'LegPos', 'bottom', ...
            'Linespec', {'k-' , 'r-' }, 'LineWidth',1, 'Maximize', 'on', ...
            'Position', [ 102.833 9.375 108.667 35.125], 'Style', 'Matlab', ...
            'xscale', [ -200.0 798.0 -100:170:750], 'YDir', 'normal', ...
            'yscale', [ -10.0 10.0 -10:5:10]);

%Short command to plot ERPs with default options
%pop_ploterps(ERP, [1,2], 1:30);
N2 = [4,38,39,11,47,46]

% Plot for N1 according to Xia
pop_ploterps(ERP, [1:2],[4,38,39,11,47,46,12,48,49],'AutoYlim', 'on', 'BinNum', 'on','Box', [3 3]);
save2pdf([file ptp.no subject '_N1_ERP.pdf'])

% Plot for P3 according to Xia
pop_ploterps(ERP, [1:2],[19,32,56,20,31,57,30],'AutoYlim', 'on', 'BinNum', 'on','Box', [3 3]);
save2pdf([file ptp.no subject '_P3_ERP.pdf'])

 %% Step 4: Creating difference waves 
%When you do this, average all HTA and all LTA (for go and no go) and
%Then calculat the differance waves between the 4 ( 2 N2, 2 P3)
% ERP bin operations
ERP = pop_binoperator( ERP, {'b3= b1-b2 label Rare minus Frequent difference wave' });  
 
 % Plotting ERP Waveforms from bin 3 with default parameters
 pop_ploterps( ERP, 3, 1:30); 
 pop_ploterps(ERP,[1,2,3],[1,2,3,4],'Box',[1 4]);
 
 % ### save plots as pdf. When you check the tab of the figure, you have
 % also the option to call the GUI and to plot the scalp topographie for a
 % given time point
 
 % saving ERP with new difference bin
 pop_savemyerp(ERP, 'erpname', [file subject '_ERPs_diff.set'], 'filename', [file subject '_ERPs_diff.erp'],'warning', 'off');
 ALLERP(CURRENTERP) = ERP;

%% Calculate descriptives 
%N2
% Measuring peak ampltidude and peak latency (time of peak amplitude) 
[Amp Lat] = pop_geterpvalues( ALLERP, [ 200 450],[1 2],N2 , 'Baseline', 'pre', 'Erpsets',1, ...
         'Filename', [file ptp.no subject 'peaklatencyN2.txt'], 'Fileformat', 'erpset', ...
         'Fracreplace', 'NaN', 'IncludeLat', 'no', 'Measure', 'peaklatbl', 'Neighborhood',10, ...
         'Peakpolarity', 'positive', 'Peakreplace', 'absolute', 'Resolution',2, 'Warning', 'on');

%Peak amplitude
ALLERP = pop_geterpvalues( ERP, [210 450],...
  [ 1 2],  N2 , 'Baseline', 'pre', 'Binlabel', 'on', 'FileFormat', 'wide', 'Filename',...
 [file ptp.no subject 'PeakAmplitudeN2.txt'], 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'peakampbl', 'Neighborhood',...
  3, 'PeakOnset',  1, 'Peakpolarity', 'positive', 'Peakreplace', 'absolute', 'Resolution',  3 );

% P3
% Peak latency
[Amp Lat] = pop_geterpvalues( ALLERP, [ 450 600],[1 2],P3 , 'Baseline', 'pre', 'Erpsets',1, ...
         'Filename', [file ptp.no subject 'peaklatencyP3.txt'], 'Fileformat', 'erpset', ...
         'Fracreplace', 'NaN', 'IncludeLat', 'no', 'Measure', 'peaklatbl', 'Neighborhood',10, ...
         'Peakpolarity', 'positive', 'Peakreplace', 'absolute', 'Resolution',2, 'Warning', 'on');

%Peak amplitude
ALLERP = pop_geterpvalues( ERP, [350 600],...
  [ 1 2],  P3 , 'Baseline', 'pre', 'Binlabel', 'on', 'FileFormat', 'wide', 'Filename',...
 [file ptp.no subject 'PeakAmplitudeP3.txt'], 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'peakampbl', 'Neighborhood',...
  3, 'PeakOnset',  1, 'Peakpolarity', 'positive', 'Peakreplace', 'absolute', 'Resolution',  3 );

% Save Stats Load new participant and start start again