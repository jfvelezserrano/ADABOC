
# Set environment ---------------------------------------------------------

setwd("datasets")


# Dataset -----------------------------------------------------------------

datasetName <- "Communities"

# Load data ---------------------------------------------------------------

trainDataName <- paste0(datasetName,"_train")
validationDataName <- paste0(datasetName,"_validation")
testDataName <- paste0(datasetName,"_test")

# Read csv

trainData <- read.csv(paste0(trainDataName,".csv"), stringsAsFactors = FALSE)
validationData <- read.csv(paste0(validationDataName,".csv"), stringsAsFactors = FALSE)
testData <- read.csv(paste0(testDataName,".csv"), stringsAsFactors = FALSE)


# Data preparation --------------------------------------------------------

trainData_ID <- trainData$ID
validationData_ID <- validationData$ID
testData_ID <- testData$ID

trainData$ID <- NULL
validationData$ID <- NULL
testData$ID <- NULL


# H2O environment ---------------------------------------------------------
library(bit64,lib="~/MyRlibs")
library(h2o,lib="~/MyRlibs")

h2o.init(nthreads = -2)

# Upload data to H2O

trainData.h2o <- as.h2o(trainData)
validationData.h2o <- as.h2o(validationData)
testData.h2o <- as.h2o(testData)

# Variable definition to H2O
# NOTE: Set the corresponding target name between "" after the %in%:

inputs <- trainData[, ! names(trainData) %in% "TARGET", drop = F]
predictors <- names(inputs)


# AutoML ----------------------------------------------------------------

mySeed <- 12345
set.seed(mySeed)
maxNumModels <- 10

# NOTE: Set the corresponding target name in the y variable:

aml <- h2o.automl(x = predictors,
                  y = "TARGET", 
                  training_frame = trainData.h2o,
                  validation_frame = validationData.h2o,
                  leaderboard_frame = testData.h2o,
                  nfolds = 0,
                  max_runtime_secs = 10800, 
                  max_models = maxNumModels,
                  stopping_metric = "MAE",
                  stopping_rounds = 100,
                  sort_metric = "MAE",
                  exclude_algos = c("DeepLearning","StackedEnsemble"),
                  seed = mySeed)

errorsTable <- as.data.frame(aml@leaderboard)

# exitPath <- "../errors"

write.csv(errorsTable, file = paste0("Errors_",datasetName,"_",maxNumModels,"models_MAE.csv"))
print(errorsTable)
