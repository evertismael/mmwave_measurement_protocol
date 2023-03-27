clear all; clc; close all;
addpath(genpath('MatlabExamples'));
addpath(genpath('./meas_libs/'));

% -------------------------------------------------------------------------
% convert from bin to mat file:
% -------------------------------------------------------------------------
dataset_path = 'C:\ti\mmwave_studio_02_01_01_00\mmWaveStudio\PostProc\dts_01\';
cfg_file = [dataset_path, 'cfg.setup.json'];
trial = 'adc_data_03';

%dataset_path = './20230124_dataset/';
%cfg_file = [dataset_path, 'trial_y.setup.json'];
%trial = 'away_towards_01';

bin_file = [dataset_path, trial,'.bin'];
mat_file = [dataset_path, trial,'.mat'];
rawDataReader(cfg_file, bin_file, mat_file, 0);
verify_data(mat_file);
disp('Finished reading data:');

%%
tmp = load(mat_file);
if strcmp(tmp.file_stage, 'out_rawDataReader')
    disp('adapting/permuting axes + converting into if-signal')
    sz_ = size(tmp.radarCube.data{1});
    [Nchirps, Nrx, Nrng] = deal(sz_(1), sz_(2), sz_(3));
    Nfr = size(tmp.radarCube.data,2);
    
    if_rngprof = cat(4,tmp.radarCube.data{:});
    % from (dplr, rx, rng, fr) to : (rng, dplr, rx, fr)
    if_rngprof = permute(if_rngprof,[3,1,2,4]);
    if_cube_all_tx = ifft(if_rngprof,[],1);

    file_stage = 'out_0010_bin2mat';
    rfParams = tmp.radarCube.rfParams;
    dim = tmp.radarCube.dim;
    save( mat_file, 'if_cube_all_tx', 'file_stage','rfParams','dim',  '-v7.3');
    disp('.mat file overwritten with good format');
elseif strcmp(tmp.file_stage, 'out_0010_bin2mat')
    disp('*** already in good format')
    sz_ = size(tmp.if_cube);
    [Nchirps, Nrx, Nrng, Nfr] = deal(sz_(1), sz_(2), sz_(3),sz_(4));
    if_cube_all_tx = tmp.if_cube_all_tx;
    rfParams = tmp.rfParams;
    dim = tmp.dim;
end


%%
addpath(genpath('../0010_matlab_main_imports_beta/'));
Ntx = dim.numTxAnt;
BW = 4;
duty_cycle = 100;
cfg_name = ['./rdr_cfg_files/tx',num2str(Ntx),'_BW_',num2str(BW),...
            '_FR_',num2str(duty_cycle),'.mat'];
tmp_cfg = load(cfg_name);
rdr = recover_radar_from_ti_exp(dim, rfParams, tmp_cfg);

if_cubes = if_cube_separate_per_tx(if_cube_all_tx, rdr);
if_cube = if_cubes{1};

% radar processing:
rwind = 10;
[rdm, rdm_gs] = if_cube_to_rdm(if_cube, rdr);
[rpm, rpm_gs] = if_cube_to_range_profile(if_cube, rdr);
[winL, hop, Nfft_dtm] = deal(512, 128, 512);
[dsm, dsm_gs] = if_cube_to_doppler_spectrogram(rpm, rdr, winL, hop, Nfft_dtm, rwind);
[ram, ram_gs] = if_rdm_to_ram(rdm, rdr, rdm_gs);
%%
Nrx_sel = 1;
rng_lim = [0 12];      % in m
vel_lim = [-7 7];      % in m/s
azim_lim = [-20 20];   % in deg
ifRdrMon = IfRdrMonitor(rng_lim, vel_lim, azim_lim);
ifRdrMon = ifRdrMon.draw_rdm(rdm, rdm_gs, Nrx_sel);
ifRdrMon = ifRdrMon.draw_range_profile(rpm, rpm_gs, Nrx_sel);
ifRdrMon = ifRdrMon.draw_doppler_spect(dsm, dsm_gs, Nrx_sel);
ifRdrMon = ifRdrMon.draw_range_azim(ram, ram_gs);
'';
for t_idx = 1:1:size(rdm,4)
    ifRdrMon = ifRdrMon.update_rdm(rdm, rdm_gs,Nrx_sel, t_idx);
    ifRdrMon = ifRdrMon.update_range_azim(ram, ram_gs, t_idx);
    pause(0.0005); %pause(1/120);
end