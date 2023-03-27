function rdr = recover_radar_from_ti_exp(rdim, rfp, tmp_cfg)
    rdrp = burst_prms_from_ti_cfg(rdim, rfp, tmp_cfg);

    [rdr_p0, rdr_rot_ZYX_deg] = deal([0, 0,  0.5].', [0, 0, 0]); 
    rdr = Radar(rdr_p0, rdr_rot_ZYX_deg, rdrp);
end

