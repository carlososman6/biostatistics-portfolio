* Set once: the folder that contains this repository, using forward slashes (e.g. C:/Users/you/biostatistics-portfolio)
if "$repo" == "" global repo "REPLACE-WITH-PATH/biostatistics-portfolio"
log using "cholesterol part 2", replace

*import data
import delimited "$repo/data/raw/assignment 2_Number 2_2025_2026.csv", clear

*RENAME COLUMNS
rename column1 sex
rename column2 sbp
rename column3 dbp
rename column4 chol
rename column5 age
rename column8 bmi

label define sexlbl 1 "Male" 2 "Female"
label values sex sexlbl

* Generate ordinal outcome
gen chol_cat = .
replace chol_cat = 0 if chol < 200
replace chol_cat = 1 if chol >= 200 & chol < 240
replace chol_cat = 2 if chol >= 240

label define chollbl 0 "Healthy" 1 "Borderline High" 2 "High"
label values chol_cat chollbl

* Verify
tab chol_cat, missing
summarize sbp dbp age bmi
tab sex


*COLLINEARITY CHECK


* 2a. Fit full model
ologit chol_cat sex sbp dbp age bmi, nolog

* 2b. Predict the linear predictor 

predict logits, xb

* 2c. Run linear regression of logits on predictors
regress logits sex sbp dbp age bmi

estat vif

*No collinearity since no vif >10


*VARIABLE SELECTION 
*since we have large sample size; we form all possible interaction terms


* ASSESS INTERACTION 
*full model;
ologit chol_cat i.sex##c.sbp i.sex##c.dbp i.sex##c.age i.sex##c.bmi c.sbp##c.dbp c.sbp##c.age c.sbp##c.bmi c.dbp##c.age c.dbp##c.bmi c.age##c.bmi, nolog or
estimates store full


*reduced model
ologit chol_cat sex sbp dbp age bmi, nolog
estimates store reduced

*compare
lrtest reduced full, stats

*significant pvalue means presence of interaction

*use step wise to drop nonsignificant terms
sw, pr(0.05) lr: ologit chol_cat sex sbp dbp age bmi i.sex#c.sbp i.sex#c.dbp i.sex#c.age i.sex#c.bmi c.sbp#c.dbp c.sbp#c.age c.sbp#c.bmi c.dbp#c.age c.dbp#c.bmi c.age#c.bmi

*Model with significant interactio terms is
ologit chol_cat i.sex i.sex#c.bmi dbp age bmi c.age#c.bmi  c.dbp#c.age i.sex#c.age, nolog


*ASSESS CONFOUNDING
*bring back dropped variable sbp and check for confounding;
*before sbp
ologit chol_cat i.sex i.sex#c.bmi dbp age bmi c.age#c.bmi  c.dbp#c.age i.sex#c.age, nolog or

*after adding sbp 

ologit chol_cat i.sex i.sex#c.bmi dbp sbp age bmi c.age#c.bmi  c.dbp#c.age i.sex#c.age, nolog or


*sbp is not a confounder;

*MODEL AFTER CONFOUNDING ASSESSMENT
ologit chol_cat i.sex i.sex#c.bmi dbp age bmi c.age#c.bmi  c.dbp#c.age i.sex#c.age, nolog or




*FINAL MODEL AND GOODNESS OF FIT
ologit chol_cat i.sex i.sex#c.bmi dbp age bmi c.age#c.bmi  c.dbp#c.age i.sex#c.age, nolog or


estat ic

estat vce


ologit chol_cat i.sex i.sex#c.bmi dbp age bmi c.age#c.bmi  c.dbp#c.age i.sex#c.age, nolog 


log close