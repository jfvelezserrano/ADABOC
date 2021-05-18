options(width=180)

# Load data --------------------------------------------------------------
datasetName    <- "Concrete"
datasetDirName <- "datasets"

trainDataName      <- paste0(datasetDirName, "/", datasetName,"_train",      ".csv")
validationDataName <- paste0(datasetDirName, "/", datasetName,"_validation", ".csv")
testDataName       <- paste0(datasetDirName, "/", datasetName,"_test",       ".csv")
scoreDataName      <- paste0(datasetDirName, "/", datasetName,"_score",      ".csv")

trainData      <- read.csv(trainDataName,      sep=",",head=TRUE)
validationData <- read.csv(validationDataName, sep=",",head=TRUE)
testData       <- read.csv(testDataName,       sep=",",head=TRUE)
# scoreData      <- read.csv(scoreDataName,      sep=",",head=TRUE)

trainData$ID      <- NULL
validationData$ID <- NULL
testData$ID       <- NULL
# scoreData$ID      <- NULL

print("******************** Training model 80")
source("code/nestedCopulasModel.R")
model <- nestedCopulasModel  (trainingDataset = trainData, 
                              target_name = "TARGET", 
                              validationDataset = validationData, 
                              testDataset=testData,
                              maxiter = 200,
                              numBins = 2000,
                              subsamplePercent = 80,
                              earlyStoppingIterations = 10,
                              epsilon = 14)


# Using the model ---------------------------------------------------------------
# print("Using model")
# source("code/nestedCopulasModelPredict.R")
# table  <- nestedCopulasModelPredict(scoreDataset = as.data.frame(scoreData), copulaModel = model)
# print(table)
