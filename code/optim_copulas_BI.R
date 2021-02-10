## Fix seed of the process of simulation
set.seed(12345)

## function to calculate the cdf of a variable via kernel estimators
ker_cdf <- function(x){
  predict(ks::kcde(x), x = as.matrix(x))
}

## function to define a grid of values between a minimum and a maximum of a vector
data_vector <- function(x, num_data = n2){
  seq(min(x), max(x), length.out = num_data)
}

## function to estimate the area under a curve, in this case the density function 
## of the selected copula
estimateArea <- function(dis, par2){
  sum(diff(dis)*caTools::runmean(par2, 3)[1:(length(dis)-1)])
}

## function to calculate the best fit copula for the pair (variable, error)
optim_copula <- function(data, pct_sample){
  
  ## the cdf distribution for the variable and the error
  d <- 2
  cdf_data <- lapply(data, function(x){apply(x, 2, ker_cdf)})

  if (!is.null(pct_sample)){
    ## if the pct_sample parameter is given, the distribution is only built with a sample of the data
    ind_sample <- lapply(cdf_data, 
                         function(x){
                             return(sample(1:nrow(x), round((pct_sample/100)*nrow(x), 0), replace = FALSE))
                           })
    
    cdf_data_aux <- lapply(as.list(1:length(cdf_data)),
                           function(x){cdf_data[[x]][ind_sample[[x]],]})
    
    cond_obs_fit <- lapply(cdf_data_aux, function(x){sum(apply(as.matrix(x[,-d]),
                                                               2,
                                                               function(y){length(unique(y))}) == 1) == 0})
    
    cdf_data <- lapply(as.list(1:length(cdf_data)),
                       function(x){if (cond_obs_fit[[x]]){ cdf_data_aux[[x]] } else { cdf_data[[x]]}})
  }
  
  ## we fit all the families to the cdf data and calculate the AIC of each fitness
  fit_copula <- function(x){
    families <- c(0,
                  1,
                  2,
                  3,
                  4,
                  5,
                  6,
                  7,
                  8,
                  9,
                  10,
                  13,
                  14,
                  16,
                  17,
                  18,
                  19,
                  20,
                  23,
                  24,
                  26,
                  27,
                  28,
                  29,
                  30,
                  33,
                  34,
                  36,
                  37,
                  38,
                  39,
                  40                  
    )
    
    itau_families <- c(1,2,3,4,5,6,13,14,16,23,24,26,33,34,36)
    fit <- list()
    
    for (i in 1:length(families)){
      if (families[i] %in% itau_families){
        capture.output(try(fit[[i]] <- BiCopEst(x[,1], x[,2], families[i], method = "itau",
                                                max.df = 3000,
                                                max.BB = list(BB1=c(500,600),BB6=c(600,600),BB7=c(500,600),BB8=c(600,1))),
                           silent = TRUE))
      } else {
        capture.output(try(fit[[i]] <- BiCopEst(x[,1], x[,2], families[i], method = "mle",
                                                max.df = 3000,
                                                max.BB = list(BB1=c(500,600),BB6=c(600,600),BB7=c(500,600),BB8=c(600,1))),
                           silent = TRUE))
      }
      
      if (length(fit)<i){
        fit[[i]] <- BiCopEst(x[,1], x[,2], families[1], method = "itau")
      }
    }
    return(fit)
  }
  
  fit <- lapply(cdf_data, fit_copula)
  
  aic <- lapply(fit, function(x){unlist(sapply(x,function(y){y$AIC}))})
  bestcopula <- lapply(aic, function(x){which.min(x)})
  copulas <- lapply(fit, function(x){unlist(sapply(x,function(y){y$familyname}))})
  
  optimcopula <- lapply(as.list(1:length(bestcopula)), 
                         function(x){fit[[x]][[bestcopula[[x]]]]})
  
  copulas <- lapply(as.list(1:length(copulas)), 
                    function(x){data.frame(copula = copulas[[x]],
                                           aic = aic[[x]])})
  
  copulas <- lapply(copulas, function(x){x[order(x$aic),]})
  
  ## finally, the funtion return a table with the best copula for each variable
  final_copula <- lapply(as.list(1:length(copulas)),
                         function(x){list(aic = copulas[[x]]$aic[1],
                                          optimcopula = optimcopula[[x]],
                                          indep = min(copulas[[x]]$aic)>=0)})
  
  return(final_copula)
}
