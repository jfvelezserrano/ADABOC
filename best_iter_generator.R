best_iter_generator <- function(iterations_info, 
                                pred_train,
                                pred_valid,
                                pred_test,
                                copulaModel){

  ## select the best iteration in the validation set (in case of exist) and build the output data
  if (is.nan(iterations_info[1,'error_valid'])){
    best_iteration <- iterations_info[which.min(iterations_info$error_train), 'iteration']
  } else {
    best_iteration <- iterations_info[which.min(iterations_info$error_valid), 'iteration']
  }

  train_errors <- data.frame(iter = 1:best_iteration,
                             error = iterations_info[1:best_iteration, 'error_train'],
                             variable = iterations_info[1:best_iteration,'variable']
  )
  
  valid_errors <-   data.frame(iter = 1:best_iteration,
                               error = iterations_info[1:best_iteration, 'error_valid'],
                               variable = iterations_info[1:best_iteration,'variable']
  )
  
  test_errors <- data.frame(iter = 1:best_iteration,
                            error = iterations_info[1:best_iteration, 'error_test'],
                            variable = iterations_info[1:best_iteration,'variable']
  )
  
  iterations_info_aux <- iterations_info[iterations_info$iteration <= best_iteration,]
  
  final_model <- copulaModel
  if (best_iteration > 1){
    final_model[['iterations']] <- lapply(copulaModel[['iterations']][1:(best_iteration - 1)], function(x){x$final})
    final_model[['iterations']][[best_iteration]] <- copulaModel[['iterations']][[best_iteration]][['original']]
  } else {
    final_model[['iterations']] <- final_model[['iterations']][[1]][['original']]
  }
 
  return(list(train_errors = train_errors,
              valid_errors = valid_errors,
              test_errors = test_errors,
              iterations_info = iterations_info,
              pred_train = pred_train[[best_iteration]],
              pred_valid = pred_valid[[best_iteration]],
              pred_test = pred_test[[best_iteration]],
              copulaModel = final_model))
}