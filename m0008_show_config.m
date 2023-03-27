% -------------------------------------------------------------------------
% It directly generate (range, velocity, azimuth, elevation) for all joints
% -------------------------------------------------------------------------
clear all; close all; clc;
Ntx = 1;
BW = 4;
duty_cycle = 100;

cfg_name = ['./rdr_cfg_files/tx',num2str(Ntx),'_BW_',num2str(BW),...
            '_FR_',num2str(duty_cycle),'.mat'];
load(cfg_name);

clc;
cfg_name
chirp_o
frame
cube



