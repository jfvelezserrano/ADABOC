options(width=180)

# Load data --------------------------------------------------------------
datasetName    <- "bias_correction_ucl_TMED"
datasetDirName <- "datasets"

trainDataName      <- paste0(datasetDirName, "/", datasetName,"_train",      ".csv")
validationDataName <- paste0(datasetDirName, "/", datasetName,"_validation", ".csv")
testDataName       <- paste0(datasetDirName, "/", datasetName,"_test",       ".csv")
scoreDataName      <- paste0(datasetDirName, "/", datasetName,"_score",      ".csv")

trainData      <- read.csv(trainDataName,      sep=",",head=TRUE)
validationData <- read.csv(validationDataName, sep=",",head=TRUE)
testData       <- read.csv(testDataName,       sep=",",head=TRUE)
scoreData      <- read.csv(scoreDataName,      sep=",",head=TRUE)

trainData$ID      <- NULL
validationData$ID <- NULL
testData$ID       <- NULL
scoreData$ID      <- NULL


# Training a model ---------------------------------------------------------------
print("Training model")
source("code/copulaLearningMethod.R")
model <- copulaLearningMethod(trainingDataset = trainData, 
                              target_name = "TARGET", 
                              validationDataset = validationData, 
                              testDataset=testData,
                              maxiter = 200,
                              numBins = 2000,
                              subsamplePercent = 60,
                              earlyStoppingIterations = 10,
                              epsilon = 14)

# Using the model ---------------------------------------------------------------
print("Using model")
source("code/copulaLearningMethodPredict.R")
table  <- copulaLearningMethodPredict(scoreDataset = as.data.frame(scoreData), copulaModel = model)
# print(table)
