* Set the working directory to the folder that contains this repository, then run.
CD 'REPLACE-WITH-PATH/biostatistics-portfolio'.
* Encoding: UTF-8.


GET DATA
  /TYPE=XLSX
  /FILE='data/raw/survival_assignment_Number_II_2026.xlsx'
  /SHEET=name 'Sheet1'
  /CELLRANGE=FULL
  /READNAMES=ON
  /DATATYPEMIN PERCENTAGE=95.0
  /HIDDEN IGNORE=YES.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

*Comment: imports the Excel sheet (206 rows). 

DELETE VARIABLES V9 V10 V11 V12.
RENAME VARIABLES (Column1 Column2 Column3 Column4 Column5 Column6 Column7 Column8 =
  ID Year_surgery Age Status Survtime Surg_care Heart_transplant Wait_time).


VARIABLE LABELS
  ID 'Patient identification number'
  Year_surgery 'Year when accepted surgery'
  Age 'Patient''s age'
  Status 'Status'
  Survtime 'Survival time in days'
  Surg_care 'Received surgical care'
  Heart_transplant 'Received heart transplant'
  Wait_time 'Waiting time before surgery'.



VALUE LABELS Status 0 'censored' 1 'died'
  /Surg_care 0 'No' 1 'Yes'
  /Heart_transplant 0 'No' 1 'Yes'.

*Comment: Status 1 = died (the event), 0 = censored. Surgical care and transplant are coded 1 = Yes, 0 = No.

VARIABLE LEVEL ID Status Surg_care Heart_transplant (NOMINAL)
  /Year_surgery Age Survtime Wait_time (SCALE).

*Comment: categorical variables set to nominal, numeric variables to scale.

FORMATS Survtime (F6.1) Wait_time (F3.0).



*inspect categories

FREQUENCIES VARIABLES=Status Surg_care Heart_transplant.

*Comment: 150 died and 56 censored. 24 rows had surgical care and 138 had a heart transplant.
*No unexpected codes. Verdict: categories clean.

*inspect continous variables

DATASET ACTIVATE DataSet1.
DESCRIPTIVES VARIABLES=Year_surgery Age Survtime Wait_time
  /STATISTICS=MEAN STDDEV MIN MAX.

*Comment: no implausible values. Survtime runs from 1 to 1799 days.
*Ages include two young outliers (8 and 19), plausible and kept. Verdict: continuous variables clean.

*check missing ness; none seen according to variable view;
    
*check duplicates
    


* Identify Duplicate Cases.
SORT CASES BY ID(A).
MATCH FILES
  /FILE=*
  /BY ID
  /FIRST=PrimaryFirst
  /LAST=Primaryidlast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-Primaryidlast.
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
VARIABLE LABELS  Primaryidlast 'Indicator of each last matching case as Primary'.
VALUE LABELS  Primaryidlast 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  Primaryidlast (ORDINAL).
FREQUENCIES VARIABLES=Primaryidlast.
EXECUTE.

*Comment: checking on ID alone finds no repeated IDs (every row is a primary case),
*so it does not detect the duplication. Verdict: no duplicate IDs.


*duplicates without ID
    

SORT CASES BY Year_surgery(A) Age(A) Status(A) Survtime(A) Surg_care(A) Heart_transplant(A) 
    Wait_time(A).
MATCH FILES
  /FILE=*
  /BY Year_surgery Age Status Survtime Surg_care Heart_transplant Wait_time
  /FIRST=PrimaryFirst
  /LAST=Primarynoid.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-Primarynoid.
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
VARIABLE LABELS  Primarynoid 'Indicator of each last matching case as Primary'.
VALUE LABELS  Primarynoid 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  Primarynoid (ORDINAL).
FREQUENCIES VARIABLES=Primarynoid.
EXECUTE.


*Comment: Matching on all variables except ID shows 103 of the 206 records (50%) are exact duplicates of another record. The dataset contains 103 unique patients, each entered twice under different ID numbers. An ID-only check does not detect this.

*Fit the model
    


