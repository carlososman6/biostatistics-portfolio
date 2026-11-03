* Set once: the folder that contains this repository, using forward slashes (e.g. C:/Users/you/biostatistics-portfolio)
if "$repo" == "" global repo "REPLACE-WITH-PATH/biostatistics-portfolio"
log using "cardiovascular", replace

*import data
import delimited "$repo/data/raw/assignment 2_Number 2_2025_2026.csv", varnames(1)

*rename columns

rename column1 sex
rename column2 sbp
rename column3 dbp
rename column4 cholesterol
rename column5 age
rename column6 persontime
rename column7 cv_events
rename column8 bmi

*Label columns

label variable sex "Sex of participant"
label variable sbp "Systolic blood pressure"
label variable dbp "Diastolic blood pressure"
label variable cholesterol "Serum cholesterol"
label variable age "Age of participant"
label variable persontime "Person time of follow up (days)"
label variable cv_events "Number of cardiovascular events"
label variable bmi "Body Mass Index"


*label values for sex;

label define sex_label 1 "Male" 2 "Female"
label values sex sex_label
tab sex


*DATA INSPECTION

bro 


*inspection of numeric variable
sum sbp dbp cholesterol age persontime cv_events

*check extreme outliers in sbp/dbp
scatter sbp dbp

*inspection of categorical variables
tab sex

*assess missingness
misstable summarize
mdesc

*only cholesterol and bmi have missing data with 0.7% and 0.19%



*Explore outcome variables and check for equidispersion 
tab cv_events
summarize cv_events, detail

*variance> mean
*need to check likelihood ratio test for alpha is significant TO DECIDE ON MODEL

summarize persontime, detail



*RUN NEGATIVE BINOMIAL MODEL ; to assess likelihood ratio test for alpha
nbreg cv_events i.sex sbp dbp cholesterol age bmi, exposure(persontime) irr
*likelihood ratio test for is significant suggesting that negative binomial is better;
*however we still need to compare it with other models

*CHOOSING MODEL
*negative binomial
nbreg cv_events i.sex sbp dbp cholesterol age bmi, exposure(persontime) irr
estimates store nbreg

*poisson model
poisson cv_events i.sex  sbp dbp cholesterol age bmi, exposure(persontime) irr
estimates store poisson

*Zero-Inflated Poisson Model
zip cv_events i.sex sbp dbp cholesterol age bmi, inflate(i.sex sbp dbp cholesterol age bmi) exposure(persontime)

**remove non significant predictors in inflated
*drop dpb
zip cv_events i.sex sbp dbp cholesterol age bmi, inflate(i.sex sbp cholesterol age bmi) exposure(persontime)
 estimates store zpoisson 


*Zero-Inflated Negative Binomial model
zinb cv_events i.sex sbp dbp cholesterol age bmi, inflate(i.sex sbp dbp cholesterol age bmi) exposure(persontime)

**drop dbp in inflated 
zinb cv_events i.sex sbp dbp cholesterol age bmi, inflate(i.sex sbp cholesterol age bmi) exposure(persontime)

**drop bmi
zinb cv_events i.sex sbp dbp cholesterol age bmi, inflate(i.sex sbp cholesterol age) exposure(persontime)

estimates store znegbin




*wont generate zero truncated models as the cardiovascular events have numerous zeroes

*now we compare the  models
lrtest ( poisson nbreg) ( zpoisson znegbin), stats force
*AIC/BIC for zero inflated  negative binomial are smallest ; hence zero inflated negative binomial model is best for this analysis; 

*BEFORE VARIABLE SELECTION WE ASSESS IF BP IS KEPT AS CONTINOUS OR CATEGORICAL AND THEN BMI

*BP
*BLOOD PRESSURE
*1.sbp as is
*2.dbp as is
*3.binary sbp (high sbp; 140mg and above); yes(1)/no(0)
*4.binary dbp (high dpb; 100mh and above); yes(1)/no(0)
*5.hypertension(systolic 140mmHg and above OR diastolic 100mmHg and above); 1(yes) and 0(no)

*3 binary sbp
gen high_sbp = 0
replace high_sbp = 1 if sbp >= 140
replace high_sbp = . if sbp == .
label variable high_sbp "High Systolic BP 140+ (1=Yes, 0=No)"
label define yesnolabel 0"No" 1"Yes"
label values high_sbp yesnolabel

