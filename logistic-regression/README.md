# Logistic regression

**Status:** coursework, MSc Clinical Epidemiology and Biostatistics (MCEB), Makerere University, 2025/26. Datasets are in [`data/raw`](../data/raw); see [`data/README.md`](../data/README.md).

| Analysis | Question / task | Methods | Tools | Code | Output |
|---|---|---|---|---|---|
| Death among babies (binary outcome `died`) | Which platelet, birth, delivery and clinical factors are associated with death? | Binary logistic regression (`logit`, `logistic`); race recoded in several ways (white vs other, black vs other); variable-type, collinearity and outlier checks | Stata | [baby outcomes](stata/do-files/baby-outcomes-assignment-2.do), [discussion version](stata/do-files/logistic-discussion.do), [full workflow](stata/do-files/logistic-regression.do) | [Stata log (PDF)](stata/do-files/baby-outcomes-assignment-2.pdf) |
| Cholesterol category (ordinal outcome) | Which factors are associated with cholesterol category: sex, blood pressure, age, BMI? | Ordinal logistic regression (`ologit`); collinearity check; interaction terms | Stata | [do-file](stata/do-files/cholesterol-part-2.do) | [Stata log (PDF)](stata/do-files/cholesterol-part-2.pdf) |
| Hypertension and salt intake | Association between salt intake and hypertension | `glm`, chi-square test, risk ratio (`epitools`), `gtsummary` | R | [R script](r/scripts/hypertension-salt.R) | None yet; the dataset is not in the repo |
