# mmWave-TI measurement and processing protocol:

## Measurements:
> m0005_chirp_configuration.m:
> > It helps with the design of the chirp parameters like: Bandwith, Slope, idle time, etc. It outputs expected range/doppler resolutions and maximum values.
> > The ouput of this scirpt is saved in: ***['./rdr_cfg_files/tx' , num2str(Ntx) , '_BW_' , num2str(BW), '_FR_', num2str(duty_cycle), '.mat']***
> 
> m0008_show_config.m:
> > It show the required parameters that are input to the TI-mmWave Studio.
> > Their output are already in the required format.
> 
> ***Measurement Protocol:***
> > Notice that the Ti-mmave script that process the binary data overwrites the file. What is more, one can run the process twice without realizing and the data is lost for good. To avoid this issue, please follow the following protocol:
> > > 1. Follow the mmwave-studio instructions.
> > > 2. Create a separate folder in the output folder of the mmwave-studio.
> > > 3. Use 'Import_Export' tap to export the mmwave-studio configuration files in the folder created in step 2.
>  > > 4. In 'SensorConfig' tap, configure the output folder created in step 2.
>  > > 5. Make an small measurement and 'PostProc' to visualize the data. This ensures that only the first measurement will be overwriten with the ti-script.
>  > > 6. Change the number of measurement in the Browse of  'SensorConfig' tap, and take the next measurment. 
>  > > 7. Repeat 6 as many times as needed.
> > Notice that the bin files are stored in the most basic form, and they cannot directly be read in matlab. For the postprocessing follow use the next script.

## Post-Processing:
> m0010_bin2mat.m:
> > It reads the binary file and converts it to a mat file. The files contains the range profile of each chirp. The fast/range FFT was done using a hanning window.
> > The following parameters should be configured in the script:
> > > 1.  dataset_path: folder that contains all the bin file measurements and the mmwave json-configuration files.
> > > 2. cfg_file: change the name of the json-configuration file is needed.
> > > 3. trial: name of the bin-file of the experiment.
> > The output of this script is a  .mat file in the same folder: dataset_path. 
> m0020_radar_proc.m
> > It reads the .mat file that is the output of the previous script. It computes the RDM, doppler spectrogram, etc.