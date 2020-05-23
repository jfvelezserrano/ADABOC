# copula-learning-method

## Requisites

You need install R

```
add to /etc/apt/source.lst
deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/
sudo apt-get update
sudo apt install r-base-core
```

## Execute the code

You need install h20 package, but bit64 is convenient too.

```
R -e 'install.packages(c("h2o", "bit64"))'
```

Finally you can execute the project that will generate a file called *Errors_Communities_10models_MAE*

```
R < code/H2O_Code_Without_DL.R --no-save
```
