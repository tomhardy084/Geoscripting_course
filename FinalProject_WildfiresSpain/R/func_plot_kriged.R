func_plot_kriged <- function(year, kriged_data, boundary) {
  ## This function plots the landuse map for the CLM region.
  ## The dimensions, coordinates, and extents are according to UTM zone 30N.
  
  ## The parameters of this function are:
    ## year: which is the year (as numeric) to perform the plotting for.
    ## kriged_data: kriged dataset with class raster.
    ## boundary: which is the region boundary in spatialpolygons format.
  
  ## NOTE: Please source the 'func_kriging' function first!
  
  # plot the kriged raster datasets for each year
  cols <- colorRampPalette(c("green", "yellow", "red"))
  breaks <- seq(-1.2, 3.2, 0.2)
  plot(kriged_data, breaks = breaks, col = cols(length(breaks) - 1),
       legend = FALSE, main = paste("wildfire risk map", year))
  legend <- c("low risk", "medium risk", "high risk")
  legend("bottomleft", legend = legend, title = "Legend", fill = c("green", "yellow", "red"), cex = 0.8)
  plot(boundary, add = TRUE)
}