## required libraries

# library(tidyverse,lib="~/MyRlibs")
# library(data.table,lib="~/MyRlibs")
# library(VineCopula,lib="~/MyRlibs")
# library(ks,lib="~/MyRlibs")
# library(caTools,lib="~/MyRlibs")
# library(rapportools,lib="~/MyRlibs")

library(tidyverse)
library(data.table)
library(VineCopula)
library(ks)
library(caTools)
library(rapportools)


###################################################################
## function that develops the copula model                       ##
##                                                               ##
## Input parameters:                                             ##
##                                                               ##
## - trainingDataset: train table for the model                  ##
## - target_name: name of the target variable                    ##
## - validationDataset: validation table for the model           ##
## - testDataset: test table for the model                       ##
## - maxiter: maximum number of iterations of the model          ##
## - numBins: number of simulations for approximate the          ##
## conditional copulas                                           ##
## - subsamplePercent: percentage of the train table to fit the  ##
## best copula for each iteration and variable                   ##
## - earlyStoppingIterations: number of iterations without       ##
## improvement until stopping the model                          ##
## - evalMetric: metric to evaluate the predictions              ##
## - minError: tolerance level                                    ##
## - verbosity: if the model shows the results iterations by     ##
## iterations                                                    ##
##                                                               ##
## Output parameters:                                            ##
##                                                               ##
## - copulaModel: object copula model with the prediction of the ##
## train, validation and test tables, the iteration process      ##
## and the information needed for a posterior scoring            ##
###################################################################

