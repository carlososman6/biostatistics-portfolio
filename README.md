# Biostatistics Portfolio

Farouk Osman, Medical Imaging Technologist (BSc Medical Radiography, Makerere University, 2022) and MSc candidate in Clinical Epidemiology and Biostatistics (MCEB), Makerere University, 2025 to present.

This repository holds my analyses in **R**, **Stata** and **SPSS**. Most are coursework assignments from the MSc; a few are self-study. Each project README states the question, the methods and whether it is coursework. Results are my own analyses and were not independently re-checked.

Its important to note that a number of projects are not complete

## Projects

| Project | Question or task | Methods | Tools |
|---|---|---|---|
| [Linear regression](linear-regression) | Birthweight and maternal smoking and race; model building for pbirths; body fat | Multiple linear regression, diagnostics | R, Stata, SPSS |
| [Logistic regression](logistic-regression) | Death among babies; cholesterol category; hypertension and salt | Binary and ordinal logistic regression | R, Stata |
| [Poisson regression](poisson-regression) | Cardiovascular event rates per person-time | Poisson and negative binomial regression | Stata |
| [Survival analysis](survival-analysis) | Cox models for several datasets; Kaplan-Meier for Drug A | Cox, parametric and Kaplan-Meier methods | R, Stata, SPSS |
| [Group comparisons](group-comparisons) | Weight gain by contraceptive; depression data; height and weight | ANOVA, GLM, t-tests, correlation | R, SPSS |
| [BELLS trial](clinical-trial-bells) | Do prednisolone or acyclovir improve recovery in Bell's palsy? | Analysis of a published randomised trial | R |
| [Data cleaning and visualisation](data-cleaning-and-visualisation) | Cleaning a raw medical dataset; TidyTuesday | Data cleaning, exploration | R |
| [Practice](practice) | Early class exercises | Descriptive statistics, wrangling | R, Stata, SPSS |

## Skills shown

| Skill | Where it is shown |
|---|---|
| Linear, logistic, ordinal, Poisson and negative binomial regression | [`linear-regression`](linear-regression), [`logistic-regression`](logistic-regression), [`poisson-regression`](poisson-regression) |
| Model diagnostics: assumptions, collinearity, influential observations | [`linear-regression`](linear-regression), [`logistic-regression`](logistic-regression) |
| Survival analysis: Kaplan-Meier, Cox regression, proportional-hazards checks, parametric models | [`survival-analysis`](survival-analysis) |
| Hypothesis testing and ANOVA | [`group-comparisons`](group-comparisons) |
| Analysing a published randomised trial | [`clinical-trial-bells`](clinical-trial-bells) |
| Data cleaning, reporting and reproducible workflows in R Markdown | [`data-cleaning-and-visualisation`](data-cleaning-and-visualisation) |
| The same analysis in R, Stata and SPSS | [`linear-regression`](linear-regression), [`survival-analysis`](survival-analysis), [`group-comparisons`](group-comparisons) |

## Layout

Every project folder uses the same layout, one sub-folder per tool:

```
<project>/
  r/        scripts/     outputs/
  stata/    do-files/    (do-files, logs and PDF/text exports of the logs)
  spss/     spss-files/  (syntax and .spv output)
data/
  raw/      original datasets
  processed/  files created by scripts
```

Only the tools used in a project are present. Outputs are PDFs where possible, because GitHub shows PDFs but not rendered HTML. SPSS `.spv` files open only in SPSS. Stata `.smcl` logs open in Stata.

## Running the code

- **R:** open any script. Paths use `here::here()` and the `.here` file in the repository root, so no `setwd()` is needed. Required packages are loaded at the top of each script. Package versions: [`r-session-info.txt`](r-session-info.txt).
- **Stata:** set the global `repo` to the folder containing this repository (first lines of each do-file).
- **SPSS:** edit the `CD` line at the top of the syntax so it points to this repository.

## Software and testing

 R 4.5.3, Stata 17 (MP) and IBM SPSS Statistics 27 on Windows 11. 
## Data

See [`data/README.md`](data/README.md) for sources. Course datasets belong to their owners and are shared only to make the coursework reproducible. No patient-identifiable data and no data from my own research projects is included.

## Licence

Code is released under the MIT licence (see [LICENSE](LICENSE)). The licence does not cover the datasets.
