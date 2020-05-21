REQUIREMENTS
===============

RStudio version: 1.2.5033

Data: the .csv's provided, which contains the data partitions of all the datasets used.
In each of them, a set of observations and variables (inputs and target) is provided.

Dependencies: none


HOW TO RUN
===============

Open the code in a R session and define the next parameters before executing:

[*] In "Set environment" section, define:
       *****************

1. dataPath: the path in which the .csv that contains the data are allocated
2. exitPath: the path in which the .csv that contains the final errors as a
	     result of the process will be saved

{Example of how to define them}:

dataPath <- "C/Documents/Copulas/Data"
exitPath <- "C/Documents/Copulas/Errors"


[*] In "Specify dataset" section, provide:
       *****************

- datasetName: the name of the dataset written in quotes. It must be one of the next:
	       Ailerons, Bostonprice, Communities, Elevators and Kdd1998

[ADVICE]: R is case sensitive, so be cereful when writing the name.

{Example of how to define it}:

datasetName <- "Communities"


FILE DESCRIPTION
===============

- H2O_Code_Without_DL .- code that generates machine learning models predictions
- H2O_Code_Only_DL .- code that generates deep learning model predictions


ADVICE
===============

To guarantee the correct operation and exact reproduction of the tests carried out,
it is advisable to close and reopen R after each one of them.

