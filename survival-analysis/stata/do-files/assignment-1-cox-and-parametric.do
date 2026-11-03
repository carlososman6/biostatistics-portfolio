* Set once: the folder that contains this repository, using forward slashes (e.g. C:/Users/you/biostatistics-portfolio)
if "$repo" == "" global repo "REPLACE-WITH-PATH/biostatistics-portfolio"
log using "Number 1", replace

**Import data
import excel "$repo/data/raw/survival_assignment_Number_I_2026.xlsx", sheet("Sheet1") firstrow

* Rename columns 
rename Column1  ptid
rename Column2  occ
rename Column3  survmonth
rename Column4  energy
rename Column5  ht
rename Column6  wt
rename Column7  hienergy
rename Column8  dentry
rename Column9  dexit
rename Column10 dbirth
rename Column11 fail

* Variable labels 
label variable ptid      "Patient ID"
label variable occ       "Occupation (0/1/2)"
label variable survmonth "Survey month"
label variable energy    "Total energy intake (1000 kcal/day)"
label variable ht        "Height (cm)"
label variable wt        "Weight (kg)"
label variable hienergy  "High energy intake indicator"
label variable dentry    "Date of study entry (SAS date)"
label variable dexit     "Date of study exit (SAS date)"
label variable dbirth    "Date of birth (SAS date)"
label variable fail      "Failure indicator (1=CHD diagnosed)"

*Value labels

label define occlab  0 "Occ 0" 1 "Occ 1" 2 "Occ 2"
label values occ occlab

label define hienergylab 0 "Low energy" 1 "High energy"
label values hienergy hienergylab

label define faillab 0 "Censored" 1 "CHD diagnosed"
label values fail faillab

*DATA INSPECTION AND CLEANING
describe

* Check missingness;

mdesc
*variables height has 5 missing values while weight has 4 missing values

*Due to minimal missingness we shall proceed

* Duplicate observations

duplicates report
*no duplicates noted


*Consistency of categorical variables;

tab1 occ hienergy fail
*All the categorical variables have consistent categories


*Generate surival time variables
gen years = (dexit - dentry) / 365.25
gen survtime = years * 12

*Generate participant Age in Years
gen ageyrs = (dentry - dbirth)/365.25

*round up
gen age = ceil(ageyrs)
label variable age "Age in years"
drop ageyrs


*Create bmi variable
gen bmi = wt/((ht/100)^2)
label variable bmi "Body mass index (kg/m2)"

*Plausability of numeric variables;

estpost summarize
*All numeric variables are plausible and fall within expected range


*Check distribution of the numeric variables
histogram survtime, normal
histogram age, normal
histogram ht, normal
histogram wt, normal
histogram bmi, normal
histogram energy, normal

*Height, weight, BMI, and energy intake are approximately normally distributed. Age is left-skewed, concentrated around 45–55 years. Survival time is irregular, with a spike near 190–215 months and another near the maximum, likely reflecting censoring.


*CATEGORIZE THE CONTINOUS VARIABLES FOR LATER CHECKS

*Age(<45, 45-55,>55)
gen agegroups = .
replace agegroups = 1 if age < 45
replace agegroups = 2 if age >= 45 & age <= 55
replace agegroups = 3 if age > 55

tab agegroups

*BMI(<18.5, 18.5-24.9, >= 25)
gen bmicat = .
replace bmicat = 1 if bmi < 18.5
replace bmicat = 2 if bmi >= 18.5 & bmi < 25
replace bmicat = 3 if bmi >= 25

tab bmicat

*Height using median
gen htcat = .
replace htcat = 0 if ht <= 172.9994 
replace htcat = 1 if ht > 172.9994

tab htcat

*Weight using median
gen wtcat = .
replace wtcat = 0 if wt <=  72.8028  
replace wtcat = 1 if wt >  72.8028 

tab wtcat



**TEST ASSUMPTIONS
*Declare survival data
stset survtime, failure(fail)

*Fit model
stcox i.occ ht wt i.hienergy age



*Plots
*loglog survival vs time

