My REQUIREMENTS
====================
R version: 3.6.1

libraries:

- tidyverse: 
	Dependencies:  	"colorspace"   "sys"          "ps"           "highr"        "markdown"    
					"plyr"         "labeling"     "munsell"      "RColorBrewer" "zeallot"     
					"askpass"      "rematch"      "prettyunits"  "processx"     "knitr"       
					"yaml"         "htmltools"    "evaluate"     "base64enc"    "tinytex"     
					"xfun"         "utf8"         "backports"    "generics"     "reshape2"    
					"assertthat"   "glue"         "pkgconfig"    "R6"           "Rcpp"        
					"tidyselect"   "BH"           "plogr"        "DBI"          "ellipsis"    
					"digest"       "gtable"       "lazyeval"     "scales"       "viridisLite" 
					"withr"        "vctrs"        "curl"         "mime"         "openssl"     
					"clipr"        "cellranger"   "progress"     "callr"        "fs"          
					"rmarkdown"    "whisker"      "selectr"      "stringi"      "fansi"       
					"pillar"       "lifecycle"    "broom"        "cli"          "crayon"      
					"dplyr"        "dbplyr"       "forcats"      "ggplot2"      "haven"       
					"hms"          "httr"         "jsonlite"     "lubridate"    "magrittr"    
					"modelr"       "purrr"        "readr"        "readxl"       "reprex"      
					"rlang"        "rstudioapi"   "rvest"        "stringr"      "tibble"      
					"tidyr"        "xml2" 
- data.table:
	Without dependencies
- VineCopula:
	Dependencies:   "mvtnorm"   "ADGofTest"
- ks:
	Dependencies:   "Rcpp"      "FNN"       "kernlab"   "mclust"    "multicool" "mvtnorm"
- caTools:
	Dependencies:   "bitops"
- rapportools:
	Dependencies:   "Rcpp"    "digest"  "reshape" "plyr"    "pander"
	
HOW TO RUN
===============

Para cargar el modelo CopulaLearningMethod, se deben de seguir los siguientes pasos:

1- guardar todos los codigos relacionados con el modelo en un mismo directorio.
2- abrir una sesion de R o R Studio y abrir el codigo "copulaLearningMethod" y 
   cambiar el code_path al directorio en el que se encunetren todos los codigos.
3- ejecuctar los codigos de "copulaLearningMethod" y "copulaLearningMethodPredict"

Con estos pasos estaran ya todas las funciones cargadas para el uso del modelo.
Cargando una tabla en formato data.frame con una variable dependiente y otra independiente o target
y una llamada a la funcion:

					copulaModel <- copulaLearningMethod(trainingDataset = train_table,
														target_name = "TARGET") 
														
Por otro lado, si se quiere puntuar una tabla (data.frame without a target variable) con un modelo ya existente
habria que ejecutar lo siguiente:

					scoring <- copulaLearningMethodPredict(scoreDataset = score_table,
														 copulaModel = copulaModel)

FILE DESCRIPTION
===============

- copulaLearningMethod: Programa principal. Tiene implementado el algoritmo Copula Learning Method. 
						Crea un objeto de "tipo cópula" que puede ser aplicado sobre otros conjuntos de datos 
						(distintos a los utilizados para entrenar) para obtener las predicciones.
	Dependencies: - best_iter_generator -
				  - comb_variables_generator -
				  - eval_metric_functions -
				  - fit_var_cop -
				  - optim_copulas_BI -
				  - score_cop -
			   	  - score_copula_opt -
				  
- copulaLearningMethodPredict: Función que, a partir de un objeto cópula creado por copulaLearningMethod,
							   permite "puntuar" otras tablas.
	Dependencies: - score_copula_opt -
	
- best_iter_generator: Select the best iteration in the validation set (in case of exist) and build the output data.

- comb_variables_generator: Auxiliary function to calculate all the combinations of the variables according 
							to the dimension of the copulas.
							
- eval_metric_functions: Metrics for the error evaluation.

- fit_var_cop: Function to calculate the copula that best fits each variable with the error.

- optim_copulas_BI: Auxiliary functions to fit copulas to the data.

- score_cop: Function to obtain the prediction of the error according to the variable with the minimun aic 
			 between all the best copulas found for each variable.

- score_copula_opt: Function to score all the values of the variable based on the bicopula built
					between the variable and the error.






	
