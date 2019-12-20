file_in='sv03-bs-cmcc-cur-an-fc-d_1554709159757.nc';
file_mask='mapBlackSearegion.txt';
% Geographical coordinates for Black Sea region of interest
lat_region=[40.00, 48.00];
lon_region=[27.00, 43.00];
readNetcdfCMCCReanalysiswriteDatFile(file_in,file_mask,lat_region,lon_region,'CurrentCMCCBlackSea2017.txt');