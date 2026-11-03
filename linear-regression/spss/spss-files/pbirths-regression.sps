* Set once: the folder that contains this repository, then run.
CD 'REPLACE-WITH-PATH/biostatistics-portfolio'.
GET DATA
  /TYPE=XLS
  /FILE='data/raw/pbirths.xls'
  /SHEET=name 'Sheet1'
  /READNAMES=on.
DATASET NAME DataSet1 WINDOW=FRONT.
* Encoding: UTF-8.

* STEP 1: FITTING THE MODEL.
* Go to: Analyze > Regression > Linear.
* Move outcome variable to Dependent box.
* Move all predictors to Independent(s) box using Shift-click.
* Leave Method as "Enter" (all variables entered simultaneously).
* -------------------------------------------------------------.

* -------------------------------------------------------------.
* STEP 2: STATISTICS OPTIONS (click "Statistics" button).
* Tick: Durbin-Watson       [tests independence of residuals].
* Tick: Casewise diagnostics [identifies outliers >3 SD].
* Tick: Collinearity diagnostics [gives VIF and Tolerance].
* Tick: Part and partial correlations [zero-order = unadjusted correlations for existence].
* Tick: Confidence intervals if needed for final model reporting.
* -------------------------------------------------------------.

* -------------------------------------------------------------.
* STEP 3: PLOTS OPTIONS (click "Plots" button).
* For LINEARITY and HOMOSCEDASTICITY (same plot tests both).
* Y-axis: ZRESID (standardized residuals).
* X-axis: ZPRED (standardized predicted values).
* This is equivalent to a residuals-vs-fitted plot.
* Tick: Produce all partial regression plots.
* Under "Standardized Residual Plots" tick: Histogram and Normal probability plot.
* These test NORMALITY of residuals.
* -------------------------------------------------------------.
DATASET ACTIVATE DataSet1.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT grams
  /METHOD=ENTER black educ gestate smoke
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

* -------------------------------------------------------------.
* STEP 4: INTERPRETING OUTPUTS.

 * INDEPENDENCE.
* Durbin-Watson statistic(1.915): acceptable range is 1 to 3.
* A value within this range confirms independence of residuals.

* COLLINEARITY.(look at the Coefficients a table; last 2 columns for collinearity statitiscs)
* VIF: no variable should exceed 10.
* Tolerance: no variable should be below 0.1 (Tolerance = 1/VIF in SPSS).
* Condition index and eigenvalues are provided but not routinely interpreted.
* Condition   index >30 is flagged but commonly exceeded, especially with dummy variables.

* EXISTENCE OF RELATIONSHIP.(look at the Coefficients a table; under correlations; specifically zero-order; equivalent of running a correlation matrix)
* Zero-order correlations (unadjusted) should be at least 0.3 for key predictors.
* Can also judge from F-statistic significance in ANOVA table.

* STRENGTH.
* SPSS reports standardized beta coefficients by default.
* The variable with the largest standardized beta has the strongest relationship with the outcome.

* NORMALITY.
* Check the normal PP plot of residuals: points should lie on the diagonal.
* A histogram of standardized residuals should be approximately bell-shaped.


* -------------------------------------------------------------.

* -------------------------------------------------------------.

* STEP 5: SAVING RESIDUALS AND PREDICTED VALUES (click "Save" button).
* Save: Unstandardized predicted values and unstandardized residuals.
* Save: Standardized predicted values and standardized residuals.
* Save: Cook's Distance and Leverage (centered).
* Save: Standardized DFBeta(s).
* Saved variables appear automatically in the data editor.
REGRESSION
  /MISSING LISTWISE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT grams
  /METHOD=ENTER black educ gestate smoke
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /SAVE PRED ZPRED COOK ZRESID DFBETA SDBETA.


* -------------------------------------------------------------.

* -------------------------------------------------------------.

* OUTLIERS.
* Casewise diagnostics lists cases with standardized residuals beyond ±3 SD(it lists the actaul observa tions as case numbers).
* Cook's Distance and Leverage are available in the residual statistics table.(to view these meaningfully we shall get the freq and the min and max checked in the stats)
* Acceptable cutoffs: Cook's Distance <1; Leverage and standardized DFBetas <0.5.


FREQUENCIES VARIABLES=COO_1 SDB0_2 SDB1_2 SDB2_2 SDB3_2 SDB4_2
  /FORMAT=NOTABLE
  /STATISTICS=MINIMUM MAXIMUM
  /ORDER=ANALYSIS.


* STEP 6: MANUAL TEST FOR HOMOSCEDASTICITY (SPSS workaround).
* SPSS has no built-in statistical test for equal variance (unlike Stata) .
* Workaround: run a new regression with saved residuals as outcome.
* and saved predicted values (or original predictors) as the predictor.
* If equal variance holds, there should be NO significant relationship.
* A p-value of ~1.0 (non-significant) confirms homoscedasticity is fulfilled.
* This replicates what Stata does automatically with its residual-vs-fitted test.
* -------------------------------------------------------------.
* ============================================================.
* SPSS LINEAR REGRESSION: MODEL BUILDING (CONTINUED FROM PREVIOUS SESSION).
* ============================================================.

* RECAP: Yesterday we confirmed all assumptions were fulfilled.
* The workflow from here: assumptions → interaction → confounding → final model.