copulaLearningMethod <- function(trainingDataset = NULL,
                         target_name = NULL,
                         validationDataset = NULL,
                         testDataset = NULL,
                         maxiter = 10,
                         numBins = 500,
                         subsamplePercent = NULL,
                         earlyStoppingIterations = 0,
                         evalMetric  = "MAE",
                         minError = 5,
                         verbosity = TRUE){
  
  ## required sources
  source('code/comb_variables_generator.R')
  source('code/optim_copulas_BI.R')
  source('code/score_copula_opt.R')
  source('code/best_iter_generator.R')
  source('code/fit_var_cop.R')
  source('code/eval_metric_functions.R')
  source('code/score_cop.R')
  
  ## input consistence and data quality
  if (is.null(trainingDataset)){
    stop('You have to include a training table')
  } else if (!is.null(trainingDataset)){
    if (!is.data.frame(trainingDataset)){
      stop('The training table must be a data.frame')
    }
  }
  
  if (!is.null(validationDataset)){
    if (!is.data.frame(validationDataset)){
      stop('The validation table must be a data.frame')
    }
  }
  
  if (!is.null(testDataset)){
    if (!is.data.frame(testDataset)){
      stop('The test table must be a data.frame')
    }
  }
  
  if (!is.numeric(maxiter) | (maxiter<=0)){
    stop('You have to include a positive number of iterations')
  } else if (is.numeric(maxiter) & length(maxiter)>1){
    stop('You have to give only one value as number of iterations')
  } else {
    maxiter <- ceiling(maxiter)
  }
  
  if (!is.numeric(earlyStoppingIterations) | (earlyStoppingIterations<0)){
    stop('You have to include a non-negative number as early stopping rounds')
  } else if (is.numeric(earlyStoppingIterations) & length(earlyStoppingIterations)>1){
    stop('You have to give only one value as early stopping rounds')
  } else {
    earlyStoppingIterations <- floor(earlyStoppingIterations)
  }
  
  if (!is.numeric(minError) | (minError<0)){
    stop('You have to include a non-negative number as minError')
  } else if (is.numeric(minError) & length(minError)>1){
    stop('You have to give only one value as minError')
  } else {
    minError <- floor(minError)
  }
  
  if (!is.numeric(numBins) | (numBins<=0)){
    stop('You have to include a positive number as numBins')
  } else if (is.numeric(numBins) & length(numBins)>1){
    stop('You have to give only one value as numBins')
  } else {
    numBins <- floor(numBins)
  }
  
  if (!is.null(subsamplePercent)){
    if (!is.numeric(subsamplePercent) | (subsamplePercent<=0) | (subsamplePercent>=100)){
      stop('You have to include a percentagew (< 100%) as subsamplePercent')
    } else if (is.numeric(subsamplePercent) & length(subsamplePercent)>1){
      stop('You have to give only one value as subsamplePercent')
    } else {
      subsamplePercent <- floor(subsamplePercent)
    }
  }
  
  if (!is.boolean(verbosity)){
    stop("verbosity has to be TRUE or FALSE")
  }
  
  if (is.null(target_name) | !target_name %in% names(trainingDataset)){
    stop("target variable name is not included in the training table or has not been specified")
  }
  
  if (is.null(validationDataset) & is.null(testDataset)){
    validationDataset <- trainingDataset[1,]
    validationDataset[, target_name] <- NA
    testDataset <- trainingDataset[1,]
    testDataset[, target_name] <- NA
  } else if (is.null(validationDataset)){
    validationDataset <- trainingDataset[1,]
    validationDataset[, target_name] <- NA
    if (length(colnames(testDataset))==length(colnames(trainingDataset))){
      if (!(all(length(sort(names(trainingDataset)))==
                length(sort(names(testDataset)))) &
            all(sort(names(trainingDataset))==
                sort(names(testDataset))))){
        stop('The variables of all the tables must be the same')
      }
    } else {
      stop('The variables of all the tables must be the same')
    }
  } else if (is.null(testDataset)){
    testDataset <- trainingDataset[1,]
    testDataset[, target_name] <- NA
    if (!(all(length(sort(names(trainingDataset)))==
              length(sort(names(validationDataset)))) &
          all(sort(names(trainingDataset))==
              sort(names(validationDataset))))){
      stop('The variables of all the tables must be the same')
    }
  } else {
    if (length(colnames(testDataset))==length(colnames(trainingDataset))){
      if (!(all(length(sort(names(trainingDataset)))==
                length(sort(names(testDataset)))) &
            all(sort(names(trainingDataset))==
                sort(names(testDataset))))){
        stop('The variables of all the tables must be the same')
      }
    } else {
      stop('The variables of all the tables must be the same')
    }
    if (!(all(length(sort(names(trainingDataset)))==
              length(sort(names(validationDataset)))) &
          all(sort(names(trainingDataset))==
              sort(names(validationDataset))))){
      stop('The variables of all the tables must be the same')
    }
  }
  
  if (!evalMetric %in% c("MAPE",
                          "MEDAPE",
                          "MSE",
                          "RMSE",
                          "MAE",
                          "SMAPE")){
    stop("The eval metric must be one of: MAPE, MEDAPE, MSE, RMSE, MAE or SMAPE")
  }
  
  colnames(trainingDataset)[which(colnames(trainingDataset)==target_name)] <- "Target"
  colnames(validationDataset)[which(colnames(validationDataset)==target_name)] <- "Target"
  colnames(testDataset)[which(colnames(testDataset)==target_name)] <- "Target"
  
  train_variables <- as.list(as.data.frame(trainingDataset))
  check_unary_variables <- lapply(train_variables, function(x){x[!duplicated(x)]})
  
  non_unary_variables <- colnames(trainingDataset)[lapply(check_unary_variables, length) != 1]
  
  valid_data <- as.list(as.data.frame(validationDataset))
  
  test_data <- as.list(as.data.frame(testDataset))
  
  if (!"Target" %in% non_unary_variables){
    stop("Target variable has only one value")
  } else if (length(non_unary_variables) <= 1){
    stop("All the variables are unaries")
  } else {
    trainingDataset <- trainingDataset[,non_unary_variables]
    validationDataset <- validationDataset[,non_unary_variables]
    testDataset <- testDataset[,non_unary_variables]
  }
  
  ## we store all the non unary variables in a  table 
  variables_table <- mapply(c, check_unary_variables, valid_data)
  variables_table <- mapply(c, variables_table, test_data)
  
  variables_table <- variables_table[names(variables_table) %in% non_unary_variables[non_unary_variables!="Target"]]
  train_variables <- train_variables[names(train_variables) %in% non_unary_variables[non_unary_variables!="Target"]]
  variables_table <- lapply(variables_table, function(x){x[!duplicated(x)]})
  
  variables <- names(trainingDataset)[which(names(trainingDataset)!="Target")]
  num_variables <- length(variables)
  var_model <- paste0('var_', 1:num_variables)
  max_dim_copulas <- 2 
  
  ## we initialize all the information for the output table
  copulaModel <- list()
  copulaModel[['trainingDataset']] <- trainingDataset
  copulaModel[['numBins']] <- numBins
  copulaModel[['iterations']] <- list()
  
  colnames(trainingDataset)[colnames(trainingDataset)!="Target"] <- paste0('var_', 1:num_variables)
  colnames(validationDataset)[colnames(validationDataset)!="Target"] <- paste0('var_', 1:num_variables)
  colnames(testDataset)[colnames(testDataset)!="Target"] <- paste0('var_', 1:num_variables)
  
  names(variables_table) <- c(paste0('var_', 1:num_variables))
  names(train_variables) <- paste0('var_', 1:num_variables)
  
  train_errors <- data.frame(iter = 0,
                              error = 0,
                              var = "")
  valid_errors <- data.frame(iter = 0,
                              error = 0,
                              var = "")
  test_errors <- data.frame(iter=0,
                             error = 0,
                             var = "")
  
  iterations_info <- data.frame()

  variables_combinations <- comb_variables_generator(num_variables,
                                             max_dim_copulas)
  comb_variables_names <- c()
  for (i in 1:length(variables_combinations)){
    comb_variables_names <- c(comb_variables_names,
                         paste0(variables[variables_combinations[[i]]], collapse = ', '))
  }
  
  ## we initialize all the auxiliary tables for the iterative proccess
  i <- 1
  pred_train <- list()
  pred_valid <- list()
  pred_test <- list()
  
  copulas_fit <- list()
  copulas_fit_var <- list()
  
  while (i <= maxiter){
    
  ## we check if the early stopping condition is verified
    if (i > 1){
      if (!is.nan(iterations_info[1,'error_valid'])){
        if (earlyStoppingIterations>0){
          if ((i - valid_errors[which.min(valid_errors$error), 'iter'] - 2) == 
              earlyStoppingIterations){
            iterations_info <- iterations_info[iterations_info$iteration<(i - 1),]
            output_tables <- best_iter_generator(iterations_info, pred_train, pred_valid, pred_test, copulaModel)
            if ((verbosity) & (nrow(iterations_info[iterations_info$iteration==i,])>0)){
              print(iterations_info[iterations_info$iteration==i,])
            }
            i <- maxiter + 1
            next
          }
        }
      }
    }
    
    ## we build the first prediction with the mean of the target variable in train and calculate 
    ## the first error to be predicted 
    if (i == 1){
      train_data <- data.frame(Target = trainingDataset$Target)
      valid_data <- data.frame(Target = validationDataset$Target)
      test_data <- data.frame(Target = testDataset$Target)
      
      train_data$prediction <- mean(train_data$Target)
      valid_data$prediction <- mean(train_data$Target)
      test_data$prediction <- mean(train_data$Target)
     
      train_data$error <- train_data$Target - train_data$prediction
      valid_data$error <- valid_data$Target - valid_data$prediction
      test_data$error <- test_data$Target - test_data$prediction
      
      train_errors$error <- round(eval_metric_functions[[evalMetric]]
                                   (train_data$Target,
                                     train_data$prediction), minError)
      
      valid_errors$error <- round(eval_metric_functions[[evalMetric]]
                                   (valid_data$Target,
                                     valid_data$prediction), minError)
      
      test_errors$error <- round(eval_metric_functions[[evalMetric]]
                                  (test_data$Target,
                                    test_data$prediction), minError)
      
    } else  {
      
      train_data <- train_data_update
      valid_data <- valid_data_update
      test_data <- test_data_update
      
    }
    
    ## we calculate the best copula for each variable related with the error
    copulas_fit[[i]] <- 
      fit_var_cop(train_data,
                  train_variables,
                  subsamplePercent)
    
    copulas_fit_var[[i]] <- data.frame(var = variables,
                                          aic = unlist(lapply(copulas_fit[[i]][[1]], function(x){x$aic}))
    )
    
    ## condition to fix infinite loops for a constant best aic value
    if (i >= 2) {
      if (round(copulas_fit_var[[i]]$aic[which.min(copulas_fit_var[[i]]$aic)], minError)==
          round(copulas_fit_var[[i - 1]]$aic[which.min(copulas_fit_var[[i - 1]]$aic)], minError)){
        copulas_fit_var[[i]]$aic[which.min(copulas_fit_var[[i]]$aic)] <- 0
      }
    }
    
    ## we select the best variable for the iteration and calculate the prediction of the errors
    ## based on the variable values and the conditional copula
    copula_iter <- which.min(copulas_fit_var[[i]]$aic)
    
    ## condition in case of finding all the variable independent to the error (stopping criteria)
    if (copulas_fit_var[[i]]$aic[copula_iter] >= 0) {
      if (i == 1){
        stop("All the variables are independent of the target variable. Use other variables")
      } else {
        iterations_info <- iterations_info[iterations_info$iteration<(i - 1),]
        output_tables <- best_iter_generator(iterations_info, pred_train, pred_valid, pred_test, copulaModel)
        if ((verbosity) & (nrow(iterations_info[iterations_info$iteration==i,])>0)){
          print(iterations_info[iterations_info$iteration==i,])
        }
        i <- maxiter + 1
        next
      }
    } else {
      train_aux <- data.frame(variables_table[[copula_iter]])
      colnames(train_aux) <- names(variables_table)[copula_iter]
      
      train_data_aux <- cbind(prediction = train_data$prediction,
                               trainingDataset[, c('Target', names(variables_table)[copula_iter])])
      valid_data_aux <- cbind(prediction = valid_data$prediction,
                               validationDataset[, c('Target', names(variables_table)[copula_iter])])
      test_data_aux <- cbind(prediction = test_data$prediction,
                              testDataset[, c('Target', names(variables_table)[copula_iter])])
      
      errors_iter <- score_cop(train_aux,
                               copulas_fit[[i]][[1]][[copula_iter]]$optimcopula,
                               copulas_fit[[i]][[2]][[copula_iter]],
                               numBins,
                               train_data_aux,
                               valid_data_aux,
                               test_data_aux)
      
    }
    
    train_errors_var_iter <- data.frame(var = names(variables_table)[copula_iter],
                                         error = round(eval_metric_functions[[evalMetric]]
                                                            (train_data$Target,
                                                              errors_iter[[1]]$prediction), minError)
    )
    
    valid_errors_var_iter <- data.frame(var = names(variables_table)[copula_iter],
                                         error = round(eval_metric_functions[[evalMetric]]
                                                              (valid_data$Target,
                                                                errors_iter[[2]]$prediction), minError)
    )
    
    test_errors_var_iter <- data.frame(var = names(variables_table)[copula_iter],
                                        error = round(eval_metric_functions[[evalMetric]]
                                                             (test_data$Target,
                                                               errors_iter[[3]]$prediction), minError)
    )
    
    iterations_info <- rbind(iterations_info,
                            data.frame(iteration = i,
                                       variable = paste0(variables[variables_combinations[[copula_iter]]], collapse = ', '),
                                       copula = as.character(errors_iter[[4]]$best_copula_var),
                                       error_train = train_errors_var_iter$error,
                                       error_valid = valid_errors_var_iter$error,
                                       error_test = test_errors_var_iter$error
                            )
    )
 
    ## we update the data with the new errro after the iteration prediction
    train_data_update <- cbind(Target = train_data$Target,
                              errors_iter[[1]])
    valid_data_update <- cbind(Target = valid_data$Target,
                              errors_iter[[2]])
    test_data_update <- cbind(Target = test_data$Target,
                             errors_iter[[3]])
    
    pred_train[[i]] <- train_data_update$prediction
    pred_valid[[i]] <- valid_data_update$prediction
    pred_test[[i]] <- test_data_update$prediction
    
    # we update the information to the output table
    copulaModel[['iterations']][[i]] <- list()
    copulaModel[['iterations']][[i]][['original']][['copula']] <- errors_iter[[5]]
    copulaModel[['iterations']][[i]][['original']][['inf_iter']] <- errors_iter[[6]]
    copulaModel[['iterations']][[i]][['final']][['copula']] <- errors_iter[[5]]
    copulaModel[['iterations']][[i]][['final']][['inf_iter']] <- errors_iter[[6]]
    
    train_errors <- rbind(train_errors,
                           data.frame(iter = i,
                                      error = train_errors_var_iter$error,
                                      var = paste0(variables[variables_combinations[[copula_iter]]], collapse = ', ')
                           )
    )
    valid_errors <- rbind(valid_errors,
                           data.frame(iter = i,
                                      error = valid_errors_var_iter$error,
                                      var = paste0(variables[variables_combinations[[copula_iter]]], collapse = ', ')
                           )
    )
    test_errors <- rbind(test_errors,
                          data.frame(iter = i,
                                     error = test_errors_var_iter$error,
                                     var = paste0(variables[variables_combinations[[copula_iter]]], collapse = ', ')
                          )
    )
    
    ## stopping criteria for number of itrations
    if (i == maxiter){
      output_tables <- best_iter_generator(iterations_info, pred_train, pred_valid, pred_test, copulaModel)
      if ((verbosity) & (nrow(iterations_info[iterations_info$iteration==i,])>0)){
        print(iterations_info[iterations_info$iteration==i,])
      }
      i <- maxiter + 1
      next
    }
    
    ## verbosity
    if ((verbosity) & (nrow(iterations_info[iterations_info$iteration==i,])>0)){
      print(iterations_info[iterations_info$iteration==i,])
    }
    i <- i + 1
    
    ## remove useless information
    if ((i - 2) >= 1){
      copulas_fit[[i - 2]] <- list()
    }
  }
  return(output_tables)
}
