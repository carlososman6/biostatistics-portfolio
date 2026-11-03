* Set once: the folder that contains this repository, using forward slashes (e.g. C:/Users/you/biostatistics-portfolio)
if "$repo" == "" global repo "REPLACE-WITH-PATH/biostatistics-portfolio"
log using "assignment 2_Number one baby outcomes", replace

*import data
import excel "$repo/data/raw/assignment 2_Number one_2025_2026_revised.xls", sheet("Sheet1") firstrow

*inspect data
bro


*RENAME VARIABLES

rename Column3  platelet
rename Column4  race
rename Column5  birthwt
rename Column6  gestage
rename Column7  placedev
rename Column8  multpreg
rename Column9  betamet
rename Column10 tocolys
rename Column11 modedev
rename Column12 apgar1
rename Column13 ventil
rename Column14 pneumo
rename Column15 pda
rename Column16 sexbaby
rename Column17 died

 *LABEL VARIABLES

label variable platelet  "Platelet count"
label variable race      "Race of mother (1=white,2=black,3=native American,4=oriental)"
label variable birthwt   "Birth weight of baby (grams)"
label variable gestage   "Gestation age"
label variable placedev  "Place of delivery (1=this hospital,2=elsewhere)"
label variable multpreg  "Multiple pregnancy (1=yes,0=no)"
label variable betamet   "Mother treated with betamethasone (1=yes,0=no)"
label variable tocolys   "Tocolysis (1=yes,0=no)"
label variable modedev   "Mode of delivery (1=abdominal,2=vaginal)"
label variable apgar1    "Apgar score at 1 minute"
label variable ventil    "Assisted ventilation used (1=yes,0=no)"
label variable pneumo    "Pneumothorax occurred (1=yes,0=no)"
label variable pda       "Patent ductus arteriosus occurred (1=yes,0=no)"
label variable sexbaby   "Sex of baby (1=female,2=male)"
label variable died      "Baby died (1=yes,0=no)"

*DATA INSPECTION

bro

* Continuous variables
summarize platelet birthwt gestage apgar1

* Categorical variables
tab race
tab placedev
tab multpreg
tab betamet
tab tocolys
tab modedev
tab ventil
tab pneumo
tab pda
tab sexbaby
tab died

* Missing values
misstable summarize platelet race birthwt gestage placedev multpreg betamet tocolys modedev apgar1 ventil pneumo pda sexbaby died

* The outcome variable (died) has no missing values - all 669 observations are available for the outcome

* PRE-ANALYSIS DECISION I: WHICH RACE CODING IS BEST?
* The question asks us to compare 4 ways of coding race.
* Since these 4 models are non-nested, we compare using AIC and BIC.
* The model with the smallest BIC is preferred.

* Generate the 3 alternative race codings

* Option ii: White (0) vs All other races (1)
gen race_white_other = 0 if race == 1
replace race_white_other = 1 if race == 2 | race == 3 | race == 4
label variable race_white_other "Race: White(0) vs Other races(1)"

* Option iii: White (1) vs Black (2) vs Other races (3)
gen race_white_black_other = 1 if race == 1
replace race_white_black_other = 2 if race == 2
replace race_white_black_other = 3 if race == 3 | race == 4
label variable race_white_black_other "Race: White(1) vs Black(2) vs Other(3)"

* Option iv: Black (1) vs All other races (0)
gen race_black_other = 0 if race == 1 | race == 3 | race == 4
replace race_black_other = 1 if race == 2
label variable race_black_other "Race: Non-black(0) vs Black(1)"

* Verify all three were generated correctly
tab race_white_other
tab race_white_black_other
tab race_black_other

* Fit all 4 models using the full set of predictors - only race coding changes
* Option i: Race as it is (4 categories)
logit died i.race platelet birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby
estimates store race_4cat

* Option ii: White vs Other races
logit died i.race_white_other platelet birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby
estimates store race_2cat_white

* Option iii: White vs Black vs Other
logit died i.race_white_black_other platelet birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby
estimates store race_3cat

* Option iv: Black vs Rest
logit died i.race_black_other platelet birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby
estimates store race_2cat_black

* Compare all four models - smaller AIC and BIC indicate better fit
estimates stats race_4cat race_2cat_white race_3cat race_2cat_black

* Both AIC and BIC agreed that option (ii) - White vs Other races - provided
* the best fit. race_white_other will be used in all subsequent analysis.

* PRE-ANALYSIS DECISION II: BIRTHWEIGHT - CONTINUOUS OR CATEGORICAL?
* The question asks whether birthweight is better analyzed as continuous
* or categorized into <1000g vs >=1000g. AIC and BIC are used to compare.

* Generate categorical birthweight variable
gen birthwt_cat = 1 if birthwt >= 1000
replace birthwt_cat = 0 if birthwt < 1000
label variable birthwt_cat "Birthweight: below 1000g(0) vs 1000g and above(1)"

* Model with birthweight as continuous
logit died i.race_white_other platelet birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby
estimates store bwt_continuous