COXREG Survtime
  /STATUS=Status(1)
  /PATTERN BY Heart_transplant
  /CONTRAST (Surg_care)=Indicator(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /METHOD=ENTER Year_surgery Age Surg_care Heart_transplant Wait_time 
  /PLOT LML
  /SAVE=LML PRESID DFBETA
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*Comment: baseline Cox model on all 206 rows (150 events, 56 censored, none dropped).
*Hazard ratios: year of surgery .926, age 1.058 per year, surgical care .537 (borderline, p = .050),
*heart transplant .251, waiting time .993. Reference category is No for both Yes/No variables.
*P-values are too small because of the duplicated rows, and transplant is coded fixed 0/1,
*so immortal-time bias is possible. Verdict: provisional model; proportional hazards still to be checked.

* plots ; Partial residual for Year when accepted surgery vs survtime  (PR1_1)


GRAPH
  /SCATTERPLOT(BIVAR)=Survtime WITH PR1_1
  /MISSING=LISTWISE.

*Partial residuals scatter around zero across follow-up, with no upward or downward slope. The narrowing at later times reflects fewer deaths. Verdict: no trend.


* plots ; Partial residual for Patient's age vs survtime 

GRAPH
  /SCATTERPLOT(BIVAR)=Survtime WITH PR2_1
  /MISSING=LISTWISE.

*Early residuals are widely spread, partly from the youngest patients (ages 8 and 19). Later residuals sit mostly above zero but rest on few points. No clear slope. Verdict: no clear trend; confirm with correlation test.


* plots ; Partial residual for Received surgical care VS SURV TIME

GRAPH
  /SCATTERPLOT(BIVAR)=Survtime WITH PR3_1
  /MISSING=LISTWISE.

*Residuals form two bands (one per category), so a trend is hard to judge by eye. Only six deaths occurred in the surgery group. Verdict: inconclusive.

* plots ; Partial residual for Received heart transplant VS SURV TIME

GRAPH
  /SCATTERPLOT(BIVAR)=Survtime WITH PR4_1
  /MISSING=LISTWISE.

*The two bands converge over the first months, and after about day 340 all deaths are in transplanted patients. This may reflect fixed transplant coding. Verdict: trend present; possible violation, confirm with correlation test.

* plots ; Partial residual for Waiting time before surgery VS SURV TIME  

GRAPH
  /SCATTERPLOT(BIVAR)=Survtime WITH PR5_1
  /MISSING=LISTWISE.

*Most residuals are negative, with a few large positives from long waits (139 and 160 days). The drift mirrors the transplant plot, because waiting time is 0 without a transplant. Verdict: inconclusive.


*correlation test on the partial residuals
    


CORRELATIONS
  /VARIABLES=Survtime PR1_1 PR2_1 PR3_1 PR4_1 PR5_1
  /PRINT=TWOTAIL NOSIG FULL
  /MISSING=PAIRWISE.
NONPAR CORR
  /VARIABLES=Survtime PR1_1 PR2_1 PR3_1 PR4_1 PR5_1
  /PRINT=SPEARMAN TWOTAIL NOSIG FULL
  /MISSING=PAIRWISE.

*Partial residuals were correlated with survival time (Pearson and Spearman). 
    *Year of surgery showed no evidence of a time-varying effect. 
    *Age was not significant on both tests (r ≈ 0.18). 
    *Surgical care was significant but with opposite signs, so the result is unreliable for a binary covariate. 
   * Heart transplant and waiting time gave discordant results. 
    *Because the correlation approach is only suggestive, proportional hazards for age, surgical care, heart transplant and waiting time will be assessed formally with time-dependent covariates. 

DATASET ACTIVATE DataSet1.
TIME PROGRAM.
COMPUTE T_COV_ = T_ * Year_surgery.
COXREG   Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Year_surgery Age Surg_care Heart_transplant Wait_time T_COV_ 
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*T_ × Year, p = .012 ; year possibly violate sph
*Comment: T_COV_ B = .001 (positive), Wald 6.385. Year's protective effect (HR .861 at time 0)
*fades as follow-up lengthens. On 206 rows p = .012; on 103 unique patients it would be about .07.
*Verdict: possible violation, fragile.
    


TIME PROGRAM.
COMPUTE T_COV_ = T_ * Age.
COXREG   Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Year_surgery Age Surg_care Heart_transplant Wait_time T_COV_ 
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*T_ × Age .023 age possibley violates
*Comment: T_COV_ Wald 5.193. B shows as .000 because age is in years and time in days,
*so direction not read. On 206 rows p = .023; on 103 unique patients about .11.
*Verdict: possible violation, fragile.
    


TIME PROGRAM.
COMPUTE T_COV_ = T_ * Surg_care.
COXREG   Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Year_surgery Age Surg_care Heart_transplant Wait_time T_COV_ 
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*Comment: T_COV_ B = .002 (positive), Wald 6.424, p = .011. The benefit of surgical care
*(HR .257 at time 0) fades as follow-up lengthens. About .07 on 103 unique patients, and the
*trend rests on only 12 patients with surgical care. Verdict: possible violation, least reliable.


TIME PROGRAM.
COMPUTE T_COV_ = T_ * Heart_transplant.
COXREG   Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Year_surgery Age Surg_care Heart_transplant Wait_time T_COV_ 
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*Comment: T_COV_ B = .004 (positive), Wald 4.251, p = .039. The benefit of transplant
*(HR .172 at time 0) fades as follow-up lengthens. About .15 on 103 unique patients.
*This tests the fixed 0/1 coding, so immortal-time bias could produce the same pattern.
*Verdict: possible violation, interpret with caution.

TIME PROGRAM.
COMPUTE T_COV_ = T_ * Wait_time.
COXREG   Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Year_surgery Age Surg_care Heart_transplant Wait_time T_COV_ 
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*Comment: T_COV_ Wald 5.594, p = .018; B shows as .000 (days by days), so direction not read.
*About .09 on 103 unique patients. Waiting time is 0 for everyone without a transplant,
*so its trend overlaps with transplant. Verdict: possible violation, fragile.

TIME PROGRAM.
COMPUTE T_COV_1 = T_ * Wait_time.
COMPUTE T_COV_2 = T_ * Age.
COMPUTE T_COV_3 = T_ * Surg_care.
COMPUTE T_COV_4 = T_ * Heart_transplant.
COMPUTE T_COV_5 = T_ * Year_surgery.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Year_surgery Age Surg_care Heart_transplant Wait_time T_COV_1 T_COV_2 T_COV_3 T_COV_4 T_COV_5
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*Comment: all five time-dependent terms together (1 wait time, 2 age, 3 surgical care,
*4 transplant, 5 year); -2LL = 1276.328. P-values: T_COV_1 .440, T_COV_2 .110, T_COV_3 .656,
*T_COV_4 .152, T_COV_5 .038. Only year of surgery stays significant; the other trends overlap
*and lose significance. Verdict: drop the least significant term, T_COV_3 (surgical care).

*drop least signficant time varying covariate surg care
    
TIME PROGRAM.
COMPUTE T_COV_1 = T_ * Wait_time.
COMPUTE T_COV_2 = T_ * Age.
COMPUTE T_COV_4 = T_ * Heart_transplant.
COMPUTE T_COV_5 = T_ * Year_surgery.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Year_surgery Age Surg_care Heart_transplant Wait_time T_COV_1 T_COV_2 T_COV_4 T_COV_5
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*Comment: -2LL = 1276.528, a change of 0.2 on 1 df from the five-term model (p about .65),
*so dropping T_COV_3 cost nothing. P-values: T_COV_1 .440, T_COV_2 .089, T_COV_4 .149,
*T_COV_5 .005. Verdict: drop T_COV_1 (waiting time) next.

*drop wait time
    
TIME PROGRAM.
COMPUTE T_COV_2 = T_ * Age.
COMPUTE T_COV_4 = T_ * Heart_transplant.
COMPUTE T_COV_5 = T_ * Year_surgery.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Year_surgery Age Surg_care Heart_transplant Wait_time T_COV_2 T_COV_4 T_COV_5
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*Comment: P-values: T_COV_2 .086, T_COV_4 .106, T_COV_5 .004. Verdict: drop T_COV_4 (transplant) next.
*This removes the trend term only; the fixed transplant coding still needs to be flagged.

*drop transplant
    
TIME PROGRAM.
COMPUTE T_COV_2 = T_ * Age.
COMPUTE T_COV_5 = T_ * Year_surgery.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Year_surgery Age Surg_care Heart_transplant Wait_time T_COV_2 T_COV_5
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*Comment: -2LL = 1280.797 (7 df); against the nine-term model the change is 4.27 on 2 df (p about .12),
*so removing both terms did not worsen the fit. Both remaining terms are significant:
*T_COV_2 (age) Wald 7.265, p = .007; T_COV_5 (year) Wald 9.640, p = .002.
*Verdict: proportional hazards violated for age and year of surgery; keep both terms in all later models.
*Main effects are now effects at time 0. P-values are too small because of the duplicated rows
*(about .06 for age and .03 for year on 103 unique patients).

*CHECKING FUNCTIONAL TERMS
    *Check distributions first and do categorisation
    
FREQUENCIES VARIABLES=Year_surgery Age Wait_time
  /FORMAT=NOTABLE
  /STATISTICS=MINIMUM MAXIMUM MEAN MEDIAN
  /ORDER=ANALYSIS.


RECODE Year_surgery (Lowest thru 71=0) (72 thru Highest=1) INTO Year_SurgeryCat.
RECODE Age (Lowest thru 47=0) (48 thru Highest=1) INTO AgeCat.
RECODE Wait_time (Lowest thru 10=0) (10.01 thru Highest=1) INTO Wait_TimeCat.
VARIABLE LABELS Year_SurgeryCat 'Year of surgery (median split)'
  /AgeCat 'Age (median split)'
  /Wait_TimeCat 'Waiting time (median split)'.
VALUE LABELS Year_SurgeryCat 0 '71 or earlier' 1 '72 or later'
  /AgeCat 0 '47 or younger' 1 '48 or older'
  /Wait_TimeCat 0 '10 days or less' 1 'More than 10 days'.
EXECUTE.
FREQUENCIES VARIABLES=Year_SurgeryCat AgeCat Wait_TimeCat.

*model A (age categorised)
    
TIME PROGRAM.
COMPUTE T_COV_2 = T_ * AgeCat.
COMPUTE T_COV_5 = T_ * Year_surgery.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /CONTRAST (AgeCat)=Indicator(1)
  /METHOD=ENTER Year_surgery AgeCat Surg_care Heart_transplant Wait_time T_COV_2 T_COV_5
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*Model B (year categorised)
    
TIME PROGRAM.
COMPUTE T_COV_2 = T_ * Age.
COMPUTE T_COV_5 = T_ * Year_SurgeryCat.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /CONTRAST (Year_SurgeryCat)=Indicator(1)
  /METHOD=ENTER Year_SurgeryCat Age Surg_care Heart_transplant Wait_time T_COV_2 T_COV_5
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*Model C (waiting time categorised)
    
TIME PROGRAM.
COMPUTE T_COV_2 = T_ * Age.
COMPUTE T_COV_5 = T_ * Year_surgery.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /CONTRAST (Wait_TimeCat)=Indicator(1)
  /METHOD=ENTER Year_surgery Age Surg_care Heart_transplant Wait_TimeCat T_COV_2 T_COV_5
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).


