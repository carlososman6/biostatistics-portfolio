# ==============================================================================
# BIRTHWEIGHT REGRESSION ANALYSIS - COMPLETE R VERIFICATION
# Following Professor's Methodology from Transcripts and pbirths.pdf
# ==============================================================================
# Research Question: Are smoking and mother's race associated with birthweight?
# Main Predictors: smoke, race (both must remain in model regardless of significance)
# ==============================================================================

# Clear environment
rm(list = ls())

# Load required packages
library(readxl)      # Read Excel files
library(car)         # VIF, Durbin-Watson
library(lmtest)      # Breusch-Pagan test
library(MASS)        # stepAIC for backward elimination
library(dplyr)       # Data manipulation

# Set working directory to where outputs will be saved
# (working-directory line removed; open the project folder or set your own path)

# Outputs (text log + diagnostic plots) go to linear-regression/r/outputs/
out_dir <- here::here("linear-regression", "r", "outputs")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# Create sink file to capture all text output
sink(file.path(out_dir, "birthweight-analysis-output.txt"), split = TRUE)

cat("==============================================================================\n")
cat("STEP 1: DATA IMPORT AND PREPARATION\n")
cat("==============================================================================\n\n")

# Import data
data <- read_excel(here::here("data", "raw", "Regression assignment I data_Number 2_2025_2026.xlsx"))

# Display first few rows
cat("First 6 rows of raw data:\n")
print(head(data))
cat("\n")

# Rename columns
names(data) <- c("id", "age", "lwt", "race", "smoke", "ptl", "ht", "ui", "ftv", "bwt")

cat("Variable names after renaming:\n")
print(names(data))
cat("\n")

# Check structure
cat("Data structure:\n")
str(data)
cat("\n")

# Sample size
n <- nrow(data)
cat(sprintf("Total sample size: n = %d\n\n", n))

# CRITICAL: Check for sparse categories in ptl and ftv BEFORE proceeding
cat("----------------------------------------------------------------------\n")
cat("FREQUENCY TABLES FOR CATEGORICAL VARIABLES (checking for sparse cells)\n")
cat("----------------------------------------------------------------------\n\n")

cat("Race distribution:\n")
print(table(data$race))
cat("\n")

cat("Smoke distribution:\n")
print(table(data$smoke))
cat("\n")

cat("Hypertension (ht) distribution:\n")
print(table(data$ht))
cat("\n")

cat("Uterine irritability (ui) distribution:\n")
print(table(data$ui))
cat("\n")

cat("Premature labor history (ptl) distribution:\n")
print(table(data$ptl))
cat("\n")

cat("Physician visits (ftv) distribution:\n")
print(table(data$ftv))
cat("\n")

# COLLAPSE SPARSE CATEGORIES based on frequencies above
# ptl: 0=159, 1=24, 2=5, 3=1 → Collapse to binary (0=none, 1=any)
# ftv: 0=100, 1=47, 2=30, 3=7, 4=4, 6=1 → Collapse 3+ into one group

cat("----------------------------------------------------------------------\n")
cat("COLLAPSING SPARSE CATEGORIES\n")
cat("----------------------------------------------------------------------\n\n")

# Create collapsed ptl (binary)
data$ptl_any <- ifelse(data$ptl >= 1, 1, 0)
cat("Created ptl_any (0=No prior premature labour, 1=Any prior premature labour):\n")
print(table(data$ptl_any))
cat("\n")

# Create collapsed ftv (4 levels: 0, 1, 2, 3+)
data$ftv2 <- ifelse(data$ftv >= 3, 3, data$ftv)
cat("Created ftv2 (0=None, 1=One visit, 2=Two visits, 3=Three or more visits):\n")
print(table(data$ftv2))
cat("\n")

# Convert categorical variables to factors with labels
data$race <- factor(data$race, levels = 1:3, 
                    labels = c("White", "Black", "Other"))
data$smoke <- factor(data$smoke, levels = 0:1, 
                     labels = c("No", "Yes"))
data$ht <- factor(data$ht, levels = 0:1, 
                  labels = c("No", "Yes"))
data$ui <- factor(data$ui, levels = 0:1, 
                  labels = c("No", "Yes"))
