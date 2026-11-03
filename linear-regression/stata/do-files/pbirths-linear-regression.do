* Set once: the folder that contains this repository, using forward slashes (e.g. C:/Users/you/biostatistics-portfolio)
if "$repo" == "" global repo "REPLACE-WITH-PATH/biostatistics-portfolio"
log using "pbirths", replace

*****BUILDING A LINEAR REGRESION MODEL
**** First import dataset
import excel "$repo/data/raw/pbirths.xls", sheet("Sheet1") firstrow

***STEP 1
*Fit multilinear model on which assumptions will be tested;
**********talk about existence of relationships by looking at the R-squared and the significance of the F-statistic
regress grams black educ gestate smoke


***STEP 2
*Correlation matrix to check for Existance(E) of possible relationships
***********when you run this, dont bother looking at the coeffiecients of the grams(outcome) with categorical predictors variables, as they will be low, look at those with numerical predictors; Is there atleast one predictor variable with correlation coefficient  of 0.3 and above? 
correlate black educ gestate smoke  grams


***DETOUR
**suppose you were building simple LRM

regress grams gestate
 
***we can use, scatter plot to assess for linearity
***or we can use a LOWESS smother, LOWESS line, or superimpose line of best fit


**this gives a scatter plot
twoway (scatter grams gestate) 

***this gives lowess smother
twoway (scatter grams gestate) (lowess grams gestate)

***this adds line of best fit to the lowess smother
twoway (scatter grams gestate) (lowess grams gestate) (lfit grams gestate) 

*FIT MODEL
regress grams black educ gestate smoke


****CHECK FOR LINEARITY IN MLRM USING cpr(component plus redual) plot
**will check for each variable; you select only the independent variable; as the dependent is already selected in the model

**is linear for black
cprplot black 

**is linear for educ
cprplot educ

**is linear for smoke
cprplot smoke

**is linear for gestate
cprplot gestate

***NOTE; when assumption of linearity is violated with curvatures, add a quadratic term and check if it improves the linearity. Common quadratic terms are squared and cubed e.g gestate-squared or gestate cubed 
*HOWEVER- PRINCIPLE - DO NOT RUN A MODEL WITH HIGHER ORDER TERMS e.g. SQUAREDs, CUBED, interaction terms when the basic variable is not there(SO MAKE SURE TO INCLUDE THE INITIAL VARIABLE)
 
**if a variable violates linearity and quadratic terms do not improve the linearity, try to categorize that predictor and see if it improves; ie try and categorize at the point where linearity starts to be violated

**CHECKING FOR INDEPENDNCE(I)
*In STATA can use rvpplots i.e. residuals versus predictor plots
*- should not have clear pattern

*- Got through regression diagnostics after fitting model
**NB; MAKE SURE TO ADD REFERENCE LINE AT Y=0

rvpplot black, yline(0)

rvpplot educ, yline(0)
*showed some slight pattern

rvpplot smoke, yline(0)

rvpplot gestate, yline(0)
**above; plots points contrate towards the right because most pregnancies are delivered towards term; so thats where birthweight will because

*CHECK Normality of residuals
*-Checked from regression standardized residuals
*-Predict the residuals since assumption is that for each X they are normally distributed
*-PROCEDURE; Statistics > postestimation > specify what you want to predict- THIS CREATES A NEW VARIABLE FOR THE RESIDUALS; WHICH WILL THEN BE USED FOR THE PLOTS 
*- Check Normal Q-Q or P-P plots
*- Or use kernel densities, box plots, etc

predict residuals, residuals
*creates the residuals variable

*can use any of the following
kdensity residuals, normal
* 1. kerenel density plot ; make sure to add normal plot as well

pnorm residuals
*2. Normal Q-Q Plot

*can also use
swilk residuals
*3. shapiro wilk test to check for normality; 

*Ho. Residuals are normally distributed
*Ha. Residuals are not normally distributed

*Non-significant p-value indicates that we fail to reject the null hypothesis hence assumption is fulfilled

*CHECK FOR EQUAL VARIANCE-HOMOSCEDACITY; these tests check for Heteroscedasticity, can be; 
*(i) Visual checks ; rvf and rvp plots
*(ii)Statistical tests; Breusch-Pagan / Cook-Weisberg test(estat hettest)

*VISUAL CHECKS
*(a)RVP
*want to see a rectangular distribution this time;
rvpplot black, yline(0)

rvpplot educ, yline(0)
*this not good enough to assess for equal variance as it appears slightly funnel shaped;

