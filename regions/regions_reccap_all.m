ncinfo('RECCAP2_region_masks_all_v20221025.nc');

lat=ncread('RECCAP2_region_masks_all_v20221025.nc','lat');
lon=ncread('RECCAP2_region_masks_all_v20221025.nc','lon');

vars={'atlantic','pacific','indian','arctic','southern'};
count=1;
reccap_master=nan(360,180);
for n=1:5
    if ~strcmp(vars{n},'arctic')
        regions{n}=ncreadatt('RECCAP2_region_masks_all_v20221025.nc',vars{n},'region_name');
    end
    reccap=ncread('RECCAP2_region_masks_all_v20221025.nc',vars{n});
    n_regions=unique(reccap); n_regions(n_regions==0)=[];

    for nn=1:max(n_regions)
        reccap_master(reccap==nn)=count;
        count=count+1;
    end


end

region_names={'NA SPSS', 'NA STSS', 'NA STPS', 'AEQU', 'SA STPS', 'MED',...
    'NP SPSS', 'NP STSS', 'NP STPS', 'PEQU-W', 'PEQU-E', 'SP STPS',...
    'Arabian Sea', 'Bay of Bengal', 'Equatorial Indian', 'Southern Indian',...
    'Arctic 1','Arctic 2','Arctic 3','Arctic 4','Arctic 5','Arctic 6','Arctic 7','Arctic 8','Arctic 9','Arctic 10',...
    'SO STSS', 'SO SPSS', 'SO ICE'};

for n=1:29
    region_indices{n}=[num2str(n) ': '];
end

%save('reccap_regions_master','reccap_master','lat','lon','region_names','region_indices');

% bsic plot of regions and indices
imagesc(rot90(reccap_master));
c=colorbar;
colormap(parula(count-1));
set(c,'YTick',[1.5:count-1],'YTickLabel',strcat(region_indices',region_names'))


