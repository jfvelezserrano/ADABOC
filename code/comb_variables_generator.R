comb_variables_generator <- function(num_variables, 
                                     dim_copulas){
  ## auxiliary function to calculate all the combinations of the variables according to 
  ## the dimension of the copulas
  n <- num_variables
  m <- dim_copulas - 1
  vector <- c(1:n)
  for (i in 1:m){
    aux <- list()
    if (i==1){
      for (j in 1:n){
        aux[[j]] <- vector[j]
      }
      assign(paste('comb_',i,sep=''),aux)
    } else {
      data <- get(paste('comb_',(i-1),sep=''))
      for (j in 1:length(data)){
        if (i==2){
          a <- data[[j]]
        } else {
          a <- data[[j]][length(data[[j]])]
        }
        if (a<n){
          for (k in (a+1):n){
            aux[[length(aux) + 1]] <- c(data[[j]],k)
          }
        }
      }
      assign(paste('comb_',i,sep=''),aux)
    }
  }
  comb <- list()
  for (i in 1:m){
    a <- get(paste('comb_',i,sep=''))
    comb <- c(comb,a)
  }
  return(comb)
}

