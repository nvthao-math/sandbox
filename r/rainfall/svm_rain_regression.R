# load library
library(jsonlite)
library(binaryLogic)
require(e1071)
# function
# rmse <- function(error) {
#   sqrt(mean(error^2))
# }
#
# data.season.rain <- read.xls(("data/input/tunning_mean_rainfall_two_season.xlsx"), sheet = 1, header = TRUE)
data.season.rain <- read.csv("data/input/twoseason.rain.csv", header=TRUE)
# data.season.dry <- read.xls(("data/input/tunning_mean_rainfall_two_season.xlsx"), sheet = 2, header = TRUE)
data.season.dry <- read.csv("data/input/twoseason.dry.csv", header=TRUE)
# extreme rain data
ind.extreme.rain <- which(data.season.rain$clazz == 2) 
ind.extreme.dry <- which(data.season.dry$clazz == 2)
rain.extreme <- rbind(data.season.rain[ind.extreme.rain, ], data.season.dry[ind.extreme.dry, ])
# normal rain data
ind.normal.rain <- which(data.season.rain$clazz == 1) 
ind.normal.dry <- which(data.season.dry$clazz == 1)
rain.normal <- rbind(data.season.rain[ind.normal.rain, ], data.season.dry[ind.normal.dry, ])
#
data <- rbind(rain.extreme, rain.normal)
data.tuning <- data.frame(data$P8_z, data$R500, data$P500, data$P_z, data$P850, data$R850, data$Rhum, data$P5zh, data$P5_v, data$rainfall)
colnames(data.tuning) <- c("P8_z", "R500", "P500", "P_z", "P850", "R850", "Rhum", "P5zh", "P5_v", "rainfall")
# feature selection
n.feature <- ncol(data.tuning) -1
# # file to save
svm.file <- "result/svm_output_regression.txt"
#
for(i in c(3:(2^n.feature-1))){
  x.bi <- as.binary(i, n=n.feature)
  index.feature <- which(x.bi)
  print(x.bi)
  print(index.feature)
  head(data.tuning[,index.feature])
  #
  feature_vec <- colnames(data.tuning)[index.feature]
  feature <- paste(feature_vec, collapse=", ")
  # raining data
  data.extreme <- data.frame(data.tuning[which(data.tuning$rainfall >= 50, arr.ind = FALSE),]) 
  data.extreme.row <- nrow(data.extreme)
  data.extreme.ntrain <- round(data.extreme.row * 0.7)
  data.extreme.tindex <- sample(data.extreme.row, data.extreme.ntrain)
  data.extreme.xtrain <- as.matrix(data.extreme[data.extreme.tindex, index.feature])
  colnames(data.extreme.xtrain) <- feature_vec
  data.extreme.xtest <- as.matrix(data.extreme[-data.extreme.tindex, index.feature])
  colnames(data.extreme.xtest) <- feature_vec
  data.extreme.ytrain <- matrix(data.extreme$rainfall[data.extreme.tindex])
  data.extreme.ytest <- matrix(data.extreme$rainfall[-data.extreme.tindex])
  # dry data
  data.normal <- data.tuning[which(data.tuning$rainfall < 50, arr.ind = FALSE),]
  data.normal.row <- nrow(data.normal)
  data.normal.ntrain <- round(data.normal.row * 0.7)
  data.normal.tindex <- sample(data.normal.row, data.normal.ntrain)
  data.normal.xtrain <- as.matrix(data.normal[data.normal.tindex, index.feature])
  colnames(data.normal.xtrain) <- feature_vec
  data.normal.xtest <- as.matrix(data.normal[-data.normal.tindex, index.feature])
  colnames(data.normal.xtest) <- feature_vec
  data.normal.ytrain <- matrix(data.normal$rainfall[data.normal.tindex])
  data.normal.ytest <- matrix(data.normal$rainfall[-data.normal.tindex])
  # merge data for train
  data.xtrain <- rbind(data.extreme.xtrain, data.normal.xtrain)
  data.ytrain <- rbind(data.extreme.ytrain, data.normal.ytrain)
  data.train <- data.frame(cbind(data.xtrain, data.ytrain))
  colnames(data.train) <- c(feature_vec, "rainfall")
  # merge data for test
  data.xtest <- rbind(data.extreme.xtest, data.normal.xtest)
  colnames(data.xtest) <- feature_vec
  data.ytest <- rbind(data.extreme.ytest, data.normal.ytest)
  ## svm regression | perform a grid search
  tuneResult <- tune(svm, rainfall ~.,  data = data.train, ranges = list(epsilon = c(0.01, 0.1), cost = c(1, 10), gamma = c(0.01, 0.1)))
  print(tuneResult)
  tunedModel <- tuneResult$best.model
  extreme.predict <- predict(tunedModel, data.extreme.xtest) 
  extreme.acc <- length(which(extreme.predict >= 50)) / length(extreme.predict)
  normal.predict <- predict(tunedModel, data.normal.xtest)
  normal.acc <- length(which(normal.predict < 50)) / length(normal.predict)
  y.predict <- predict(tunedModel, data.xtest)
  error <- data.ytest - y.predict  
  rmse <- sqrt(mean(error^2)) # rmse(error)
  df <- data.frame(feature, c(extreme.acc), c(normal.acc), c(rmse))
  line <- toJSON(df)
  write(line,file=svm.file,append=TRUE)
}