**Comment: age categorised (median split), time term built from AgeCat. -2LL = 1299.938, 19.1 higher than the continuous model (1280.797). T_COV_2 loses significance (p = .215). Verdict: continuous age fits better.
*Comment: year categorised (median split), -2LL = 1287.098, 6.3 higher than the continuous model. Verdict: continuous year fits better.
*Comment: waiting time categorised (median split; 106 vs 100 rows), -2LL = 1281.983, 1.2 higher than the continuous model. Verdict: no gain from categorising; keep continuous.

*BIVARIATE SCREENING
    
*Bivariate: year with its time term.
TIME PROGRAM.
COMPUTE T_COV_5 = T_ * Year_surgery.
COXREG Survtime
  /STATUS=Status(1)
  /METHOD=ENTER Year_surgery T_COV_5
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*Bivariate: age with its time term.
TIME PROGRAM.
COMPUTE T_COV_2 = T_ * Age.
COXREG Survtime
  /STATUS=Status(1)
  /METHOD=ENTER Age T_COV_2
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*Bivariate: surgical care.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Surg_care
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*Bivariate: heart transplant.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /METHOD=ENTER Heart_transplant
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*Bivariate: waiting time.
COXREG Survtime
  /STATUS=Status(1)
  /METHOD=ENTER Wait_time
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*Comment: bivariate screening by likelihood-ratio test (cut-off p < 0.2): year with T_COV_5 chi-square 16.815, 2 df, p < .001;
*age with T_COV_2 14.670, 2 df, p < .001; surgical care 15.991, 1 df, p < .001; heart transplant 51.499, 1 df, p < .001;
*waiting time 36.446, 1 df, p < .001. Verdict: all five variables enter the multivariable model.

