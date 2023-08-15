#' fieldShape_render 
#' 
#' @title Building the plot \code{fieldshape} file using Zoom Visualization
#' 
#' @description The user should select the four experimental field corners and the shape file with plots will be automatically 
#' built using a grid with the number of ranges and rows. Attention: The clicking sequence must be (1) upper left, (2) upper right, (3) lower right, and (4) lower left.
#' 
#' @param mosaic object of class 'rast' or 'stars' obtained from function \code{\link{terra::rast()}}.
#' @param ncols number of columns.
#' @param nrows number of rows.
#' @param fieldData data frame with plot ID and all attributes of each plot (Traits as columns and genotypes as rows).
#' @param fieldMap matrix with plots ID identified by rows and ranges, please use first the funsction \code{\link{fieldMap}}.
#' @param plotID name of plot ID in the fieldData file to combine with fieldShape.
#' @param buffer negative values should be used to remove boundaries from neighbor plot.
#' @param r red layer in the mosaic (for RGB image normally is 1). If NULL the first single layer will be plotted. 
#' @param g green layer in the mosaic (for RGB image normally is 2). If NULL the first single layer will be plotted.
#' @param b blue layer in the mosaic (for RGB image normally is 3). If NULL the first single layer will be plotted.
#' @param color_options single layer coloring options. Check more information at \code{\link{color_options}} from \code{\link{leafem}} package.
#' @param max_pixels maximun pixels allowed before down sampling. Reducing size to accelerate analysis. Default = 100000000.
#' @param downsample  numeric downsample reduction factor. Default = 5.
#'  
#' @importFrom sf st_crs st_bbox st_transform st_is_longlat st_crop st_make_grid st_cast st_coordinates st_buffer st_sf
#' @importFrom terra crop nlyr rast
#' @importFrom stars write_stars st_warp st_as_stars 
#' @importFrom mapview mapview
#' @importFrom mapedit editFeatures editMap
#' @importFrom leafem addGeoRaster
#' @importFrom dplyr mutate
#'
#' @return A field plot shape file class "sf" & "data.frame".
#'
#' @export
fieldShape_render<- function(mosaic,
                             ncols, 
                             nrows, 
                             fieldData=NULL,
                             fieldMap=NULL,
                             PlotID=NULL,
                             buffer=NULL,
                             r=1,
                             g=2,
                             b=3,
                             color_options=NULL,
                             max_pixels=100000000,
                             downsample=5
                             ) {
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
  } else{
    stars_object <- mosaic
    if (!inherits(stars_object, "stars")) {
      stars_object <- st_as_stars(mosaic)
      names(stars_object)<-"layer_name"
      stars_object <- read_stars(stars_object$layer_name, proxy = TRUE)
      stars_object <- st_downsample(stars_object, n = downsample)
    }
      }

  print("Use 'Draw Marker' to select 4 points at the corners of field and press 'DONE'. Attention is very important start clicking from left to the right and top to bottom.")
  if(nlyr(mosaic)>2){
    stars_object[is.na(stars_object)]<-0
    four_point <- mapview() %>%
    leafem:::addRGB(
      x = stars_object,r=r,g=g,b=b,
      fieldData= path_csv_file
    ) %>%
    editMap("mosaic", editor = "leafpm")}
  else{
    if(nlyr(mosaic)==1){
      stars_object[is.na(stars_object)]<-NA
      four_point <- mapview() %>%
        leafem:::addGeoRaster(
          x = stars_object,colorOptions = leafem:::colorOptions(palette = colorOptions, na.color = "transparent"),
          fieldData= path_csv_file
        ) %>%
        editMap("mosaic", editor = "leafpm")  
      }
    
  }
  if (length(four_point$finished$geometry) == 4) {
    grids <- st_make_grid(four_point$finished$geometry, n = c(ncols, nrows)) %>% st_transform(st_crs(mosaic))
    point_shp <- st_cast(st_make_grid(four_point$finished$geometry, n = c(1, 1)), "POINT")
    sourcexy <- rev(point_shp[1:4]) %>% st_transform(st_crs(mosaic))
    Targetxy <- four_point$finished$geometry %>% st_transform(st_crs(mosaic))
    controlpoints <- as.data.frame(cbind(st_coordinates(sourcexy), st_coordinates(Targetxy)))
    linMod <- lm(formula = cbind(controlpoints[, 3], controlpoints[, 4]) ~ controlpoints[, 1] + controlpoints[, 2], data = controlpoints)
    parameters <- matrix(linMod$coefficients[2:3, ], ncol = 2)
    intercept <- matrix(linMod$coefficients[1, ], ncol = 2)
    affineT <- grids * parameters + intercept
    grid_shapefile <- st_sf(affineT, crs = st_crs(mosaic)) %>% mutate(ID = seq(1:length(affineT)))
    
    if (!is.null(buffer)) {
      if (st_is_longlat(grid_shapefile)) {
        grid_shapefile <- st_transform(grid_shapefile, crs = 3857)
        grid_shapefile <- st_buffer(grid_shapefile, dist = buffer)
        grid_shapefile <- st_transform(grid_shapefile, st_crs(mosaic))
      }else{
        grid_shapefile<-st_buffer(grid_shapefile,dist= buffer)
        grid_shapefile <- st_transform(grid_shapefile, st_crs(mosaic))
      }
    }
    
    print("Almost there ...")
    if(!is.null(fieldMap)){
      id<-NULL
      # for(i in 1:dim(fieldMap)[1]){
      #   id<-c(id,rev(fieldMap[i,]))
      # }
      for(i in dim(fieldMap)[1]:1){
        id<-c(id,fieldMap[i,])
      }
      grid_shapefile$PlotID<-as.character(id)}
    
    if(!is.null(fieldData)){
      if(is.null(fieldMap)){
        cat("\033[31m", "Error: fieldMap is necessary", "\033[0m", "\n")
      }
      fieldData<-as.data.frame(fieldData)
      fieldData$PlotID<-as.character(fieldData[,colnames(fieldData)%in%c(PlotID)])
      plots<-merge(grid_shapefile,fieldData,by="PlotID")
    } else{
      if(!is.null(grid_shapefile)){
        #Plot
        plots<-grid_shapefile} 
    }
    print("End!")
    return(plots)
  } else {
    cat("\033[31m", "Error: Select four points only.Points must be set at the corners of field of interest under the plots space", "\033[0m", "\n")
  }
}