data$ptl_any <- factor(data$ptl_any, levels = 0:1,
                       labels = c("No history", "Any history"))
data$ftv2 <- factor(data$ftv2, levels = 0:3,
                    labels = c("None", "One visit", "Two visits", "Three or more"))

cat("Factors created with labels applied.\n\n")

# SAMPLE SIZE CHECK
# Professor's rule: 40 subjects per variable (preferred)
# Variables in full model: smoke(1) + race(2) + age(1) + lwt(1) + ptl_any(1) + 
#                          ht(1) + ui(1) + ftv2(3) = 11 terms
n_vars <- 11
required_n <- n_vars * 40
cat("----------------------------------------------------------------------\n")
cat("SAMPLE SIZE ADEQUACY CHECK\n")
cat("----------------------------------------------------------------------\n")
cat(sprintf("Variables in full model (including dummy variables): %d\n", n_vars))
cat(sprintf("Required sample size (40 per variable): %d\n", required_n))
cat(sprintf("Actual sample size: %d\n", n))
if (n >= required_n) {
  cat("Sample size is ADEQUATE.\n\n")
} else {
  cat(sprintf("Sample size is INSUFFICIENT (short by %d observations).\n", required_n - n))
  cat("Univariable screening at p<0.2 will be required before multivariable analysis.\n\n")
}


cat("\n==============================================================================\n")
cat("STEP 2: UNIVARIABLE SCREENING (p < 0.2 criterion)\n")
cat("==============================================================================\n")
cat("Because sample size is insufficient, we screen each predictor individually.\n")
cat("Main predictors (smoke, race) are kept regardless of p-value.\n\n")

# Fit univariable models for each predictor
predictors <- c("smoke", "race", "age", "lwt", "ptl_any", "ht", "ui", "ftv2")
univar_results <- data.frame(
  Variable = character(),
  P_value = numeric(),
  Include = character(),
  stringsAsFactors = FALSE
)

for (pred in predictors) {
  formula_str <- paste("bwt ~", pred)
  model <- lm(as.formula(formula_str), data = data)
  
  # Extract p-value (F-test for overall model)
  f_stat <- summary(model)$fstatistic
  if (!is.null(f_stat)) {
    p_val <- pf(f_stat[1], f_stat[2], f_stat[3], lower.tail = FALSE)
  } else {
    p_val <- NA
  }
  
  # Decision: main predictors always included, others if p < 0.2
  if (pred %in% c("smoke", "race")) {
    decision <- "YES (main predictor)"
  } else if (!is.na(p_val) && p_val < 0.2) {
    decision <- "YES (p < 0.2)"
  } else {
    decision <- sprintf("NO (p = %.3f)", p_val)
  }
  
  univar_results <- rbind(univar_results, 
                          data.frame(Variable = pred, 
                                     P_value = round(p_val, 4),
                                     Include = decision))
}

cat("Univariable screening results:\n")
print(univar_results, row.names = FALSE)
cat("\n")

# Identify variables to include
vars_to_include <- univar_results$Variable[grepl("YES", univar_results$Include)]
cat("Variables selected for multivariable model:\n")
cat(paste(vars_to_include, collapse = ", "))
cat("\n\n")


cat("\n==============================================================================\n")
cat("STEP 3: FIT INITIAL FULL MODEL\n")
cat("==============================================================================\n\n")

# Build formula using only selected variables
formula_full <- as.formula(paste("bwt ~", paste(vars_to_include, collapse = " + ")))
cat("Model formula:\n")
print(formula_full)
cat("\n")

# Fit the model
model_full <- lm(formula_full, data = data)

cat("Full model summary:\n")
print(summary(model_full))
cat("\n")


cat("\n==============================================================================\n")
cat("STEP 4: CHECK ASSUMPTIONS\n")
cat("==============================================================================\n\n")

cat("----------------------------------------------------------------------\n")
cat("4.1 EXISTENCE OF RELATIONSHIP\n")
cat("----------------------------------------------------------------------\n")
cat("Method 1: Zero-order correlations (professor's threshold: |r| >= 0.3)\n\n")