rvpplot educ, addplot((lfit residuals educ)) yline(0)
*This is better;RVP plot with an overlaid linear fit line (lfit) and a zero-reference line  is generated ;to check if the vertical spread of residuals remains consistent and rectangular across all levels of education.

rvpplot educ, addplot((lfit residuals educ)) yline(0)
*For educ can also use lowess smother

rvpplot smoke, yline(0)

rvpplot gestate, yline(0)
*same issue here as educ; not really ideal as it appears funnel shaped

rvpplot gestate, addplot((lowess residuals gestate)) yline(0)
*lowess smother and fit line both added which is more helpful; shows its linear


*(b) RVF
*An Rvf plot is also used to assess for equal variance
*Since its residual vs fitted,First predict the fitted values(create new variable for fitted values:linear)
predict fitted, xb

rvfplot, ytitle(0)
rvfplot, addplot((lfit residuals fitted)) ytitle(0)

*STATISTICAL TESTS; for equal ; Breusch-Pagan / Cook-Weisberg test(estat hettest)
*can check for the fitted 
estat hettest

*or one variable at a time; especially those you are suspicious about
estat hettest black
estat hettest educ
estat hettest smoke
estat hettest gestate

*or even all
*the p value is not significant for all the above
 
**ALL THE ASSUMPTIONS ARE NOW FULFILLED

*TWO OTHER THINGS TO CHECK FOR BEFORE ANALYSIS;
*Collinearity/Multilinearity
*Outliers

*CHECK FOR COLLINEARITY;
*-correlations matrix; can eye ball(however cant drop variables because of this )
correlate black educ smoke gestate grams

*-Variance Inflation Factor(VIF); should not be > 10
*Tolerance(1/VIF); should not be > 0.1

estat vif
*no VIF > 10
*NB; If there is a variable that has VIF higher than 10, determine which variable it has a strong relationship with(using correlation matrix). Remove the variable which has high VIF and the other variable it has a strong relationship with  will be the proxy variable.

*CHECK FOR OUTLIERS
*Regression is very sensitive to outliers. These outliers pull the regression coefficients towards themselves. Check to see how much influence does each subject have on the regression coefficients

*-dfbetas;quantify how much @ of the coefficients would change if @ observation were omitted from the data set
*-SHOULD NOT > 0.5
*- done per variable

predict dfbetablack, dfbeta(black)
predict dfbetaeduc, dfbeta(educ)
predict dfbetasmoke, dfbeta(smoke)
predict dfbetagestate, dfbeta(gestate)

*HAVE TO CHECK THE ABSOLUTE VALUE OF MIN AND MAX (after summarising ) TO MAKE SURE ITS NOT > 0.5

sum dfbetablack
sum dfbetaeduc
sum dfbetasmoke
sum dfbetagestate

*Cooks distance(Cooks'D); not greater than 1
*get it by predicting(creates new variable) and summarise that variables
predict cooksd, cooksd
*creates column cooksd

summarize cooksd
*summarises column cooksd; look at max value; should not be greater than 1 (if below 1 = no outliers)

*also can use leverage: but this is too stringent


*ALL ASSUMPTIONS FULFILLED

* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* WHICH VARIABLES TO INCLUDE IN MULTIVARIABLE ANALYSIS?
* ----------------------------------------------------------
* Ideal: include ALL variables studied (here: gestational age,
*   maternal smoking, education level, race).
* Rule: ~40 subjects per variable must be met.
*   If not, screen variables using univariable analysis first:
*   run each variable alone against birthweight; record its p-value.
*
* Cut-off for selecting variables to carry forward:
*   - Default:       p < 0.2
*   - Small sample:  relax to p < 0.3  (cast a wider net)
*   - Large sample:  tighten to p < 0.1 (be more selective)
*
* Override allowed: keep a variable regardless of p-value if it is
*   consistently established in the literature as an important predictor.
*
* Why p < 0.2 and not p < 0.05?
*   Some variables look non-significant alone but become important
*   confounders in the full model — especially NEGATIVE confounders
*   (variables that suppress an association; a strict cut-off would
*   drop them and introduce bias).

* SAMPLE SIZE RULES FOR NUMBER OF VARIABLES ALLOWED IN MODEL
* ----------------------------------------------------------
*   i)   40 subjects per variable  (most commonly used); we shall use this
*   ii)  100 subjects per variable (conservative)
*   iii) (8 × number of variables) + 40
*   iv)  10 subjects per variable- MINIMUM

* CHECKING FOR INTERACTION
*-----------------------------------------------------------------------------------------------------------------------------------------------------------

