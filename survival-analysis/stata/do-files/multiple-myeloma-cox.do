* Set once: the folder that contains this repository, using forward slashes (e.g. C:/Users/you/biostatistics-portfolio)
if "$repo" == "" global repo "REPLACE-WITH-PATH/biostatistics-portfolio"
log using "multiplemyeloma", replace




*CHECK FOR PH ASSUMPTIONS
***Load Data
use "$repo/data/raw/multiple myeloma.dta", clear


*Declare survival data
stset time, failure(event==1) 

*Fit model
stcox age sex bun ca hb pc bj



**GRAPHICAL CHECKS

**Log-log Survival Curve vs TIME
stphplot, by(sex) nolntime
*PH assumption is VIOLATED for sex based on this log-log vs time plot because the lines cross.

stphplot, by(bj) nolntime
*PH assumption is VIOLATED for bj based on this log-log vs time plot because the lines cross.


**Log-log Survival Curve vs log time
stphplot, by(sex)
*PH assumption is not VIOLATED for sex based on this log-log vs log-log time plot because the curves are roughly linear.

stphplot, by(bj)
*PH assumption is not VIOLATED for bj based on this log-log vs log-log time plot because the curves are roughly linear.


**Expected vs Observed Survival Curves

*observed v expected for sex
stcoxkm, by(sex)
****** PH assumption not violated on this plot due to the fact that the observed vs expected curves are close for both sexes


*observed v expected for bj
stcoxkm, by(bj)
****** PH assumption not violated on this plot due to the fact that the observed vs expected curves are close for both sexes


**Schoenfeld Residuals Plot

estat phtest, plot(age) yline(0)
**the smoothed line is roughly horizontal meaning HR is constatnt overtime and PH assumption fulfilled

estat phtest, plot(sex) yline(0)
**the smoothed line is roughly horizontal meaning HR is constatnt overtime and PH assumption fulfilled

estat phtest, plot(bun) yline(0)
**the smoothed line is roughly horizontal meaning HR is constatnt overtime and PH assumption fulfilled

estat phtest, plot(ca) yline(0)
**the smoothed line is roughly horizontal meaning HR is constatnt overtime and PH assumption fulfilled


estat phtest, plot(hb) yline(0)
**the smoothed line is roughly horizontal meaning HR is constatnt overtime and PH assumption fulfilled


estat phtest, plot(pc) yline(0)
**the smoothed line not perfectly horizontal and will be need to be checked

estat phtest, plot(bj) yline(0)
**the smoothed line is roughly horizontal meaning HR is constatnt overtime and PH assumption fulfilled


*STATISTICAL TEST

***Schoenfeld Residuals Formal Test


estat phtest, detail
***No variable shows pvalue < 0.05; PH assumption is fulfilled



*Extended Cox Model using TIME
stcox age sex bun ca hb pc bj, tvc(age sex bun ca hb pc bj) texp(_t) nohr

**All variables have p > 0.05 therefore PH assumption is fulfilled for ALL variables according to the extended Cox model using time


**SELECTING VARIABLES
*your supposed to keep dropping the most non significant variables?????????


*UNIVARIATE ANALYSIS(drop > 0.2)


stcox age
**Look at the p value of LR pvalue; in this case age is above 0.2(0.7263) so we drop it


stcox sex
**dropped

stcox bun
**keep

stcox ca
*Drop

stcox hb
*keep

stcox pc
*drop

stcox bj
* keep



*CONCLUSION- Use bun hb and bj


* Check functional form of covariates
*Predict martingale residuals from the null model
*plot residuals againts each covariates
*a linear plot implies that linear form of covariate is appropriate


*run null model
stcox, estimate

*predict residuals
predict mgalnull, mgale


*Plot residuals against covariates
twoway (scatter mgalnull bun) (lowess mgalnull bun)


gen buncat20=bun

recode buncat20 min/20=1 21/max=2


stcox bun

estimates store bun

stcox buncat20

estimates store buncat20


estimates stats bun buncat20


*quadratic covariates
gen bunsqrd=bun*bun
gen buncubed=bun^3
stcox bun bunsqrd
estimates store bunsqrd
stcox bun buncubed
estimates store buncubed
lrtest bun bunsqrd, stats
lrtest bun buncubed, stats



**bun is better handles as numeric

*hb; repeat process as above(here categories are 3 levels)
* NOTE: the commands that create hbcat10 (categorised haemoglobin) are not in this file, so the code from here on stops with "variable hbcat10 not found" until that step is added.
*


*conclusion; hbcat10 is the best functional form for hb; BUT CHECK THE QUADRATIC FIRST



*CHECK FOR INTERACTION
*bun, hbcat10, bj
*w ecant form all possible interaction terms because of small sample size; therefore we shall choose what variables form int terms by stepwise; signfircat level for removal= 0.05; MAKE SURE TO USE LIKELIHOOD RATIO


**ONLY bun and hbcat 10 are allowed to form interaction terms

*run reduced model first(no interaction terms)
stcox bun hbcat10 bj 

*then store estimates

*then run full model with interaction terms

stcox bun hbcat10 bj c.bun#i.hbcat10

*store estimates

*THEN COMPARE LR test for full and reduced


*Full mode is worse; so no interaction



































log close