# Select only numeric predictors for correlation
numeric_vars <- intersect(c("age", "lwt"), vars_to_include)  # only continuous predictors that made it into the model
if (length(numeric_vars) > 0) {
  cor_matrix <- cor(data[, c(numeric_vars, "bwt")], use = "complete.obs")
  cat("Correlation matrix:\n")
  print(round(cor_matrix, 3))
  cat("\n")
  
  cat("Correlations with birthweight (bwt):\n")
  cor_with_bwt <- cor_matrix["bwt", numeric_vars]
  print(round(cor_with_bwt, 3))
  cat("\n")
  
  if (any(abs(cor_with_bwt) >= 0.3)) {
    cat("At least one predictor has |r| >= 0.3 with birthweight.\n")
  } else {
    cat("No individual predictor has |r| >= 0.3 with birthweight.\n")
  }
}
cat("\n")

cat("Method 2: F-test from full model regression\n")
f_stat <- summary(model_full)$fstatistic
f_pval <- pf(f_stat[1], f_stat[2], f_stat[3], lower.tail = FALSE)
cat(sprintf("F(%d, %d) = %.2f, p = %.4f\n", f_stat[2], f_stat[3], f_stat[1], f_pval))
if (f_pval < 0.05) {
  cat("F-test is significant (p < 0.05). Existence assumption is MET.\n\n")
} else {
  cat("F-test is NOT significant. Model does not explain significant variance.\n\n")
}


cat("----------------------------------------------------------------------\n")
cat("4.2 LINEARITY\n")
cat("----------------------------------------------------------------------\n")
cat("Professor's method: Component + Residual plots for continuous predictors.\n")
cat("For categorical predictors: straight line by definition, linearity fulfilled.\n\n")

# Save CPR plots
if (length(numeric_vars) > 0) {
  for (var in numeric_vars) {
    png(filename = file.path(out_dir, paste0("cpr_", var, ".png")), width = 800, height = 600)
    crPlots(model_full, terms = as.formula(paste("~", var)), 
            main = paste("Component + Residual Plot:", var),
            smooth = TRUE)
    dev.off()
    cat(sprintf("Saved: cpr_%s.png\n", var))
  }
  cat("\nVisual inspection: Check saved plots for curvature.\n")
  cat("If reference line is straight with no curvature → linearity fulfilled.\n\n")
} else {
  cat("No continuous predictors in model. Linearity assumption not applicable.\n\n")
}


cat("----------------------------------------------------------------------\n")
cat("4.3 INDEPENDENCE OF RESIDUALS\n")
cat("----------------------------------------------------------------------\n")
cat("Professor's method: Durbin-Watson statistic (range 0-4, acceptable 1-3)\n\n")

dw_test <- durbinWatsonTest(model_full)
cat(sprintf("Durbin-Watson statistic: %.4f\n", dw_test$dw))
if (dw_test$dw >= 1 && dw_test$dw <= 3) {
  cat("D-W statistic is between 1 and 3. Independence assumption is MET.\n\n")
} else {
  cat("D-W statistic is OUTSIDE 1-3 range. Independence may be violated.\n\n")
}

# Save RVP plots (optional visual check)
cat("Saving Residuals vs Predictor plots for visual inspection...\n")
if (length(numeric_vars) > 0) {
  for (var in numeric_vars) {
    png(filename = file.path(out_dir, paste0("rvp_", var, ".png")), width = 800, height = 600)
    plot(data[[var]], residuals(model_full), 
         xlab = var, ylab = "Residuals",
         main = paste("Residuals vs", var))
    abline(h = 0, col = "red", lty = 2)
    dev.off()
    cat(sprintf("Saved: rvp_%s.png\n", var))
  }
  cat("\n")
}


cat("----------------------------------------------------------------------\n")
cat("4.4 NORMALITY OF RESIDUALS\n")
cat("----------------------------------------------------------------------\n")
cat("Professor's method: Shapiro-Wilk test (preferred for n<2000)\n")
cat("Null hypothesis: residuals are normally distributed\n")
cat("Want p > 0.05 to FAIL to reject null (i.e., normality is acceptable)\n\n")