* --- SCENARIO A: you HAVE a main exposure ---
* (e.g. main exposure = maternal smoking → outcome = birthweight)
*
*   Ideal: make an interaction term between the main exposure
*     and EVERY other variable in the model.
*   If sample size does not allow this:
*     → prioritise variables that were significant in the model;
*       make interaction terms between those and the main exposure only.
*
* --- SCENARIO B: you DO NOT have a main exposure ---
* (our model: gestational age, smoking, education, race — all equal)
*
*   Ideal: make ALL possible pairwise interaction terms.
*   If sample size does not allow this, two options:
*     i)  Find significant variables; make interaction terms between
*           each significant variable and all other variables.
*     ii) Make interaction terms between ONLY the significant variables.

*Write equations with all the predictors and interaction terms;

*Y = alpha + b1black + b2educ + b3smoke + b4gestate + sig1blackeduc + sig2blacksmoke + sig3blackgest + sig4educsmoke + sig5educgest + sig6smokegest

*Above equation contains all the predictors(4) and possible all possible interaction terms(6); makes 10 total variables; therefore need 400 observations for analysis

*We have to generate all the variables(new columns) with those interaction terms;

gen blackeduc = black*educ
gen blacksmoke = black*smoke
gen blackgestate = black*gestate
gen educsmoke = educ*smoke
gen educgestate = educ*gestate
gen smokegestate = smoke*gestate

*Now we use, backward to remove non-significant terms; all the basic variables are added to term1; then all the interaction terms are added to terms 2,3,4...
*Avoid using forward as you may end up remove negative confounders leading to a biased model
stepwise, pr(0.05) lockterm1 : regress grams black educ smoke gestate blackeduc blacksmoke blackgestate educsmoke educgestate smokegestate

*If you want to use stepwise; click both forward and backward boxes in stata; but the backward box(probability f) should have higher p value

*in the above command; educ is removed and yet black*educ was included(which is a higher order term; THIS IS NOT ALLOWED); to correct this we add parentheses() on the basic variables in term 1 ; this asks  stata to consider variables in the parentheses as one and drop all if non-significant
stepwise, pr(0.05) lockterm1 : regress grams (black educ smoke gestate) blackeduc blacksmoke blackgestate educsmoke educgestate smokegestate

*From the above command ; you can see that the non-significant interaction terms were removed and only the significant ones will be kept going forward
*In backward; stata runs the model with all the variables included; and then after removes the least significant; and then reruns the model and the removes the least significant; and so and so on



*new equation;
*ŷ = −2594.9 + (−666.3)black + (−9.3)educ + (−334.7)smoke + (157.3)gestate + (35.7)blackeduc + (251.1)blacksmoke

*INTERPRETATION
* 1. Always check Prob>F first — if not significant, the whole model is useless, stop there
* 2. R-squared tells you how much of the outcome your model explains — higher is better
* 3. P-value tells you if a variable is significant — want p<0.05
* 4. Coefficient sign (+ or -) tells you the direction of the effect on the outcome
* 5. Coefficient size tells you the real-world magnitude of the effect in outcome units
* 6. t-statistic = coefficient divided by standard error — high t means strong signal, low t means noise: term with highest t is the strongest predictor

*------------------------------------------------------------------------------------------------------------------------------------------------------------

*Suppose you had a main exposure?

*QN; Does smoking have an influence on birthweight?

*- Interaction

*1) You can form all possible interaction terms with the main exposure if the sample size allows(40 subjects per variable)
*2) If the sample size is not sufficient, form interaction terms with the significant variables and the main exposure

*NOTE; The main exposure has to remain in the analysis regardless of its significance

*always write out model first;

*Y = alpha + b1smoke + b2black + b3educ + b4gestate + sig1smokeblack + sig2smokeeduc + sig3smokegest 

* as you can see above; the model we are about to do a backward assessment on includes all the basic variables and all the interaction terms with the main predictor/exposure

*command becomes to do backward is now ;

stepwise, pr(0.05) : regress grams black educ smoke gestate blacksmoke educsmoke smokegestate
*this becomes our model to check for interaction; as you can see all the nonsignificant variables are dropped; dont mind about educ this time as no higher order terms of educ remained in the model

*-----------------------------------------------------------------------------------------------------------------------------------------------------------


*CHECKING FOR CONFOUNDING

*- Check the variables that have been dropped if they are confounders or not. If they are confounders they are returned to the model and from part of the crude model
*- We check them in the order in which they were dropped
*- variables that  interact(those that form significant interaction terms eg blacksmoke; so that means black wont be checked for confounding as it interacts ) ; are not assessed for confounding
*- When we do not have a main predictor look at the effect on all variables that were left significant in the model
*- with main exposure, check for effect on main exposure


