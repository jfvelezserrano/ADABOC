# Load data ---------------------------------------------------------------
datasetName <- "Kdd1998"

trainDataName <- paste0(datasetName,"_train")
validationDataName <- paste0(datasetName,"_validation")
testDataName <- paste0(datasetName,"_test")

setwd("datasets")
trainData <- read.csv(paste0(trainDataName,".csv"),sep=",",head=TRUE)
validationData <- read.csv(paste0(validationDataName,".csv"),sep=",",head=TRUE)
testData <- read.csv(paste0(testDataName,".csv"),sep=",",head=TRUE)
setwd("..")

# Execute model ---------------------------------------------------------------
source("code/copulaLearningMethod.R")

table <- copulaLearningMethod(trainingDataset = trainData, target_name = "TARGET", validationDataset = validationData, testDataset=testData,
maxiter = 200,numBins = 2000,subsamplePercent = 0.1,earlyStoppingIterations = 10,minError = 14)
print(table)
