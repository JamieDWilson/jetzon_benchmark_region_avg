# README

## Use

get_RECCAP_region.m returns the id and name of the RECCAP2 regions (https://reccap2-ocean.github.io/regions/) for a given latitude and longitude using nearest neighbour interpolation. 

## Download

If you are not used to using git, click the big green CODE button top left, select the 'Download Zip' option. Save and unzip in your MATLAB folder. 

## Get RECCAP regions

The function get_RECCAP_region.m will take in any number of longitude and latitude coordinates and return the nearest corresponding region from the RECCAP regions:
```matlab
[ region , region_names , coords] = get_RECCAP_region ( lat , lon );
```
where:
 ```lat``` is latitude in degrees north (mx1 or mxn array)
 ```lon``` is longitude in degrees east (mx1 or mxn array)
 ```region``` is the number code of the RECCAP region (mx1 or mxn array)
 ```region_names``` are the long names of the RECCAP regions (cell of strings)
 ```coords``` are the lat/lon values corresponding to the nearest grid point

 For point observations, pass 1D ararys of lat and lon to the function. The region output will be a 1D array.
 For gridded data, use the meshgrid function to convert 1D dimension arrays to 2D arrays. The get_RECCAP_region.m will return a 2D array for the region output.

 ### Combine RECCAP regions
 The function get_RECCAP_region.m can combine existing regions together. This is useful if you want to define basins for example. Pass in any number of additional input pairs: 1) name of the new region and 2) array of region numbers to combine. The function will output the new adjusted regions and names.
```matlab
[ region , region_names , coords] = get_RECCAP_region ( lat , lon , 'new_region_1', [1 2 3] , 'new_region_2' , [4 5 6 7]);
```

For example, to get ocean basins use:
```matlab
[regions_basins,regions_names]=get_RECCAP_region(LAT,LON,'Atlantic',[1:6],'Pacific',[7:12],'Indian',[13:16],'Arctic',[17:26],'SO',[27:29]);
```

## JETZON BCP Benchmark

The regions defined for the JETZON BCP Benchmark activity can be automatically selected using:

```matlab
[regions_basins,regions_names]=get_RECCAP_region(lat,lon,'jetzon');
```