* Model with birthweight as categorical
logit died i.race_white_other platelet i.birthwt_cat gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby
estimates store bwt_categorical

* Compare the two models
estimates stats bwt_continuous bwt_categorical

* Both AIC and BIC agreed that birthweight is better analyzed as a continuous
* (numerical) variable. Birthweight will be kept as continuous going forward.

*CHECK FOR COLLINEARITY
* VIF cannot be run directly after logistic regression. We first predict the
* logit (the linear predictor), then run a linear regression using the logit
* as the outcome, and compute VIF from that linear model.

* Fit the full logistic model with finalised variable codings
logit died i.race_white_other platelet birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby

* Predict the logit (linear prediction)
predict Logit, xb

* Run linear regression with logit as outcome to allow VIF computation
regress Logit race_white_other platelet birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby

* Compute VIF - values >10 indicate collinearity
estat vif

* No VIF exceeded 10 - no multicollinearity detected between predictors.

* STEP 2: CHECK FOR OUTLIERS
* We assess overall influence using Dbeta (cutoff: max < 1) and
* leverage (cutoff: max < 0.5) after the logistic model.

* Re-fit the logistic model
logit died i.race_white_other platelet birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby

* Overall influence (Dbeta) - max should not exceed 1
predict dbeta, dbeta

* Leverage - values should not exceed 0.5
predict leverage, hat

summarize dbeta leverage

* No outliers detected - Dbeta max < 1 and leverage max < 0.5.


* VARIABLE SELECTION 
* stepwise is used to identify independent predictors of death.

stepwise, pr(0.05): logit died i.race_white_other platelet birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby

* Independent predictors retained: race_white_other, birthwt, gestage,
* ventil, pneumo; these form interaction terms

*ASSESS FOR INTERACTION
* A chunk test is performed by comparing a model with interaction terms
* (full model) against a model without them (reduced model) using the
* likelihood ratio test. A non-significant result means no interaction.

* Reduced model - basic variables only, no interaction terms
logit died i.race_white_other platelet birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby
estimates store reducedmodel

* Full model - basic variables plus plausible interaction terms
* Interaction terms are formed between the key predictors identified
* from clinical relevance and preliminary inspection
logit died i.race_white_other platelet birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby i.pneumo#c.birthwt i.pneumo#c.gestage i.pneumo#i.race_white_other i.pneumo#i.ventil c.birthwt#c.gestage c.birthwt#i.race_white_other c.birthwt#i.ventil c.gestage#i.race_white_other c.gestage#i.ventil i.race_white_other#i.ventil
estimates store fullmodel

* Likelihood ratio test comparing full model (with interaction) to reduced model
* A non-significant p-value means no evidence of interaction - reduced is better
lrtest fullmodel reducedmodel, stats

* The likelihood ratio test was not significant. No interaction was detected.
* The reduced model (without interaction terms) is preferred.



* ASSESS FOR CONFOUNDING
* Variables dropped during stepwise are added back one at a time to check
* whether they confound the relationship between the retained predictors
* and the outcome. A change of 10% or more in any odds ratio indicates
* confounding - that variable is then retained in the final model.

* Base model with independent predictors from stepwise
logit died i.race_white_other birthwt gestage i.ventil i.pneumo, or

* Add betamethasone
logit died i.race_white_other birthwt gestage i.ventil i.pneumo i.betamet, or

* Add multiple pregnancy
logit died i.race_white_other birthwt gestage i.ventil i.pneumo i.multpreg, or

* Add platelet count
logit died i.race_white_other birthwt gestage i.ventil i.pneumo platelet, or

* Add PDA
logit died i.race_white_other birthwt gestage i.ventil i.pneumo i.pda, or

* Add place of delivery
logit died i.race_white_other birthwt gestage i.ventil i.pneumo i.placedev, or

* Add Apgar score
logit died i.race_white_other birthwt gestage i.ventil i.pneumo apgar1, or

* Add tocolysis
logit died i.race_white_other birthwt gestage i.ventil i.pneumo i.tocolys, or

* Add sex of baby
logit died i.race_white_other birthwt gestage i.ventil i.pneumo i.sexbaby, or

* Add mode of delivery
logit died i.race_white_other birthwt gestage i.ventil i.pneumo i.modedev, or

* None of the dropped variables changed any odds ratio by 10% or more.
* No confounding was detected. The final model retains only the independent
* predictors identified from backward LR.

* FINAL MODEL

logit died i.race_white_other birthwt gestage i.ventil i.pneumo
estimates store finalmodel

* Display as odds ratios with 95% confidence intervals
logistic died i.race_white_other birthwt gestage i.ventil i.pneumo

* GOODNESS OF FIT
* The Hosmer-Lemeshow test divides observations into 10 groups by predicted
* probability and compares observed to expected frequencies. A non-significant
* p-value (p>0.05) indicates a good fit.

logistic died i.race_white_other birthwt gestage i.ventil i.pneumo
estat gof, group(10)

* A non-significant Hosmer-Lemeshow test indicates the model fits the data well.




log close