*4. binary dbp
gen high_dbp = 0
replace high_dbp =1 if dbp >= 100
replace high_dbp = . if dbp == .
label variable high_dbp "High Diastolic BP 100+ (1=Yes, 0=No)"
label values high_dbp yesnolabel

*5 hypertension
gen hypertension = 0
replace hypertension =1 if sbp >= 140 | dbp >= 100
replace hypertension = . if sbp ==. & dbp == .
label variable hypertension "Hypertension"
label values hypertension yesnolabel

*check
tab high_sbp 
tab high_dbp 
tab hypertension

*BMI
gen obese_ow = 0
replace obese_ow =1 if bmi >=25
replace obese_ow = . if bmi==.
label variable obese_ow "Overweight or Obese"
label values obese_ow yesnolabel

tab obese_ow


*NOW WE CREATE DIFFERENT MODELS WITH THE DIFFERENT COMBINATIONS OF BP
*The models; 
*1. BP AS IS
zinb cv_events i.sex sbp dbp cholesterol age bmi, inflate(i.sex sbp cholesterol age) exposure(persontime)
estimates store bp_as_is

*2. spb binary categorical and dbp continous

zinb cv_events i.sex i.high_sbp dbp cholesterol age bmi, inflate(i.sex i.high_sbp cholesterol age) exposure(persontime)
estimates store cat_sbp

*3. dbp binary categorical and spb continous
zinb cv_events i.sex sbp i.high_dbp cholesterol age bmi, inflate(i.sex sbp cholesterol age) exposure(persontime)
estimates store cat_dbp

*4 both sbp and dbp as binary categorical
zinb cv_events i.sex i.high_sbp i.high_dbp cholesterol age bmi, inflate(i.sex i.high_sbp cholesterol age) exposure(persontime)
estimates store both_cat

*5 hypertension coded
zinb cv_events i.sex i.hypertension cholesterol age bmi, inflate(i.sex i.hypertension cholesterol age) exposure(persontime)
estimates store hypertension_coded

*now compare all 5 models 
estimates stats bp_as_is cat_sbp cat_dbp both_cat hypertension_coded

*the model with dbp as categorical and sbp as continous had the lowest aic/bic; so it will be the best going forward

zinb cv_events i.sex sbp i.high_dbp cholesterol age bmi, inflate(i.sex sbp cholesterol age) exposure(persontime)

*NOW WE DETERMINE IF BMI SHOULD BE CATEGORIZED
*MODEL 1;bmi as is(continous)
zinb cv_events i.sex sbp i.high_dbp cholesterol age bmi, inflate(i.sex sbp cholesterol age) exposure(persontime)
estimates store bmi_cont


*MODEL 2;bmi as binary
zinb cv_events i.sex sbp i.high_dbp cholesterol age i.obese_ow, inflate(i.sex sbp cholesterol age) exposure(persontime)
estimates store bmi_cat


*COMPARE THE TWO MODELS;
estimates stats bmi_cont bmi_cat

*Both AIC/BIC agree and are smaller when bmi categorical

*SO MODEL IS NOW
zinb cv_events i.sex sbp i.high_dbp cholesterol age i.obese_ow, inflate(i.sex sbp cholesterol age) exposure(persontime)



*Assess for collinearity
*model;
zinb cv_events i.sex sbp i.high_dbp cholesterol age i.obese_ow, inflate(i.sex sbp cholesterol age) exposure(persontime)


*predict linear function
predict zneglin, xb

*run regress with linear function as outcome
regress zneglin i.sex sbp i.high_dbp cholesterol age persontime i.obese_ow

*check vif
estat vif
**none above 10; collinearity assumption fulfilled;
zinb cv_events i.sex sbp i.high_dbp cholesterol age i.obese_ow, inflate(i.sex sbp cholesterol age) exposure(persontime)





*SELECTION OF VARIABLES TO INCLUDE IN MODEL;

*CHECK INTERACTION
*reduced models
zinb cv_events i.sex sbp i.high_dbp cholesterol age i.obese_ow, inflate(i.sex sbp cholesterol age) exposure(persontime)
estimates store reduced

*All possible interaction terms included; 

