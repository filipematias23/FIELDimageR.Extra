#' fieldView
#' 
#' @title Image and plot grid shape file visualization
#' 
#' @description Graphic visualization of trait values for each plot using the \code{\link{fieldShape}} file and original image. 
#' @param mosaic object of class 'rast' or 'stars' obtained from function \code{\link{terra::rast()}}.
#' @param fieldShape plot grid 'fieldShape' object to be edited from \code{\link{fieldShape_render()}}. 
#' @param plotCol column name in  'fieldShape' to color each plot.
#' @param editor editing image.
#' @param type if 1 mosaic and 'fieldShape' will be visualized side by side. If 2, 'mosaic' and 'fieldShape' will be overlayed (Attention: only small size mosaics can be visualized on type=2).
#' @param r red layer in the mosaic (for RGB image normally is 1). If NULL the first single layer will be plotted. 
#' @param g green layer in the mosaic (for RGB image normally is 2). If NULL the first single layer will be plotted.
#' @param b blue layer in the mosaic (for RGB image normally is 3). If NULL the first single layer will be plotted.
#' @param colorOptions single layer coloring options. Check more information at \code{\link{colorOptions}} from \code{\link{leafem}} package (check for 'palette').
#' @param col_grid grid color options similar to 'col.regions' parameter in 'mapview'.
#' @param alpha_grid transparency with values between 0 and 1.
#' @param seq_grid color classes similar to 'at' parameter in 'mapview'.
#' @param max_pixels maximun pixels allowed before down sampling. Reducing size to accelerate analysis. Default = 100000000.
#' @param downsample  numeric downsample reduction factor. Default = 5.
#' 
#' @importFrom sf st_crs st_bbox st_transform st_is_longlat st_crop 
#' @importFrom terra crop nlyr rast
#' @importFrom stars read_stars write_stars st_warp st_as_stars st_downsample
#' @importFrom mapview mapview 
#' @importFrom mapedit editFeatures drawFeatures
#' @importFrom leafem addGeoRaster addImageQuery
#' @importFrom raster stack
#' @importFrom dplyr %>%
#' @importFrom leaflet addLayersControl
#' @importFrom leafsync sync 
#' 
#' @return Mosaic and fieldShape visualization object.
#' 
#'
#' @export
fieldView <- function(mosaic = NULL, 
                      fieldShape = NULL,
                      plotCol = NULL, 
                      editor = FALSE,
                      type = 1,
                      r = 1, 
                      g = 2, 
                      b = 3,
                      colorOptions = viridisLite::viridis,
                      col_grid = viridisLite::viridis,
                      alpha_grid = 1,
                      seq_grid = NULL,
                      max_pixels = 100000000,
                      downsample = 5) {
  print("Starting analysis ...")

  if (is.null(mosaic)) {
    stop("The input 'mosaic' object is NULL.")
  }

  if(class(mosaic)%in%c("RasterStack","RasterLayer","RasterBrick")){
    mosaic<-terra::rast(mosaic)
  }

  pixels <- prod(dim(mosaic))
  if(pixels > max_pixels){
    print("Your 'mosaic' is too large and downsapling is being applied.")
  }
  if (pixels < max_pixels) {
    stars_object <- mosaic
    if (!inherits(stars_object, "stars")) {
      stars_object <- st_as_stars(mosaic)
      if (!st_is_longlat(stars_object) && nlyr(mosaic) > 2) {
        stars_object <- st_warp(stars_object, crs = 4326)
      }
    }
  } else {
    stars_object <- mosaic
    if (!inherits(stars_object, "stars")) {
      stars_object <- st_as_stars(mosaic, proxy = TRUE)
      names(stars_object)<-"layer_name"
      # stars_object <- read_stars(stars_object$layer_name, proxy = TRUE)
      stars_object <- st_downsample(stars_object, n = downsample)
    }
  }

  if(type==1){
    if (!is.null(mosaic) && !editor) {
      if (nlyr(mosaic) > 2) {
        stars_object[is.na(stars_object)] <- 0
        m1 <- mapview() %>%
          leafem:::addRGB(x = stars_object, r = r, g = g, b = b) 
        sf_end <- m1
        gc()
      } else if (nlyr(mosaic) == 1) {
        stars_object[is.na(stars_object)] <- NA
        m1 <- mapview() %>%
          leafem:::addGeoRaster(x = stars_object, colorOptions = leafem:::colorOptions(palette = colorOptions, na.color = "transparent")) %>%
          addImageQuery(x = stars_object, type = "mousemove", digits = 2, layerId = names(mosaic)) %>%
          addLayersControl(overlayGroups = names(mosaic))
        sf_end <- m1
        gc()
      }
    } else if (!is.null(mosaic) && editor) {  
      if (nlyr(mosaic) > 2) {
        stars_object[is.na(stars_object)] <- 0
        sf_shp <- mapview() %>%
          leafem:::addRGB(x = stars_object, r = r, g = g, b = b) %>%
          drawFeatures(editor = "leafpm")
        gc()
        if (!is.null(sf_shp)) {
          sf_obj <- sf_shp %>% st_transform(st_crs(mosaic))
        } else {
          print("No feature created ...")
          sf_end <- NULL
        }
      } else if (nlyr(mosaic) == 1) {
        if (nlyr(mosaic) == 1)
  stars_object[is.na(stars_object)] <- NA
sf_shp <- mapview() %>%
  leafem:::addGeoRaster(x = stars_object, colorOptions = leafem:::colorOptions(palette = colorOptions, na.color = "transparent")) %>%
          addImageQuery(x = stars_object, type = "mousemove", digits = 2, layerId = names(mosaic)) %>%
          addLayersControl(overlayGroups = names(mosaic)) %>%
          drawFeatures(editor = "leafpm") 
        gc()
        if (!is.null(sf_shp)) {
          sf_obj <- sf_shp %>% st_transform(st_crs(mosaic))
        } else {
          print("No feature created ...")
          sf_end <- NULL
        }
      } else {
        sf_end <- NULL
      }
      sf_end <- sf_obj
    }}
  if(!is.null(fieldShape)){
    if(type==1){m1<-sf_end}
    m2<-mapview(fieldShape, 
                col.regions = col_grid, 
                alpha.regions=alpha_grid,
                at = seq_grid)
    if(!is.null(plotCol)){
      if(!all(plotCol%in%colnames(fieldShape))){
        print("'plotCol' in not a column in fieldShape")
      }
      if(all(plotCol%in%colnames(fieldShape))){
        m2<-mapview(fieldShape,
                    zcol=plotCol,
                    legend=TRUE,
                    alpha.regions=alpha_grid,
                    col.regions = col_grid,
                    at = seq_grid,
                    layer.name=plotCol)
      }
    }
    if(type==1){
      sf_end<-sync(m1,m2)
    }
    if(type==2){
      if(class(mosaic)%in%c("SpatRaster")){
        nBand<-nlyr(mosaic)
      }
      if(class(mosaic)%in%c("RasterStack")){
        nBand<-length(mosaic1@layers)
      }
      if (nBand == 1){
        layer<-st_as_stars(mosaic)
        sf_end<-mapview(layer,
                        col.regions=colorOptions,
                        layer.name="")+m2
      }
      if (nBand > 2){
        mosaic<-raster::stack(mosaic)
        sf_end<-viewRGB(mosaic)+m2
      }
    }
  }
  print("End!")
  return(sf_end)
}
