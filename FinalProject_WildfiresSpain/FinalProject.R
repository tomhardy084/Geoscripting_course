########################################
# Title: Geoscripting Final Project
# Authors: Tom Hardy, Chantalle Diepmaat
# Date: February 2, 2018
########################################


### Initialization ----------------------------------------------------------

# empty work environment
rm(list = ls())

# store names of necessary packages in a list
package_names <- c("knitr", "spatstat", "spatstat.data", "maptools", "sp",
                   "raster", "rgeos", "rgdal", "automap", "gstat", "leaflet")

# install and load the packages
lapply(package_names, FUN = function(X) {if(!(X %in% rownames(installed.packages())))
  {install.packages(X)}})
lapply(package_names, require, character.only = TRUE)

# store names of directories in a list and create the directories
directories <- c("data", "R", "output")
lapply(directories, FUN = function(X) {if (!(file.exists(X)))
  {dir.create(file.path(X))}})

# store function names in a list and source the functions
functions <- list.files("R")
lapply(functions, FUN = function(X) {source(paste0("R/", X))})



### Extract files -----------------------------------------------------------

# set project string for UTM zone 30N WGS84 projection (Spain)
proj_string <- "+proj=utm +zone=30 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"

# extract CLM dataset from spatstat package,
# and apply the 'func_projection' function to set the right coordinates for zone UTM 30N
clm_vector_raw <- spatstat::clmfires
clm_vector <- func_projection(proj_string = proj_string, input_data = clm_vector_raw)

# Extract CLM boundary, convert to spatial polygon, and assign UTM projection
clm_bound_sp <- as(clm_vector$window, "SpatialPolygons")
crs(clm_bound_sp) <- proj_string

# Extract CLM point data containing wildfire locations with 'func_extract_points' function
clm_fires_sp <- func_extract_points(proj_string = proj_string, vector_data = clm_vector)

# Extract CLM landuse data 'func_extract_landuse' function
clm_landuse <- func_extract_landuse(proj_string = proj_string, func = func_projection, boundary = clm_bound_sp)

# Plot CLM landuse data with 'func_plot_landuse' function
png("output/clm_landuse_plot.png")
clm_landuse_plot <- func_plot_landuse(landuse_data = clm_landuse[[1]], boundary = clm_bound_sp)
clm_landuse_plot
dev.off()



### Spatial interpolation ---------------------------------------------------

# NOTE: This section of code might produce some warnings when running the 'func_kriging' function for some years.
# This does not affect the output, so please ignore these warnings.

# Create list with all the years
years <- 1998:2007

# Derive CLM kriged data for all years with 'func_kriging' function
kriged_data <- list()
for (year in 1:length(years)) {
  kriged_data[[year]] <- func_kriging(proj_string = proj_string,
                                      year = years[year],
                                      landuse_data = clm_landuse[[2]],
                                      point_data = clm_fires_sp,
                                      boundary = clm_bound_sp)
}
names(kriged_data) <- years

# Plot CLM kriged data for all years with 'func_plot_kriged' function
for (i in 1:length(kriged_data)){
  png(paste0("output/clm_landuse_plot.png", years[i]))
  func_plot_kriged(years[i], kriged_data[[i]], clm_bound_sp)
}

dev.off()

#### end ####

##########################################################################################################