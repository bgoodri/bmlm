# bmlm: An R package for Bayesian MultiLevel Mediation models

## Installing bmlm

Please ensure you have the [latest version of R](https://cran.r-project.org/) installed.

Currently, bmlm is only available on GitHub, and therefore requires [devtools](https://cran.r-project.org/web/packages/devtools/index.html) for installation. If you don't have the devtools package installed in R, first run this line:

```r
install.packages(devtools)
```

Then proceed to install bmlm:

```r
devtools::install_github("mvuorre/bmlm")
```

This package depends on [Stan](http://mc-stan.org/). Please see [here](http://mc-stan.org/interfaces/rstan.html) for how to install the R Stan interface.

## Example

bmlm ships with an example data set from Intensive Longitudinal Methods: An Introduction to Diary and Experience Sampling Research (Bolger & Laurenceau, 2013, chapter 9). To estimate the multilevel mediation model presented in that chapter, run:

```r
library(bmlm)
data(BLch9)
fit <- mlm(BLch9)
```

After a while, you will have a joint posterior distribution of plausible parameter values from the model applied to this data. Inspect the model:

```r
print(fit)
```

# Information

bmlm is in active development, please contact the author of the package for questions and suggestions.