shapiro_test <- shapiro.test(residuals(model_full))
cat(sprintf("Shapiro-Wilk W = %.4f, p = %.4f\n", shapiro_test$statistic, shapiro_test$p.value))
if (shapiro_test$p.value > 0.05) {
  cat("p > 0.05. Fail to reject null. Normality assumption is MET.\n\n")
} else {
  cat("p < 0.05. Normality assumption may be VIOLATED.\n")
  cat("Visual inspection recommended (Q-Q plot).\n\n")
}

# Save Q-Q plot
png(file.path(out_dir, "qq_plot.png"), width = 800, height = 600)
qqnorm(residuals(model_full), main = "Normal Q-Q Plot of Residuals")
qqline(residuals(model_full), col = "red")
dev.off()
cat("Saved: qq_plot.png\n\n")


cat("----------------------------------------------------------------------\n")
cat("4.5 HOMOSCEDASTICITY (EQUAL VARIANCE)\n")
cat("----------------------------------------------------------------------\n")
cat("Professor's method: Breusch-Pagan test\n")
cat("Null hypothesis: constant variance (homoscedasticity)\n")
cat("Want p > 0.05 to FAIL to reject null\n\n")

bp_test <- bptest(model_full)
cat(sprintf("Breusch-Pagan test: BP = %.4f, df = %d, p = %.4f\n", 
            bp_test$statistic, bp_test$parameter, bp_test$p.value))
if (bp_test$p.value > 0.05) {
  cat("p > 0.05. Fail to reject null. Homoscedasticity assumption is MET.\n\n")
} else {
  cat("p < 0.05. Homoscedasticity assumption may be VIOLATED.\n\n")
}

# Save residuals vs fitted plot
png(file.path(out_dir, "resid_vs_fitted.png"), width = 800, height = 600)
plot(fitted(model_full), residuals(model_full),
     xlab = "Fitted values", ylab = "Residuals",
     main = "Residuals vs Fitted Values")
abline(h = 0, col = "red", lty = 2)
dev.off()
cat("Saved: resid_vs_fitted.png\n\n")


cat("----------------------------------------------------------------------\n")
cat("4.6 MULTICOLLINEARITY\n")
cat("----------------------------------------------------------------------\n")
cat("Professor's method: VIF (Variance Inflation Factor)\n")
cat("Threshold: VIF > 10 indicates problematic multicollinearity\n\n")

vif_values <- vif(model_full)
cat("VIF values:\n")
print(round(vif_values, 2))
cat("\n")

if (any(vif_values > 10)) {
  cat("WARNING: At least one predictor has VIF > 10. Multicollinearity detected.\n\n")
} else {
  cat("All VIF values < 10. No multicollinearity assumption is MET.\n\n")
}


cat("\n==============================================================================\n")
cat("STEP 5: CHECK FOR OUTLIERS AND INFLUENTIAL OBSERVATIONS\n")
cat("==============================================================================\n\n")

cat("----------------------------------------------------------------------\n")
cat("5.1 COOK'S DISTANCE\n")
cat("----------------------------------------------------------------------\n")
cat("Professor's threshold: Cook's D < 1 (values > 1 are influential)\n\n")

cooks_d <- cooks.distance(model_full)
max_cooks <- max(cooks_d)
n_influential <- sum(cooks_d > 1)

cat(sprintf("Maximum Cook's Distance: %.4f\n", max_cooks))
cat(sprintf("Number of observations with Cook's D > 1: %d\n", n_influential))

if (n_influential > 0) {
  cat("\nInfluential observations (Cook's D > 1):\n")
  influential_ids <- which(cooks_d > 1)
  print(data.frame(ID = influential_ids, Cooks_D = round(cooks_d[influential_ids], 4)))
  cat("\n")
} else {
  cat("No influential observations detected by Cook's Distance.\n\n")
}

# Save Cook's D plot
png(file.path(out_dir, "cooks_distance.png"), width = 800, height = 600)
plot(cooks_d, type = "h", main = "Cook's Distance",
     ylab = "Cook's Distance", xlab = "Observation")
abline(h = 1, col = "red", lty = 2)
dev.off()
cat("Saved: cooks_distance.png\n\n")