*occupation
stphplot, by(occ) nolntime
*The 3 curves appear to overlap and arent parallel; possible PH violation

*hienergy
stphplot, by( hienergy ) nolntime
* the groups dont overlap and appear to be parallel; PH not violated by this plot

*age groups
stphplot, by( agegroups ) nolntime
*The 3 groups appear to overlap around 40 months but age group 1 stays seperate and above the other 2 age groups afterwards. The other two age groups appear to move together but dont overlap; possible PH violation according to this plot

*bmicat
stphplot, by( bmicat ) nolntime
*The normal and overweight group appear to move togerther an not overlap ; however the under weight group appears to overlap with the other two groups at around 90 monhs and 130months ; Possible PH violation; However note that the underweight group had few observations


*height categorical
stphplot, by( htcat ) nolntime
*The two groups dont appeas to overlap at any points ; They initially move together in the first 50months but appear to move parallel after that; PH assumption holds according to this plot

*weight categorical
stphplot, by( wtcat ) nolntime
*Groups dont overlap at any point; PH assumption holds


*loglog survival vs logtime

*occupation
stphplot, by(occ)
*Occupation, log-log vs ln(time): the three curves are approximately linear with mild curvature, so no PH violation is indicated by this plot


**hienergy
stphplot, by( hienergy )
*both curves are approximately linear; no pH violation

**agegroups
stphplot, by( agegroups )
*age groups 2 and 3 are approximately linear; however group 1 is not clearly linear


**bmicat
stphplot, by( bmicat )
*normal and overwight bmi groups are approximately linear ; however the undeweight group isnt linear ; probably due to the few observations

**htcat
stphplot, by( htcat )
*both curves are approximately linear; no ph violation


**wtcat
stphplot, by( wtcat )
*both curves are approximately linear; no ph violation



*Observed vs expected plots;
*occupation
stcoxkm, by(occ)
*the observed and expected for each of the 3 groups appear to move toether; no ph violation

*hienergy
stcoxkm, by( hienergy )
*the observed and expected for each of the 2 groups appear to move toether; no ph violation




*agegroups
stcoxkm, by( agegroups )
*the observed and expected for each of the 3 groups appear to move toether; no ph violation


*bmicat
stcoxkm, by( bmicat )
*normal and overwight observed and expected curves appear to move togtehrr; however ; the observed and expected for the underweigh group dont move closesly; possible ph violation



*htcat
stcoxkm, by( htcat )
*the observed and expected for each of the 2 groups appear to move toether; no ph violation



*wtcat
stcoxkm, by( wtcat )
*the observed and expected for each of the 2 groups appear to move toether; no ph violation




***Schonfeld residuals plots

*Fit model 1 (with ht and wt)
stcox i.occ ht wt energy age

**ocuppation
*1.occ
estat phtest, plot(1.occ) yline(0)
* 1.occ, scaled Schoenfeld residual plot: the smoothed curve is approximately constant over time (small upward drift, well within the spread of the residuals); no clear trend, so this plot gives no evidence against PH for Occ 1. To be confirmed with the Schoenfeld test (estat phtest, detail).

*2.occ
estat phtest, plot(2.occ) yline(0)
**the estimates appear approximately constant over time; hence no evidence of ph violation


**energy 
estat phtest, plot(energy) yline(0)
**the estimates appear approximately constant over time; hence no evidence of ph violation


*age
estat phtest, plot(age) yline(0)
**the estimates appear approximately constant over time; hence no evidence of ph violation

*height
estat phtest, plot( ht ) yline(0)
**the estimates appear approximately constant over time; hence no evidence of ph violation

*weight
estat phtest, plot(wt) yline(0)
**the estimates appear approximately constant over time; hence no evidence of ph violation







*Fit model 2 with bmi 
stcox i.occ bmi energy age

**ocuppation
*1.occ
estat phtest, plot(1.occ) yline(0)
* 1.occ, scaled Schoenfeld residual plot: the smoothed curve is approximately constant over time (small upward drift, well within the spread of the residuals); no clear trend, so this plot gives no evidence against PH for Occ 1. To be confirmed with the Schoenfeld test (estat phtest, detail).

