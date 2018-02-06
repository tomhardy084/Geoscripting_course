# Team: Chantalle_Tom
# Names: Chantalle Diepmaat & Tom Hardy
# Date: 11 January 2018

# R script to test whether created NDVI maps can be loaded and plotted.


# empty work environment
rm(list=ls())
# change working directory to your own
setwd("~/M/Geo_Scripting/Exercises/Exercise4")

# install and import packages
if(!("raster" %in% rownames(installed.packages()))) {
  install.packages("raster")}
if(!("rgdal" %in% rownames(installed.packages()))) {
  install.packages("rgdal")}
library(raster)
library(rgdal)

# create variables from the maps
NDVI <- raster("Data/NDVI.tif")
NDVI6060 <- raster("Data/NDVI6060.tif")
WGS84 <- raster("Data/NDVI_WGS84.tif")

# plot the maps
plot(NDVI)
plot(NDVI6060)
plot(WGS84)