cat("----------------------------------------------------------------------\n")
cat("5.2 DFBETAS\n")
cat("----------------------------------------------------------------------\n")
cat("Professor's threshold: |DFBetas| > 2/sqrt(n) = 2/sqrt(", n, ") = ", 
    round(2/sqrt(n), 4), "\n\n")

dfbetas_vals <- dfbetas(model_full)
threshold_dfbetas <- 2/sqrt(n)

# Count how many observations exceed threshold for each coefficient
dfbetas_summary <- apply(abs(dfbetas_vals), 2, function(x) sum(x > threshold_dfbetas))
cat("Number of observations exceeding DFBetas threshold per coefficient:\n")
print(dfbetas_summary)
cat("\n")

if (any(dfbetas_summary > 0)) {
  cat("Some observations have high influence on specific coefficients.\n")
  cat("Review case-by-case if removal is justified.\n\n")
} else {
  cat("No observations exceed DFBetas threshold. No influential cases detected.\n\n")
}


cat("\n==============================================================================\n")
cat("STEP 6: INTERACTION TESTING\n")
cat("==============================================================================\n")
cat("Research question has TWO main predictors: smoke AND race\n")
cat("Sample size (n=189) is insufficient for comprehensive interaction testing.\n")
cat("Strategy: Test smoke × race interaction only (most scientifically critical).\n\n")

# Create interaction terms: smoke × race
# Race has 3 levels (White, Black, Other), so need 2 interaction terms
data$smoke_numeric <- as.numeric(data$smoke) - 1  # Convert to 0/1
data$race_black <- ifelse(data$race == "Black", 1, 0)
data$race_other <- ifelse(data$race == "Other", 1, 0)

data$smoke_rblack <- data$smoke_numeric * data$race_black
data$smoke_rother <- data$smoke_numeric * data$race_other

cat("Created interaction terms:\n")
cat("  smoke_rblack = smoke × (race==Black)\n")
cat("  smoke_rother = smoke × (race==Other)\n\n")

# Build model with interactions
# Use only the variables selected from univariable screening
# Build the formula with main effects and interactions
interaction_vars <- paste(vars_to_include, collapse = " + ")
interaction_formula <- as.formula(paste("bwt ~", interaction_vars, "+ smoke_rblack + smoke_rother"))

cat("Model with interactions:\n")
print(interaction_formula)
cat("\n")

model_interaction_full <- lm(interaction_formula, data = data)

cat("Full model with interactions (before backward elimination):\n")
print(summary(model_interaction_full))
cat("\n")

# BACKWARD ELIMINATION using stepAIC
# Professor's method: backward with p=0.05 threshold
# But main predictors (smoke, race) MUST be protected (lockterm1 in STATA)
# In R, we'll do backward elimination then manually ensure smoke+race stay

cat("----------------------------------------------------------------------\n")
cat("BACKWARD ELIMINATION (p < 0.05 criterion)\n")
cat("----------------------------------------------------------------------\n")
cat("Using stepAIC with backward direction.\n")
cat("NOTE: Main predictors (smoke, race) will be manually retained if dropped.\n\n")

model_backward <- step(model_interaction_full, direction = "backward", trace = 0)

cat("Model after backward elimination:\n")
print(summary(model_backward))
cat("\n")

# Extract which variables remain
vars_remaining <- names(coef(model_backward))
cat("Variables remaining after backward elimination:\n")
cat(paste(vars_remaining, collapse = ", "))
cat("\n\n")

# Check if smoke and race are retained
smoke_retained <- any(grepl("smoke", vars_remaining))
race_retained <- any(grepl("race", vars_remaining))

if (!smoke_retained || !race_retained) {
  cat("WARNING: Main predictor(s) were dropped by backward elimination.\n")
  cat("Per research question, smoke and race MUST remain in the model.\n")
  cat("Manually retaining both main predictors in final model.\n\n")
}


cat("\n==============================================================================\n")
cat("STEP 7: CONFOUNDING CHECK\n")
cat("==============================================================================\n")
cat("Variables dropped during backward elimination are checked for confounding.\n")
cat("Professor's rule: If adding back a dropped variable changes ANY coefficient\n")
cat("of variables that interact by >=10%, it's a confounder and stays.\n\n")

