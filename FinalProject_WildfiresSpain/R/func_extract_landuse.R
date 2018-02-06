func_extract_landuse <- function(proj_string, func, boundary) {
  ## This function extracts the CLM landuse raster image from the spatstat 'clmfires.extra' dataset.
  ## It creates a spatialgriddataframe from this and subsequentially a raster dataset.
  
  ## The parameters of this function are:
    ## proj_string, which is a project string for the selected UTM zone.
    ## func, which is the reprojection function (for example 'func_reproject') to set the proper dimensions and coordinates.
    ## boundary, which is the region boundary in spatialpolygons format.
  
  ## This function returns a list containing both a landuse grid and landuse raster. The dimensions, coordinates, 
  ## and extents are according to UTM zone 30N.
  
  ## NOTE: Please source the 'func_extract_points' function first!
  
  # extract landuse image from clmfires.extra dataset in spatstat package, and apply the 'func_projection' function
  clm_landuse_img <- spatstat::clmfires.extra$clmcov200$landuse
  clm_landuse_prj <- func(proj_string = proj_string, input_data = clm_landuse_img)
  
  # Convert image to a spatial grid dataframe and raster, and assign UTM projection
  clm_landuse_grid <- as.SpatialGridDataFrame.im(clm_landuse_prj)
  clm_landuse_ras <- raster(clm_landuse_grid)
  crs(clm_landuse_grid) <- proj_string
  crs(clm_landuse_ras) <- proj_string
  
  # mask the landuse raster according to clm boundary
  clm_landuse <- mask(clm_landuse_ras, boundary)
  
  return(c(clm_landuse, clm_landuse_grid))
}
