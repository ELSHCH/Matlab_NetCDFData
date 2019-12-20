file_in3='adaptor.mars.internal-1576421659.7089527-15854-13-e401db13-c4d5-44eb-b82a-4737a3206990.nc'; %1 Oct- 30 Dec 2017
file_in1='adaptor.mars.internal-1576421752.8789294-8900-3-e3b928f8-fda7-4ae4-a8d4-64524506dcba.nc'; % 1 Jan- 30 Jun 2017
file_in2='adaptor.mars.internal-1576421706.0607471-7857-31-1db75a62-c71b-47bf-806f-396fb5c46e78.nc'; % % 1 Jul- 30 Sep 2017
% Geographical coordinates for Black Sea region of interest
lat_region=[40.00, 48.00];
lon_region=[27.00, 43.00];

readERA5toDatFile(file_in1,lat_region,lon_region, 'windBlackSeaNetcdf.txt');
readERA5toDatFile(file_in2,lat_region,lon_region, 'windBlackSeaNetcdf.txt');
readERA5toDatFile(file_in3,lat_region,lon_region, 'windBlackSeaNetcdf.txt');