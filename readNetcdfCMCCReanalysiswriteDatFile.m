%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Read Black Sea current data from NETCDF file from CMEMS 
%        BLKSEA_ANALYSIS_FORECAST_PHYS_007_001 - http://marine.copernicus.eu" 
%        extract data for given coordinates, interpolate coastal currents using bilinear interpolation  
%
%         Ref: 	http://marine.copernicus.eu/documents/PUM/CMEMS-BS-PUM-007-001.pdf
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Input parameters: file_in - name of netcdf current data
%                         file_out - name of output .dat file 
%                         lat_region - limits of latitude in format [lat_min, lat_max] 
%                         lon_region - limits of longitude in format [lon_min, lon_max]          
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function readNetcdfCMCCReanalysiswriteDatFile(file_in, maskfile, lat_region,lon_region, file_out)

nc=netcdf.open(file_in);
finfo=ncinfo(file_in);

lat_min = lat_region(1); 
lat_max = lat_region(2);
lon_min = lon_region(1);
lon_max = lon_region(2);

ID_lat1=netcdf.inqVarID(nc,'lat');
ID_lon1=netcdf.inqVarID(nc,'lon');
ID_time1=netcdf.inqVarID(nc,'time'); 
ID_depth1=netcdf.inqVarID(nc,'depth'); 

%ID_depth=netcdf.inqVarID(nc,'gridlat_0');
ID_u1=netcdf.inqVarID(nc,'vozocrtx');
ID_v1=netcdf.inqVarID(nc,'vomecrty');


%vo= netcdf.getVar(nc,ID_vo);
%windnorth= double(netcdf.getVar(nc1,ID_windnorth))*0.01;
%windeast = double(netcdf.getVar(nc1,ID_windeast))*0.01;
u1 = netcdf.getVar(nc,ID_u1);
%scale1 = netcdf.inqAttName(nc1,ID_u1,'scale_factor')
%offset1 = netcdf.inqAtt(nc1,ID_u1,'add_offset')
v1= netcdf.getVar(nc,ID_v1);

lat1= netcdf.getVar(nc,ID_lat1);
lon1= netcdf.getVar(nc,ID_lon1);
time1= netcdf.getVar(nc,ID_time1);

base=datenum(1970,1,1); %number of days since 00.00.0000  hours since 01.01.1800
%base=datenum(1990,1,1); % seconds since 01.01.1990
for i=1:length(time1)
%new_t1(i)=posixtime(datetime(datestr(days(time1(i)/3600/24+base)))); 
new_t1(i)=posixtime(datetime(datestr(days(time1(i)/24/3600+base)))); % one days time step 
%t1(i)=datetime(datestr(days(time1(i)/24+base)));
end;

dimx1=length(u1(:,1,1,1));
dimy1=length(u1(1,:,1,1));
dimtime1 = length(time1);
dimdepth=length(u1(1,1,:,1));

k=1;

% Read mask file for Black Sea

file_msk=fopen(maskfile,'r');

data_msk=fscanf(file_msk,"%d\t%g\t%g\n",[3, inf]);

% Select data according to given coordinate region given in latitudes and
% longitudes

 for t=1:dimtime1
     for i=1:dimy1
       for j=1:dimx1
      %     if time1(t)==time1(1)
              if (lon1(j)>=lon_min)&&(lon1(j)<=lon_max)
 
                if  (lat1(i)>=lat_min)&&(lat1(i)<=lat_max)
 
                 u101(k)=u1(j,i,1,t);
                 v101(k)=v1(j,i,1,t);
                 lt1(k)=lat1(i);
                 ln1(k)=lon1(j);
                 t1(k)=new_t1(t);
                 %speed(k)=sqrt(u101(k)^2+v101(k)^2);
                 k=k+1;
                end;
              end;
       end;
     end; 
end;
% Initialize onland region values of zonal and meridional current with zeros

dm=zeros(dimx1,dimy1);
size(dm)
for i=1:dimy1
   for j=1:dimx1 
      dm(j,i)=1; 
      if (data_msk(1,j+(i-1)*dimx1)==0) 
        u1(j,i,1,:)=0;
        v1(j,i,1,:)=0;
        dm(j,i)=0;
      end;
   end;
