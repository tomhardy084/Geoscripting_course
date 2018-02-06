## GeoScripting Exercise 3 Team Chantalle_Tom ##

# Function definition
is.leap <- function(year) {
  # Provide a year as numerical value, in order to determine
  # whether it is a leap year or not.
  # Output will be TRUE or FALSE. If a non-numerical input,
  # or a year below 1581 was given, you'll be asked to provide a proper year again.
  
  while(!is.numeric(year)) {
    year <- as.integer(readline("Wrong input. Please give a numerical value:"))}
  while(year < 1582) {
    year <- as.integer(readline("Input out of range. Please give a year above 1581:"))}
  if(year%%4 != 0) {
    return(FALSE)
  } else if(year%%100 != 0) {
    return(TRUE)
  } else if(year%%400 != 0) {
    return(FALSE)
  } else {
    return(TRUE)
  }
}