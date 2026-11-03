# Group comparisons and hypothesis tests

**Status:** coursework, MSc Clinical Epidemiology and Biostatistics (MCEB), Makerere University, 2025/26. Datasets are in [`data/raw`](../data/raw); see [`data/README.md`](../data/README.md).

| Analysis | Question / task | Methods | Tools | Code | Output |
|---|---|---|---|---|---|
| Weight gain by contraceptive | Does weight gain differ between contraceptive groups? | One-way ANOVA with descriptives, homogeneity of variance and means plot | SPSS, R | [SPSS syntax](spss/spss-files/contraceptives-one-way-anova.sps), [R Markdown](r/scripts/contraceptives-anova.Rmd) | [SPSS output (PDF)](spss/spss-files/contraceptives-one-way-anova.pdf); [R report (PDF)](r/outputs/contraceptives-anova.pdf) |
| Depression dataset | Data inspection and cleaning (duplicates, missing values, miscoded categories), then a general linear model | `GLM`, `EXAMINE`, `FREQUENCIES` | SPSS | [GLM](spss/spss-files/depress-glm.sps), [descriptives](spss/spss-files/depress-descriptives.sps) | [GLM output (PDF)](spss/spss-files/depress-glm.pdf), [descriptives output (PDF)](spss/spss-files/depress-descriptives.pdf); SPSS `.spv`: [depress](spss/spss-files/depress-glm.spv) |
| Height and weight | t-tests, correlation and charts | `T-TEST`, `CORRELATIONS`, `EXAMINE`; replicated in R | SPSS, R | [SPSS syntax](spss/spss-files/hwg-ttest-correlation.sps), [R script](r/scripts/hwg-replication.R) | [SPSS output (PDF)](spss/spss-files/hwg-ttest-correlation.pdf) |
| Hypothesis testing practice | Worked examples of t-tests | `t.test` | R | [R script](r/scripts/hypothesis-testing.R) | None yet |
