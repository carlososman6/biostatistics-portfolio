# Data cleaning and visualisation

**Status:** self-study.

| Analysis | Question / task | Methods | Tools | Code | Output |
|---|---|---|---|---|---|
| Cleaning a raw medical dataset | Clean a messy public dataset (Kaggle) and explore it afterwards | Data cleaning with `janitor` and `dplyr`; descriptive tables; exploratory analysis | R | [cleaning](r/scripts/cleaning-medical-data.Rmd), [exploration](r/scripts/exploratory-analysis-after-cleaning.Rmd) | [Cleaning report (PDF)](r/outputs/cleaning-medical-data.pdf) |
| TidyTuesday: scurvy | Weekly TidyTuesday challenge (week 30, 2023): James Lind's scurvy trial data | `tidyverse`; tables and plots | R | [Quarto](r/scripts/tidytuesday-scurvy.qmd), [script](r/scripts/tidytuesday-2023-07-25.R) | [PDF](r/outputs/tidytuesday-scurvy.pdf) |

The Kaggle dataset is in [`data/raw/realworld_medical_dirty.csv`](../data/raw/realworld_medical_dirty.csv); the cleaned version is in [`data/processed`](../data/processed).
