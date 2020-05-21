## metrics for the error evaluation
eval_metric_functions <- list()
## MAPE = Mean Absolute Percentage Error (non-defining with Target = 0)
eval_metric_functions[['MAPE']] <- function(Target, prediction){
  return(100*mean(ifelse(Target == 0 & prediction == 0,
                         0,
                         ifelse(Target == 0,
                                NA,
                                abs((Target-prediction)/Target))), na.rm = T))
}
## MEDAPE = Median Absolute Percentage Error (non-defining with Target = 0)
eval_metric_functions[['MEDAPE']] <- function(Target, prediction){
  return(100*median(ifelse(Target == 0 & prediction == 0,
                         0,
                         ifelse(Target == 0,
                                NA,
                                abs((Target-prediction)/Target))), na.rm = T))
}
## MSE = Mean Square Error
eval_metric_functions[['MSE']] <- function(Target, prediction){
  return(mean((Target-prediction)^2))
}
## RMSE = Root Mean Square Error
eval_metric_functions[['RMSE']] <- function(Target, prediction){
  return(sqrt(mean((Target-prediction)^2)))
}
## MAE = Mean Absolute Error
eval_metric_functions[['MAE']] <- function(Target, prediction){
  return(mean(abs(Target-prediction)))
}
## SMAPE = Symmetric Mean Absolute Percentage Error
eval_metric_functions[['SMAPE']] <- function(Target, prediction){
  return(100*mean(ifelse(prediction == 0 & Target == 0,
                         0,
                         (abs(prediction-Target)/((abs(prediction)+abs(Target))/2)))))
}










