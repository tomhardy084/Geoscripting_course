# Team: Chantalle_Tom
# Names: Chantalle Diepmaat & Tom Hardy
# Date: 16 January 2018

## Please set working directory via Session -> Set Working Directory -> To Source File Location


## empty work environment
rm(list = ls())

# create directories
if (!(file.exists('data'))) {
  dir.create(file.path('data'))
  }
if (!(file.exists('R'))) {
  dir.create(file.path('R'))
  }
if (!(file.exists('output'))) {
  dir.create(file.path('output'))
  }

## install and load packages
if(!("sf" %in% rownames(installed.packages()))) {
  install.packages("sf")}
if(!("sp" %in% rownames(installed.packages()))) {
  install.packages("sp")}
if(!("raster" %in% rownames(installed.packages()))) {
  install.packages("raster")}
if(!("rgeos" %in% rownames(installed.packages()))) {
  install.packages("rgeos")}


library(sf)
library(sp)
library(raster)
library(rgeos)


## get modis data
url <- "https://raw.githubusercontent.com/GeoScripting-WUR/VectorRaster/gh-pages/data/MODIS.zip"
method <- "auto" # change to "wget" or "curl" if "auto" does not work
download.file(url = url, destfile = "data/MODIS.zip", method = method)

## unzip the Modis file in the 'data' directory
unzip("data/MODIS.zip", exdir = "data")

## load Modis data into environment and create a rasterBrick
ModisPath <- list.files(pattern = glob2rx('MOD*.grd'), full.names = TRUE, path = 'data')
ModisBrick <- brick(ModisPath)

## get municipality boundaries, transform them to class 'sf', 
nlMunicipality <- raster::getData('GADM', country='NLD', level=2, path = 'data')
nlMunicipality_sf <- as(nlMunicipality, "sf")

## reproject them to 'proj4string(ModisBrick)', and transform them back to class 'Spatial'
nlMunicipality_proj <- st_transform(nlMunicipality_sf, crs = proj4string(ModisBrick))
nlMunicipality_sp <- as(nlMunicipality_proj, "Spatial")

## check whether spatial polygons and rasterBrick have same projection
identical(proj4string(ModisBrick), proj4string(nlMunicipality_sp))

## mask Modis brick according to municipality boundaries
ModisBrickMask <- mask(ModisBrick, nlMunicipality_sp)

## extract single Modis raster layers for January, August, and the average over the year
ModisJan <- ModisBrickMask[[1]]
ModisAug <- ModisBrickMask[[8]]
ModisMean <- mean(ModisBrickMask)

## extract and calculate the mean NDVI values for each municipality
NDVIMunicJan <- extract(ModisJan, nlMunicipality_sp, df=TRUE, fun=mean, na.rm = TRUE)
NDVIMunicAug <- extract(ModisAug, nlMunicipality_sp, df=TRUE, fun=mean, na.rm = TRUE)
NDVIMunicMean <- extract(ModisMean, nlMunicipality_sp, df=TRUE, fun=mean, na.rm = TRUE)

## make one dataframe from the three extractions
NDVIMunicDF <- cbind(as.data.frame(nlMunicipality@data$NAME_2), NDVIMunicJan[, 2], NDVIMunicAug[, 2], NDVIMunicMean[, 2])
names(NDVIMunicDF) <- c("Name", "January", "August", "YearAverage")

## find the greenest municipality
greenestJan <- as.character(NDVIMunicDF[which(NDVIMunicDF$January == max(NDVIMunicDF$January)), "Name"])
greenestAug <- as.character(NDVIMunicDF[which(NDVIMunicDF$August == max(NDVIMunicDF$August)), "Name"])
greenestAvg <- as.character(NDVIMunicDF[which(NDVIMunicDF$YearAverage == max(NDVIMunicDF$YearAverage)), "Name"])


## Plot results
par <- par(mfrow = c(1,3), oma = c(0, 0, 2, 0))
plot(ModisJan, main = paste("Municipality highest NDVI January: \n", greenestJan))
plot(nlMunicipality_sp, lwd = 0.3, add = TRUE)
plot(nlMunicipality_sp[which(nlMunicipality_sp@data$NAME_2 == greenestJan),], col = "red", add = TRUE)

plot(ModisAug, main = paste("Municipality highest NDVI August: \n", greenestAug))
plot(nlMunicipality_sp, lwd = 0.3, add = TRUE)
plot(nlMunicipality_sp[which(nlMunicipality_sp@data$NAME_2 == greenestAug),], col = "red", add = TRUE)

plot(ModisMean, main = paste("Municipality highest NDVI Average: \n", greenestAvg))
plot(nlMunicipality_sp, lwd = 0.3, add = TRUE)
plot(nlMunicipality_sp[which(nlMunicipality_sp@data$NAME_2 == greenestAvg),], col = "red", add = TRUE)

title("NDVI(*10000) of the Netherlands in January, August, and average over the year", outer = TRUE)


### BONUS: Greenest province in January
## Agreggate municipalities to provinces
nlProvince_sp <- aggregate(nlMunicipality_sp, by = "NAME_1")

## mask Modis brick according to province boundaries
ModisBrickMaskProv <- mask(ModisBrick, nlProvince_sp)

## extract single Modis raster layers for January
ModisJanProv <- ModisBrickMaskProv[[1]]

## extract and calculate the mean NDVI values for each province
NDVIProvJan <- extract(ModisJanProv, nlProvince_sp, df=TRUE, fun=mean, na.rm = TRUE)

## find the greenest municipality
greenestProvJan <- as.character(NDVIProvJan[which(NDVIProvJan$January == max(NDVIProvJan$January)), "ID"])

## Plot results
plot(ModisJan, main = "Province highest NDVI January: \n Utrecht")
plot(nlProvince_sp, lwd = 0.3, add = TRUE)
plot(nlProvince_sp[which(nlProvince_sp@data$NAME_1 == "Utrecht"), ], col = "red", add = TRUE)

##################################################################################################################################
