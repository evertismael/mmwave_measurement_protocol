function burst = burst_from_ti_exp(rdim, rfp)
    
    % --------------------------------------------------------------------
    % CHIRP frame:
    % --------------------------------------------------------------------
    burst.fc = rfp.startFreq*1e9;
    burst.S = rfp.freqSlope*1e6/1e-6; % MHz/us
    burst.ADC = 5e6;

    burst.Nsamp_range = rfp.numRangeBins;
    burst.Nsamp_doppler = rfp.numDopplerBins;
    
    burst.idle_chirp = 60e-6;
    burst.idle_frame = 0; % no dummy chirp
    
    % rdm construction params:
    burst.Nfft_range = rfp.numRangeBins;
    burst.Nfft_doppler = rfp.numDopplerBins;   
    
    
    % --- derivated params:
    burst.dt = 1/burst.ADC;
    burst.Nsamp_idle_chirp = round(burst.idle_chirp/burst.dt);
    burst.Nsamp_idle_frame = round(burst.idle_frame/burst.dt);
    burst.Nsamp_frame = (burst.Nsamp_range + burst.Nsamp_idle_chirp)*burst.Nsamp_doppler + burst.Nsamp_idle_frame;
    burst.dt_frame = burst.Nsamp_frame*burst.dt;
    
    burst.Nsamp_chirp_plus_idle = burst.Nsamp_range + burst.Nsamp_idle_chirp;
    
    % IF generation:
    burst.mask_idle_samples = false;


    % derived parameters:
    glbp = glb_prms();
    burst.B = burst.S*burst.Nsamp_range*burst.dt;
    burst.range_res = glbp.c/(2*burst.B);
    burst.range_max = (0.9*burst.ADC*glbp.c)/(2*burst.S);


    burst.lambda = glbp.c/burst.fc;
    T_chirp = (burst.Nsamp_chirp_plus_idle)*burst.dt;
    if rdim.numTxAnt > 1
        burst.chirp_seq = 1:rdim.numTxAnt;
        Tcri = T_chirp*size(burst.chirp_seq,2);
    else
        burst.chirp_seq = [1];
        Tcri = T_chirp;
    end    
    burst.doppler_res = burst.lambda/(2*burst.Nsamp_doppler*Tcri);
    burst.doppler_max = burst.lambda/(4*Tcri);
end



