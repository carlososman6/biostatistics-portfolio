* Set once: the folder that contains this repository, using forward slashes (e.g. C:/Users/you/biostatistics-portfolio)
if "$repo" == "" global repo "REPLACE-WITH-PATH/biostatistics-portfolio"
log using "birthweight_assignment2", replace


*2)	A study was conducted to determine if smoking and mother's race are associated with birthweight of babies. The data is attached as Regression assignment I Number_2_2025_2026 and the table below contains the details about the variables. Use it to answer the question. Interpret the final model obtained. USE STATA for the analysis

* Import data
import excel "$repo/data/raw/Regression assignment I data_Number 2_2025_2026.xlsx", sheet("Sheet1") firstrow

* Rename columns 
rename Column1  id       // Identification code
rename Column2  age      // Age of mother in years
rename Column3  lwt      // Mother's weight at last menstrual period (lbs)
rename Column4  race     // Mother's race (1=White, 2=Black, 3=Other)
rename Column5  smoke    // Smoking during pregnancy (1=Yes, 0=No)
rename Column6  ptl      // History of premature labour
rename Column7  ht       // History of hypertension (1=Yes, 0=No)
rename Column8  ui       // Uterine irritability (1=Yes, 0=No)
rename Column9  ftv      // Physician visits – 1st trimester
rename Column10 bwt      // Birthweight in grams (OUTCOME)

*check to see if renaming was succesful
bro

*Label columns after renaming

label variable id    "Identification Code"
label variable age   "Age of the Mother in Years"
label variable lwt   "Weight in Pounds at the Last Menstrual Period"
label variable race  "Mothers Race (1=White, 2=Black, 3=Other)"
label variable smoke "Smoking Status During Pregnancy (1=Yes, 0=No)"
label variable ptl   "History of Premature Labor (0=None, 1=One, etc.)"
label variable ht    "History of Hypertension (1=Yes, 0=No)"
label variable ui    "Presence of Uterine Irritability (1=Yes, 0=No)"
label variable ftv   "Number of Physician Visits During First Trimester"
label variable bwt   "Birth Weight in Grams"

*Data inspection
bro

*ptl and ftv have levels with sparse categories

tab ptl

tab ftv

*COLLAPSE SPARSE CATEGORIES; 
*History of premature labor acategories(ptl); 0=159, 1=24, 2=5, 3=1 → Collapse 2 and 3 into "2 or more"
gen ptl2 = ptl
recode ptl2 (2 3 = 2)
label define ptl2_lbl 0 "No prior premature labor"  1 "One prior premature labor"   2 "Two or more prior premature labors"
label values ptl2 ptl2_lbl
tab ptl2

* Number of Physician Visits During the First Trimester()ftv2: 0=100, 1=47, 2=30, 3=7, 4=4, 6=1 → Collapse 3, 4, 6 into "3 or more"
gen ftv2 = ftv
recode ftv2 (3 4 6 = 3)
label define ftv2_lbl 0 "No physician visits" 1 "One physician visit" 2 "Two physician visits" 3 "Three or more physician visits"


label values ftv2 ftv2_lbl
tab ftv2


* SAMPLE SIZE CHECK 
* We need atleast 40 subjects per variable 
* 
bro

* FIT  MODEL
regress bwt smoke i.race age lwt i.ptl2 ht ui i.ftv2

*CHECK ASSUMPTIONS

* EXISTENCE OF A RELATIONSHIP

correlate smoke race lwt ptl2 ht ui age ftv2 bwt
*None of the predictor variables have a correlation coefficient > 0.3 with the birthweight

regress bwt smoke i.race age lwt i.ptl2 ht ui i.ftv2
*However the F-test shows a p value <0.05; which shows there is existence of a relationships between predictors and outcome; Therefore the assumption of existence of a relationships is met


* CHECK FOR LINEARITY
* use CPR plots with each predictor.

cprplot age, rlopts(lcolor(red)) lowess
*looking at this graph;  The CPR plot shows a straight reference line with no meaningful curvature, indicating that the linearity assumption is satisfied for age.the lowess line also closely aligns with with it for most of the data range; hence linearity is fulfilled

cprplot lwt, rlopts(lcolor(red)) lowess
*  straight reference line with no curvature, therefore linearity assumption is satisfied;lowess line here also closely aligns with the line of best fit therefore

cprplot smoke, rlopts(lcolor(red)) lowess
* The line of best fit,along with the lowess smoother are straight indicating linearity

regress bwt smoke race age lwt ptl2 ht ui ftv2

cprplot race
*race


