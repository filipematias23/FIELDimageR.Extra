#' fieldCrop_grid 
#' 
#' @title Cropping image according to the plot grid shapefile.
#' 
#' @description It crops each plot and associate it with a ID and store it according to the user specification
#' 
#' @param mosaic image object format \code{\link{rast}} or \code{\link{stars}}.
#' @param fieldShape crop the image using the fieldShape as reference. 
#' @param classifier column name on fieldShape with levels to create folders at 'output_dir' directory. Cropped plots will be sorted and stored on related folders. If NULL all plots will be saved at the working directory.
#' @param plotID column name on fieldShape with the desired plots identification. If NULL plots will be saved in sequence according to the field map.
#' @param format save plots as \code{\link{.tif}} (by default) or \code{".jpg"}.
#' @param output_dir directory to save cropped plot images. Default is the working directory.
#' 
#' @importFrom jpeg writeJPEG
#' @importFrom EBImage readImage display
#' @importFrom sf st_crs st_bbox st_transform st_is_longlat st_crop 
#' @importFrom terra crop nlyr rast as.array minmax
#' @importFrom stars write_stars st_warp st_as_stars 
#' 
#' @return A list with plots image format 'stars'. The function also saves plot images identified by 'plotID' sorted according to the 'classifier' folder at the 'output_dir' directory.
#' 
#' @export
fieldCrop_grid <- function(mosaic, 
                           fieldShape, 
                           classifier =NULL, 
                           plotID = NULL, 
                           format = ".tif", 
                           output_dir = "./") {
  print("Cropping plots ...") 
  crop_list <- list()
  stars_object <- mosaic
  
  if(class(mosaic)%in%c("RasterStack","RasterLayer","RasterBrick")){
    mosaic<-terra::rast(mosaic)
  }
  
  nBand<-nlyr(mosaic)
  
  if (!inherits(stars_object, "stars")) {
    stars_object <- st_as_stars(mosaic)
  }
  
  if (!st_is_longlat(stars_object) && nBand > 2) {
    stars_object <- st_warp(stars_object, crs = 4326)
  }
  
  if (!st_is_longlat(fieldShape)) {
    fieldShape <- st_transform(fieldShape, crs = 4326)
  }
  
  for (i in 1:nrow(fieldShape)) {
    
    grid_polygon <- fieldShape[i, ]
    
    if (!is.null(plotID) && !is.null(classifier)) {
      
      plot_name <- grid_polygon[[plotID]]
      
      classifier_name <- grid_polygon[[classifier]]
      
      
      if (!is.null(plot_name) && !is.null(classifier_name)) {
        file_name <- paste0(plot_name, format)
      } else if (!is.null(plot_name)) {
        file_name <- paste0(plot_name, format)
      } else {
        file_name <- paste0("ID_", i, format)
      }
      
      classifier_dir <- file.path(output_dir, classifier_name)
      dir.create(classifier_dir, showWarnings = FALSE)
      file_path <- file.path(classifier_dir, file_name)
    } else if (is.null(plotID) && is.null(classifier) && is.null(format)) {
      file_name <- paste0("ID_", i, ".tif")
      file_path <- file.path(output_dir, file_name)
    } else {
      file_name <- paste0("ID_", i, format)
      file_path <- file.path(output_dir, file_name)
    }
    
    if (is.null(format) && is.null(plotID) && is.null(classifier)) {
      grid_polygon <- st_transform(grid_polygon, crs = st_crs(stars_object))
      plot_raster <- st_crop(stars_object, grid_polygon)
      if (nBand > 2) {
        plot_raster <- st_warp(plot_raster, crs = st_crs(mosaic))
        plot_raster[is.na(plot_raster)] <- 0
      }
      if (nBand == 1) {
        plot_raster <- st_warp(plot_raster, crs = st_crs(mosaic))
        plot_raster[is.na(plot_raster)] <- NA
      }
      plot_raster = as(plot_raster, "Raster")
      plot_raster = rast(plot_raster)
      terra::writeRaster(plot_raster, file_path)
      
    } else if (format == ".jpg") {
      # Save the crop raster as a JPEG image
      grid_polygon <- st_transform(grid_polygon, crs = st_crs(mosaic))
      plot_raster <- terra::crop(mosaic, grid_polygon)
      if (nBand > 2) {
        if(as.numeric(minmax(plot_raster[[1]])[[2]]>1)) {
          red<-plot_raster[[1]]/255
          green<-plot_raster[[2]]/255
          blue<-plot_raster[[3]]/255
          plot_raster <- c(red, green, blue)
        }else {
          red<-plot_raster[[1]]
          green<-plot_raster[[2]]
          blue<-plot_raster[[3]]
          plot_raster <- c(red, green, blue)
        }
        if (nBand == 1) {
          if(as.numeric(minmax(plot_raster)[[2]]>1)) {band_1<-plot_raster[[1]]/255}
          plot_raster <- band_1
        }
        # Save the crop raster as a JPEG image
        plot_raster_j<-raster::as.array(plot_raster)
        jpeg::writeJPEG(plot_raster_j, target = file_path)
      }} else {
        # Save the crop raster as a GeoTIFF image
        grid_polygon <- st_transform(grid_polygon, crs = st_crs(stars_object))
        plot_raster <- st_crop(stars_object, grid_polygon)
        if (nBand > 2) {
          plot_raster <- st_warp(plot_raster, crs = st_crs(mosaic))
          plot_raster[is.na(plot_raster)] <- 0
        }
        if (nBand == 1) {
          plot_raster <- st_warp(plot_raster, crs = st_crs(mosaic))
          plot_raster[is.na(plot_raster)] <- NA
        }
        plot_raster = as(plot_raster, "Raster")
        plot_raster = rast(plot_raster)
        terra::writeRaster(plot_raster, file_path)
      }
    # Add the crop raster and grid to the list
    crop_list[[i]] <- plot_raster
  }
  if(!is.null(plotID)){
    names(crop_list)<-fieldShape[[plotID]]
  }else{
    names(crop_list)<-paste0("ID_", 1:nrow(fieldShape),sep="")
  }
  print("End!")
  return(crop_list)
}

