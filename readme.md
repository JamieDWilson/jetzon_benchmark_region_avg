# README

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