*2.occ
estat phtest, plot(2.occ) yline(0)
**the estimates appear approximately constant over time; hence no evidence of ph violation


**energy categorical
estat phtest, plot(energy) yline(0)
**the estimates appear approximately constant over time; hence no evidence of ph violation


*age
estat phtest, plot(age) yline(0)
**the estimates appear approximately constant over time; hence no evidence of ph violation

*bmi
estat phtest, plot(bmi) yline(0)
**the estimates appear approximately constant over time; hence no evidence of ph violation


*All schonfeld plots show no PH violation


*STATITICAL CHECKS FOR ASSUMPTIONS
*Model 1; no bmi
stcox i.occ ht wt energy age

*test
estat phtest, detail
*Schoenfeld test: no variable (all p > 0.18) or the global model (p = 0.52) violates proportional hazards

*Model 2; with bmi
stcox i.occ bmi energy age

*test
estat phtest, detail
*No PH volation noted here as well

*test using extended cox model
*create dummy variables occupation
gen occ1 = (occ == 1) if !missing(occ)
gen occ2 = (occ == 2) if !missing(occ)

*model 1 with no bmi
stcox occ1 occ2 energy ht wt age, tvc(occ1 occ2 energy ht wt age) texp(_t)

*Conclusion: no tvc term is significant (all p > 0.17), so the extended Cox test gives no evidence of a PH violation for any variable. This agrees with the Schoenfeld test.

*model 2; with bmi
stcox occ1 occ2 energy bmi age, tvc(occ1 occ2 energy bmi age) texp(_t)
*same concluson as in extended model 1



** PH VERDICT: Graphical checks flagged possible violations for occupation, age and underweight BMI (log-log crossings in sparse regions); the Schoenfeld test (all p > 0.18; global p = 0.52) and the extended Cox model (all tvc p > 0.17; 332 subjects, 78 events) found no evidence of violation for any variable. PH is accepted for all variables; no stratification or time-extension is applied. Power is limited by the number of events.

*UNIVARIATE SCREENING
*since sample size is adequate; this step is skipped



*Functional forms
*fit null model
stcox, estimate

*save martingale residuals
predict mgale, mgale

*Plots
*energy
twoway (scatter mgale energy) (lowess mgale energy )

* energy: lowess of martingale residuals declines roughly linearly from 2 to 3.7 (1000 kcal/day), flattening above 3.7 where data are sparse; approximately linear, but to be later compared to other forms


*height
twoway (scatter mgale ht) (lowess mgale ht )
** Height: the lowess line is not linear (nearly flat from about 163 to 176 cm, then falling steeply), so height will be categorized at 178 cm, where the fall begins

*weight
twoway (scatter mgale wt) (lowess mgale wt )
** Weight: the lowess line is not linear (flat at about 50-55 kg, falling from about 57 kg, then flat again above about 73 kg), so weight will be categorized at 60 kg, where the fall starts

*bmi
twoway (scatter mgale bmi) (lowess mgale bmi)
*non linear 

*age
twoway (scatter mgale age) (lowess mgale age)
* Age: the lowess line is close to flat (about -0.07 to +0.06) and rises slowly from about age 40, with the left end based on very few patients; if categorized, age will be split at 45, ignoring the sparse left end


*GENERATE the functional forms

*energy
gen energy2 = energy^2
gen energy3 = energy^3

*height
gen ht2 = ht^2
gen ht3 = ht^3

*ht cat 2 from the mgale residuals plot
gen htcat2 = . 
replace htcat2 = 0 if ht <= 178 
replace htcat2 = 1 if ht > 178
tab htcat2

*weight
gen wt2 = wt^2
gen wt3 = wt^3
*ht cat 2 from the mgale residuals plot
gen wtcat2 = .
replace wtcat2 = 0 if wt <=  60  
replace wtcat2 = 1 if wt >  60 
tab wtcat2


*bmi
gen bmi2 = bmi^2
gen bmi3 = bmi^3

*age
gen age2 = age^2
gen age3 = age^3

