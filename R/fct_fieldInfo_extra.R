#' fieldInfo_extra
#'
#' @title Extract information from image using the fieldShape file as reference
#'
#' @description Function that use \code{exactextractr::exact_extract()} to extract information from the original
#' image using fieldShape file as reference.
#'
#' @param mosaic object of class stack.
#' @param fieldShape plot shape file, please use first the function \code{\link{fieldShape}}.
#' @param fun character to summarize the values (e.g. "mean").
#' @param progress if TRUE, display a progress bar during processing
#'
#' @importFrom sf st_crs st_transform st_as_sf st_join
#' @importFrom exactextractr exact_extract
#' @importFrom stars write_stars st_warp st_as_stars st_extract
#'
#' @return A data frame class "sf" with values by plot.
#'
#' @export
fieldInfo_extra <- function(mosaic,
                             fieldShape,
                             fun = "mean",
                             progress = FALSE) {
  print("Starting data extraction per plot ...")
  
  if (is.null(mosaic)) {
    stop("The input 'mosaic' object is NULL.")
  }
  
  if (class(mosaic) %in% c("RasterStack", "RasterLayer", "RasterBrick")) {
    mosaic <- terra::rast(mosaic)
  }
  
  valid_functions <- c('mean', 'sum', 'max', 'min', 'mode', 'stdev', 'variance', 'coefficient_of_variation', 'majority', 'minority', "summary")
  if (!(fun %in% valid_functions)) {
    stop("Use one of the functions from ('mean', 'sum', 'max', 'min', 'mode', 'stdev', 'variance', 'coefficient_of_variation', 'majority', 'minority', 'summary').")
  }
  
  if (fun == "summary") {
    fun <- c('mean', 'sum', 'max', 'min', 'mode', 'stdev', 'variance', 'coefficient_of_variation', 'majority', 'minority')
  }
  
  plotInfo <- as.data.frame(exactextractr::exact_extract(x = mosaic, y = fieldShape, fun = fun, progress = progress, force_df = TRUE))
  
  if (length(fun) == 1) {
    colnames(plotInfo) <- paste0(names(mosaic), '_', fun)
  } else {
    colnames(plotInfo) <- paste0(names(mosaic), '_', fun)
  }
  Out<-cbind(fieldShape, plotInfo[,!colnames(plotInfo)%in%c("ID"),drop=FALSE])
  return(Out)
}