regress bwt smoke i.race age lwt i.ptl2 ht ui i.ftv2


regress bwt smoke race age lwt ptl2 ht ui ftv2

cprplot ptl2
*ptl2


regress bwt smoke i.race age lwt i.ptl2 ht ui i.ftv2


*cprplot ptl2, rlopts(lcolor(red)) lowess
*The line of best fit is straight indicating linearity

cprplot ht
*The line of best fit is straight indicating linearity

cprplot ui
*The line of best fit is straight indicating linearity with no curvatures

regress bwt smoke race age lwt ptl2 ht ui ftv2

cprplot ftv2
*ftv2


regress bwt smoke i.race age lwt i.ptl2 ht ui i.ftv2

* CHECK FOR INDEPENDENCE OF RESIDUALS

* Use RVP plots (residuals versus predictor plots) – should show no clear pattern.

rvpplot age, yline(0)
*no pattern or funnel-shape noted

rvpplot lwt, yline(0)
*no pattern or funnel shaped

regress bwt smoke race age lwt ptl2 ht ui ftv2

rvpplot race, yline(0)
*race
regress bwt smoke i.race age lwt i.ptl2 ht ui i.ftv2


rvpplot smoke, yline(0)
*no pattern


regress bwt smoke race age lwt ptl2 ht ui ftv2
rvpplot ptl2, yline(0)
* no pattern

regress bwt smoke i.race age lwt i.ptl2 ht ui i.ftv2


rvpplot ht, yline(0)
*no pattern

rvpplot ui, yline(0)
*no pattern

regress bwt smoke race age lwt ptl2 ht ui ftv2
rvpplot ftv2, yline(0)
*ftv2

regress bwt smoke i.race age lwt i.ptl2 ht ui i.ftv2



* Interpretation: No clear pattern in any plot → independence assumption is met.


* CHECK NORMALITY OF RESIDUALS
* create new variable of residuals in the model
predict residuals, residuals


* Check normalty using:Shapiro-Wilk test.
swilk residuals

* H0: Residuals are normally distributed.
* Non-significant p-value (p =  0.59724) means we fail to reject the null hypothesis that the residuals are normally distributed




* CHECK FOR EQUAL VARIANCE (HOMOSCEDASTICITY)

*Use both visual checks and statistical test

*Visual checks using rvpplot and rvf plots

* (a) RVP plots
rvpplot age, yline(0)
*distribution is rectangular

rvpplot lwt, yline(0)
*distribution is largely rectangular

regress bwt smoke race age lwt ptl2 ht ui ftv2
rvpplot race, yline(0)
* no pattern

regress bwt smoke i.race age lwt i.ptl2 ht ui i.ftv2

*race

rvpplot smoke, yline(0)
*rectangular distribution is observed

regress bwt smoke race age lwt ptl2 ht ui ftv2
rvpplot ptl2, yline(0)
* no pattern

regress bwt smoke i.race age lwt i.ptl2 ht ui i.ftv2


rvpplot ht, yline(0)
*rectangular distribution noted

rvpplot ui, yline(0)
*rectangular distribution noted


regress bwt smoke race age lwt ptl2 ht ui ftv2
rvpplot ftv2, yline(0)
* no pattern

regress bwt smoke i.race age lwt i.ptl2 ht ui i.ftv2

* (b) RVF plot 
* First predict fitted values 
predict fitted, xb

rvfplot, yline(0)
*by observation; we can see that there is a a rectangular spread of the data points ; this fulfills the assumption of equal variance

* Use Statistical test: Breusch-Pagan / Cook-Weisberg test (estat hettest)

* H0: Constant variance. p > 0.05 → assumption holds.

* Overall check
estat hettest

* per variable;

estat hettest age
*Breusch-Pagan / Cook-Weisberg test for age is signficant; hence null hypotheis of constant variance is rejected

estat hettest race
estat hettest smoke
estat hettest lwt
estat hettest ptl2
estat hettest ht
estat hettest ui
estat hettest ftv2

*Though the age-specific Breusch-Pagan / Cook-Weisberg test for age is signficant, the overall test is non signficant and the RVP plot for age looked rectangular; therefore the  assumption of equal variance in model is considered met.


*CHECK FOR MULTICOLLINEARITY
* Correlation matrix – eyeball for strong relationships 

correlate smoke race lwt ptl2 ht ui age ftv2 bwt
*from  eyeballing; there was no multicollinearity as the relationship between continuous predictors was not strong (0.1801) 



* Using VIF (Variance Inflation Factor) 

estat vif
*No VIF was noted >10; No multicollinearity between the predictors


