# Data

All datasets used by the scripts. Scripts find them through the repository root (R: `.here` file and `here::here()`; Stata: the `$repo` global; SPSS: `CD`), so they run from any folder once those are set.

## Folders

- `raw/`: original files, unchanged.
- `processed/`: files created by scripts from the raw data.

## Raw data

| File | Used for | Source |
|---|---|---|
| Regression assignment I data_Number 2_2025_2026.xlsx | Linear regression: birthweight | Lecturer, class group email, 18 Apr 2026 |
| Regression assignment I data_Number 3_2025_2026.xlsx | Linear regression: body fat | Lecturer, class group email, 18 Apr 2026 |
| pbirths.xls | Linear regression: pbirths | Class dataset (not found in email) |
| body fat final.sav | Linear regression: body fat (SPSS file; the R script reads it) | SPSS version of the Number 3 data |
| assignment 2_Number one_2025_2026_revised.xls | Logistic regression: death among babies | Lecturer, class group email, 8 May 2026 (revised data) |
| assignment 2_Number 2_2025_2026.csv | Ordinal logistic and Poisson regression | Lecturer, class group email, 27 Apr 2026 |
| survival_assignment_Number_I_2026.xlsx | Survival analysis: assignment 1 | Lecturer, class group email, 22 Sep 2026 |
| survival_assignment_Number_II_2026.xlsx | Survival analysis: assignment 2 | Lecturer, class group email, 22 Sep 2026 |
| multiple myeloma.dta | Survival analysis: multiple myeloma | Class dataset (not found in email) |
| Drug A.dta | Survival analysis: Drug A | Class dataset (not found in email) |
| one_Way_ANOVA classwork_2022.xlsx | Group comparisons: contraceptives ANOVA | Lecturer, class group email, 9 Apr 2026 |
| depress data.sav | Group comparisons: depression dataset | Class dataset (not found in email) |
| hwg.sav | Group comparisons: height and weight | Class dataset (not found in email) |
| bells.csv | Clinical trial: BELLS | Published BELLS trial dataset |
| class_data.xlsx | Practice | Class exercise data (8 records) |
| ITN Access.xlsx | Practice | WHO indicator table used in class |
| Malaria cases, suspected, number.csv | Practice | WHO indicator table used in class |
| MALARIA_TOTAL_CASES.dta | Practice | Class dataset (not found in email) |
| realworld_medical_dirty.csv | Data cleaning | Public Kaggle dataset (link in the script) |

## Processed data

| File | Created by |
|---|---|
| medical_clean.csv | `data-cleaning-and-visualisation/r/scripts/cleaning-medical-data.Rmd` |

## Not included

These files are read by scripts but are not on the author's computer: `hypertension_dataset.csv` (`logistic-regression/r/scripts/hypertension-salt.R`) and `survival_analysis example.xlsx` (the Drug A scripts).

## Rights

Course datasets were supplied by lecturers for teaching and remain the property of their owners. They are shared here only so the coursework can be reproduced. No data from the author's own research projects, and no patient-identifiable data, is included.
