* Set once: the folder that contains this repository, then run.
CD 'REPLACE-WITH-PATH/biostatistics-portfolio'.
GET FILE='data/raw/body fat final.sav'.
DATASET NAME DataSet1 WINDOW=FRONT.
* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.
DESCRIPTIVES VARIABLES=fat age weight height neck chest abdomen hip thigh knee ankle biceps forearm 
    wrist
  /STATISTICS=MEAN STDDEV MIN MAX.

*data cleaning 

USE ALL.
COMPUTE filter_$=(fat > 0 & height > 30).
VARIABLE LABELS filter_$ 'fat > 0 & height > 30 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

DESCRIPTIVES VARIABLES=fat age weight height neck chest abdomen hip thigh knee ankle biceps forearm 
    wrist
  /STATISTICS=MEAN STDDEV MIN MAX.

*fit model; check all 5 assumptions; collinearity and outliers

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER age weight height neck chest abdomen hip thigh knee ankle biceps forearm wrist
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3)
  /SAVE PRED COOK RESID SDBETA.

DATASET ACTIVATE DataSet1.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT RES_1
  /METHOD=ENTER PRE_1.

*correlate the predictors to check which correlates with weight the most


NONPAR CORR
  /VARIABLES=age weight height neck chest abdomen hip thigh knee ankle biceps forearm wrist
  /PRINT=SPEARMAN TWOTAIL NOSIG FULL
  /MISSING=PAIRWISE.

*regress again to look at vif when weight is removed



REGRESSION
  /MISSING LISTWISE
  /STATISTICS R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER age height neck chest abdomen hip thigh knee ankle biceps forearm wrist
  /SCATTERPLOT=(*ZRESID ,*ZPRED).

*regress again to look at vif when abdominal circumference at umbilicus is removed

REGRESSION
  /MISSING LISTWISE
  /STATISTICS R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER age height neck chest hip thigh knee ankle biceps forearm wrist
  /SCATTERPLOT=(*ZRESID ,*ZPRED).


*summarises cooksd and all dfebetas

FREQUENCIES VARIABLES=COO_1 SDB0_1 SDB1_1 SDB2_1 SDB3_1 SDB4_1 SDB5_1 SDB6_1 SDB7_1 SDB8_1 SDB9_1 
    SDB10_1 SDB11_1 SDB12_1 SDB13_1
  /FORMAT=NOTABLE
  /STATISTICS=MINIMUM MAXIMUM
  /ORDER=ANALYSIS.

*manual check for equal variance

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT RES_1
  /METHOD=ENTER PRE_1.


*Model we are using at this point

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER age height neck chest hip thigh knee ankle biceps forearm wrist.

* CHECK FOR INTERACTION
    *first run bivariate analysis for each predictor with body fat; we use a cutt off for 0.2



REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER age.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER height.


REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER neck.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER chest.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER hip.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER thigh.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER knee.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER ankle.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER biceps.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER forearm.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER wrist.


*from above height with pvalue>0.2 is removed
    
*new model becomes;
   
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER age neck chest hip thigh knee ankle biceps forearm wrist.

*eliminiate non significant variables using backward;

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=BACKWARD age neck chest hip thigh knee ankle biceps forearm wrist.


*now we form interaction terms from the signficant variables from above

COMPUTE age_chest  = age   * chest.
COMPUTE age_thigh  = age   * thigh.
COMPUTE age_wrist  = age   * wrist.
COMPUTE chest_thigh = chest * thigh.
COMPUTE chest_wrist = chest * wrist.
COMPUTE thigh_wrist = thigh * wrist.
EXECUTE.
    
*add to model and run backward
    


REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=BACKWARD age chest thigh wrist age_chest age_thigh age_wrist chest_thigh chest_wrist 
    thigh_wrist.
*in the above model; interaction terms of; age_wrist and thigh_wrist are retained; but wrist was dropped; so we first bring it back

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER age chest thigh wrist age_wrist thigh_wrist.
*all other variables remain signficant; so we keep wrist;
    

*check for confounding
*crude model is as follows;

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER age chest thigh wrist age_wrist thigh_wrist

*the last variables to be removed follow this order; hip,neck,forearm,knee,ankle and biceps was the first to be removed
    *so we shall add hip and then compare the model with crude; and so on and so forth
    

*adjusted model for hip below

DATASET ACTIVATE DataSet1.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER age chest thigh wrist age_wrist thigh_wrist hip.
*Chest, wrist and thighwrist have %change >10%, so hip is a confounder
    
*adjusted model for neck

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER age chest thigh wrist hip age_wrist thigh_wrist neck.

*adjusted forearm

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER age chest thigh wrist hip age_wrist thigh_wrist forearm.

*knee adjusted

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER age chest thigh wrist hip age_wrist thigh_wrist forearm knee.

*ankle adjusted

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER age chest thigh wrist hip age_wrist thigh_wrist forearm knee ankle.
*ankle not confounder

*adjusted biceps

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER age chest thigh wrist hip age_wrist thigh_wrist forearm knee biceps.


FINAL MODEL TO BE INTERPRETED

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT fat
  /METHOD=ENTER age chest thigh wrist hip age_wrist thigh_wrist forearm knee.