*agecat2 from mgale plot
gen agecat = .
replace agecat = 0 if age <=  45  
replace agecat = 1 if age >  45 
tab agecat

*for the missingness
replace htcat  = . if missing(ht)
replace htcat2 = . if missing(ht)
replace wtcat  = . if missing(wt)
replace wtcat2 = . if missing(wt)
replace bmicat = . if missing(bmi)


*COMPARING MODELS
*ENERGY  

stcox i.occ energy ht wt age
estimates store en_num

stcox i.occ i.hienergy ht wt age
estimates store en_cat

stcox i.occ energy2 ht wt age
estimates store en_sqd

stcox i.occ energy3 ht wt age
estimates store en_cub

estimates stats en_num en_cat en_sqd en_cub
*The model with energy as a numeric variable had the lowest aic/bic ; hence energy is better analysed as a numeric variable

*HEIGHT  
stcox i.occ energy ht wt age
estimates store ht_num

stcox i.occ energy i.htcat2 wt age
estimates store ht_cat2

stcox i.occ energy ht2 wt age
estimates store ht_sqd

stcox i.occ energy ht3 wt age
estimates store ht_cub

estimates stats ht_num ht_cat2 ht_sqd ht_cub
*htcat2 has the lowest aic/bic ; hence height is better as htcat2 in the model

*WEIGHT 
stcox i.occ energy i.htcat2 wt age
estimates store wt_num

stcox i.occ energy i.htcat2 i.wtcat2 age
estimates store wt_cat2

stcox i.occ energy i.htcat2 wt2 age
estimates store wt_sqd

stcox i.occ energy i.htcat2 wt3 age
estimates store wt_cub

estimates stats wt_num wt_cat2 wt_sqd wt_cub
*wtcub has the lowest aic/bic ; hence weight is better as wt3 in the model



*BMI  
stcox i.occ energy bmi age
estimates store bmi_num

stcox i.occ energy i.bmicat age
estimates store bmi_cat

stcox i.occ energy bmi2 age
estimates store bmi_sqd

stcox i.occ energy bmi3 age
estimates store bmi_cub

estimates stats bmi_num bmi_cat bmi_sqd bmi_cub
*bmi3 has the lowest aic/bic ; hence bmi is better as bmi3 in the model

*Now to dediced whether to use ht/wt or bmi; we shall compare models oh htcat2 wtcat 2 bmi3

estimates stats ht_cat2 wt_cub bmi_cub 
*the model with htcat2 and wtc_cub had the lowest aic/bic; hence we shall run height as htcat2 and weight as wt3

* AGE  
stcox i.occ energy i.htcat2 wt3 age
estimates store age_num

stcox i.occ energy i.htcat2 wt3 i.agecat
estimates store age_cat

stcox i.occ energy i.htcat2 wt3 age2
estimates store age_sqd

stcox i.occ energy i.htcat2 wt3 age3
estimates store age_cub

estimates stats age_num age_cat age_sqd age_cub
*model with age as numeric appears as the best

*Model with the correct variables
stcox i.occ energy i.htcat2 wt3 age


*INTERACTION

*reduced model
stcox i.occ energy htcat2 wt3 age
*store estimates
estimates store reduced


*Full models
stcox i.occ##c.energy i.htcat2##c.energy c.wt3##c.energy c.age##c.energy
*estimates

estimates store full

*LR test
lrtest ( reduced ) ( full ), stats

*Reduced model is better; so, no evidence of inetarction

*Model after checking for interaction
stcox i.occ energy htcat2 wt3 age


*stepwise estimation to determine order of confounding

stepwise, pr(0.05) lockterm1 lr : stcox energy i.occ htcat2 wt3 age


*Fit crude models
stcox energy htcat2 


*reintroduce age
stcox energy htcat2 age
*percent change = 4.77%; age not confounder

*reintroduced occ

stcox energy htcat2 i.occ
*occupation not a confounder


*reintroduce wt3
stcox energy htcat2 wt3
*weight not confounder

*Final model after confounding
stcox energy htcat2 



