###################################################################
## function to obtain the prediction of the error according to   ##
## the variable with the minimun aic between all the best        ##
## copulas found for each variable                               ##
## input variables:                                              ##
## - train_aux: train table for the conditional copulas          ##
## simulations                                                   ##
## - best_copula: best_copula for an iteration and variable      ##
## - train_var: variable to include in this iterations           ##
## - numBins: number of simulations for approximate the          ##
## conditional copulas                                           ##
## - train_data_aux: train table with the currently predictions  ##
## - valid_data_aux: valid table with the currently predictions  ##
## - test_data_aux: test table with the currently predictions    ##
## output variables:                                             ##
## - errors_aux: list with the prediction of the                 ##
## train, validation and test tables updated and the information ##
##  for a posterior scoring                                      ##
###################################################################
score_cop <- function(train_aux,
                      best_copula,
                      train_var,
                      numBins,
                      train_data_aux,
                      valid_data_aux,
                      test_data_aux){
  ## function to obtain the prediction of the error according to the variable with the minimun aic
  ## between all the best copulas found for each variable 
  results <- data.frame()
  n <- nrow(train_aux)
  ## we calculate the prediction of the error, with the conditional distribution of the best copula
  if ((n*numBins)>=1000000){
    if (floor((n*numBins)/1000000) == (n*numBins)/1000000) {
      maxiter <- (n*numBins)/1000000
    } else {
      maxiter <- floor((n*numBins)/1000000) + 1
    }
    row_start <- 1
    row_end <- min(c(floor(row_start + (1000000/numBins)),n))
    for (i in 1:maxiter){
      train_aux_2 <- data.frame(train_aux[row_start:row_end,])
      colnames(train_aux_2) <- colnames(train_aux)
      results_aux <- score_copula_opt(input_data = train_aux_2,
                                      numBins = numBins,
                                      optim_copula = best_copula,
                                      train =  train_var)
      
      results <- rbind(results, results_aux)
      row_start <- row_end + 1
      row_end <- min(c(floor(row_start + (1000000/numBins)),n))
    }
  } else {
    results <- score_copula_opt(input_data = train_aux,
                                numBins = numBins,
                                optim_copula = best_copula,
                                train =  train_var)
  }
  
  ## Then we build the new target prediction and calculate the new error 
  names(results)[names(results) == 'error'] <- 'error_cop'
  
  results2 <- train_data_aux %>% left_join(results, by = names(train_var)[1])
  results3 <- valid_data_aux %>% left_join(results, by = names(train_var)[1])
  results4 <- test_data_aux %>% left_join(results, by = names(train_var)[1])
  
  results2$new_pred <- results2$prediction + results2$error_cop
  results2$new_error <- results2$Target - results2$new_pred
  results3$new_pred <- results3$prediction + results3$error_cop
  results3$new_error <- results3$Target - results3$new_pred
  results4$new_pred <- results4$prediction + results4$error_cop
  results4$new_error <- results4$Target - results4$new_pred
  
  ## we store all the useful data in a list as the output of the function
  errors_aux <- list()
  errors_aux[[1]] <- data.frame(prediction = results2$new_pred,
                                 error = results2$new_error)
  errors_aux[[2]] <- data.frame(prediction = results3$new_pred,
                                error = results3$new_error)
  errors_aux[[3]] <- data.frame(prediction = results4$new_pred,
                                error = results4$new_error)
  errors_aux[[4]] <- data.frame(best_copula_var = best_copula$familyname,
                                 ind_indepCopula = 0)
  results <- results %>% left_join(train_aux, by = colnames(train_aux)[1])
  errors_aux[[5]] <- best_copula
  names <- c(colnames(train_aux)[1], 'error_cop')
  info_iter <- results[,..names]
  info_iter <- info_iter[!duplicated(info_iter),]
  errors_aux[[6]] <- info_iter
  
  return(errors_aux)
}
