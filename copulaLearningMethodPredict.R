###################################################################
## function to score a table with a copula model                 ##
##                                                               ##
## Input parameters:                                             ##
##                                                               ##
## - scoreDataset: table to score                                ##
## - copulaModel: object copula model with the information needed##
## for a scoring                                                 ##
##                                                               ##
## Output parameters:                                            ##
##                                                               ##
## - prediction: predictions for the score data                  ##
###################################################################

copulaLearningMethodPredict <- function(scoreDataset = NULL,
                           copulaModel = NULL){
  
  ## required sources
  source('score_copula_opt.R')
  
  ## input consistence
  if (is.null(scoreDataset)){
    stop('You have to include a table to score')
  } else if (!is.data.frame(scoreDataset)){
    stop('The score table must be a data.frame')
  }
  
  names_model <- c("train_errors",
                    "valid_errors",
                    "test_errors",
                    "iterations_info",
                    "pred_train",
                    "pred_valid",
                    "pred_test",
                    "copulaModel")
  
  if (is.null(copulaModel)){
    stop('You have to include a copula_model object to do the prediction')
  } else if (!(all(length(sort(names(copulaModel)))==
                   length(sort(names_model))) &
               all(sort(names(copulaModel))==
                   sort(names_model)))){
    stop('You have to include a copula_model object to do the prediction')
  }
  
  if (!(all(length(sort(names(copulaModel$copulaModel$train)[names(copulaModel$copulaModel$train)!="Target"]))==
            length(sort(names(scoreDataset)))) &
        all(sort(names(copulaModel$copulaModel$train)[names(copulaModel$copulaModel$train)!="Target"])==
            sort(names(scoreDataset))))){
    stop('The variables in the scoreDataset table must be the same that the variables used for training (without the target)')
  }
  
  ## we load the data for the model needed for the scoreDataset
  variables <- names(copulaModel$copulaModel$train)[which(names(copulaModel$copulaModel$train)!="Target")]
  num_variables <- length(variables)
  
  colnames(copulaModel$copulaModel$train)[colnames(copulaModel$copulaModel$train)!="Target"] <- paste0('var_', 1:num_variables)
  colnames(scoreDataset)[colnames(scoreDataset)!="Target"] <- paste0('var_', 1:num_variables)
  
  copulaModel$copulaModel$train$prediction <- mean(copulaModel$copulaModel$train$Target)
  copulaModel$model$train$error <- (copulaModel$copulaModel$train$Target - copulaModel$copulaModel$train$prediction)/
    copulaModel$copulaModel$train$Target
  scoreDataset$prediction <- mean(copulaModel$copulaModel$train$Target)
  
  ## for each iteration of the original model, we calculate the prediction in score of the needed values
  ## for the variable used.
  for (i in 1:length(copulaModel$copulaModel$iterations)){
    
    dim_iter <- ncol(copulaModel$copulaModel$iterations[[i]]$inf_iter) - 1
    var_iter <- colnames(copulaModel$copulaModel$iterations[[i]]$inf_iter)[1:dim_iter]
    
    values_scores <- data.frame(scoreDataset[!duplicated(scoreDataset[,var_iter]),var_iter])
    colnames(values_scores) <- var_iter
      
    for (j in 1:dim_iter){
      
      if (j == 1){
        coincidences <- data.frame(apply(as.matrix(values_scores[,j]),
                                          1,
                                          function(x){x %in% copulaModel$copulaModel$iterations[[i]]$inf_iter[,j]}))
      } else {
        coincidences <- cbind(coincidences,
                               apply(as.matrix(values_scores[,j]),
                                     1,
                                     function(x){x %in% copulaModel$copulaModel$iterations[[i]]$inf_iter[,j]}))
      }
    }
    
    new_values_var <- data.frame(values_scores[apply(coincidences,
                                                          1,
                                                          function(x){sum(x)!=dim_iter}),])
    
    ## if all the values of the variable are inside the values of the training model variable, 
    ## it is not neccessary to do any prediction. In contrast, only the new values will be scored 
    if (nrow(new_values_var)>0){
      colnames(new_values_var) <- var_iter
      
      variables <- c(var_iter, 'error')
      
      train_var <- copulaModel$copulaModel$train %>% 
        select_(.dots = variables) 
      train_var <- train_var[!duplicated(train_var),]
      
      results <- data.frame()
      
      n <- nrow(new_values_var)
      
      if ((n*copulaModel$copulaModel$numBins)>=1000000){
        
        if (floor((n*copulaModel$copulaModel$numBins)/1000000) == (n*copulaModel$copulaModel$numBins)/1000000) {
          num_iter <- (n*copulaModel$copulaModel$numBins)/1000000
        } else {
          num_iter <- floor((n*copulaModel$copulaModel$numBins)/1000000) + 1
        }
        
        row_start <- 1
        row_end <- min(c(floor(row_start + (1000000/copulaModel$copulaModel$numBins)),n))
        for (j in 1:num_iter){
          train_aux <- new_values_var[row_start:row_end,]
          results_aux <- score_copula_opt(input_data = data.frame(train_aux),
                                          numBins = copulaModel$copulaModel$numBins,
                                          optim_copula = copulaModel$copulaModel$iterations[[i]]$copula,
                                          train =  train_var)
          results <- rbind(results, results_aux)
          row_start <- row_end + 1
          row_end <- min(c(floor(row_start + (1000000/copulaModel$copulaModel$numBins)),n))
        }
      } else {
        results <- score_copula_opt(input_data = new_values_var,
                                    numBins = copulaModel$copulaModel$numBins,
                                    optim_copula = copulaModel$copulaModel$iterations[[i]]$copula,
                                    train =  train_var)
      }
      
      info_iter <- copulaModel$copulaModel$iterations[[i]]$inf_iter
      colnames(info_iter)[1:dim_iter] <- var_iter
      names(results)[names(results) == 'error'] <- 'error_cop'
      
      results2 <- rbind(results[,c(var_iter, "error_cop")],
                        info_iter)
      
      results3 <- copulaModel$copulaModel$train %>% left_join(results2, by = var_iter)
      results4 <- scoreDataset %>% left_join(results2, by = var_iter)
      
      results3$new_pred <- results3$prediction + results3$error_cop
      results3$new_error <- results3$Target - results3$new_pred
      results4$new_pred <- results4$prediction + results4$error_cop
    
      copulaModel$copulaModel$train$prediction <- results3$new_pred
      copulaModel$copulaModel$train$error <- results3$new_error
      scoreDataset$prediction <- results4$new_pred
    } else {
      
      info_iter <- copulaModel$copulaModel$iterations[[i]]$inf_iter
      colnames(info_iter)[1:dim_iter] <- var_iter
      
      results2 <- info_iter
      
      results3 <- copulaModel$copulaModel$train %>% left_join(results2, by = var_iter)
      results4 <- scoreDataset %>% left_join(results2, by = var_iter)
       
      results3$new_pred <- results3$prediction + results3$error_cop
      results3$new_error <- results3$Target - results3$new_pred
      results4$new_pred <- results4$prediction + results4$error_cop
      
      copulaModel$copulaModel$train$prediction <- results3$new_pred
      copulaModel$copulaModel$train$error <- results3$new_error
      scoreDataset$prediction <- results4$new_pred
      
    }
  }
  return(scoreDataset$prediction)
}