end; 
lon=unique(data_msk(2,:));
lat=unique(data_msk(3,:));
u1_interp=u1;
v1_interp=v1;
wind_speed=zeros(dimx1,dimy1);
subplot(2,1,1);
wind_speed=sqrt(u1(:,:,1,1).^2+v1(:,:,1,1).^2);
contourf(lon, lat,wind_speed',40);
dm1=dm;
dm2=dm1;
% Make near-to-coast interpolation of zonal and meridional current 
for k=1:5
    k
for i=2:dimy1-1 
 for j=2:dimx1-1
    if (dm1(j,i)+dm1(j-1,i)+dm1(j-1,i-1)+dm1(j+1,i)+dm1(j-1,i+1)+...
        dm1(j+1,i+1)+dm1(j+1,i-1)+dm1(j,i-1)+dm1(j,i+1)>0)&&...
        (dm1(j,i)+dm1(j-1,i)+dm1(j-1,i-1)+dm1(j+1,i)+dm1(j-1,i+1)+...
        dm1(j+1,i+1)+dm1(j+1,i-1)+dm1(j,i-1)+dm1(j,i+1)<9)
    for s=1:dimtime1
     NumZeros_u1=nnz([u1_interp(j,i,1,s),u1_interp(j-1,i,1,s),u1_interp(j-1,i-1,1,s),...
              u1_interp(j-1,i+1,1,s),...
               u1_interp(j,i+1,1,s),u1_interp(j,i-1,1,s),...
               u1_interp(j+1,i,1,s),u1_interp(j+1,i-1,1,s),u1_interp(j+1,i+1,1,s)]);
     if NumZeros_u1>0      
        u1_interp(j,i,1,s)=(u1_interp(j-1,i,1,s)+u1_interp(j-1,i-1,1,s)+...
              u1_interp(j-1,i+1,1,s)+...
               u1_interp(j,i+1,1,s)+u1_interp(j,i-1,1,s)+...
               u1_interp(j+1,i,1,s)+u1_interp(j+1,i-1,1,s)+u1_interp(j+1,i+1,1,s))/NumZeros_u1;
     end;
      NumZeros_v1=nnz([v1_interp(j,i,1,s),v1_interp(j-1,i,1,s),v1_interp(j-1,i-1,1,s),...
              v1_interp(j-1,i+1,1,s),...
               v1_interp(j,i+1,1,s),v1_interp(j,i-1,1,s),...
               v1_interp(j+1,i,1,s),v1_interp(j+1,i-1,1,s),v1_interp(j+1,i+1,1,s)]);  
     if NumZeros_v1>0      
        v1_interp(j,i,1,s)=(v1_interp(j-1,i,1,s)+v1_interp(j-1,i-1,1,s)+...
               v1_interp(j-1,i+1,1,s)+...
               v1_interp(j,i+1,1,s)+v1_interp(j,i-1,1,s)+...
               v1_interp(j+1,i,1,s)+v1_interp(j+1,i-1,1,s)+v1_interp(j+1,i+1,1,s))/NumZeros_v1; 
     end;  
    end;  
        dm2(j,i)=(dm1(j,i)+dm1(j-1,i)+dm1(j-1,i-1)+...
                dm1(j-1,i+1)+...
                dm1(j,i+1)+dm1(j,i-1)+...
                dm1(j+1,i)+dm1(j+1,i-1)+dm1(j+1,i+1))/9;      
    end;
end;
end;     
for i=1:dimy1 
 for j=1:dimx1
     if dm2(j,i)>0.001
         dm2(j,i)=1;
     end;
end;
end;
dm1=dm2;
end;
u1=u1_interp;
v1=v1_interp;
wind_speed=sqrt(u1(:,:,1,:).^2+v1(:,:,1,:).^2);
wd=zeros(dimx1,dimy1);
wd=wind_speed(:,:,1,300);
subplot(2,1,2);
contourf(lon, lat,wd',40);
shading flat
num1=k-1;
file1=fopen(file_out,'w');
ind_s=[1,32,63,95,126,158,189,221,252,284,315,347]
ind_e=[31,62,94,125,157,188,220,251,283,314,346,365];
for k=1:12
for i=1:dimy1 
 for j=1:dimx1
  mean_u1(j,i,k)=mean(u1(j,i,1,ind_s(k):ind_e(k)));
  mean_v1(j,i,k)=mean(v1(j,i,1,ind_s(k):ind_e(k)));
  mean_ws(j,i,k)=mean(wind_speed(j,i,1,ind_s(k):ind_e(k)));
 end;
end;
end;

% for k=1:12
% for i=1:2:dimy1 
%  for j=1:2:dimx1
%   fprintf(file1,'%g\t%g\t%g\t%g\t%g\n',mean_u1(j,i,k),mean_v1(j,i,k),mean_ws(j,i,k),lon(j),lat(i));   
%  end;
% end;
% end;

for k=1:dimtime1
for i=1:dimy1 
 for j=1:dimx1
  fprintf(file1,'%g\t%g\t%g\t%ld\t%g\t%g\n',u1(j,i,1,k),v1(j,i,1,k),wind_speed(j,i,1,k),t1(k),ln1(k),lt1(k));   
 end;
end;
end;
fclose(file1);  
netcdf.close(nc);
fclose(file_msk);