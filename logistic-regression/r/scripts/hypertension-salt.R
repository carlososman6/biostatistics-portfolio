#HYPERTENSION

library(tidyverse)
library(epitools)
library(gtsummary)

htn_salt <- read.csv(here::here("data", "raw", "hypertension_dataset.csv"))

htn2 <- read.csv(here::here("data", "raw", "hypertension_dataset.csv"))

View(htn_salt)

glimpse(htn_salt)

htn_salt$Salt_Intake <- ifelse(htn_salt$Salt_Intake >= 5, "High", "Low")

htn_salt$Has_Hypertension <- as.factor(htn_salt$Has_Hypertension)

htn_salt$Salt_Intake <- as.factor(htn_salt$Salt_Intake)

glimpse(htn_salt)

htn_table <- table(htn_salt$Salt_Intake, htn_salt$Has_Hypertension)

addmargins(htn_table)

chisq.test(htn_table)

htn_salt <- htn_salt %>% 
  mutate(BP_History = as.factor(BP_History), Medication = as.factor(Medication), Family_History = as.factor(Family_History), Exercise_Level = as.factor(Exercise_Level), Smoking_Status = as.factor(Smoking_Status))

htn_salt$Medication <- as.factor(htn_salt$Medication)

riskratio(htn_table)

htn_model <- glm(Has_Hypertension ~ Salt_Intake + Age + Family_History + Exercise_Level + Smoking_Status, 
                 family = "binomial", data = htn_salt)

summary(htn_model)

exp(coef(htn_model))

tbl_regression(htn_model, exponentiate = TRUE)
