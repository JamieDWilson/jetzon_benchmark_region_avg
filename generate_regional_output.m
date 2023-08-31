
function [ output ] = generate_regional_output ( input_data , regions_file )

    %% load data

    % load excel data
    [lon,lat,b] = readvars(input_data); 
    
    % copy input data to standard variable name
    data_in=b; 

    % convert from deg W to deg E centred at 180 (0 to 360 deg E)
    % for sampling region definitions
    for n=1:size(lon)
        if lon(n,1)<0
            lon(n,1)=360-(-lon(n,1)); 
        end
    end

    % -> to add
    % also consider gridded data
    % gridded data will work here if vectorised

    %% load definition of regions

    run(strcat('regions/',regions_file))
    region_names=fieldnames(regions);

    %% process data

    % examples: processing data by region
    for n=1:length(fieldnames(regions))
        
        % get region logical indices
        ind=getfield(regions,region_names{n});

        % EX1: basic use of region indices
        % e.g., calculate mean of data in region    
        data_mean(n)=mean(data_in(ind));
        
        % EX2: sort input_data into data structure by regions for further
        % analysis, e.g., averaging into depth profiles.
        % This could be done with cells to avoid clunky structure fields!
        eval(['data.' region_names{n} '=data_in(ind);' ]);

    end
    
    %% outputs
    
    output = data;




end