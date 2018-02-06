# Team: Chantalle_Tom
# Names: Chantalle Diepmaat & Tom Hardy
# Date: 12 January 2018

# Initializing (empty work environment and load packages)
rm(list=ls())
if(!("sp" %in% rownames(installed.packages()))) {
  install.packages("sp")}
if(!("rgal" %in% rownames(installed.packages()))) {
  install.packages("rgdal")}
if(!("raster" %in% rownames(installed.packages()))) {
  install.packages("raster")}
library(sp)
library(rgdal)
library(raster)

# downloading, unzipping and untarring the files
# Ls5 refers to the image from 1990 from Landsat 5 and Ls8 to one from 2014 from Landsat 8.

download.file(url='https://www.dropbox.com/sh/3lz5vylc7tzpiup/AAB3HCFHdJFa8lV_PMRlV5Wda?dl=1',
              destfile='Data/Landsat', method='auto')
unzip('Data/Landsat', exdir= 'Data')
untar('Data/LT51980241990098-SC20150107121947.tar.gz', exdir= 'Data/Ls5')
untar('Data/LC81970242014109-SC20141230042441.tar.gz', exdir= 'Data/Ls8')

# check the files that are in the zip
listLs5 <- list.files(path = 'Data/Ls5', pattern=glob2rx('*tif'), full.names=TRUE)
listLs8 <- list.files(path = 'Data/Ls8', pattern=glob2rx('*tif'), full.names=TRUE)

# stack the layers we need, because we work with the NDVI the layers we want are NIR and Red.
# for landsat 5 Red and NIR correspond to band 3 and 4, which are located at the index 6 and 7.
stackLs5 <- stack(listLs5[[6]], listLs5[[7]], listLs5[[1]])
plot(stackLs5[[1]])
# for landsat 8 Red and NIR correspond to band 4 and 5, which are located at the index 5 and 6.
stackLs8 <- stack(listLs8[[5]], listLs8[[6]], listLs8[[1]])

# making a mask layer so that we can crop water and cloud out of the image, and apply the actual mask to the two stacks
maskLs5 <- stackLs5[[3]]
maskLs8 <- stackLs8[[3]]
maskLs5[maskLs5 != 0] <- NA
maskLs8[maskLs8 != 0] <- NA
cloudFreeLs5 <- mask(x = stackLs5, mask = maskLs5)
cloudFreeLs8 <- mask(x = stackLs8, mask = maskLs8)

# create intermediate results in the output folder
png(filename = "output/maskLs5.png")
plot(maskLs5)
png(filename = "output/maskLs8.png")
plot(maskLs8)
png(filename = "output/cloudFreeLs5.png")
plot(cloudFreeLs5)
png(filename = "output/cloudFreeLs8.png")
plot(cloudFreeLs8)

# Check coordinate system and check if they are equal for the two steps(stackLs5)
proj4string(cloudFreeLs5)
proj4string(cloudFreeLs8)
proj4string(cloudFreeLs5) == proj4string(cloudFreeLs8)

# Crop the larger image (landsat5) according to the extent of the smaller image(landsat8).
croppedLs5 <- intersect(cloudFreeLs5, cloudFreeLs8)
# Crop again because they didn't fit yet.
croppedLs8 <- intersect(cloudFreeLs8, croppedLs5)


# Calculate the NDVI (y=NIR and x=Red)
ndviOver <- function (x , y){
  ndvi <- (y - x)/(y+x)
  return(ndvi)
}
ndviLs5 <- overlay(x = croppedLs5[[1]], y = croppedLs5[[2]], fun=ndviOver)
ndviLs8 <- overlay(x = croppedLs8[[1]], y = croppedLs8[[2]], fun=ndviOver)

png(filename = "output/ndvi5.png")
plot(ndviLs5)
png(filename = "output/ndvi8.png")
plot(ndviLs8)

# Calculate the difference in the NDVI
DifferenceNDVI <- ndviLs8 - ndviLs5
png(filename = "output/DifferenceNDVI.png")
plot(DifferenceNDVI)

# command to close png function. To visualize the png's, please also close R itself.
dev.off()

######################################################################################
