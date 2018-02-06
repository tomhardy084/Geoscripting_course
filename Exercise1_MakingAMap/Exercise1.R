# Name: Chantalle_Tom, Chantalle & Tom
# Date: 8 January 2018

# initialization (empty environment)
rm(list = ls())


# load packages
library(raster)

# Define the function
Make_Map <- function(country, level){
  
  datdir<-'data'
  dir.create(datdir, showWarnings = FALSE)
  adm <- raster::getData("GADM", country = country,
                       level = level, path=datdir)

  country <- adm[adm$NAME_0 == country,]
  plot(country, bg = "dodgerblue", axes=TRUE)
  plot(country, lwd = 10, border = "skyblue", add=TRUE)
  plot(country, col = "yellow3", add = TRUE)
  grid()
  box()
  invisible(text(getSpPPolygonsLabptSlots(country),
               labels = as.character(country$NAME_1), cex = 0.8, col = "black", font = 2))


  mtext(side = 3, line = 1, c("National Map of\n", country$NAME_0[1]), cex = 2)
  mtext(side = 1, "Longitude", line = 2.5, cex=1.1)
  mtext(side = 2, "Latitude", line = 2.5, cex=1.1)
  }

# An example based on that function. 
raster::getData("ISO3")
Make_Map("Senegal", 1) #The first argument should be a country in English, 
                       #the second argument should be the administrative level (0, 1 or 2)