*Goodness of fit check
*fit model
stcox energy htcat2 

*predict mgale residuals from final model
predict mgalefinal, mgale

*Predict the Cox-Snell residuals
predict csnellr, csnell


*Reset the survival-time setting
stset csnellr, failure(fail) scale(1)

*Nelson-Aalen cumulative hazard:
sts generate NA_cs = na

*Plot Nelson-Aalen against Cox-Snell
twoway (scatter NA_cs csnellr) (function x)

*The Nelson-Aalen cumulative hazard plotted against the Cox-Snell residuals follows the 45° reference line closely, suggesting the Cox model provides a good fit to the data.


*regress test line
regress NA_cs csnellr

*Cox-Snell residuals were used to assess overall goodness of fit. After resetting the survival-time data to use the Cox-Snell residuals as the time variable, the Nelson-Aalen cumulative hazard was plotted against the Cox-Snell residuals. The points followed the 45° reference line closely. A regression of the Nelson-Aalen cumulative hazard on the Cox-Snell residuals confirmed this: the intercept was not significantly different from zero and the 95% confidence interval for the slope included 1, indicating that the final Cox model fits the data well.

*redeclare survival data
stset survtime, failure(fail) scale(1)


*check for influential observations
*refit model

stcox energy htcat2 


*Predict dfbeta residuals
predict db1 db2, scores
*db1-energy, db2- htcat2

*dbetas plot for energy
twoway (scatter db1 ptid)


*Influential observations were assessed using dfbeta residuals. For total energy intake, one patient (approximately ID 120) had a dfbeta value of approximately 1.5, exceeding the conventional threshold of 1, suggesting this patient exerts undue influence on the energy coefficient. For height category, no patients exceeded the threshold. The influential patient was not removed, as there was no evidence of a data error; however, its presence should be noted as a limitation of the model.


*PARAMETRIC MODELS

stset survtime, id(ptid) failure(fail) scale(1)

*generate the hazard function
sts generate Hazard_ht = h
twoway (lowess Hazard_ht _t)

*USING GRAPHICAL METHODS
sts generate survivor_function = s

*FOR EXPONENTIAL
gen neglogSt = -ln(survivor_function)
twoway (lowess neglogSt survtime) (scatter neglogSt survtime)
regress neglogSt survtime

*WEIBULL
gen logneglogSt = ln(neglogSt)
gen logtime = ln(survtime)
twoway (lowess logneglogSt logtime) (scatter logneglogSt logtime)

*GOMPERTZ
gen loght = ln(Hazard_ht)
twoway (lowess loght survtime) (scatter loght survtime)

*LOG-LOGISTIC MODEL
gen logodds = ln(survivor_function/(1-survivor_function))
twoway (lowess logodds logtime) (scatter logodds logtime)

*COMPARING AIC AND BIC
streg i.occ energy ht wt age, distribution(exponential)
estimates store exponential

streg i.occ energy ht wt age, distribution(weibull)
estimates store weibull

streg i.occ energy ht wt age, distribution(gompertz)
estimates store Gompertz

streg i.occ energy ht wt age, distribution(loglogistic)
estimates store loglogistic

streg i.occ energy ht wt age, distribution(lognormal)
estimates store lognormal

streg i.occ energy ht wt age, distribution(ggamma)
estimates store ggamma

estimates stats exponential weibull Gompertz loglogistic lognormal ggamma

streg i.occ energy ht wt age, distribution(exponential)

*CHECKING FUNCTIONAL FORM

*AGE
tab agecat




streg i.occ energy ht wt age, distribution(exponential)
estimates store AGE_exp

streg i.occ energy ht wt age2, distribution(exponential)
estimates store Agesqd_exp

streg i.occ energy ht wt age3, distribution(exponential)
estimates store agecubed_exp

streg i.occ energy ht wt i.agecat, distribution(exponential)
estimates store ageCat_exp

lrtest (AGE_exp) (Agesqd_exp), stats force
lrtest (AGE_exp) (agecubed_exp), stats force
estimates stats AGE_exp ageCat_exp

