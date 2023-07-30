#' addRGB
#'
#' @description A utils function
#'
#' @return The return value, if any, from executing the utility.
#' 
#' @importFrom raster values
#'
#' @noRd
addRGB = function(
    map,
    x,
    r = NULL, g = NULL, b = NULL,
    band=NULL,
    group = NULL,
    layerId = NULL,
    resolution = 96,
    opacity = 0.8,
    options = leaflet::tileOptions(),
    colorOptions = NULL,
    project = TRUE,
    pixelValuesToColorFn = NULL,
    ...
) {
  
  if (inherits(x, "Raster")) {
    x = stars::st_as_stars(x)
  }
  
  if (project & !sf::st_is_longlat(x)) {
    x = stars::st_warp(x, crs = 4326)
  }
  
  if (is.null(colorOptions)) {
    colorOptions = colorOptions()
  }
  
  fl = tempfile(fileext = ".tif")
  
  if (inherits(x, "stars_proxy")) {
    # file.copy(x[[1]], fl)
    fl = x[[1]]
  }
  
  if (!inherits(x, "stars_proxy")) {
    stars::write_stars(x, dsn = fl)
  }
  
  minband = min(r, g, b)
  
  rgbPixelfun = htmlwidgets::JS(
    sprintf(
      "
        pixelValuesToColorFn = values => {
        // debugger;
          if (isNaN(values[0])) return '%s';
          return rgbToHex(
            Math.ceil(values[%s])
            , Math.ceil(values[%s])
            , Math.ceil(values[%s])
          );
        };
      "
      , colorOptions[["naColor"]]
      , r - minband
      , g - minband
      , b - minband
    )
  )
  
  # todo: streching via quantiles and domain...
  
  addGeotiff(
    map
    , file = fl
    , url = NULL
    , group = group
    , layerId = layerId
    , resolution = resolution
    , bands = c(r, g, b)
    , arith = NULL
    , opacity = opacity
    , options = options
    , colorOptions = colorOptions
    , rgb = TRUE
    , pixelValuesToColorFn = rgbPixelfun
  ) 
  
}