zinb cv_events i.sex sbp i.high_dbp cholesterol age i.obese_ow i.sex#c.sbp i.sex#i.high_dbp i.sex#c.cholesterol i.sex#c.age i.sex#i.obese_ow c.sbp#i.high_dbp c.sbp#c.cholesterol c.sbp#c.age c.sbp#i.obese_ow i.high_dbp#c.cholesterol i.high_dbp#c.age i.high_dbp#i.obese_ow c.cholesterol#c.age c.cholesterol#i.obese_ow c.age#i.obese_ow, inflate(i.sex sbp cholesterol age) exposure(persontime)

estimates store full

*do likelihood test on both models above;
lrtest ( reduced) ( full), stats dir

*pvalue of  0.0003 and the full model with interactions has a lower -2logs likelihood ratio,means that there is interaction

*lets drop most non significant term and compare;
*drop  high_dbp#c.cholesterol
zinb cv_events i.sex sbp i.high_dbp cholesterol age i.obese_ow i.sex#c.sbp i.sex#i.high_dbp i.sex#c.cholesterol i.sex#c.age i.sex#i.obese_ow c.sbp#i.high_dbp c.sbp#c.cholesterol c.sbp#c.age c.sbp#i.obese_ow i.high_dbp#c.age i.high_dbp#i.obese_ow c.cholesterol#c.age c.cholesterol#i.obese_ow c.age#i.obese_ow, inflate(i.sex sbp cholesterol age) exposure(persontime)
estimates store minushigh_dbpcholesterol

lrtest (minushigh_dbpcholesterol) ( full), stats dir
*but looking at the log likelihood of the two models; dropping high_dbp#c.cholesterol does not change the log likelhood; so we shall drop high_dbp#c.cholesterol even LR test is signficant

*significant p value means we keep high_dbpcholesterol

*drop  sbp#cholesterol

zinb cv_events i.sex sbp i.high_dbp cholesterol age i.obese_ow i.sex#c.sbp i.sex#i.high_dbp i.sex#c.cholesterol i.sex#c.age i.sex#i.obese_ow c.sbp#i.high_dbp c.sbp#c.age c.sbp#i.obese_ow i.high_dbp#c.age i.high_dbp#i.obese_ow c.cholesterol#c.age c.cholesterol#i.obese_ow c.age#i.obese_ow, inflate(i.sex sbp cholesterol age) exposure(persontime)
estimates store minussbpcholesterol

lrtest (minushigh_dbpcholesterol) (minussbpcholesterol), stats dir

*significant p value means we keep sbpcholestorol; However looking the at the -2xLL of the the two models; the model without the sbpcholestorol; has the smaller -2xLL; therefore ; we drop it


*drop  high_dbp 
zinb cv_events i.sex sbp cholesterol age i.obese_ow i.sex#c.sbp i.sex#i.high_dbp i.sex#c.cholesterol i.sex#c.age i.sex#i.obese_ow c.sbp#i.high_dbp c.sbp#c.age c.sbp#i.obese_ow i.high_dbp#c.age i.high_dbp#i.obese_ow c.cholesterol#c.age c.cholesterol#i.obese_ow c.age#i.obese_ow, inflate(i.sex sbp cholesterol age) exposure(persontime)
estimates store minushigh_dbp

*lrtest (minushigh_dbp) (minussbpcholesterol), stats dir
*models cant be compared becauses; "df(unrestricted) = df(restricted) = 26"
*however looking at the -2 log likelihood for both models; they look exactly the same; so droping  high_dbp wont weaken our model

*verdict; drop high_dbp


*drop sex#high_dbp
zinb cv_events i.sex sbp cholesterol age i.obese_ow i.sex#c.sbp i.sex#c.cholesterol i.sex#c.age i.sex#i.obese_ow c.sbp#i.high_dbp c.sbp#c.age c.sbp#i.obese_ow i.high_dbp#c.age i.high_dbp#i.obese_ow c.cholesterol#c.age c.cholesterol#i.obese_ow c.age#i.obese_ow, inflate(i.sex sbp cholesterol age) exposure(persontime)
estimates store minussexhigh_dbp


lrtest (minushigh_dbp) (minussexhigh_dbp), stats dir
*nonsignificant LR test; drop sex#high_dbp




