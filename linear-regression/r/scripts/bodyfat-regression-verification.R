out_dir <- here::here("linear-regression", "r", "outputs")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
sink(file.path(out_dir, "bodyfat-regression-output.txt"), split = TRUE)


# ============================================================
# BODY FAT REGRESSION - VERIFICATION SCRIPT
# ============================================================


library(car)
library(lmtest)
library(olsrr)
library(dplyr)
library(haven)

# ---- LOAD DATA ----
df <- read_sav(here::here("data", "raw", "body fat final.sav"))

str(df)
summary(df)


# ============================================================
# STEP 1: FULL MODEL (ENTER METHOD)
# ============================================================
m1 <- lm(fat ~ age + weight + height + neck + chest + abdomen + hip +
           thigh + knee + ankle + biceps + forearm + wrist, data = df)
summary(m1)
anova(m1)


# ============================================================
# STEP 2: ASSUMPTIONS
# ============================================================

# 2.1 INDEPENDENCE — Durbin-Watson (acceptable: 1 to 3)
dwtest(m1)

# 2.2 MULTICOLLINEARITY — VIF (<10) and Tolerance (>0.1)
vif(m1)
1 / vif(m1)

# 2.3 EXISTENCE OF RELATIONSHIP — zero-order correlations with fat (>=0.3 for key predictors)
cor(df[, c("fat","age","weight","height","neck","chest","abdomen","hip",
           "thigh","knee","ankle","biceps","forearm","wrist")])[, "fat"]

# 2.4 NORMALITY OF RESIDUALS — visual + formal
hist(rstandard(m1), breaks = 20, main = "Histogram of Std Residuals")
qqnorm(rstandard(m1)); qqline(rstandard(m1))
shapiro.test(residuals(m1))

# 2.5 LINEARITY & HOMOSCEDASTICITY — visual
plot(fitted(m1), rstandard(m1),
     xlab = "ZPRED", ylab = "ZRESID", main = "Residuals vs Fitted")
abline(h = 0, lty = 2)

# 2.5b HOMOSCEDASTICITY — formal (Breusch-Pagan; SPSS workaround = regress resid on pred)
bptest(m1)
# SPSS workaround equivalent:
summary(lm(rstandard(m1) ~ fitted(m1)))


# ============================================================
# STEP 3: OUTLIERS & INFLUENCE
# ============================================================
# Cook's D (<1), Std DFBetas (<0.5), |Std Resid| (<3)
max(cooks.distance(m1))
which(abs(rstandard(m1)) > 3)
apply(abs(dfbetas(m1)), 2, max)


# ============================================================
# STEP 4: STEPWISE TO IDENTIFY SIGNIFICANT BASIC FACTORS
# (Used to shortlist variables for interaction-term formation)
# ============================================================
m_step <- ols_step_both_p(m1, p_enter = 0.05, p_remove = 0.10, details = FALSE)
m_step$model


# ============================================================
# STEP 5: INTERACTION TERMS (BACKWARD)
# Form pair-wise products among significant factors from Step 4
# Then run backward elimination
# NOTE: Update the formula below after seeing Step 4 output
# ============================================================
# Placeholder — assumes abdomen, weight, wrist, forearm are the survivors.
# Adjust based on actual stepwise output:
df <- df %>%
  mutate(abd_wt    = abdomen * weight,
         abd_wrist = abdomen * wrist,
         abd_fore  = abdomen * forearm,
         wt_wrist  = weight  * wrist,
         wt_fore   = weight  * forearm,
         wrist_fore= wrist   * forearm)

m_full <- lm(fat ~ age + weight + height + neck + chest + abdomen + hip +
               thigh + knee + ankle + biceps + forearm + wrist +
               abd_wt + abd_wrist + abd_fore + wt_wrist + wt_fore + wrist_fore,
             data = df)

m_back <- step(m_full, direction = "backward", trace = 1)
summary(m_back)


# ============================================================
# STEP 6: VALIDATE INTERACTION TERMS
# Any surviving interaction must have BOTH basic components in the model.
# If a basic component was dropped, force it back with ENTER and re-check
# significance of the interaction.
# (Manual step — depends on Step 5 output)
# ============================================================


# ============================================================
# STEP 7: FINAL MODEL with 95% CI
# Edit variable list after Step 5/6 confirmation
# ============================================================
# Example placeholder:
# m_final <- lm(fat ~ <final_vars>, data = df)
# summary(m_final)
# confint(m_final)


sink()