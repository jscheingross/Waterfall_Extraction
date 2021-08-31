function [P] = profile_generator(DEM_fname,thresh_A,name,tt_location,dem_location)
%Function to create a profile from a DEM 

%Add the folders where TopoToolbox and the DEMs are saved
addpath(genpath(tt_location)) %path to where TopoToolbox is saved
addpath(dem_location) %path to where DEMs are saved (must be in tif format)

% addpath(genpath('D:\MATLAB\topotoolbox-master')) %path to where TopoToolbox is saved
% addpath D:\MATLAB\GIS_Data\San_Gabriel_Mnts\Clipped_DEMs_tif %path to where DEMs are saved (must be in tif format)

DEM = GRIDobj(DEM_fname); %general variable for DEM, creates a grid object

FD = FLOWobj(DEM,'preprocess','carve'); %caclculate flow direction and carve the DEM to remove holes

DEMc = imposemin(FD,DEM); %create new carved DEM using the above output FD

A = flowacc(FD).*(FD.cellsize^2); %Calculate flow accumulation and make A give drainage area in m2 instead of # of pixels
A_thresh = thresh_A./(FD.cellsize^2); % upper drainage area threshold (in m^2), sets the channel head location - everything with smaller drainage is not counted as a stream 

S = STREAMobj(FD,'minarea',A_thresh); %define the stream network

S_largest = klargestconncomps(S); %extract the largest connected stream network
S_trunk = trunk(S_largest); %extract the trunk of the stream network (the longest channel in the network)

MS = STREAMobj2mapstruct(S_largest); %Create a map structure of the river network to save as a shapefile for loading into ArcGIS

[lat,long,elev,dist,area] = STREAMobj2XY(S_largest,DEMc,S_largest.distance,A); %extract the variables of interest 

%calculate the slope at each pixel along the channel
slope = zeros(size(dist));
slope(:) = NaN;

for i = 2:(length(dist)-1)
    slope(i) = (elev(i-1)-elev(i+1))./(dist(i-1)-dist(i+1)); %slope is rise over run for each pixel
end

slope_deg = atand(slope); %convert slope to degrees

%%
%combine all of the variables into one for output
P.x = lat;
P.y = long;
P.d = dist;
P.z = elev;
P.a_m = area;
P.s = slope;
P.s_deg = slope_deg;
P.MS = MS; %this saves the map structure of the stream network for uploading into ArcGIS
%%
%Plot a hillshade of the DEM with the main stem overlain on it
figure
imageschs(DEM, DEM, 'colorbarylabel', 'Elevation (m)')
hold on
plot(S_trunk,'r-', 'linewidth', 2)
title({'Entire stream network ',name})
xlabel('UTM Easting (m)')
ylabel('UTM Northing (m)')