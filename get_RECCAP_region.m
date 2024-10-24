% -------------------------------------------------------------------------
% get_RECCAP_region
%
% Description: takes latitude and longitude pairs and finds the closest
% RECCAP region based on the 1deg RECCAP grid
%
% Inputs: 
%   - lat:      latitude (mx1 array)
%   - lon:      longitude (mx1 array , lon values between 0 to 360 degE)
%   - varargin: pairs of string and integer array for combining regions
%           
% Outputs:
%   - region:       region number for given lon/lat pair (mx1 array)
%   - region_names: region long names (mx1 cell of strings)
%   - coords:       nearest lon and lat values (struct)
%
% Notes:
% To combine regions: add any number of string/array pairs containing name
% of new region and region numbers to combine, e.g., 
% get_RECCAP_region(lat,lon,'region1',[1 2 3],'region2',[3 4 5]);
%
% Default Region Numbering:
% 1) Arctic
% 2) North Atlantic
% 3) North Pacific
% 4) Subtropical North Atlantic
% 5) Subtropical North Pacific
% 6) Subtropical Indian
% 7) Equatorial Atlantic
% 8) Equatorial Pacific
% 9) Subtropical South Atlantic
% 10) Subtropical South Pacific
% 11) Subtropical Indian
% 12) Subantarctic
% 13) Antarctic
%
% authors: Jamie D. Wilson (jamie.wilson@liverpool.ac.uk); Erik Fields (fields@ucsb.edu)
% created: 30th January 2024
% -------------------------------------------------------------------------

function [ region , region_names , coords] = get_RECCAP_region ( data_lat , data_lon , varargin )


% load RECCAP region data
% - reccap_master: all reccap regions
% - lon : longitude
% - lat : latitude
% - region_names : names from netcdf attributes
% - region_indices : numerical index of regions correspondng to region_names
load('regions/reccap_regions_master.mat')

% vectorise RECCAP region
MASK = reshape(reccap_master,[],1);
[LON,LAT]=meshgrid(lon,lat);
LON=reshape(LON,[],1);
LAT=reshape(LAT,[],1);

% remove land (==0) so as to find closest wet grid points
ind=isnan(MASK);
MASK(ind)=[];
LON(ind)=[];
LAT(ind)=[];

% reshape data_lon & data_lat if not 1D
flag_lonlat_vector=false;
if (~isvector(data_lon) & ~isvector(data_lat)) 
    if all(size(data_lon) == size(data_lat))

        flag_lonlat_vector=true;
        
        lonlat_dims=size(data_lon);
        lonlat_ind=find(data_lon);
    
        data_lon=data_lon(lonlat_ind);
        data_lat=data_lat(lonlat_ind);
    
        else
    
        disp(['lon/lat inputs mismatched in size'])
        return

    end

end

% reccap lon is [0 360]E so adjust incoming lon if not the same
% and flag if need to reverse at end
flag_lonshift=false;
if any(any(data_lon<0))
    flag_lonshift=true;
    lonshift_ind=data_lon<0;
    data_lon(lonshift_ind)=(data_lon(lonshift_ind))+360;
end

% region names
% region_names={...
%     'Arctic',...
%     'North Atlantic',...
%     'North Pacific',...
%     'Subtropical North Atlantic',...
%     'Subtropical North Pacific',...
%     'Subtropical Indian',...
%     'Equatorial Atlantic',...
%     'Equatorial Pacific',...
%     'Subtropical South Atlantic',...
%     'Subtropical South Pacific',...
%     'Subtropical Indian',...
%     'Subantarctic',...
%     'Antarctic'};

% update regions if requested
if ~isempty(varargin)

    % make copies and variables
    mask_tmp=MASK;
    names_tmp=region_names;
    merge_names=varargin(1:2:end);
    merge_list=varargin(2:2:end);
    
    % loop over and update region definitions
    for n=1:numel(merge_list)
           [mask_tmp , names_tmp , merge_list] = update_regions (mask_tmp , names_tmp , merge_names , merge_list ,n );
    end
    
    % update numbering
    region_ind=unique(mask_tmp);
    count=1;
    for n=1:numel(region_ind)
        mask_tmp(mask_tmp==region_ind(n))=count;
        count=count+1;
    end
    
    % assign back to master variables
    MASK=mask_tmp;
    region_names=unique(names_tmp,'stable');

end

% nearest point search
k=dsearchn([LON LAT],[data_lon data_lat]);

% regions for given lat/lon 
region=MASK(k);

% reshape regions to match lon/lat input dimensions if needed
if flag_lonlat_vector
    tmp=nan(lonlat_dims);
    tmp(lonlat_ind)=region;
    region=tmp;
end

% nearest lat/lon for reference 
coords.lon = LON(k);
coords.lat = LAT(k);

% shift from [0 360]E and reshape if needed
if flag_lonshift
    coords.lon(lonshift_ind) = -(coords.lon(lonshift_ind)-360);
end
if flag_lonlat_vector
    tmp=nan(lonlat_dims);
    tmp(lonlat_ind)=coords.lon;
    coords.lon=tmp;

    tmp=nan(lonlat_dims);
    tmp(lonlat_ind)=coords.lat;
    coords.lat=tmp;
end



end

% -------------------------------------------------------------------------
% subfunction: update_regions
% - overwrites new region and names
% -------------------------------------------------------------------------
function [ mask_tmp , names_tmp , merge_ind ] = update_regions (mask_tmp , names_tmp , merge_name , merge_ind, n)

    loop_name=merge_name{n};
    loop_ind=merge_ind{n};
    
    ind=min(loop_ind);
    for i=1:numel(loop_ind)
        mask_tmp(mask_tmp==loop_ind(i))=ind;
        names_tmp{loop_ind(i)}=loop_name;
    end

end