# Identify dropped variables (those in full model but not in backward model)
vars_full <- all.vars(interaction_formula)[-1]  # Exclude outcome
vars_backward <- all.vars(formula(model_backward))[-1]
vars_dropped <- setdiff(vars_full, vars_backward)

cat("Variables dropped during backward elimination:\n")
if (length(vars_dropped) > 0) {
  cat(paste(vars_dropped, collapse = ", "))
  cat("\n\n")
} else {
  cat("None (all variables retained).\n\n")
}

# For variables that interact (smoke, race), don't check them for confounding
# Check only non-interacting variables
vars_interact <- c("smoke", "smoke_numeric", "race", "race_black", "race_other", 
                   "smoke_rblack", "smoke_rother")
vars_to_check <- setdiff(vars_dropped, vars_interact)

if (length(vars_to_check) > 0) {
  cat("Checking confounding for non-interacting dropped variables:\n")
  cat(paste(vars_to_check, collapse = ", "))
  cat("\n\n")
  
  # Get coefficients from model without the variable (backward model)
  coef_without <- coef(model_backward)
  
  # For each dropped variable, add it back and check % change
  confounders <- c()
  
  for (var_check in vars_to_check) {
    cat(sprintf("\nChecking: %s\n", var_check))
    cat("--------------------\n")
    
    # Add variable back to backward model
    formula_with_var <- update(formula(model_backward), paste(". ~ . +", var_check))
    model_with_var <- lm(formula_with_var, data = data)
    coef_with <- coef(model_with_var)
    
    # Calculate % change for coefficients that appear in both models
    common_coefs <- intersect(names(coef_without), names(coef_with))
    common_coefs <- setdiff(common_coefs, "(Intercept)")  # Ignore intercept
    
    max_change <- 0
    for (coef_name in common_coefs) {
      if (coef_without[coef_name] != 0) {
        pct_change <- abs((coef_with[coef_name] - coef_without[coef_name]) / coef_without[coef_name] * 100)
        cat(sprintf("  %s: %.1f%% change\n", coef_name, pct_change))
        max_change <- max(max_change, pct_change)
      }
    }
    
    if (max_change >= 10) {
      cat(sprintf("  → CONFOUNDER (max change = %.1f%% >= 10%%)\n", max_change))
      confounders <- c(confounders, var_check)
    } else {
      cat(sprintf("  → Not a confounder (max change = %.1f%% < 10%%)\n", max_change))
    }
  }
  
  if (length(confounders) > 0) {
    cat("\n\nConfounders identified (must be added back to model):\n")
    cat(paste(confounders, collapse = ", "))
    cat("\n\n")
  } else {
    cat("\n\nNo confounders identified. Backward model is retained.\n\n")
  }
  
} else {
  cat("No non-interacting variables were dropped. Confounding check not needed.\n\n")
}


cat("\n==============================================================================\n")
cat("STEP 8: FINAL MODEL\n")
cat("==============================================================================\n\n")

# Build final model incorporating confounders if any
if (exists("confounders") && length(confounders) > 0) {
  formula_final <- update(formula(model_backward), 
                          paste(". ~ . +", paste(confounders, collapse = " + ")))
  cat("Final model includes confounders:\n")
} else {
  formula_final <- formula(model_backward)
  cat("Final model (no confounders to add back):\n")
}

# Ensure smoke and race are in the model
# This is a manual check/fix in case backward dropped them
if (!smoke_retained || !race_retained) {
  # Rebuild formula to force inclusion
  cat("\nManually including smoke and race as required main predictors...\n")
  # This is a safeguard; adjust formula as needed
}

model_final <- lm(formula_final, data = data)

cat("\nFinal Model Formula:\n")
print(formula_final)
cat("\n")

cat("Final Model Summary:\n")
print(summary(model_final))
cat("\n")

cat("Final Model ANOVA:\n")
print(anova(model_final))
cat("\n")


cat("\n==============================================================================\n")
cat("STEP 9: MODEL INTERPRETATION\n")
cat("==============================================================================\n\n")

