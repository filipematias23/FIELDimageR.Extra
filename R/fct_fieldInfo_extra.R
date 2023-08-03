#' fieldInfo 
#' 
#' @title Extract information from image using the fieldShape file as reference
#' 
#' @description Function that use \code{raster::extract()} to extract information from the original 
#' image using fieldShape file as reference.
#' 
#' @param mosaic object of class stack.
#' @param fieldShape plot shape file, please use first the function \code{\link{fieldShape}}. 
#' @param fun to summarize the values (e.g. mean).
#' @param plot if is TRUE the original and crop image will be plotted.
#' @param buffer negative values should be used to remove boundaries from neighbor plot 
#'  (normally the unit is meters, please use values as 0.1 = 10 cm). 
#' @param n.core number of cores to use for multicore processing (Parallel).
#' @param projection if is FALSE projection will be ignored.
#' 
#' @importFrom sf st_crs st_transform st_as_sf st_join
#' @importFrom terra rast
#' @importFrom stars write_stars st_warp st_as_stars st_extract
#' 
#' @return A data frame class "sf" with values by plot.
#'
#' @export
fieldInfo_extra <- function(mosaic, 
                            fieldShape, 
                            fun = mean) { 
  print("Starting extracting ...")
  
  if (is.null(mosaic)) {
    stop("The input 'mosaic' object is NULL.")
  }
  
  stars_object<-mosaic
  if(!class(stars_object)=="stars"){stars_object<-st_as_stars(rast(mosaic))}
  fieldShape_utm <- st_transform(fieldShape, st_crs(stars_object))
  plotInfo <- st_as_sf(aggregate(stars_object, fieldShape_utm, FUN = fun, na.rm = TRUE))
  Out<-st_join(fieldShape_utm, st_as_sf(plotInfo))
  print("End!")
  return(Out)
}
