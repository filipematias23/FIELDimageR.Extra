#' fieldKmeans 
#' 
#' @title Clustering pixels using kmeans algorithm.
#' 
#' @description It allows cluster pixels on k groups that can be related with plants, soil, shadows, etc.
#' 
#' @param mosaic image object format \code{\link{rast}} or \code{\link{stars}}.
#' @param clusters number of clusters to sort pixels (Default = 3). 
#' @param iteration number of iterations (Default = 500).
#' @param algorithm kmeans algorithm. Check for options on \code{\link{stats::kmeans}} (Default = "Lloyd").
#' @param plot plot clusters
#' @param seed set.seed
#' 
#' @importFrom terra nlyr rast plot
#' @importFrom stats kmeans
#' 
#' @return An image object format \code{\link{rast}} identified with clusters.
#' 
#' @export
fieldKmeans <- function(mosaic,
                        clusters = 3,
                        iteration = 500,
                        algorithm ="Lloyd",
                        plot=TRUE,
                        seed=25) {
  
  print("Starting k-mean classification ...")
  
  if (is.null(mosaic)) {
    stop("The input 'mosaic' object is NULL.")
  }
  
  if (class(mosaic) %in% c("RasterStack", "RasterLayer", "RasterBrick")) {
    mosaic <- rast(mosaic)
  }
  
  tryCatch({
    if (nlyr(mosaic) > 2) {
      mosaic<-na.omit(mosaic)
      ortho <- as.data.frame(mosaic[[1]], cell = TRUE)
      set.seed(seed)
      kmncluster <- kmeans(ortho[, -1], 
                           centers = clusters, 
                           iter.max = iteration, 
                           nstart = 5, 
                           algorithm = algorithm)
      kmean_cluster <- rast(mosaic, nlyr = 1)
      kmean_cluster[] <- kmncluster$cluster[ortho$cell]
    } else if (nlyr(mosaic) == 1) {
      mosaic<-na.omit(mosaic)
      ortho <- as.data.frame(mosaic, cell = TRUE)
      set.seed(seed)
      kmncluster <- kmeans(ortho[, -1], 
                           centers = clusters, 
                           iter.max = iteration, 
                           nstart = 5, 
                           algorithm = algorithm)
      kmean_cluster <- rast(mosaic, nlyr = 1)
      kmean_cluster[] <- kmncluster$cluster[ortho$cell]
    }
  }, error = function(e) {
    warning("An error occurred:", conditionMessage(e))
    print("Please increase the number of iterations and try again ...")
  })
  if(plot){terra::plot(kmean_cluster)}
  print("End!")
  return(kmean_cluster)
}
