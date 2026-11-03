* Set once: the folder that contains this repository, then run.
CD 'REPLACE-WITH-PATH/biostatistics-portfolio'.
GET FILE='data/raw/depress data.sav'.
DATASET NAME DataSet1 WINDOW=FRONT.
* Encoding: UTF-8.

*import data




*DATA INSPECTION AND CLEANIG
* Identify Duplicate Cases.
* depress data.sav already contains PrimaryLast from an earlier run of this block; drop it so the block can recreate it.
MATCH FILES FILE=* /DROP=PrimaryLast.
SORT CASES BY ID(A).
MATCH FILES
  /FILE=*
  /BY ID
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryFirst InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryLast 'Indicator of each last matching case as Primary'.
VALUE LABELS  PrimaryLast 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryLast (ORDINAL).
FREQUENCIES VARIABLES=PrimaryLast.
EXECUTE.
*no duplicates
    
*outliers and missing  IN  original DATASET

FREQUENCIES VARIABLES=ID treatment dep_t0 dep_t1 dep_t3 dep_t6 age sex education PrimaryLast
  /STATISTICS=STDDEV MINIMUM MAXIMUM MEAN MEDIAN
  /ORDER=ANALYSIS.
*no missing values ; wrong coding for categorical variables and 
    

    
*collapse educaton; yes or no
    
* MODEL 1 - Education with all four original categories.
GLM dep_t0 dep_t1 dep_t3 dep_t6 BY treatment sex education WITH age
  /WSFACTOR=time 4 Polynomial
  /METHOD=SSTYPE(3)
  /PLOT=PROFILE(time*treatment) TYPE=LINE ERRORBAR=NO 
   MEANREFERENCE=NO YAXIS=AUTO
  /EMMEANS=TABLES(time) WITH(age=MEAN) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(treatment) WITH(age=MEAN) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(treatment*time) WITH(age=MEAN)
  /PRINT=DESCRIPTIVE ETASQ HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time
  /DESIGN=age treatment sex education treatment*sex treatment*education 
   sex*education treatment*sex*education.

* Recode education into binary variable.
RECODE education (1=1) (2=1) (3=2) (4=2) INTO edu_binary.
VARIABLE LABELS edu_binary 'Education Binary (1=Lower, 2=Higher)'.
VALUE LABELS edu_binary 1 'Lower (No edu + Primary)' 2 'Higher (Secondary + Tertiary)'.
EXECUTE.

* MODEL 2 - Education collapsed into two categories.
GLM dep_t0 dep_t1 dep_t3 dep_t6 BY treatment sex edu_binary WITH age
  /WSFACTOR=time 4 Polynomial
  /METHOD=SSTYPE(3)
  /PLOT=PROFILE(time*treatment) TYPE=LINE ERRORBAR=NO 
   MEANREFERENCE=NO YAXIS=AUTO
  /EMMEANS=TABLES(time) WITH(age=MEAN) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(treatment) WITH(age=MEAN) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(treatment*time) WITH(age=MEAN)
  /PRINT=DESCRIPTIVE ETASQ HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time
  /DESIGN=age treatment sex edu_binary treatment*sex treatment*edu_binary 
   sex*edu_binary treatment*sex*edu_binary.

*normality checks within each group
    
* Compute pairwise differences between time points.
COMPUTE diff_t0_t1 = dep_t0 - dep_t1.
EXECUTE.
COMPUTE diff_t0_t3 = dep_t0 - dep_t3.
EXECUTE.
COMPUTE diff_t0_t6 = dep_t0 - dep_t6.
EXECUTE.
COMPUTE diff_t1_t3 = dep_t1 - dep_t3.
EXECUTE.
COMPUTE diff_t1_t6 = dep_t1 - dep_t6.
EXECUTE.
COMPUTE diff_t3_t6 = dep_t3 - dep_t6.
EXECUTE.

* Check normality of differences using Shapiro-Wilk.
EXAMINE VARIABLES=diff_t0_t1 diff_t0_t3 diff_t0_t6 
                  diff_t1_t3 diff_t1_t6 diff_t3_t6
  /PLOT NPPLOT
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

*Running Mixed Design Repeated Measures ANOVA ;examining the effect of time, treatment, sex, education, and age on depression scores

GLM dep_t0 dep_t1 dep_t3 dep_t6 BY treatment sex education WITH age
  /WSFACTOR=time 4 Polynomial 
  /METHOD=SSTYPE(3)
  /PLOT=PROFILE(time*treatment) TYPE=LINE ERRORBAR=NO MEANREFERENCE=NO YAXIS=AUTO
  /EMMEANS=TABLES(time) WITH(age=MEAN)COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(treatment) WITH(age=MEAN)COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(treatment*time) WITH(age=MEAN)
  /PRINT=DESCRIPTIVE ETASQ HOMOGENEITY 
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time 
  /DESIGN=age treatment sex education treatment*sex treatment*education sex*education 
    treatment*sex*education.

** Final Reduced Model - Significant terms only including three-way interaction.
GLM dep_t0 dep_t1 dep_t3 dep_t6 BY treatment sex WITH age
  /WSFACTOR=time 4 Polynomial
  /METHOD=SSTYPE(3)
  /PLOT=PROFILE(time*treatment) TYPE=LINE ERRORBAR=NO 
   MEANREFERENCE=NO YAXIS=AUTO
  /EMMEANS=TABLES(time) WITH(age=MEAN) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(treatment) WITH(age=MEAN) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(time*treatment) WITH(age=MEAN)
  /EMMEANS=TABLES(sex) WITH(age=MEAN) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(treatment*sex) WITH(age=MEAN)
  /EMMEANS=TABLES(time*treatment*sex) WITH(age=MEAN)
  /PRINT=DESCRIPTIVE ETASQ HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time
  /DESIGN=treatment sex treatment*sex.


*take out nonsignificant predictors
    
* Final Reduced Model - Between subjects significant terms only.
GLM dep_t0 dep_t1 dep_t3 dep_t6 BY treatment WITH age
  /WSFACTOR=time 4 Polynomial
  /METHOD=SSTYPE(3)
  /PLOT=PROFILE(time*treatment) TYPE=LINE ERRORBAR=NO 
   MEANREFERENCE=NO YAXIS=AUTO
  /EMMEANS=TABLES(time) WITH(age=MEAN) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(treatment) WITH(age=MEAN) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(time*treatment) WITH(age=MEAN)
  /PRINT=DESCRIPTIVE ETASQ HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time
  /DESIGN=treatment.

*CHECK FOR CONFOUDING
    
* Step 1 - Base model (treatment only).

GLM dep_t0 dep_t1 dep_t3 dep_t6 BY treatment
  /WSFACTOR=time 4 Polynomial
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time
  /DESIGN=treatment.

* Step 2 - Add sex 
    .
GLM dep_t0 dep_t1 dep_t3 dep_t6 BY treatment sex
  /WSFACTOR=time 4 Polynomial
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time
  /DESIGN=treatment sex.

* Step 3 - Add education 

GLM dep_t0 dep_t1 dep_t3 dep_t6 BY treatment education
  /WSFACTOR=time 4 Polynomial
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time
  /DESIGN=treatment education.

* Step 4 - Add age 

GLM dep_t0 dep_t1 dep_t3 dep_t6 BY treatment WITH age
  /WSFACTOR=time 4 Polynomial
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time
  /DESIGN=treatment age.



*FINAL MODEL
    
GLM dep_t0 dep_t1 dep_t3 dep_t6 BY treatment
  /WSFACTOR=time 4 Polynomial
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time
  /DESIGN=treatment.