*CHECK INTERACTIONS
    *Reduced model
    
TIME PROGRAM.
COMPUTE T_COV_2 = T_ * Age.
COMPUTE T_COV_5 = T_ * Year_surgery.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Year_surgery Age Surg_care Heart_transplant Wait_time T_COV_2 T_COV_5
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).
*Comment: reduced model (no interactions), -2LL 1280.797, 7 df.
*Full model
    
TIME PROGRAM.
COMPUTE T_COV_2 = T_ * Age.
COMPUTE T_COV_5 = T_ * Year_surgery.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Year_surgery Age Surg_care Heart_transplant Wait_time T_COV_2 T_COV_5
     Age*Surg_care Age*Heart_transplant Age*Wait_time Age*Year_surgery
     Heart_transplant*Surg_care Surg_care*Wait_time Surg_care*Year_surgery
     Heart_transplant*Wait_time Heart_transplant*Year_surgery Wait_time*Year_surgery
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).
*Comment: full model, -2LL 1257.225, 15 df (SPSS dropped 2 redundant terms: Heart_transplant*Surg_care, Heart_transplant*Wait_time).
*LR = 1280.797 - 1257.225 = 23.57 on 8 df, above 15.51, so interactions are significant. Limitation: sample too small for all terms.
*SELECTING INTERACTION TERMS (backward elimination, LR)
TIME PROGRAM.
TIME PROGRAM.
COMPUTE T_COV_Age = T_ * Age.
COMPUTE T_COV_YearSurg = T_ * Year_surgery.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=BSTEP(LR) Year_surgery Age Surg_care Heart_transplant Wait_time T_COV_Age T_COV_YearSurg
     Age*Surg_care Age*Heart_transplant Age*Wait_time Age*Year_surgery
     Heart_transplant*Surg_care Surg_care*Wait_time Surg_care*Year_surgery
     Heart_transplant*Wait_time Heart_transplant*Year_surgery Wait_time*Year_surgery
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).
*Comment: BSTEP stopped at step 9. Interactions kept: Age*Heart_transplant, Age*Year_surgery, Surg_care*Year_surgery, Wait_time*Year_surgery.
*SPSS also removed the Age and Heart_transplant main effects, so they are re-entered below.

