# Team: Chantalle_Tom
# Names: Chantalle Diepmaat & Tom Hardy
# Date: 15 January 2018

# Initializing (empty work environment and load packages)
# Please set working directory via Session -> Set Working Directory -> To Source File Location

rm(list=ls())
if(!("sp" %in% rownames(installed.packages()))) {
  install.packages("sp")}
if(!("rgal" %in% rownames(installed.packages()))) {
  install.packages("rgdal")}
if(!("rgeos" %in% rownames(installed.packages()))) {
  install.packages("rgeos")}
if(!("sf" %in% rownames(installed.packages()))) {
  install.packages("sf")}
if(!("geosphere" %in% rownames(installed.packages()))) {
  install.packages("geosphere")}
if(!("lwgeom" %in% rownames(installed.packages()))) {
  install.packages("lwgeom")}
library(sp)
library(rgdal)
library(rgeos)
library(sf)
library(geosphere)
library(lwgeom)

## Download data from websites
url1 <- "http://www.mapcruzin.com/download-shapefile/netherlands-railways-shape.zip"
url2 <- "http://www.mapcruzin.com/download-shapefile/netherlands-places-shape.zip"
method <- "auto" # change to "wget" or "curl" if "auto" does not work

download.file(url = url1, destfile = "data/railways.zip", method = method)
download.file(url = url2, destfile = "data/places.zip", method = method)

## Unzip the files in the 'data' directory
unzip("data/railways.zip", exdir = "data")
unzip("data/places.zip", exdir = "data")

## Read the files into R environment
places <- st_read("data/places.shp")
railways <- st_read("data/railways.shp")

## Select the industrial railways from the 'railways' dataset
rail_ind <- railways[railways$type == "industrial", ]

## Transform projection of both datasets into RD_NEW (crs = 28992) and extract geometry
places_string <- st_transform(places, crs = 28992)
rail_ind_string <- st_transform(rail_ind, crs = 28992)
rail_ind_geom <- st_geometry(rail_ind_string)

## Create buffer of 1000 meters around industrial railway and extract geometry
buffer_rail_ind <- st_buffer(rail_ind_string, dist = 1000)
buffer_rail_ind_geom <- st_geometry(buffer_rail_ind)

## Make an intersection of the buffer and the places, in order to derive the place located within the buffer
rail_place_intersect <- st_intersection(buffer_rail_ind, places_string)

## Derive place name and population of the place within the buffer
place_name <- as.character(rail_place_intersect$name.1)
place_pop <- as.character(rail_place_intersect$population)

## Plot map of buffer including railway and place
plot(buffer_rail_ind_geom, col = "lightgreen",
     main = "Buffer around industrial railway \n including location of the city center of nearest place")
plot(rail_ind_geom, col = "red", pch = 19, add = TRUE)
plot(rail_place_intersect, col = "blue", pch = 19, add = TRUE)
grid(col = "gray")
box(col = "gray")
legend <- c("Buffer, radius = 1000m", "Industrial railway", place_name)
legend("bottomright", legend = legend, title = "Legend", fill = c("lightgreen", "red", "blue"))

(city_details <- paste("The place within the generated buffer around the industrial railway is", place_name,
                       "and has (according to the available dataset) a population of", place_pop, "inhabitants.",
                       "However, according to Wikipedia, in 2017 the city's population was 344384 inhabitants."))
#################################################################################################################
