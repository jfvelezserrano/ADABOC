###################################################################
## function to score all the values of the variable based on the ##
## bicopula built between the variable and the error             ##                        
## input variables:                                              ##
## - input_data: values of the variable to score                 ##
## - numBins: number of simulations for approximate the          ##
## conditional copulas                                           ##
## - optim_copula: best copula to fit the current error with the ##
## selected variable                                             ##
## - train: relations between the variable and the error in train##  
## output variables:                                             ##
## - score: prediction of the error with the diferent values of  ##
## the variable                                                  ##
###################################################################
score_copula_opt <- function(input_data,
                             numBins,
                             optim_copula,
                             train){
  
  ## function to score all the values of the variable based on the bicopula 
  ## built between the variable and the error
  
  d <- ncol(train)
  
  ## we build a grid of error of dimension num_simulation between 
  ## the minimum and the maximum of the errors
  errors <-  data_vector(train[,d], 
                        numBins)
  
  ## join the grid of error with the variable values
  names <- paste0(colnames(train)[1:(d-1)])
  join1 <- do.call(rbind, replicate(numBins, as.matrix(input_data[,names]),
                                     simplify=FALSE))
  rownames(join1) <- NULL
  join2 <- data.frame(errors = sort(unlist(replicate(nrow(data.frame(input_data[,names])),
                                                      as.matrix(errors), 
                                                      simplify=FALSE))))
  rownames(join2) <- NULL
  data_sim <- data.frame(join1,
                         join2)
  
  # We calculate the CDF for the simulated data
  grid_cdf_data <- matrix(0,nrow = nrow(data_sim), ncol = d)
  grid_data_orig <- matrix(0,nrow = nrow(data_sim), ncol = d)
  
  for (i in 1:d){
    
    uni_data_sim <- as.matrix(data_sim[!duplicated(data_sim[,i]), i])
    
    cdf <- predict(ks::kcde(train[,i]), x = uni_data_sim)
    
    cdf <- data.frame(uni_data_sim,
                      cdf = cdf)
    if (i == d){
      cdf_aux <- cdf
      
      cdf_aux$round <- round(cdf_aux$cdf, 7)
      group_table <- cdf_aux %>% 
        group_by(round) %>%
        summarise(mean = mean(uni_data_sim))
      
      y2 <- group_table$mean
    }
    
    colnames(cdf)[1] <- colnames(data_sim)[i]
    
    data_sim_aux <- data_sim %>% left_join(cdf, by = colnames(data_sim)[i]) 
    
    grid_cdf_data[, i] <- data_sim_aux[,d + 1]
    grid_data_orig[, i] <- data_sim[,i]
    
  }
  
  grid_cdf_data <- ifelse(grid_cdf_data<0.99999,grid_cdf_data,0.99999)
  grid_cdf_data <- ifelse(grid_cdf_data>0.00001,grid_cdf_data,0.00001)
  
  grid_cdf_data <- data.table(grid_cdf_data)
  var_indep <- names(train)[1:(ncol(train)-1)]
  names(grid_cdf_data)[1:(d-1)] <- var_indep
  names(grid_cdf_data)[d] <- 'y'
  
  grid_data_orig <- data.table(grid_data_orig)
  names(grid_data_orig) <- paste(names(train), '_orig', sep = '')
  
  names(grid_data_orig)[1:(d-1)] <- paste(var_indep, '_orig', sep = '')
  names(grid_data_orig)[d] <- 'y_orig'
  
  grid_cdf_data <- round(grid_cdf_data, 7)
  score_join <- cbind(grid_data_orig[,1:(d-1)], grid_cdf_data[,1:(d-1)])
  score_join <- score_join[!duplicated(score_join),]
  ind_dup <- duplicated(grid_cdf_data)
  grid_cdf_data <- grid_cdf_data[!ind_dup, ]
  grid_data_orig <- grid_data_orig[!ind_dup, ]
  
  
  ## we calculate the density of all the values in the grid (variable, error)
  distr_cop <- BiCopPDF(unlist(grid_cdf_data[,1]), unlist(grid_cdf_data[,2]), optim_copula)
 
  grid_cdf_data <- cbind(grid_cdf_data, distr_cop)
  grid_cdf_data <- data.table(grid_cdf_data)
  
  var_agrup <- paste(var_indep, collapse = ',')
  
  ## we calculate the expectation for each variable value to obtain the
  ## marginal distribution of the variable
  grid_cdf_data <- grid_cdf_data[, margin_prob := estimateArea(y, distr_cop), by = var_agrup]
  
  ## we calculate the disribution of the error condicionated to the variable 
  grid_cdf_data$distr_condic <- grid_cdf_data$distr_cop/grid_cdf_data$margin_prob
  
  ## finally we calculate the condicional expectation of an error subject to a specific
  ## value of the variable 
  grid_cdf_data$expectation <- grid_cdf_data$distr_condic*grid_cdf_data$y
  
  grid_cdf_data <- grid_cdf_data[, condic_expectation := estimateArea(y, expectation), by = var_agrup]
  
  grid_condic_expectation <- grid_cdf_data[, c(var_indep, 'condic_expectation'), with = FALSE]
  
  grid_condic_expectation <- cbind(grid_condic_expectation, grid_data_orig)
  
  grid_condic_expectation <- grid_condic_expectation[!duplicated(grid_condic_expectation[,1:(ncol(grid_condic_expectation)-1)]),1:(ncol(grid_condic_expectation)-1)]
  
  ## we use the discrete inverse transformation to convert the prediction obtain in real values
  ## of the error variable 
  real_data <- grid_cdf_data[!duplicated(grid_cdf_data[,d, with = FALSE]), d, with = FALSE]
  
  grid_condic_expectation$estim_copula <- sapply(grid_condic_expectation$condic_expectation,
                                         function(x){y2[min(which(x < real_data))]})
  
  grid_condic_expectation$lower_int <- 0
  grid_condic_expectation$upper_int <- 0
  
  ## we build the output table with all the posible values of the variable with their prediction error values
  score_join <- score_join %>% left_join(grid_condic_expectation[,colnames(grid_condic_expectation)[!grepl('_orig', colnames(grid_condic_expectation))], with = FALSE], by = colnames(input_data)[1:(d-1)])
 
  names2 <- c(paste(names(train)[-d], '_orig', sep = ''), 'estim_copula', 'lower_int', 'upper_int')
  
  score <- score_join[, names2]
  colnames(score)[1:(d-1)] <- paste0(colnames(input_data)[1:(d-1)])
  score <- score  %>% left_join(input_data, by = names)
  
  colnames(score)[2] <- "error"
  
  return(score)
}
