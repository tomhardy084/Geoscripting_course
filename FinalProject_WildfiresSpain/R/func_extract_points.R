func_extract_points <- function(proj_string, vector_data) {
  ## This function extracts the CLM forest locations as points, including attributes 'cause', 'burnt_area', 'date'.
  ## It creates a dataframe from this and subsequentially a spatialpointsdataframe.
  
  ## The parameters of this function are:
    ## proj_string, which is a project string for the selected UTM zone.
    ## vector_data, which is a dataset in owin, spatialpoints, or spatialpolygons format.
  
  ## This function returns a spatialpointsdataframe including coordinates and attributes. The dimensions, coordinates, 
  ## and extents are according to UTM zone 30N.
  
  ## NOTE: Please source the 'func_projection' function first!
  
  # extract CLM forest fire locations incl. its attributes
  clm_fires_xcoor <- vector_data$x
  clm_fires_ycoor <- vector_data$y
  clm_fires_cause <- vector_data$marks$cause
  clm_fires_area <- vector_data$marks$burnt.area
  clm_fires_date <- vector_data$marks$date
  
  # convert these data to a dataframe
  clm_fires_df <- data.frame(clm_fires_xcoor, clm_fires_ycoor,
                             clm_fires_cause, clm_fires_area,
                             clm_fires_date)
  names(clm_fires_df) <- c("x", "y", "cause", "burnt_area", "date")
  
  # select data that contain burnt area sizes of at leas 0.25 ha
  selected_burn <- which(clm_fires_df$burnt_area >= 0.25)
  clm_fires_reduced <- clm_fires_df[selected_burn, ]
  
  # Convert dataframe to spatial points, and assign UTM projection
  clm_fires_sp <- SpatialPointsDataFrame(coords = clm_fires_reduced[, 1:2], data = clm_fires_reduced)
  crs(clm_fires_sp) <- proj_string
  
  return(clm_fires_sp)
}

