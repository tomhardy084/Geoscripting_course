func_plot_landuse <- function(landuse_data, boundary) {
  ## This function plots the landuse map for the CLM region.
  ## The dimensions, coordinates, and extents are according to UTM zone 30N.
  
  ## The parameters of this function are:
    ## landuse_data: landuse dataset with class spatialGridDataFrame (not a raster!)
    ## boundary, which is the region boundary in spatialpolygons format.
  
  ## NOTE: Please source the 'func_extract_landuse' function first!
  
  # plot the landuse raster
  legend <- na.omit(as.character(landuse_data@data@attributes[[1]][,"levels"]))
  colors <- c('#006837', '#1a9850', '#66bd63', '#a6d96a', '#d9ef8b', '#fee08b', '#fdae61', '#f46d43', '#d73027', '#a50026')
  plot(landuse_data, legend = FALSE, col = colors,
       main = "Landuse map Castilla-La Mancha")
  legend("bottomleft", legend = legend, title = "Legend", fill = colors, cex = 0.8)
  plot(boundary, add = TRUE)
}