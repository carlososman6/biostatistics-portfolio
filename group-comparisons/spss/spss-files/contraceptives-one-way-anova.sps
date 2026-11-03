* Set once: the folder that contains this repository, then run.
CD 'REPLACE-WITH-PATH/biostatistics-portfolio'.
GET DATA
  /TYPE=XLSX
  /FILE='data/raw/one_Way_ANOVA classwork_2022.xlsx'
  /SHEET=name 'Sheet2'
  /READNAMES=on.
DATASET NAME DataSet1 WINDOW=FRONT.
* Encoding: UTF-8.

*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*ONE WAY ANOVA SPSS.
*- Analyze - compare means - one way ANOVA.
*- Click on dependent and put in dependent list.
*- Click independent and put in box labeled factor.
*- Click options - descriptives - homogeneity of variances and means plots.
*- Click on Post hoc & click Tukey - continue - OK.
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


ONEWAY wtgain BY contraceptive
  /STATISTICS DESCRIPTIVES HOMOGENEITY 
  /MISSING ANALYSIS
  /CRITERIA=CILEVEL(0.95).
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*From above OUTPUT; note that to check for homoegenity of variances; SPSS performs a levenes tests with the following hypotheses;.
*Ho; There is no difference in population variance of the four groups.
*Ha: there is a difference in population variance.

*NOTE; For assumption to be fulfilled the p-value SHOULD NOT BE significant.
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* You can Also see the ANOVA table; we use it to conclude on the hypotheses of interest from our research question.
*QUESTION;
     *Family health worker receives complaints of weight gain from clients on contraceptives. 
    *He has also noticed & is aware that wt gain varies from individual to individual. 
    *He wants to find out if it is due to genetic variation or contraceptives. He compares four different contraceptives.

*HYPOTHESIS
*Ho: there is no difference in weight gain among populations using different contraceptives; µ1=µ2=µ3=µ4.
*Ha: the average weight gain in the population of at least one group is different; µi≠µj.

*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




ONEWAY wtgain BY contraceptive
  /PLOT MEANS
  /MISSING ANALYSIS
  /CRITERIA=CILEVEL(0.95).

*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
