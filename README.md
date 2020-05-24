# copula-learning-method

An action that execute the whole project over a sample dataset is provided.

## Requisites

The algorithms are programed on R. You can execute it on Windows, Linux or Mac. The [provided example](.github/workflows/blank.yml) is test on Ubuntu 18.04.

To repdroduce it, you need install R from the marutter repository which contains several needed precompiled packages. Also, the H2O is compiled.

```
sudo add-apt-repository ppa:marutter/rrutter3.5
        sudo add-apt-repository ppa:marutter/c2d4u3.5
        sudo apt-get update
        sudo apt-get install r-base
        sudo apt-get install r-cran-tidyverse r-cran-bitops r-cran-catools r-cran-vinecopula r-cran-ks r-cran-data.table r-cran-rapportools
        sudo apt-get install r-cran-rcurl r-cran-bitops r-cran-rjson r-cran-statmod libssl-dev```
        
        sudo R -e 'install.packages("h2o")'
```

## Execute the code

Thre are 2 main pieces of code:
- [H2O_Code_Without_DL.R](code/H2O_Code_Without_DL.R) - The test using the autoML of H2O (a compilation of some Machine Learning methods).
- [copula_learning_example.R][code/copula_learning_example.R] - This script uses two important functions:
  - copulaLearningMethod() in [copulaLearningMethod.R](code/copulaLearningMethod.R) - The model training function.
  - copulaLearningMethodPredict() in [copulaLearningMethodPredict.R](code/copulaLearningMethodPredict.R) - The model scoring function.

```
        R < code/H2O_Code_Without_DL.R --no-save
        R < code/copula_learning_example.R --no-save
```
[Here](https://github.com/jfvelezserrano/copula-learning-method/runs/703504103?check_suite_focus=true) you can see the result of an execution.
