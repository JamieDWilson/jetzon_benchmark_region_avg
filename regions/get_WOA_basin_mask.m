% -------------------------------------------------------------------------
% get_WOA_basin_mask
%
% description: takes latitude and longitude pairs and finds the closest
%   basin mask from the WOA2018 masks
% inputs: 
%   - lat: latitude
%   - lon: longitude (0 to 360 degE)
% outputs:
%   - mask: structure with logical arrays for each basin mask 
%           (ATL, PAC, IND, SO, ARCT)
%   - basin_id: single array containing basin mask numbers
%           (ATL=1, PAC=2, IND=3, SO=4, ARCT=5)
% authors: Jamie D. Wilson (jamie.wilson@liverpool.ac.uk); Erik Fields (fields@ucsb.edu)
% date: 31st Aug 2023
% -------------------------------------------------------------------------

function [ mask , basin_id ] = get_WOA_basin_mask( lat , lon )

    % load in WOA18 1 degree basin mask info (surface)
    % (:,1)=lat, (:,2)=lon, (:,3)=basin_id
    % ATL=1, PAC=2, Indian=3, 10=SO, anything else see WOA18 documentation
    T=readtable('basinmask_01.csv');
    f=fields(T);
    
    woaMask=NaN(180,360);                       
    ix=(T.Longitude)+179.5+1;
    iy=(T.Latitude)+89.5+1;
    
    woaMask(iy+(ix-1)*180)=T.Basin_0m;
    woaMask(~ismember(woaMask,[1 2 3 10 11]))=NaN;
    toRenumber=find(woaMask>3);
    woaMask(toRenumber)=woaMask(toRenumber)-6;
    woaMask=flipud(woaMask);

    woaMask=reshape(woaMask,[],1);
    [woalon,woalat]=meshgrid(-179.5:1:179.5,89.5:-1:-89.5);
    woalon=reshape(woalon,[],1); woalon(woalon<0)=woalon(woalon<0)+360;
    woalat=reshape(woalat,[],1);

    % adjust data lon/lat values to nearest x.5 value to match WOA18 1 deg mask values 
    tmp_lon=round(lon);
    tmp_lat=round(lat);

    lon_adj=nan(numel(tmp_lon),1);
    lon_adj((lon-tmp_lon)>0)=tmp_lon((lon-tmp_lon)>0)+0.5;
    lon_adj((lon-tmp_lon)<0)=tmp_lon((lon-tmp_lon)<0)-0.5;
    lon_adj((lon-tmp_lon)==0)=tmp_lon((lon-tmp_lon)==0)-0.5;

    lat_adj=nan(numel(tmp_lat),1);
    lat_adj((lat-tmp_lat)>0)=tmp_lat((lat-tmp_lat)>0)+0.5;
    lat_adj((lat-tmp_lat)<0)=tmp_lat((lat-tmp_lat)<0)-0.5;
    lat_adj((lat-tmp_lat)==0)=tmp_lat((lat-tmp_lat)==0)-0.5;
    
    % (time consuming) loop over data to find corresponding basin id
    basin_id=nan(numel(lon),1);
    for n=1:numel(lon)
        ind=find(woalon==lon_adj(n,1) & woalat==lat_adj(n,1));
        if ~isempty(ind)
            basin_id(n,1)=woaMask(ind,1);
        end
    end

    % logical arrays output
    mask.ATL=basin_id==1;
    mask.PAC=basin_id==2;
    mask.IND=basin_id==3;
    mask.SO=basin_id==4;
    mask.ARCT=basin_id==5;


end