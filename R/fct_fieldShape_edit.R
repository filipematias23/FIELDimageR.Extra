#' fieldShape_edit 
#' 
#' @title Editing each plot in the grid of a shapefile.
#' 
#' @description It allows editing each plot (change shape, remove, move, etc.).
#' 
#' @param mosaic image object format \code{\link{rast}} or \code{\link{stars}}.
#' @param fieldShape plot grid 'fieldShape' object to be edited from \code{\link{fieldShape_render()}}. 
#' @param shp plot grid made in any other GIS software. Please use \code{\link{shp=st_read("path to .shp file")}}.
#' @param r red layer in the mosaic (for RGB image normally is 1). If NULL the first single layer will be plotted. 
#' @param g green layer in the mosaic (for RGB image normally is 2). If NULL the first single layer will be plotted.
#' @param b blue layer in the mosaic (for RGB image normally is 3). If NULL the first single layer will be plotted.
#' @param color_options single layer coloring options. Check more information at \code{\link{color_options}} from \code{\link{leafem}} package.
#' @param max_pixels maximun pixels allowed before down sampling. Reducing size to accelerate analysis. Default = 100000000.
#' @param downsample  numeric downsample reduction factor. Default = 5.
#' 
#' @importFrom jpeg writeJPEG
#' @importFrom EBImage readImage display
#' @importFrom sf st_crs st_bbox st_transform st_is_longlat st_crop 
#' @importFrom terra crop nlyr rast
#' @importFrom stars write_stars st_warp st_as_stars 
#' @importFrom mapview mapview
#' @importFrom mapedit editFeatures
#' @importFrom leafem addGeoRaster
#' @importFrom dplyr %>%
#' @importFrom leaflet addLayersControl
#' 
#' @return A new edited plot 'fieldShape' class "sf" & "data.frame".
#' 
#' @export
fieldShape_edit<- function(mosaic,
                            fieldShape = NULL, 
                            shp = NULL,
                            r = 1, 
                            g = 2, 
                            b = 3, 
                            color_options = viridisLite::viridis,
                            max_pixels = 100000000,
                            downsample = 5) {
  print("Starting analysis ...")
  if (is.null(mosaic)) {
    stop("The input 'mosaic' object is NULL.")
  }
  
  if (class(mosaic) %in% c("RasterStack", "RasterLayer", "RasterBrick")) {
    mosaic <- terra::rast(mosaic)
  }
  pixels <- prod(dim(mosaic))
  if (pixels > max_pixels) {
    print("Your 'mosaic' is too large, and downsampling is being applied.")
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
    }
  }
  
  if (!is.null(fieldShape) & nlyr(mosaic) > 2) {
    if (pixels < max_pixels) {
      stars_object[is.na(stars_object)] <- 0
      edit_shp <- fieldShape %>% st_transform(4326) %>%
        editFeatures(map = mapview() %>%
                       leafem:::addRGB(x = stars_object, r = r, g = g, b = b, editor = "leafpm"))
      finshapefile <- edit_shp %>% st_transform(st_crs(mosaic))
    } else {
      starsRGB <- read_stars(stars_object[[1]], proxy = TRUE)
      starsRGB <- st_downsample(starsRGB, n = downsample)
      starsRGB[is.na(starsRGB)] <- 0
      edit_shp <- fieldShape %>% st_transform(4326) %>%
        editFeatures(map = mapview() %>%
                       leafem:::addRGB(x = starsRGB, r = r, g = g, b = b, editor = "leafpm"))
      finshapefile <- edit_shp %>% st_transform(st_crs(mosaic))
    }
  } else if (!is.null(shp)) {
    if (pixels < max_pixels) {
      edit_shp <- shp %>% st_transform(4326) %>%
        editFeatures(map = mapview(st_bbox(stars_object), color = 'red', lwd = 5, alpha = 0) %>%
                       leafem:::addRGB(x = stars_object, r = r, g = g, b = b, editor = "leafpm"))
      finshapefile <- edit_shp %>% st_transform(st_crs(mosaic))
    } else {
      edit_shp <- shp %>% st_transform(4326) %>%
        editFeatures(map = mapview(st_bbox(stars_object), color = 'red', lwd = 5, alpha = 0) %>%
                       leafem:::addRGB(x = starsRGB, r = r, g = g, b = b, editor = "leafpm"))
      finshapefile <- edit_shp %>% st_transform(st_crs(mosaic))
    }
  } else {
    if (!is.null(fieldShape) & nlyr(mosaic) == 1) {
      if (pixels < max_pixels) {
        stars_object[is.na(stars_object)] <- NA
        edit_shp <- fieldShape %>% st_transform(4326) %>%
          editFeatures(map = mapview() %>%
                         leafem:::addGeoRaster(x = stars_object, colorOptions = leafem:::colorOptions(palette = color_options, na.color = "transparent"), editor = "leafpm"))
        finshapefile <- edit_shp %>% st_transform(st_crs(mosaic))
      } else {
        stars_object[is.na(stars_object)] <- NA
        edit_shp <- fieldShape %>% st_transform(4326) %>%
          editFeatures(map = mapview() %>%
                         leafem:::addGeotiff(stars_object[[1]], colorOptions = leafem:::colorOptions(palette = color_options, na.color = "transparent"), editor = "leafpm"))
        finshapefile <- edit_shp %>% st_transform(st_crs(mosaic))
      }
    } else if (!is.null(shp)) {
      if (pixels < max_pixels) {
        edit_shp <- shp %>% st_transform(4326) %>%
          editFeatures(map = mapview(st_bbox(stars_object), color = 'red', lwd = 5, alpha = 0) %>%
                         leafem:::addGeoRaster(x = stars_object, colorOptions = color_options, editor = "leafpm"))
        finshapefile <- edit_shp %>% st_transform(st_crs(mosaic))
      } else {
          edit_shp <- shp %>% st_transform(4326) %>%
          editFeatures(map = mapview(st_bbox(stars_object), color = 'red', lwd = 5, alpha = 0) %>%
                         leafem:::addGeotiff(stars_object[[1]], colorOptions = color_options, editor = "leafpm"))
        finshapefile <- edit_shp %>% st_transform(st_crs(mosaic))
      }
      print("End!")
      return(finshapefile)
    } else { 
      cat("\033[31m", "Error: fieldShape or shp do not exist", "\033[0m", "\n")
    }
  }
}