*drop  high_dbpobese_ow
zinb cv_events i.sex sbp cholesterol age i.obese_ow i.sex#c.sbp i.sex#c.cholesterol i.sex#c.age i.sex#i.obese_ow c.sbp#i.high_dbp c.sbp#c.age c.sbp#i.obese_ow i.high_dbp#c.age c.cholesterol#c.age c.cholesterol#i.obese_ow c.age#i.obese_ow, inflate(i.sex sbp cholesterol age) exposure(persontime)
estimates store minushigh_dbpobese_ow

lrtest (minushigh_dbpobese_ow) (minussexhigh_dbp), stats dir
*nonsignificant LR; DROP high_dbpobese_ow


*drop sex#obese_ow 
zinb cv_events i.sex sbp cholesterol age i.obese_ow i.sex#c.sbp i.sex#c.cholesterol i.sex#c.age c.sbp#i.high_dbp c.sbp#c.age c.sbp#i.obese_ow i.high_dbp#c.age c.cholesterol#c.age c.cholesterol#i.obese_ow c.age#i.obese_ow, inflate(i.sex sbp cholesterol age) exposure(persontime)
estimates store minussexobese_ow 


lrtest (minushigh_dbpobese_ow) (minussexobese_ow), stats dir
*nonsignificant; drop sex#obese_ow 


*drop sex#c.age 
zinb cv_events i.sex sbp cholesterol age i.obese_ow i.sex#c.sbp i.sex#c.cholesterol c.sbp#i.high_dbp c.sbp#c.age c.sbp#i.obese_ow i.high_dbp#c.age c.cholesterol#c.age c.cholesterol#i.obese_ow c.age#i.obese_ow, inflate(i.sex sbp cholesterol age) exposure(persontime)
estimates store minusexage          


lrtest (minusexage) (minussexobese_ow), stats dir
*nonsignificant; drop

*drop sbp
zinb cv_events i.sex cholesterol age i.obese_ow i.sex#c.sbp i.sex#c.cholesterol c.sbp#i.high_dbp c.sbp#c.age c.sbp#i.obese_ow i.high_dbp#c.age c.cholesterol#c.age c.cholesterol#i.obese_ow c.age#i.obese_ow, inflate(i.sex cholesterol age) exposure(persontime)
estimates store sbpdropped

*lrtest (minusexage) (sbpdropped), stats dir
*-2LL lowered significantly after dropping sbp


*drop  sex#c.sbp
zinb cv_events i.sex cholesterol age i.obese_ow i.sex#c.cholesterol c.sbp#i.high_dbp c.sbp#c.age c.sbp#i.obese_ow i.high_dbp#c.age c.cholesterol#c.age c.cholesterol#i.obese_ow c.age#i.obese_ow, inflate(i.sex cholesterol age) exposure(persontime)
estimates store minussexsbp



lrtest (minussexsbp) (sbpdropped), stats dir
*signficant; keep ; also model with sexsbp has lower -2LL


*drop obese_ow#csbp
zinb cv_events i.sex cholesterol age i.obese_ow i.sex#c.sbp i.sex#c.cholesterol c.sbp#i.high_dbp c.sbp#c.age i.high_dbp#c.age c.cholesterol#c.age c.cholesterol#i.obese_ow c.age#i.obese_ow, inflate(i.sex cholesterol age) exposure(persontime)
estimates store minusobese_owcsbp

lrtest (sbpdropped) (minusobese_owcsbp), stats dir
*nonsignificant drop



*drop obese_ow#c.cholesterol 
zinb cv_events i.sex cholesterol age i.obese_ow i.sex#c.sbp i.sex#c.cholesterol c.sbp#i.high_dbp c.sbp#c.age i.high_dbp#c.age c.cholesterol#c.age c.age#i.obese_ow, inflate(i.sex cholesterol age) exposure(persontime)
estimates store minusobesechole


lrtest (minusobesechole) (minusobese_owcsbp), stats dir
*nonsignificant drop obese_ow#c.cholesterol 

*drop c.sbp#c.age 
zinb cv_events i.sex cholesterol age i.obese_ow i.sex#c.sbp i.sex#c.cholesterol c.sbp#i.high_dbp i.high_dbp#c.age c.cholesterol#c.age c.age#i.obese_ow, inflate(i.sex cholesterol age) exposure(persontime)
estimates store minussbpage

