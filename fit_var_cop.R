###################################################################
## function to calculate the copula that best fits each variable ##
## with the error                                                ##
## input variables:                                              ##
## - train_data: train data for fit the copulas with the error   ##
## - variables_train: variables of the model                     ##
## a scoring                                                     ##
## - subsamplePercent: percentage of the train table to fit the  ##
## best copula for each iteration and variable                   ##
## output variables:                                             ##
## - best_copulas: list of the best copula for each variable and ##
## the currently error                                           ##
###################################################################
fit_var_cop <- function(train_data,
                        variables_train,
                        subsamplePercent){
  
  ## function to calculate the copula that best fits each variable with the error
  aux_train_var <- function(x){
    aux <- data.frame(var = variables_train[[x]],
                        error = train_data$error)
    colnames(aux)[1] <- names(variables_train)[x]
    return(aux[!duplicated(aux),])
  }
  
  train_var <- lapply(as.list(1:length(variables_train)), aux_train_var)
  
  best_copula <- optim_copula(train_var, subsamplePercent)
  
  return(list(best_copula,
              train_var))
}
