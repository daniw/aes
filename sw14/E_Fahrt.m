clc;
clear;
close all;

%% Import the data
[~, ~, raw] = xlsread('C:\Daten\Daniel\studium\sem8\aes\sw14\E-Fahrt\doc.csv','doc');
raw = raw(2:end,:);
%% Create output variable
data = cell2mat(raw);
%% Allocate imported array to column variable names
time = data(:,1);
longitude = data(:,2);
latitude = data(:,3);
altitude = data(:,4);
speed = 3.6 * data(:,5);
bearing = data(:,6);
accuracy = data(:,7);
%% Clear temporary variables
clearvars data raw columnIndices;

%% Convert WGS84 to CH1903
% http://www.swisstopo.admin.ch/internet/swisstopo/de/home/products/software/products/skripts.parsysrelated1.45237.downloadList.24407.DownloadFile.tmp/ch1903wgs84de.pdf
lon_conv = (3600 * longitude - 26782.5)/10000;
lat_conv = (3600 * latitude - 169028.66)/10000;
x = 600072.37 ...
  + 211455.00 * lon_conv ...
  -  10938.51 * lon_conv    .* lat_conv ...
  -      0.36 * lon_conv    .* lat_conv.^2 ...
  -     44.54 * lon_conv.^3;
y = 200147.07 ...
  + 308807.95                * lat_conv ...
  +   3745.25 * lon_conv.^2 ...
  +     76.63                * lat_conv.^2 ...
  -    194.56 * lon_conv.^2 .* lat_conv ...
  +    119.79                * lat_conv.^3;
z = altitude ...
  -     49.55 ...
  +      2.73 * lon_conv ...
  +      6.94                * lat_conv;

%% calculate axis
x_center = (max(x) + min(x)) / 2;
x_span = max(x) - min(x);
y_center = (max(y) + min(y)) / 2;
y_span = max(y) - min(y);
z_center = (max(z) + min(z)) / 2;
z_span = max(z) - min(z);

%% Plot drive
figure(1)
cmap = colormap;
% change speed into an index into the colormap
% min(speed) -> 1, max(speed) -> number of colors
speed_colormap = round(1+(size(cmap,1)-1)*(speed - min(speed))/(max(speed)-min(speed)));
% make a blank plot
plot3(x-x(1), y-y(1), z-z(1), 'linestyle', 'none')
title('Think city test drive Horw -> Hergiswil -> Horw');
xlabel('X [m]');
ylabel('Y [m]');
zlabel('Altitude [m]');
axis([x_center - x_span/2 - x(1), x_center + x_span/2 - x(1), y_center - y_span/2 - y(1), y_center + y_span/2 - y(1), z_center - z_span/2 - z(1), z_center + z_span/2 - z(1)]);
% add line segments
for k = 1:(length(x)-1)
line(x(k:k+1)-x(1),y(k:k+1)-y(1),z(k:k+1)-z(1), 'Linewidth', 2,'color',cmap(speed_colormap(k),:))
end
colorbar
grid on

print -dpdf E-Fahrt
