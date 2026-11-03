# Survival analysis

**Status:** coursework, MSc Clinical Epidemiology and Biostatistics (MCEB), Makerere University, 2025/26. Datasets are in [`data/raw`](../data/raw); see [`data/README.md`](../data/README.md).

| Analysis | Question / task | Methods | Tools | Code | Output |
|---|---|---|---|---|---|
| Assignment 1 | Time to CHD diagnosis: Cox regression on occupation, height, weight, high energy intake and age | `stset`; Cox model (`stcox`); proportional-hazards checks (`stcoxkm`, `estat phtest`, `stphplot`); parametric models (`streg`) | Stata | [do-file](stata/do-files/assignment-1-cox-and-parametric.do) | [Stata log (text)](stata/do-files/assignment-1-cox-and-parametric-log.txt) |
| Assignment 2 (206 records: 150 deaths, 56 censored) | Cox regression with surgical care and transplant as covariates | Data inspection; Cox regression (`COXREG`) | SPSS | [SPSS syntax](spss/spss-files/assignment-2-cox-regression.sps) | [SPSS output (PDF)](spss/spss-files/assignment-2-cox-regression.pdf); SPSS `.spv` (opens in SPSS only): [output](spss/spss-files/assignment-2-cox-regression.spv) |
| Multiple myeloma | Cox model for survival with age, sex, BUN, calcium, haemoglobin, PC and Bence-Jones protein | Cox regression; graphical and formal proportional-hazards checks | Stata | [do-file](stata/do-files/multiple-myeloma-cox.do) | None yet. The do-file stops at the interaction step because the commands that create `hbcat10` are missing (see the note in the file) |
| Drug A | Kaplan-Meier survival for a single treatment group | Life table and survival curve (`sts list`, `sts graph`); `KM` in SPSS | Stata, SPSS | [do-file](stata/do-files/drug-a-kaplan-meier.do), [SPSS syntax](spss/spss-files/drug-a-kaplan-meier.sps) | [SPSS output (PDF)](spss/spss-files/drug-a-kaplan-meier.pdf); SPSS `.spv`: [Drug A](spss/spss-files/drug-a-kaplan-meier.spv) |
| Survival analysis in R (study notes) | Self-study notes following the public tutorial by Emily C. Zabor, using the `lung` dataset from the `survival` package | Kaplan-Meier curves, log-rank test, Cox regression | R | [R Markdown](r/scripts/survival-analysis-notes.Rmd) | [PDF](r/outputs/survival-analysis-notes.pdf) |