*now renter the dropped main varaiables with the surviving interaction terms
    
TIME PROGRAM.
COMPUTE T_COV_Age = T_ * Age.
COMPUTE T_COV_YearSurg = T_ * Year_surgery.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Year_surgery Surg_care Wait_time T_COV_Age T_COV_YearSurg
     Age*Heart_transplant Age*Year_surgery Surg_care*Year_surgery Wait_time*Year_surgery
     Age Heart_transplant
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).
*Comment: -2LL 1261.335 (11 df). Age*Year_surgery is the least significant interaction (p = .204), so it is dropped first.
*remove non sigfinact interaction terms; starting with least signficant
    
TIME PROGRAM.
COMPUTE T_COV_Age = T_ * Age.
COMPUTE T_COV_YearSurg = T_ * Year_surgery.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Year_surgery Surg_care Wait_time T_COV_Age T_COV_YearSurg
     Age*Heart_transplant Surg_care*Year_surgery Wait_time*Year_surgery
     Age Heart_transplant
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).
*Comment: -2LL 1262.992 (10 df); LR for dropping Age*Year_surgery = 1.66, 1 df, not significant. Age*Heart_transplant (p = .172) goes next.
*now remove agextransplant
    
TIME PROGRAM.
COMPUTE T_COV_Age = T_ * Age.
COMPUTE T_COV_YearSurg = T_ * Year_surgery.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Year_surgery Surg_care Wait_time T_COV_Age T_COV_YearSurg
     Surg_care*Year_surgery Wait_time*Year_surgery Age Heart_transplant
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).
*Comment: -2LL 1264.860 (9 df); LR for dropping = 1.87, 1 df, not significant. All terms p < .05, so this is the final model.
*No confounding step: no main variable was dropped. Estimates use the 206 duplicated rows; rerun on the 103 unique patients.

*Confounding not assessed: no main variable was dropped, because all five main variables remain and all terms have p < .05.
*Only non-significant interaction terms were removed
    
*FINAL MODEL
    

TIME PROGRAM.
COMPUTE T_COV_Age = T_ * Age.
COMPUTE T_COV_YearSurg = T_ * Year_surgery.
COXREG Survtime
  /STATUS=Status(1)
  /CONTRAST (Heart_transplant)=Indicator(1)
  /CONTRAST (Surg_care)=Indicator(1)
  /METHOD=ENTER Year_surgery Surg_care Wait_time T_COV_Age T_COV_YearSurg
     Surg_care*Year_surgery Wait_time*Year_surgery Age Heart_transplant
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).
