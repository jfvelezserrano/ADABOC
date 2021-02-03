options(width=180)

# Load data --------------------------------------------------------------
datasetName    <- "electrical_grid"
datasetDirName <- "datasets"

trainDataName      <- paste0(datasetDirName, "/", datasetName,"_train",      ".csv")
validationDataName <- paste0(datasetDirName, "/", datasetName,"_validation", ".csv")
testDataName       <- paste0(datasetDirName, "/", datasetName,"_test",       ".csv")
# scoreDataName      <- paste0(datasetDirName, "/", datasetName,"_score",      ".csv")

trainData      <- read.csv(trainDataName,      sep=",",head=TRUE)
validationData <- read.csv(validationDataName, sep=",",head=TRUE)
testData       <- read.csv(testDataName,       sep=",",head=TRUE)
# scoreData      <- read.csv(scoreDataName,      sep=",",head=TRUE)

trainData$ID      <- NULL
validationData$ID <- NULL
testData$ID       <- NULL
# scoreData$ID      <- NULL


# Training a model ---------------------------------------------------------------
print("******************** Training model 10")
source("code/nestedCopulasModel.R")
model <- nestedCopulasModel  (trainingDataset = trainData, 
                              target_name = "TARGET", 
                              validationDataset = validationData, 
                              testDataset=testData,
                              maxiter = 200,
                              numBins = 2000,
                              subsamplePercent = 10,
                              earlyStoppingIterations = 10,
                              epsilon = 14)

print("******************** Training model 20")
source("code/nestedCopulasModel.R")
model <- nestedCopulasModel  (trainingDataset = trainData, 
                              target_name = "TARGET", 
                              validationDataset = validationData, 
                              testDataset=testData,
                              maxiter = 200,
                              numBins = 2000,
                              subsamplePercent = 20,
                              earlyStoppingIterations = 10,
                              epsilon = 14)

print("******************** Training model 30")
source("code/nestedCopulasModel.R")
model <- nestedCopulasModel  (trainingDataset = trainData, 
                              target_name = "TARGET", 
                              validationDataset = validationData, 
                              testDataset=testData,
                              maxiter = 200,
                              numBins = 2000,
                              subsamplePercent = 30,
                              earlyStoppingIterations = 10,
                              epsilon = 14)

print("******************** Training model 40")
source("code/nestedCopulasModel.R")
model <- nestedCopulasModel  (trainingDataset = trainData, 
                              target_name = "TARGET", 
                              validationDataset = validationData, 
                              testDataset=testData,
                              maxiter = 200,
                              numBins = 2000,
                              subsamplePercent = 40,
                              earlyStoppingIterations = 10,
                              epsilon = 14)

print("******************** Training model 50")
source("code/nestedCopulasModel.R")
model <- nestedCopulasModel  (trainingDataset = trainData, 
                              target_name = "TARGET", 
                              validationDataset = validationData, 
                              testDataset=testData,
                              maxiter = 200,
                              numBins = 2000,
                              subsamplePercent = 50,
                              earlyStoppingIterations = 10,
                              epsilon = 14)

print("******************** Training model 60")
source("code/nestedCopulasModel.R")
model <- nestedCopulasModel  (trainingDataset = trainData, 
                              target_name = "TARGET", 
                              validationDataset = validationData, 
                              testDataset=testData,
                              maxiter = 200,
                              numBins = 2000,
                              subsamplePercent = 60,
                              earlyStoppingIterations = 10,
                              epsilon = 14)

print("******************** Training model 70")
source("code/nestedCopulasModel.R")
model <- nestedCopulasModel  (trainingDataset = trainData, 
                              target_name = "TARGET", 
                              validationDataset = validationData, 
                              testDataset=testData,
                              maxiter = 200,
                              numBins = 2000,
                              subsamplePercent = 70,
                              earlyStoppingIterations = 10,
                              epsilon = 14)

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

print("******************** Training model 90")
source("code/nestedCopulasModel.R")
model <- nestedCopulasModel  (trainingDataset = trainData, 
                              target_name = "TARGET", 
                              validationDataset = validationData, 
                              testDataset=testData,
                              maxiter = 200,
                              numBins = 2000,
                              subsamplePercent = 90,
                              earlyStoppingIterations = 10,
                              epsilon = 14)

print("******************** Training model 100")
source("code/nestedCopulasModel.R")
model <- nestedCopulasModel  (trainingDataset = trainData, 
                              target_name = "TARGET", 
                              validationDataset = validationData, 
                              testDataset=testData,
                              maxiter = 200,
                              numBins = 2000,
                              subsamplePercent = NULL,
                              earlyStoppingIterations = 10,
                              epsilon = 14)

# Using the model ---------------------------------------------------------------
# print("Using model")
# source("code/nestedCopulasModelPredict.R")
# table  <- nestedCopulasModelPredict(scoreDataset = as.data.frame(scoreData), copulaModel = model)
# print(table)
