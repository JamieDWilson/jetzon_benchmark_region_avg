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

function [ region , region_names , coords] = get_RECCAP_region ( lat , lon , varargin)


% load RECCAP region data
% - masky: region index
% - lony : longitude
% - laty : latitude
load('regions/RECCAP_region_data')

% vectorise RECCAP region
MASK = reshape(masky,[],1);
[LON,LAT]=meshgrid(lony,laty);
LON=reshape(LON,[],1);
LAT=reshape(LAT,[],1);

% remove land (==0) so as to find closest wet grid points
ind=MASK==0;
MASK(ind)=[];
LON(ind)=[];
LAT(ind)=[];

% region names
region_names={...
    'Arctic',...
    'North Atlantic',...
    'North Pacific',...
    'Subtropical North Atlantic',...
    'Subtropical North Pacific',...
    'Subtropical Indian',...
    'Equatorial Atlantic',...
    'Equatorial Pacific',...
    'Subtropical South Atlantic',...
    'Subtropical South Pacific',...
    'Subtropical Indian',...
    'Subantarctic',...
    'Antarctic'};

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
k=dsearchn([LON LAT],[lon lat]);

% regions for given lat/lon
region=MASK(k);

% nearest lat/lon for reference
coords.lon = LON(k);
coords.lat = LAT(k);


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