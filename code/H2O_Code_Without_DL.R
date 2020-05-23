
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

