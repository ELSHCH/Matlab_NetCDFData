%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Read data "ERA5 hourly estimates of variables on single
%              levels" , extract data according to provided geographical
%              region and write output to data file
%
%         Ref: https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Input parameters: file_in - name of .nc file for reading with wind data
%                         file_out - name of .dat file for writing data 
%                         lat_region - limits of latitude in format [lat_min, lat_max] 
%                         lon_region - limits of longitude in format [lon_min, lon_max]          
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function readERA5toDatFile(file_in, lat_region,lon_region, file_out)

nc=netcdf.open(file_in);
finfo=ncinfo(file_in);

lat_min = lat_region(1); 
lat_max = lat_region(2);
lon_min = lon_region(1);
lon_max = lon_region(2);

ID_lat1=netcdf.inqVarID(nc,'latitude');
ID_lon1=netcdf.inqVarID(nc,'longitude');
ID_time1=netcdf.inqVarID(nc,'time'); 

%ID_depth=netcdf.inqVarID(nc,'gridlat_0');
ID_u1=netcdf.inqVarID(nc,'u10');
ID_v1=netcdf.inqVarID(nc,'v10');


%vo= netcdf.getVar(nc,ID_vo);
%windnorth= double(netcdf.getVar(nc1,ID_windnorth))*0.01;
%windeast = double(netcdf.getVar(nc1,ID_windeast))*0.01;
u1 = netcdf.getVar(nc,ID_u1);
u1_scale1=finfo.Variables(4).Attributes(1).Value;
u1_offset1=finfo.Variables(4).Attributes(2).Value;
%scale1 = netcdf.inqAttName(nc1,ID_u1,'scale_factor')
%offset1 = netcdf.inqAtt(nc1,ID_u1,'add_offset')
v1= netcdf.getVar(nc,ID_v1);
v1_scale1=finfo.Variables(5).Attributes(1).Value;
v1_offset1=finfo.Variables(5).Attributes(2).Value;
lat1= netcdf.getVar(nc,ID_lat1);
lon1= netcdf.getVar(nc,ID_lon1);
time1= netcdf.getVar(nc,ID_time1);

base=datenum(1900,1,1); %number of days since 00.00.0000  hours since 01.01.1800
%base=datenum(1990,1,1); % seconds since 01.01.1990
for i=1:length(time1)
%new_t1(i)=posixtime(datetime(datestr(days(time1(i)/3600/24+base)))); 
new_t1(i)=posixtime(datetime(datestr(days(time1(i)/24+base)))); 
%t1(i)=datetime(datestr(days(time1(i)/24+base)));
end;

dimx1=length(u1(:,1,1));
dimy1=length(u1(1,:,1));
dimtime1 = length(time1);

k=1;
u1=double(u1)*double(u1_scale1)+double(u1_offset1);
v1=double(v1)*double(v1_scale1)+double(v1_offset1);

% Select data according to given coordinate region given in latitudes and
% longitudes

 for t=1:dimtime1
     for i=1:dimy1
       for j=1:dimx1
      %     if time1(t)==time1(1)
              if (lon1(j)>=lon_min)&&(lon1(j)<=lon_max)
 
                if  (lat1(i)>=lon_max)&&(lat1(i)<=lat_max)
 
                 u101(k)=u1(j,i,t);
                 v101(k)=v1(j,i,t);
                 lt1(k)=lat1(i);
                 ln1(k)=lon1(j);
                 t1(k)=new_t1(t);
                 speed1(k)=sqrt(u101(k)^2+v101(k)^2);
                 k=k+1;
                end;
              end;
       end;
     end;
end;
num1=k-1;
file1=fopen(file_out,'a');
for kk=1:num1
     fprintf(file1,'%g\t%g\t%ld\t%g\t%g\n',u101(kk),v101(kk),t1(kk),ln1(kk),lt1(kk));   
end;
fclose(file1);  
netcdf.close(nc);
