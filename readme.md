# README

## Download

Click the big green CODE button, select the 'Download Zip' option. Save and unzip in your MATLAB folder. 

## Get RECCAP regions

The function get_RECCAP_region.m will take in any number of longitude and latitude coordinates and return the nearest corresponding region from the RECCAP regions:
```matlab
[ region , region_names , coords] = get_RECCAP_region ( lat , lon );
```
where:
 ```lat``` is latitude in degrees (mx1 array)
 ```lon``` is longitude in degrees (mx1 array)
 ```region``` is the number code of the RECCAP region
 ```region_names``` are the long names of the RECCAP regions
 ```coords``` are the lat/lon values corresponding to the nearest grid point

 For gridded data, use vectorised longitude and latitude values as inputs.

 ### Combine RECCAP regions
 The function get_RECCAP_region.m can combine existing regions together. This is useful if you want to define basins for example. Pass in any number of additional input pairs: 1) name of the new region and 2) array of region numbers to combine. The function will output the new adjusted regions and names.
```matlab
[ region , region_names , coords] = get_RECCAP_region ( lat , lon , 'new_region_1', [1 2 3] , 'new_region_2' , [4 5 6 7]);
```

For example, to get ocean basins use:
```matlab
[ region , region_names , coords] = get_RECCAP_region ( lat , lon , 'Atlantic , [2 4 7 9] , 'Pacific' , [3 5 8 10] , 'Indian' , [6 11] , 'Southern Ocean' , [12 13]);
```
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
README FOR OLDER CODE
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

## Reading benchmark spreadsheet

[!NOTE] 
This is currently under development! See the example_spreadsheet.xlsx for current working example

You can load information from a benchmark template spreadsheet, collate by regions, and perform a calculation using the ```general_regional_output``` function, e.g., 
 ```matlab
output=generate_regional_output('example_spreadsheet.xlsx','regions_weberlinear');
```
Function inputs: 
input_data: string containing name of spreadsheet input
regions_file: string containing name of script in regions subfolder

Function outputs:
 - currently outputing a structure of data sorted by regions


## Defining Regions for lat/lon data
You can generate arrays in MATLAB containing the region defintions by:
1. load latitude and longitude data into MATLAB as ```lon``` and ```lat``` variables (longitude must be 0 to 360 deg E)
2. run the region definition script of choice, e.g.,
   ``` run('regions/regions_weberlinear_basins.m')```


## Adding basin information to region definitions
You can add basin information using the WOA18 mask definitions:
1. load latitude and longitude data into MATLAB as ```lon``` and ```lat``` variables (longitude must be 0 to 360 deg E)
2. add ```[ mask , basin_id ] = get_WOA_basin_mask ( lat , lon );``` to the top of the region defintion script of choice.
3. run the region definition script of choice, e.g.,
   ``` run('regions/regions_weberlinear_basins.m')```

## Currently Available Region Definitions
* regions_weberlinear (Adrian Martin's "by eye" linear approximation of Weber et al., 2016 PNAS regions)
* regions_weberlinear_hemispheres (... separated by hemipsheres)
* regions_weberlinear_basin (... separated by basins)
