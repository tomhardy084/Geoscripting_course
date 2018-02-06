func_kriging <- function(proj_string, year, landuse_data, point_data, boundary) {
  ## This function constructs a kriged raster map, containing the predictions for wildfire risks in the CLM region.
  ## These predictions are determined by first building a linear model (lm) with 'burnt area' as response,
  ## and 'landuse', 'cause', 'date' as predictors. This lm is used as input for variogram estimation and fitting,
  ## and subsequentially this variogram is used as input for the kriging function. Moreover, a new dataset is created
  ## (mask_raster and clm_mask) providing the input for the kriging function
  
  ## The parameters of this function are:
    ## proj_string, which is a project string for the selected UTM zone.
    ## year, which is the year (as numeric) to perform the kriging function for.
    ## landuse_data: landuse dataset with class spatialGridDataFrame (not a raster!)
    ## point_data: the dataset with class spatialpointsdataframe containing information about the wildfires
    ## boundary, which is the region boundary in spatialpolygons format.
  
  ## This function returns a kriged raster map from the selected year for the CLM region.
  ## The dimensions, coordinates, and extents are according to UTM zone 30N.
  
  ## NOTE: Please source the 'func_extract_landuse' function first!
  
  # select data from the input year
  selected_year <- which(startsWith(as.character(point_data$date), as.character(year)))
  clm_fires_year_df <- point_data[selected_year, ]
  clm_fires_year_sp <- as(clm_fires_year_df, "SpatialPointsDataFrame")
  
  # create grid-points overlay and add landuse data to spatialpointsdataframe
  clm_overlay = sp::over(clm_fires_year_sp, landuse_data)
  clm_fires_year_sp@data$landuse = clm_overlay$v
  
  # create a linear model with log(burnt_area) as response, and landuse and data as predictors
  clm_lin_mod <- lm(log(burnt_area) ~ landuse + cause + date, data = clm_fires_year_sp)
  clm_residuals <- residuals(clm_lin_mod)
  
  # apply autofitVariogram function to estimate and fit a semivariogram, based on residuals linear model
  clm_fires_vgm <- autofitVariogram(formula = clm_residuals ~ 1,
                                    input_data = clm_fires_year_sp,
                                    model = c("Sph", "Exp", "Gau", "Mat", "Ste"),
                                    kappa = c(0.05, seq(0.2, 2, 0.1), 5, 10),
                                    miscFitOptions = list(merge.small.bins = TRUE))
  
  # as input for the krige function: create a new raster with a value (1) and set its extents
  new_raster <- raster(ncol = 200, nrow = 200, crs = proj_string)
  new_raster[] <- 1
  extent(new_raster) <- extent(landuse_data)
  
  # mask the raster according to clm boundary
  mask_raster <- mask(new_raster, boundary)
  crs(mask_raster) <- proj_string
  
  # change raster cells to points, points to dataframe, and dataframe to spatialpoints dataframe
  clm_mask <- rasterToPoints(mask_raster)
  clm_mask_sp <- as.data.frame(clm_mask)
  coordinates(clm_mask_sp) <- ~ x + y
  crs(clm_mask_sp) <- proj_string
  
  # perform kriging based on the autofitted variogram, point locations, and new raster
  clm_kriged_points <- krige(formula = clm_residuals ~ 1,
                             locations = clm_fires_year_sp,
                             newdata = clm_mask_sp,
                             model = clm_fires_vgm$var_model)
  
  
  # transform kriged map into a raster map and set the proper project string for UTM zone 30N
  clm_kriged <- rasterFromXYZ(clm_kriged_points)
  crs(clm_kriged) <- proj_string
  
  return(clm_kriged)
}