*TOTAL ENERGY
streg i.occ energy ht wt age, distribution(exponential)
estimates store energy_exp

streg i.occ i.hienergy ht wt age, distribution(exponential)
estimates store Indicator_exp

estimates stats energy_exp Indicator_exp

*HEIGHT
tab htcat2

streg i.occ energy i.htcat2 wt age, distribution(exponential)
estimates store HeightCat2_exp

streg i.occ energy ht wt age, distribution(exponential)
estimates store Height_exp

streg i.occ energy ht2 wt age, distribution(exponential)
estimates store Heightsdq_exp

streg i.occ energy ht3 wt age, distribution(exponential)
estimates store Heightcubed_exp

lrtest (Height_exp) (Heightsdq_exp), stats force
lrtest (Height_exp) (Heightcubed_exp), stats force
estimates stats Height_exp HeightCat2_exp

*WEIGHT
tab wtcat2

streg i.occ energy i.htcat2 wt age, distribution(exponential)
estimates store Weight_exp

streg i.occ energy i.htcat2 i.wtcat2 age, distribution(exponential)
estimates store Weightcat_exp

streg i.occ energy i.htcat2 wt2 age, distribution(exponential)
estimates store Weightsqd_exp

streg i.occ energy i.htcat2 wt3 age, distribution(exponential)
estimates store Weightcubed_exp

lrtest (Weight_exp) (Weightsqd_exp), stats force
lrtest (Weight_exp) (Weightcubed_exp), stats force
estimates stats Weight_exp Weightcat_exp

*MODEL FOR ANALYSIS
streg i.occ energy i.htcat2 wt age, distribution(exponential)

*INTERACTION
display (9*40)

streg energy i.occ i.htcat2 wt age, distribution(exponential)
estimates store withweight

*DROP WEIGHT
streg energy i.occ i.htcat2 age, distribution(exponential)
estimates store no_weight

lrtest (withweight) (no_weight), stats 

*DROP OCCUPATION
streg energy i.htcat2 age, distribution(exponential)
estimates store no_occupation

lrtest (no_occupation) (no_weight), stats 

*DROP AGE
streg energy i.htcat2, distribution(exponential)
estimates store no_age

lrtest (no_occupation) (no_age), stats 

*MODEL WITH SIGNIFICANT VARIABLES
streg energy i.htcat2, distribution(exponential)

*FORM INTERACTION TERM
streg energy i.occ i.htcat2 wt age c.energy#i.htcat2, distribution(exponential)
estimates store fullmodel_exp

streg energy i.occ i.htcat2 wt age, distribution(exponential)
estimates store reducedmodel_exp

lrtest (fullmodel_exp) (reducedmodel_exp), stats 

*CONFOUNDING
streg energy i.occ i.htcat2 wt age, distribution(exponential)

*CRUDE MODEL
streg energy i.htcat2, distribution(exponential)

*BRING BACK AGE
streg energy i.htcat2 age, distribution(exponential)

*BRING BACK OCCUPATION
streg energy i.htcat2 i.occ, distribution(exponential)

*BRING BACK WEIGHT
streg energy i.htcat2 wt, distribution(exponential)

*CHECKING WHETHER HEIGHT CONFOUNDS
streg energy, distribution(exponential)

*GOODNESS OF FIT
streg energy i.htcat2, distribution(exponential)

predict Mgalefinal_EXP, mgale
predict Coxsnellfinal_EXP, csnell

stset Coxsnellfinal_EXP, id(ptid) failure(fail) scale(1)

sts generate Nelson_Aalen_EXP = na

twoway (scatter Nelson_Aalen_EXP Coxsnellfinal_EXP) (lowess Nelson_Aalen_EXP Coxsnellfinal_EXP)

stset survtime, id(ptid) failure(fail) scale(1)

streg energy ht, distribution(exponential)

predict Deviance_EXP, deviance

twoway (scatter Deviance_EXP survtime)

*FINAL MODEL
streg energy i.htcat2, distribution(exponential) nohr










log close

translate "Number 1.smcl" "Number1.pdf", replace