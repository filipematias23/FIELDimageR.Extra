#' fieldSegment
#' 
#' @title Clustering pixels with Machine Learning models.
#' 
#' @description It allows clustering pixels based on training image samples (n clusters) using machine learning models that can be related with plants, soil, shadows, etc.
#' 
#' @param mosaic image object format \code{\link{rast}} or \code{\link{stars}}.
#' @param trainDataset number of clusters to sort pixels (Default = 3). 
#' @param model machine learning models for classification objects in the mosaic based on samples. There are two options the model Randon Forest ('rf'). (Default='rf')
#' @param seed set.seed
#' 
#' @importFrom terra nlyr rast plot spatSample subset extract predict
#' @importFrom dplyr group_by 
#' @importFrom sf st_sample st_as_sf
#' @importFrom dplyr setdiff sample_frac
#' @importFrom caret trainControl train
#' @importFrom rpart rpart
#' 
#' @return An image object format \code{\link{rast}} identified with clusters.
#' 
#' @export
fieldSegment <- function(mosaic, 
                         trainDataset, 
                         model = 'rf',
                         seed = 5) {
  
  print("Starting supervised classification ...")
  
  if (is.null(mosaic)) {
    stop("The input 'mosaic' object is NULL.")
  }
  
  if (class(mosaic) %in% c("RasterStack", "RasterLayer", "RasterBrick")) {
    mosaic <- rast(mosaic)
  }
  
  extr_train <- terra::extract(mosaic, trainDataset)
  extr_train$class <- trainDataset$class
  
  train <- extr_train %>%
    group_by(class) %>%
    sample_frac(0.7, replace = FALSE)
  
  test <- setdiff(extr_train, train)
  
  train <- data.frame(train)
  train$class <- as.factor(train$class)
  
  test <- data.frame(test)
  test$class <- as.factor(test$class)
  
  train <- na.omit(train)
  test <- na.omit(test)
  
  x <- train[, 3:(ncol(train) - 1)]
  y <- train$class
  
  set.seed(seed)
  fitControl <- trainControl(method = "repeatedcv",
                             number = 5,
                             repeats = 5)
  
  if (model =='rf') {
    mtry <- sqrt(ncol(x))
    tunegrid <- expand.grid(.mtry = mtry)
    sup_model <- caret::train(x, y, 
                              method = model, 
                              metric = 'Accuracy', 
                              tuneGrid = tunegrid, 
                              trControl = fitControl)
  } else if (model =="cart") {
    sup_model <-  rpart(y~., x, method = 'class', minsplit = 5)
  }
  
  pred <- terra::predict(sup_model, test,na.rm=TRUE)
  rastPred <- terra::predict(mosaic, sup_model,na.rm=TRUE)
  
  print("End!")
  return(list(sup_model = sup_model, pred = pred, rastPred = rastPred))
}
