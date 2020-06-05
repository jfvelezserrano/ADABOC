# H2O library ---------------------------------------------------------
library(h2o,lib="~/MyRlibs")


# Specify dataset ---------------------------------------------------------

datasetDirName <- "datasets"
datasetName <- "kdd"

# Load data ---------------------------------------------------------------

trainDataName      <- paste0(datasetDirName, "/", datasetName,"_train",      ".csv")
validationDataName <- paste0(datasetDirName, "/", datasetName,"_validation", ".csv")
testDataName       <- paste0(datasetDirName, "/", datasetName,"_test",       ".csv")

trainData      <- read.csv(trainDataName,      stringsAsFactors = FALSE)
validationData <- read.csv(validationDataName, stringsAsFactors = FALSE)
testData       <- read.csv(testDataName,       stringsAsFactors = FALSE)

# Data preparation --------------------------------------------------------

trainData_ID      <- trainData$ID
validationData_ID <- validationData$ID
testData_ID       <- testData$ID

trainData$ID      <- NULL
validationData$ID <- NULL
testData$ID       <- NULL

# Data normalization

trainData_TARGET      <- trainData$TARGET
validationData_TARGET <- validationData$TARGET
testData_TARGET       <- testData$TARGET

trainData$TARGET      <- NULL
validationData$TARGET <- NULL
testData$TARGET       <- NULL

trainData      <- data.frame(scale(trainData), TARGET = trainData_TARGET)
validationData <- data.frame(scale(validationData), TARGET = validationData_TARGET)
testData       <- data.frame(scale(testData), TARGET = testData_TARGET)


# H2o environment ---------------------------------------------------------

h2o.init(nthreads = -2)

# Upload data to H2O

trainData.h2o      <- as.h2o(trainData)
validationData.h2o <- as.h2o(validationData)
testData.h2o       <- as.h2o(testData)

# Variable definition to H2O
# NOTE: the corresponding target name is specified between "" after the %in%:

inputVars <- trainData[, ! names(trainData) %in% "TARGET", drop = F]
inputs    <- names(inputVars)


# AutoML ----------------------------------------------------------------

mySeed <- 12345
set.seed(mySeed)
maxNumModels <- 10

# NOTE: Set the corresponding target name in the "y" variable:

aml <- h2o.automl(x = inputs,
                  y = "TARGET", 
                  training_frame = trainData.h2o,
                  validation_frame = validationData.h2o,
                  leaderboard_frame = testData.h2o,
                  nfolds = 0,
                  max_runtime_secs = 25500, 
                  max_models = maxNumModels,
                  stopping_metric = "MAE",
                  stopping_rounds = 100,
                  sort_metric = "MAE",
                  include_algos = c("DeepLearning"),
                  seed = mySeed)

errorsTable <- as.data.frame(aml@leaderboard)

# exitPath <- "../errors"
# write.csv(errorsTable,file = paste0(exitPath,"DL_Errors_",datasetName,".csv"))
print(errorsTable)