* -------------------------------------------------------------.
* STEP 7: GENERATING INTERACTION TERMS.
* SPSS linear regression CANNOT generate interaction terms automatically.
* (Unlike logistic regression, which can generate them within the dialog box).
* You must create interaction terms manually before running the model.
* Go to: Transform > Compute Variable.
* Multiply the relevant variables together (e.g., black*smoke = blacksmoke).
* Generate all candidate interaction terms this way, one at a time.
* Run all compute statements from the syntax editor at once for efficiency.
* -------------------------------------------------------------.

* -------------------------------------------------------------.
* STEP 8: TESTING FOR INTERACTION — NO MAIN EXPOSURE SCENARIO.
* (Research question: "What factors are associated with birthweight?").

* When there is no designated main exposure:.
* - Form all possible interaction terms between variables if sample size allows.
* - Rule of thumb: need at least 10 observations per variable (including each dummy).
* - Count dummy variables separately; a 3-category variable = 2 variables.
* - If sample size is insufficient, first identify significant factors via stepwise,.
*   then form interaction terms only between those significant factors.

* To run the model: Analyze > Regression > Linear.
* Enter the dependent variable, then all basic (main) variables and interaction terms.
* Set Method to BACKWARD.
* (Backward is preferred because it handles negative confounding better than forward:.
*  starting with all variables together allows masking effects to be detected).
* Default significance level of 5% is acceptable; leave Options as they are.
* Click OK or Paste to Syntax.
* -------------------------------------------------------------.

* -------------------------------------------------------------.
* STEP 9: READING THE BACKWARD ELIMINATION OUTPUT.
* The model summary table shows all steps (models) fitted.
* Each step shows the R-squared, adjusted R-squared, and predictors remaining.
* Focus on the LAST STEP — this is the final interaction model.
* Check which interaction terms have survived.

* CRITICAL RULE: Before accepting a surviving interaction term as valid,.
*   confirm that ALL its component (basic) variables are present in the model.
* If a basic variable was dropped (e.g., education was dropped but black*education survived):.
*   - Force that basic variable back in.
*   - Change Method to ENTER and re-run.
*   - Check whether the interaction term remains significant.
*   - If it loses significance: it was a proxy, not a true interaction — drop it.
*   - If it stays significant: retain both the basic variable and the interaction term.
* -------------------------------------------------------------.

* -------------------------------------------------------------.
* STEP 10: TESTING FOR INTERACTION — WITH A MAIN EXPOSURE.
* (Research question: "Does smoking affect birthweight?").

* When there IS a designated main exposure (e.g., smoking):.
* - Form interaction terms ONLY between the main exposure and all other variables.
* - Basic variables must all remain in the model (you cannot exclude them).
* - This is because higher-order terms (interaction terms) cannot be in a model.
*   without their component basic variables — this is a fundamental modelling rule.
* - Set Method to BACKWARD and run.
* - Focus on the last step to identify which smoke* interaction terms survive.
* - Verify that all basic variables of surviving interaction terms are present.
* -------------------------------------------------------------.

* -------------------------------------------------------------.
* STEP 11: ASSESSING FOR CONFOUNDING.
* Confounding is assessed for the MAIN EXPOSURE only (e.g., smoking coefficient).
* The starting model for confounding assessment includes:.
*   - All basic variables.
*   - Only the significant interaction terms from Step 10.
*   - Variables that held significant interaction terms must remain, even if not significant.

* Procedure (using BACKWARD method):.
* Note which basic variables are dropped by the backward procedure.
* Bring them back one at a time, starting with the LAST variable to be dropped.
* (The last dropped is assessed first; work backwards through the order of dropping).

* For each variable assessed for confounding:.
* Run ENTER method with that variable included.
* Compare the main exposure coefficient (e.g., smoke) to the model without it.
* If the coefficient changes by 10% or more: it IS a confounder — keep it.
*   That model then becomes the reference (crude) model for the next variable.
* If the coefficient changes by less than 10%: it is NOT a confounder — drop it.
*   The previous reference model remains the crude model for the next variable.
* -------------------------------------------------------------.

* -------------------------------------------------------------.
* STEP 12: STRATIFIED ANALYSIS (OPTIONAL BUT RECOMMENDED WITH INTERACTION).
* When a significant interaction term is present, stratified analysis helps.
*   interpret what is actually happening in each group.
* In SPSS, use Data > Select Cases to filter by the stratifying variable.
* Run the regression model separately for each stratum.
* Example: to explore smoking*black interaction,.
*   run one model for non-blacks (black=0) and one for blacks (black=1).
*   Or stratify by smoking status to see the effect of race in each group.
* Stratification is useful for interpretation and reporting of interaction effects.
* It is not required for the Stata analysis but applies equally to both software.
* -------------------------------------------------------------.

* -------------------------------------------------------------.
* STEP 13: FINAL MODEL AND REPORTING.
* The final model contains: significant basic variables + significant interaction terms + confirmed confounders.
* Tick Confidence Intervals under Statistics before the final run.
* Report: regression coefficients, 95% CIs, p-values, R-squared, adjusted R-squared.
* Interpret coefficients as done in the Stata session (previous notes).
* When a basic variable is non-significant but its interaction term is significant:.
*   it means that variable has no effect in the reference group,.
*   but its effect differs significantly in the interacting group — keep it.

* IF AN ASSUMPTION IS VIOLATED:.
* - Normality violation: attempt transformation (e.g., log), then re-check all assumptions.
*   (Transforming for normality can affect homoscedasticity — verify both).
* - If transformation fails: consider a different regression model altogether.
* -------------------------------------------------------------.
