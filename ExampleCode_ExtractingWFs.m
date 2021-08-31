clc, clear all, close all

%First set the threshold inputs
A = 1e6; %sets the threshold drainage area for what is defined as a channel from the DEM (m^2)
dh = 1.5; %sets the theshold waterfall height (vertical distance between waterfall lip and base) (m)
s = 30; %sets the threshold waterfall slope (sets of 3 pixels must be above this slope) (degrees)

% Set where TopoToolbox and your DEM are contained
tt_location = 'D:\Box Sync\topotoolbox\topotoolbox-master2';
dem_location = 'D:\Box Sync\topotoolbox\topotoolbox-master2';

%Run the code to generate the river long profile from TopoToolbox
[P_Rubio] = profile_generator('Rubio_DEM.tif',A,'Rubio',tt_location,dem_location); %uses the DEM created in ArcGIS and saved in .tif format, the threshold drainage area set above, and the name of the watershed
%produces a DEM hillshade of the watershed with the trunk channel


%Run the code to pick out waterfalls and calculate the morphologic metrics
[WF_Rubio] = wf_finder(P_Rubio,s,dh,'Rubio'); %uses the output from the function above, the threshold waterfall slope and height set above, and the name of the watershed
%produces a profile with the waterfalls plotted on it 