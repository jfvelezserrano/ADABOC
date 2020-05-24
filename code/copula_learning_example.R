# Load data ---------------------------------------------------------------
datasetName <- "Kdd1998"

trainDataName      <- paste0("datasets/",datasetName,"_train"     ,".csv")
validationDataName <- paste0("datasets/",datasetName,"_validation",".csv")
testDataName       <- paste0("datasets/",datasetName,"_test"      ,".csv")
scoreDataName      <- paste0("datasets/",datasetName,"_score"     ,".csv")

trainData      <- read.csv(trainDataName,      sep=",",head=TRUE)
validationData <- read.csv(validationDataName, sep=",",head=TRUE)
testData       <- read.csv(testDataName,       sep=",",head=TRUE)
scoreData      <- read.csv(scoreDataName,      sep=",",head=TRUE)

# Train model ---------------------------------------------------------------
source("code/copulaLearningMethod.R")

model <- copulaLearningMethod(trainingDataset = trainData, 
                              target_name = "TARGET", 
                              validationDataset = validationData, 
                              testDataset=testData,
                              maxiter = 200,
                              numBins = 2000,
                              subsamplePercent = 10,
                              earlyStoppingIterations = 10,
                              minError = 14)

# Use model ---------------------------------------------------------------
source("code/copulaLearningMethodPredict.R")

table  <- copulaLearningMethodPredict(scoreDataset = as.data.frame(scoreData), copulaModel = model)

print(table)