*Check for confounding will begin for when there is a main predictor/exposure;
*Since we have main exposure, we check for effect of variables removed from the model first. The last one to be dropped is checked first. If it changes the regression coefficient by significant magnitude (i.e 10% and above, then it is a confounder)

*first disable non-significant variables and interaction terms after checking for interaction(model from line 313);remove; educ, educsmoke, and smokegestate; and then run to get initial crude model; 

*the initial crude model; 
regress grams black  smoke gestate blacksmoke

*Now we need if educ(last variable to be dropped )is a cofounder
*Bring it back into the model 
regress grams black educ smoke gestate blacksmoke

*Since smoke is our main exposure; we shall look at the changes in the coefficient of smoke ; without educ(crude) and with educ*gestate

regress grams black smoke gestate blacksmoke
*without educ=-319.665

regress grams black educ smoke gestate blacksmoke
*with educ = -307.3471

*Percentage change; = 3.85%

*EDUCATION IS NOT A CONFOUNDER; DONT NEED TO INCLUDE IT IN THE MODEL

*Now we check gestate; so we take it out (becomes our crude)  and compare it to when gestate is present in model(coefficients for smoke)

regress grams black smoke blacksmoke
*without gestate= -387.7827

regress grams black smoke gestate blacksmoke
*with gestate = -319.665

*Percentage change; = 17.6%

*GESTATE IS A CONFOUNDER; dont remove from model but make sure to report on it
*------------------------------------------------------------------------------------------------------------------------------------------------------------

*Final Model
*After completing interaction and confounding checks, the final model is:

regress grams black smoke gestate blacksmoke
*----------------------------------------------------------------------------------------------------------------

*Standardized Beta Coefficients

*Used to compare the relative importance / strength of different predictors in the same model. Raw coefficients cannot be compared because they depend on units of measurement.

*•	Standardized betas are dimensionless — units of measurement are removed
*•	Range from −1 to +1, like a correlation coefficient
*•	The variable with the largest magnitude (ignoring sign) is the strongest predictor
*•	Sign tells you direction (positive or negative relationship) — not importance
*•	Can be obtained regardless of whether interaction is present in the model


* In Stata: Statistics > Linear models > Reporting > tick 'Standardized beta coefficients'
* Or add 'beta' option to regress command:

regress grams black smoke gestate blacksmoke, beta

*gestate had the largest standardized beta → strongest predictor of birthweight

*R-squared and the Multiple Correlation Coefficient;
*•	R-squared: proportion of variation in the outcome (birthweight) explained by all predictors together
*•	Adjusted R-squared: use this as the population estimate — it penalizes for number of predictors
*•	Square root of R-squared: gives the multiple correlation coefficient — the correlation between observed birthweight and the birthweight predicted by the model

*the constant( _cons); the value of the outcome Y;  which is birthweight in grams in this model; when the predictors are all at 0


*CHECK BOOK FOR INTERPRETATION

*When we have variables that are categorical with more than 2 levels we need indicate them as such in the analysis
*now lets generate new variables gestcat and educcat where we create categories with more than 2 levels

*Generating gestcat variable with 3 levels
gen gestcat=gestate
recode gestcat min/27=1 28/35=2 36/max=3
label define gestcat 1"less than 28 weeks" 2"28 weeks to 35 weeks" 3"36 weeks and above"
label values gestcat gestcat


*Generating educcat with 4 levels
gen educcat=educ
recode educcat min/7=1 8/11=2 12/13=3 14/max=4
label define educcat 1"Upto 7 years" 2"8 to 11 years" 3"12 to 13 years" 4" 14 years and above"
label values educcat educcat

*to tell stata that this is a categorical vraiable; add prefix i. before the variable name; eg i.gestcat; this tells stata its a categorical variable and stata automatically creates dummy variables; NOTE; stata automatically uses the lowest level amongst the categories as the constant(_cons) to which other higher levels are compared; if you want to compare to a specific level,maybe level 3 as the baseline; then you do ib3.gestcat

regress grams gestcat
*notice how it doesnt treat it as actegorical variable but rather a continous variable using the underlying levels

regress grams i.gestcat
*notice how stata recognises that its a categorical variable and  compares it to the lowest level(1)

regress grams ib3.gestcat
*this uses level 3 as the baseline

*if you want to store dummy variables ; use xi: before the command

xi: regress grams i.gestcat
**look in variable window; the dummy variables have been stored

*END*











log close

translate pbirths.smcl pbirths.pdf, replace