* CHECK FOR OUTLIERS

* Using DFbetas

predict dfbetas_age, dfbeta(age)
predict dfbeta_smoke, dfbeta(smoke)
predict dfbeta_2race, dfbeta(2.race)   
predict dfbeta_3race, dfbeta(3.race)   
predict dfbeta_lwt, dfbeta(lwt)
predict dfbeta_1ptl2, dfbeta(1.ptl2)
predict dfbeta_2ptl2, dfbeta(2.ptl2) 
predict dfbeta_ht, dfbeta(ht)
predict dfbeta_ui, dfbeta(ui)
predict dfbeta_1ftv2, dfbeta(1.ftv2)
predict dfbeta_2ftv2, dfbeta(2.ftv2) 
predict dfbeta_3ftv2, dfbeta(3.ftv2)  

 
* Summarise each ;

sum dfbetas_age
* noted to have max dfbeta > 0.5

*to identify ids causing this influence ;

list if abs( dfbetas_age) > 0.5
* ids listed are 159,188 and 226


sum dfbeta_smoke
*both abs min max dfbeta are <0.5

sum dfbeta_2race
*both abs min max dfbeta are <0.5
   
sum dfbeta_3race
*both abs min max dfbeta are <0.5

   
sum dfbeta_lwt
*both abs min max dfbeta are <0.5


sum dfbeta_1ptl2
*both abs min max dfbeta are <0.5


sum dfbeta_2ptl2 
*both abs min max dfbeta are <0.5

  
sum dfbeta_ht
*min abs dfbeta>0.5

**to identify ids causing this influence ;

list if abs(dfbeta_ht) > 0.5
** ids listed are 159,188 and 11


sum dfbeta_ui
*min abs dfbeta>0.5

**to identify ids causing this influence ;

list if abs(dfbeta_ui) > 0.5
*ids are 159,188,10

sum dfbeta_1ftv2
*both abs min max dfbeta are <0.5


sum dfbeta_2ftv2 
*both abs min max dfbeta are <0.5


sum dfbeta_3ftv2
*both abs min max dfbeta are <0.5

  

regress bwt smoke i.race age lwt i.ptl2 ht ui i.ftv2


* Using Cook's Distance

predict cooksd, cooksd
summarize cooksd
*max is <1




*What predictors enter the multivariate analysis
*we shall do simple linear regression for each predictor outcome and set cut off of p-value<0.2

regress bwt age
*pvalue= 0.219

regress bwt lwt
*pvalue=0.010

regress bwt i.race
*pvalue=0.0079

regress bwt smoke
*pvalue= 0.009

regress bwt i.ptl2
*pvalue=0.0047

regress bwt ht
*pvalue= 0.045

regress bwt ui
*pvalue= 0.000

regress bwt i.ftv2
*pvalue= 0.2369

*because Age of the Mother in Years and Number of Physician Visits During the First Trimester have a p value >0.2; they should be dropped from the model; However ; maternal age is clinically important so it cannot be dropped


*
* STEP 10: CHECK FOR INTERACTION
* Main predictors: smoke and race.

**check for signficance of variables
regress bwt age lwt i.race smoke i.ptl2 ht ui 
*age is not signficant; so we dont from interaction terms with its

*

* Use stepwise backward to remove non-significant interaction terms.
*
stepwise, pr(0.05) : regress bwt (i.smoke i.race) i.smoke#i.race i.smoke##c.lwt i.smoke##ht i.smoke##ui i.smoke##i.ptl2 i.race##c.lwt i.race##i.ht i.race##ui i.race##i.ptl2

*then we bring back the predictors 

regress bwt i.smoke i.race i.smoke#i.race i.race#i.ht i.smoke#i.ptl2 i.ht i.ui i.ptl2
*notice how the interaction terms become non significant

*final model after interaction is as follows;

regress bwt i.smoke i.race i.smoke#i.race i.ui


*CHECK FOR CONFOUNDING;
*we start with last variable to be dropped ;

*hypertension (ht)

regress bwt i.smoke i.race i.smoke#i.race i.ui ht

*History of Premature Labor (ptl2)

regress bwt i.smoke i.race i.smoke#i.race i.ui i.ptl2

*Weight in Pounds at the Last Menstrual Period(lwt)  

regress bwt i.smoke i.race i.smoke#i.race i.ui lwt

*Age

regress bwt i.smoke i.race i.smoke#i.race i.ui age
 
*FINAL MODEL

regress bwt i.smoke i.race i.smoke#i.race i.ui , beta



log close