lrtest (minusobesechole) (minussbpage), stats dir
*nonsignificant drop sbpage


*drop high_dbp#c.age
zinb cv_events i.sex cholesterol age i.obese_ow i.sex#c.sbp i.sex#c.cholesterol c.sbp#i.high_dbp c.cholesterol#c.age c.age#i.obese_ow, inflate(i.sex cholesterol age) exposure(persontime)
estimates store minusdbpage

lrtest (minusdbpage) (minussbpage), stats dir
*nonsignificant drop high_dbp#c.age

* drop sex#c.sbp 
zinb cv_events i.sex cholesterol age i.obese_ow i.sex#c.cholesterol c.sbp#i.high_dbp c.cholesterol#c.age c.age#i.obese_ow, inflate(i.sex cholesterol age) exposure(persontime)
estimates store minussexsbp2

lrtest (minusdbpage) (minussexsbp2), stats dir
*signficant ; keep ; also model with sexsbp has smaller -2LL



*DROP  high_dbp#c.sbp
zinb cv_events i.sex cholesterol age i.obese_ow i.sex#c.sbp i.sex#c.cholesterol c.cholesterol#c.age c.age#i.obese_ow, inflate(i.sex cholesterol age) exposure(persontime)
estimates store minusdbpsbp


lrtest (minusdbpage) (minusdbpsbp), stats dir
*nonsignificant drop high_dbp#c.sbp


*drop obese_ow
zinb cv_events i.sex cholesterol age i.sex#c.sbp i.sex#c.cholesterol c.cholesterol#c.age c.age#i.obese_ow, inflate(i.sex cholesterol age) exposure(persontime)
estimates store minusobese

lrtest (minusobese) (minusdbpsbp), stats dir
*nonsignificant drop obese_ow


*drop  obese_ow#c.age
zinb cv_events i.sex cholesterol age i.sex#c.sbp i.sex#c.cholesterol c.cholesterol#c.age , inflate(i.sex cholesterol age) exposure(persontime)
estimates store minusobeseage


*lrtest (minusobese) (minusobeseage), stats dir
*keep model with obeseage as it has smaller -2LL

*drop sex#c.cholesterol 
zinb cv_events i.sex cholesterol age i.sex#c.sbp c.cholesterol#c.age c.age#i.obese_ow, inflate(i.sex cholesterol age) exposure(persontime)
estimates store minussexcholest

lrtest (minusobese) (minussexcholest), stats dir
*nonsignificant drop


*drop  sex#c.sbp as its most nonsignficant
zinb cv_events i.sex cholesterol age c.cholesterol#c.age c.age#i.obese_ow, inflate(i.sex cholesterol age) exposure(persontime)


*drop sex as its most nonsignficant
zinb cv_events cholesterol age c.cholesterol#c.age c.age#i.obese_ow, inflate( cholesterol age) exposure(persontime)


*all terms remaining are significant; now bring back interacting predictors

*obese_ow brought back
zinb cv_events cholesterol age i.obese_ow c.cholesterol#c.age c.age#i.obese_ow, inflate(cholesterol age) exposure(persontime)

* obese_ow#c.age  no longer signficant; we drop both_cat

*final model after interaction(crude)
zinb cv_events cholesterol age c.cholesterol#c.age, inflate(cholesterol age) exposure(persontime) irr


*CHECK FOR CONFOUNDING;
*BRING in this order; sex, obese_ow, sbp dbp

zinb cv_events i.sex cholesterol age c.cholesterol#c.age, inflate(i.sex cholesterol age) exposure(persontime) irr
*no percent chnage >10% in any of the preditors; so sex not confounder


*return obese_ow
zinb cv_events cholesterol age c.cholesterol#c.age i.obese_ow, inflate(cholesterol age) exposure(persontime) irr
*obese_ow not confounder

*return sbp
zinb cv_events i.sex cholesterol age c.cholesterol#c.age sbp , inflate(i.sex cholesterol age sbp ) exposure(persontime) irr
*sbp not confounder


*return dbp
zinb cv_events cholesterol age c.cholesterol#c.age i.high_dbp, inflate(cholesterol age) exposure(persontime) irr
*dbp not confounder


*FINAL MODEL
zinb cv_events cholesterol age c.cholesterol#c.age, inflate(cholesterol age) exposure(persontime) irr



log close
