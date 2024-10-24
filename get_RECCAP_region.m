% -------------------------------------------------------------------------
% get_RECCAP_region
%
% Description: takes latitude and longitude pairs and finds the closest
% RECCAP region based on the 1deg RECCAP grid
%
% Inputs: 
%   - lat:      latitude (mx1 or mxn array)
%   - lon:      longitude (mx1 mxn array)
%   - varargin: pairs of string and integer array for combining regions
%           
% Outputs:
%   - region:       region number for given lon/lat pair (mx1 or mxn array)
%   - region_names: region long names (mx1 cell of strings)
%   - coords:       nearest lon and lat values (struct)
%
% Notes:
% 1) To combine regions: add any number of string/array pairs containing name
% of new region and region numbers to combine, e.g., 
% get_RECCAP_region(lat,lon,'region1',[1 2 3],'region2',[3 4 5]);
%
% 2) call without any inputs to show a map of the RECCAP2 regions and region indices listed
% e.g., get_RECCAP_region();
%
% authors: Jamie D. Wilson (jamie.wilson@liverpool.ac.uk); Erik Fields (fields@ucsb.edu)
% created: 30th January 2024
% updated:
%          24th October 2024, JDW: updated with all reccap regions; mxn
%           arrays; automatic [0 360]E conversion; map
% -------------------------------------------------------------------------

function [ region , region_names , coords] = get_RECCAP_region ( data_lat , data_lon , varargin )


% load RECCAP region data
% - reccap_master: all reccap regions
% - lon : longitude
% - lat : latitude
% - region_names : names from netcdf attributes
% - region_indices : numerical index of regions correspondng to region_names
load('regions/reccap_regions_master.mat')

% display regions as map if no inputs given
if nargin==0
    plot_regions(lon,lat,reccap_master,region_names,region_indices);
    names=strcat(region_indices',region_names')';
    fprintf('%s \n','Region indices and names:')
    fprintf('%s \n',names{:})
    return
end

% vectorise RECCAP region
MASK = reshape(reccap_master,[],1);
[LAT,LON]=meshgrid(lat,lon);
LON=reshape(LON,[],1);
LAT=reshape(LAT,[],1);

% remove land (==NaN) so as to find closest wet grid points
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

% the actual work - nearest point search
k=dsearchn([LON LAT],[data_lon data_lat]);

% get the regions for given lat/lon 
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
    coords.lon(lonshift_ind) = coords.lon(lonshift_ind)-360;
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

% -------------------------------------------------------------------------
% subfunction: plot_regions
% - plots RECCAP2 regions
% -------------------------------------------------------------------------
function [ ] = plot_regions(lon,lat,reccap_master,region_names,region_indices)

    plot_data=rot90(reccap_master);
    [coastlines] = make_coastlines(plot_data,lat);
    figure;
    imAlpha=ones(size(plot_data));
    imAlpha(isnan(plot_data))=0;
    imagesc(lon,lat,plot_data,'AlphaData',imAlpha); hold on;
    caxis([1 size(region_names,2)+1]);
    c=colorbar;
    colormap(parula(size(region_names,2)+1));
    set(c,'YTick',[1.5:size(region_names,2)+1],'YTickLabel',strcat(region_indices',region_names'));
    set(gca, 'color', [0.8 0.8 0.8]);
    set(gca,'YTickLabel',flipud(get(gca,'YTickLabel')));
    xlabel('Longutude (deg E)')
    ylabel('Latitude (deg N)')
    title('RECCAP2 Regions')
    axis normal
    pbaspect([2 1 1])
    plot(coastlines(:,1:2)'-1.5,coastlines(:,3:4)'-1.5,'k')

end

% -------------------------------------------------------------------------
% subfunction: make_coastlines
% - calculate coast outline for plot
% -------------------------------------------------------------------------
function [coastlines] = make_coastlines(data,lat)
   
    grid_mask=zeros(size(data,1),size(data,2));
    grid_mask(~isnan(data))=1;
    grid_mask = [grid_mask(:,1) grid_mask grid_mask(:,end)];
    grid_mask = [grid_mask(1,:) ;grid_mask; grid_mask(end,:)];

    dx=diff(grid_mask,1,2); 
    dy=diff(grid_mask,1,1); 
    [jv iv]=find(dx~=0);
    [jh ih]=find(dy~=0);
    vertedge=[iv+1 iv+1 lat(jv) lat(jv+1)];
    horzedge=[ih ih+1 lat(jh+1) lat(jh+1)];
    coastlines=[vertedge;horzedge];
    
end