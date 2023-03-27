% -------------------------------------------------------------------------
% It directly generate (range, velocity, azimuth, elevation) for all joints
% -------------------------------------------------------------------------
clear all; close all; clc;
addpath(genpath('../0010_matlab_main_imports/')); %mbpdy library
% -------------------------------------------------------------------------
% Based on chirp parameters we compute the expected resolution:
% -------------------------------------------------------------------------
rf.c = 2.99e8;
rf.fc = 77e9;
rf.lambda = rf.c/rf.fc;
rf.ADC_BW = 5e6;
rf.dt = 1/rf.ADC_BW;

%--------------------------------
% modifiable parameters:
%--------------------------------
chirp.S = 62e6/1e-6; % MHz/us
chirp.idle =100e-6; % usec:
chirp.adc_start = 5e-6; %usec
chirp.Nsamp_range = 128;
chirp.ramp_end = 30.7e-6; %usec


chirp.B_effective = chirp.S*chirp.Nsamp_range*rf.dt;
chirp.B_ramp = chirp.S*chirp.ramp_end;
chirp.duration = chirp.idle + chirp.ramp_end;
chirp.adc_start_plus_samples = chirp.adc_start + chirp.Nsamp_range*rf.dt;
chirp

assert(chirp.ramp_end > chirp.adc_start_plus_samples,...
    'Ramp duration cannot be smaller than sampling-part of chirp, decrease number of adc_samples, or increase rate');

% doppler resolution:
frame.tx_seq = [1];
frame.Nsamp_doppler= 128;
frame.rate = 33.6e-3/2;
Tcri = size(frame.tx_seq,2)*chirp.duration;
frame.duration = Tcri*frame.Nsamp_doppler;
frame.duty_cycle = ceil((frame.duration/frame.rate)*100);


cube.range_res = rf.c/(chirp.B_effective);
cube.range_max = cube.range_res*chirp.Nsamp_range;
cube.doppler_res = rf.lambda/(2*frame.Nsamp_doppler*Tcri);
cube.doppler_max = cube.doppler_res*(frame.Nsamp_doppler/2);


Ntx = size(frame.tx_seq,2);
BW = ceil(chirp.B_effective/1e9);
duty_cycle = ceil(frame.duty_cycle);


% -----------------------------------------------------------------------
% Format for readeability:
% -----------------------------------------------------------------------
cfg_name = ['./rdr_cfg_files/tx',num2str(Ntx),'_BW_',num2str(BW),...
            '_FR_',num2str(duty_cycle),'.mat'];

chirp_o.S_MHz_us = chirp.S/(1e6/1e-6);
chirp_o.idle_us = chirp.idle/(1e-6);
chirp_o.adc_start_us = chirp.adc_start/(1e-6);
chirp_o.Nsamp_range = chirp.Nsamp_range;
chirp_o.ramp_end_us = chirp.ramp_end/(1e-6);
chirp_o.B_effective_Ghz = chirp.B_effective/(1e9);
chirp_o.B_ramp_Ghz = chirp.B_ramp/(1e9);
chirp_o.duration_us = chirp.duration/(1e-6);


frame.rate_ms = frame.rate/(1e-3);
frame.duration_ms = frame.duration/(1e-3);
frame.Nfr_5sec = 5/frame.duration;


save(cfg_name,'chirp_o','frame', 'cube');

clc;
chirp_o
frame
cube



