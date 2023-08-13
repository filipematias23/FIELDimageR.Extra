#' fieldInfo_extra 
#' 
#' @title Extract information from image using the fieldShape file as reference
#' 
#' @description Function that use \code{raster::extract()} to extract information from the original 
#' image using fieldShape file as reference.
#' 
#' @param mosaic object of class stack.
#' @param fieldShape plot shape file, please use first the function \code{\link{fieldShape}}. 
#' @param fun to summarize the values (e.g. mean).
#' 
#' @importFrom sf st_crs st_transform st_as_sf st_join
#' @importFrom terra rast extract
#' @importFrom stars write_stars st_warp st_as_stars st_extract
#' 
#' @return A data frame class "sf" with values by plot.
#'
#' @export
fieldInfo_extra <- function(mosaic,
                            fieldShape,
                            fun = mean) {
  print("Starting data extraction per plot ...")
  if (is.null(mosaic)) {
    stop("The input 'mosaic' object is NULL.")
  }
  if(class(mosaic)%in%c("RasterStack","RasterLayer","RasterBrick")){
    mosaic<-terra::rast(mosaic)
  }
  plotInfo <- terra::extract(mosaic, fieldShape, fun = fun, na.rm = TRUE)
  Out<-cbind(fieldShape, plotInfo[,!colnames(plotInfo)%in%c("ID")])
  print("End!")
  return(Out)
}
