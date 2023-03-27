% -------------------------------------------------------------------------
% It loads the if signal and converts it into RDmaps, Spectrograms, etc
% -------------------------------------------------------------------------
clear all; close all; clc;
addpath(genpath('./0010_matlab_main_imports/')); % mbody&radar processing library
addpath(genpath('./meas_libs/'));
% -------------------------------------------------------------------------
% 0010: Load data from if_cube file, and reconstruct rdr from file
% -------------------------------------------------------------------------
dataset_path = './Dataset/';
trial = 'adc_data_03';
BW = 4;
duty_cycle = 100;

% ------------------------------------------------------------------------
mat_file = [dataset_path, trial,'.mat'];
tmp = load(mat_file);

if strcmp(tmp.file_stage, 'out_0010_bin2mat')
    disp('*** already in good format')
    sz_ = size(tmp.if_cube_all_tx);
    [Nchirps, Nrx, Nrng, Nfr] = deal(sz_(1), sz_(2), sz_(3),sz_(4));
    if_cube_all_tx = tmp.if_cube_all_tx;
    rfParams = tmp.rfParams;
    dim = tmp.dim;
else
    error('Ensure: file_stage==out_0010_bin2mat');
end

%%
% -------------------------------------------------------------------------
% 0020: separate azimuth antennas and TD chirps
% -------------------------------------------------------------------------
Ntx = dim.numTxAnt;
cfg_name = ['./rdr_cfg_files/tx',num2str(Ntx),'_BW_',num2str(BW),...
            '_FR_',num2str(duty_cycle),'.mat'];
tmp_cfg = load(cfg_name);
rdr = recover_radar_from_ti_exp(dim, rfParams, tmp_cfg);
if_cubes = if_cube_separate_per_tx(if_cube_all_tx, rdr);
if_cube = if_cubes{1};

%%
% -------------------------------------------------------------------------
% radar processing:
% -------------------------------------------------------------------------
rwind = 10;
[rdm, rdm_gs] = if_cube_to_rdm(if_cube, rdr);
[rpm, rpm_gs] = if_cube_to_range_profile(if_cube, rdr);
[winL, hop, Nfft_dtm] = deal(256, 128, 128*2*2);
[dsm, dsm_gs] = if_cube_to_doppler_spectrogram(rpm, rdr, winL, hop, Nfft_dtm,rwind);
[ram, ram_gs] = if_rdm_to_ram(rdm, rdr, rdm_gs);


%%
Nrx_sel = 1;
rng_lim = [0 12];      % in m
vel_lim = [-7 7];      % in m/s
azim_lim = [-90 90];   % in deg
ifRdrMon = IfRdrMonitor(rng_lim, vel_lim, azim_lim);
ifRdrMon = ifRdrMon.draw_rdm(rdm, rdm_gs, Nrx_sel);
ifRdrMon = ifRdrMon.draw_range_profile(rpm, rpm_gs, Nrx_sel);
ifRdrMon = ifRdrMon.draw_doppler_spect(dsm, dsm_gs, Nrx_sel);
ifRdrMon = ifRdrMon.draw_range_azim(ram, ram_gs);
'';
for t_idx = 1:1:size(rdm,4)
    ifRdrMon = ifRdrMon.update_rdm(rdm, rdm_gs,Nrx_sel, t_idx);
    ifRdrMon = ifRdrMon.update_range_azim(ram, ram_gs, t_idx);
    pause(0.02); %pause(1/120);
end

%%
