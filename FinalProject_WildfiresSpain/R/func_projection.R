func_projection <- function(proj_string, input_data) {
  ## This function calculates the difference in extents between the CLM administrative boundary datasets derived
  ## from the raster package and from the spatstat'clmfires' dataset. Moreover, it changes the dimensions
  ## from kilometers to meters by multiplying it with a factor of 1000.
  
  ## The parameters of this function are:
     ## proj_string, which is a project string for the selected UTM zone.
     ## input_data, which is a dataset in image, raster, grid, spatialpoints, or spatialpolygons format.
  
  ## This function returns the same map as the input maps, but then in the right dimensions, coordinates, 
  ## and extents according to UTM zone 30N.
  
  # extract administrative boundary for CLM from the raster package, assign UTM projection, an derive extents
  clm_gadm <- raster::getData('GADM', country='ESP', level=1, path = 'data')
  clm_gadm_sp <- clm_gadm[clm_gadm$NAME_1 == "Castilla-La Mancha", ]
  clm_gadm_utm <- spTransform(clm_gadm_sp, CRSobj = proj_string)
  clm_gadm_ext <- bbox(clm_gadm_utm)
  
  # extract administrative boundary for CLM from clmfires dataset, and derive extents
  clm_gadm2 <- affine(spatstat::clmfires, mat = diag(c(1000, 1000)))
  clm_gadm2_sp <- as(clm_gadm2$window, "SpatialPolygons")
  clm_gadm2_ext <- bbox(clm_gadm2_sp)
  
  # calculate difference between two extents, and average out the x and y differences
  clm_diff_ext <- clm_gadm_ext - clm_gadm2_ext
  clm_shift <- as.vector(apply(clm_diff_ext, MARGIN = 1, mean))
  
  # apply affine transformation to correct the shift in extents
  output_data <- affine(input_data, mat = diag(c(1000, 1000)), vec = clm_shift)
  
  return(output_data)
}