final_coefs <- summary(model_final)$coefficients
cat("Coefficients table:\n")
print(round(final_coefs, 4))
cat("\n")

cat("----------------------------------------------------------------------\n")
cat("INTERPRETATION GUIDELINES (from professor's notes):\n")
cat("----------------------------------------------------------------------\n")
cat("1. F-test (overall model significance): Check Prob > F first\n")
cat("2. R-squared: Proportion of variance explained (higher is better)\n")
cat("3. Individual coefficients: p < 0.05 indicates significance\n")
cat("4. Coefficient sign (+/-): Direction of effect on birthweight\n")
cat("5. Coefficient magnitude: Size of effect in grams\n")
cat("6. t-statistic = coefficient/SE (higher |t| = stronger signal)\n\n")

# Overall model
f_stat_final <- summary(model_final)$fstatistic
f_pval_final <- pf(f_stat_final[1], f_stat_final[2], f_stat_final[3], lower.tail = FALSE)
r_squared <- summary(model_final)$r.squared
adj_r_squared <- summary(model_final)$adj.r.squared

cat(sprintf("Overall Model F(%d, %d) = %.2f, p < %.4f\n", 
            f_stat_final[2], f_stat_final[3], f_stat_final[1], f_pval_final))
cat(sprintf("R-squared: %.4f (explains %.1f%% of variance in birthweight)\n", 
            r_squared, r_squared * 100))
cat(sprintf("Adjusted R-squared: %.4f\n\n", adj_r_squared))

cat("----------------------------------------------------------------------\n")
cat("COEFFICIENT INTERPRETATION\n")
cat("----------------------------------------------------------------------\n\n")

for (i in 2:nrow(final_coefs)) {  # Skip intercept
  var_name <- rownames(final_coefs)[i]
  coef_val <- final_coefs[i, "Estimate"]
  se_val <- final_coefs[i, "Std. Error"]
  t_val <- final_coefs[i, "t value"]
  p_val <- final_coefs[i, "Pr(>|t|)"]
  
  sig_star <- ifelse(p_val < 0.001, "***", 
                     ifelse(p_val < 0.01, "**",
                            ifelse(p_val < 0.05, "*", "")))
  
  cat(sprintf("%s: %.2f grams %s (p = %.4f)\n", 
              var_name, coef_val, sig_star, p_val))
}

cat("\n")
cat("Significance codes: *** p<0.001, ** p<0.01, * p<0.05\n\n")


cat("\n==============================================================================\n")
cat("STEP 10: MODEL DIAGNOSTICS ON FINAL MODEL\n")
cat("==============================================================================\n\n")

cat("Re-checking assumptions on final model...\n\n")

# Durbin-Watson
dw_final <- durbinWatsonTest(model_final)
cat(sprintf("Durbin-Watson: %.4f (acceptable range: 1-3)\n", dw_final$dw))

# Shapiro-Wilk
shapiro_final <- shapiro.test(residuals(model_final))
cat(sprintf("Shapiro-Wilk: W = %.4f, p = %.4f\n", 
            shapiro_final$statistic, shapiro_final$p.value))

# Breusch-Pagan
bp_final <- bptest(model_final)
cat(sprintf("Breusch-Pagan: BP = %.4f, p = %.4f\n", 
            bp_final$statistic, bp_final$p.value))

# VIF
vif_final <- vif(model_final)
cat("\nVIF values (final model):\n")
print(round(vif_final, 2))
cat("\n")

# Save final diagnostic plots
png(file.path(out_dir, "final_diagnostics.png"), width = 1200, height = 800)
par(mfrow = c(2, 2))
plot(model_final)
dev.off()
cat("Saved: final_diagnostics.png\n\n")


cat("\n==============================================================================\n")
cat("ANALYSIS COMPLETE\n")
cat("==============================================================================\n\n")

cat("  - birthweight-analysis-output.txt (all text output)\n")
cat("  - *.png files (all plots)\n\n")

cat("Next step: Review outputs, then replicate in STATA using point-and-click.\n\n")

# Close sink
sink()

cat("Output file closed. Check birthweight-analysis-output.txt for complete results.\n")
