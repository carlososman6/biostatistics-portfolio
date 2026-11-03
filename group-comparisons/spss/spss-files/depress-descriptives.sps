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
    
ONEWAY dep_t0 BY education
  /STATISTICS DESCRIPTIVES HOMOGENEITY 
  /MISSING ANALYSIS
  /CRITERIA=CILEVEL(0.95)
  /POSTHOC=BTUKEY ALPHA(0.05).

*normality checks within each group
    
EXAMINE VARIABLES=dep_t0 dep_t1 dep_t3 dep_t6 BY treatment
  /PLOT BOXPLOT NPPLOT
  /COMPARE GROUPS
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








