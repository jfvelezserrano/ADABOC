# copula-learning-method

This code implements a novel forecasting method based on bivariate copula. The method offers competitive results when it is compared with several popular machine learning techniques.

## Requisites

The algorithms are programed on R. You can execute it on Windows, Linux or Mac. The [provided action](.github/workflows/blank.yml) uses Ubuntu 18.04.

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

At top levevel there are 2 scripts:
- [H2O_Code_Without_DL.R](code/H2O_Code_Without_DL.R) - Which uses the autoML of H2O (a compilation of some Machine Learning methods) over the data with comparison purpose.
- [copula_learning_example.R](code/copula_learning_example.R) - Which train and test the proposed model over a dataset. This script uses two important functions:
  - copulaLearningMethod() in [copulaLearningMethod.R](code/copulaLearningMethod.R) - The model training function.
  - copulaLearningMethodPredict() in [copulaLearningMethodPredict.R](code/copulaLearningMethodPredict.R) - The model scoring function.

```
        R < code/H2O_Code_Without_DL.R --no-save
        R < code/copula_learning_example.R --no-save
```
In both cases you can edit the top level scripts to select other dataset.

An action that execute the whole project over a sample dataset is provided. [Here](https://github.com/jfvelezserrano/copula-learning-method/runs/703504103?check_suite_focus=true) you can see the result of an execution over the kdd1998 dataset.
