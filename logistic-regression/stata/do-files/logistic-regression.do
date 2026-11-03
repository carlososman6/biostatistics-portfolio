* Set once: the folder that contains this repository, using forward slashes (e.g. C:/Users/you/biostatistics-portfolio)
if "$repo" == "" global repo "REPLACE-WITH-PATH/biostatistics-portfolio"



log using "LOGISTIC_REGRESSION_QN", replace

import excel "$repo/data/raw/assignment 2_Number one_2025_2026_revised.xls", sheet("Sheet1") firstrow

rename Column3 PlateletCount
rename Column4 Race
rename Column5 Birthweight
rename Column6 Gestate
rename Column7 Delivery_Place
rename Column8 Multi_Pregnancy
rename Column9 Betamethasone
rename Column10 Tocolysis
rename Column11 Delivery_Mode
rename Column12 Apgar_score
rename Column13 Assisted_Ventilation
rename Column14 Pneumothorax
rename Column15 PDA
rename Column16 Sex
rename Column17 Died




label variable PlateletCount "Platelet Count"
label variable Race "Race of the mother"
label variable Birthweight "Birth weight of Baby"
label variable Gestate "Gestation age"
label variable Delivery_Place "Place of delivery"
label variable Multi_Pregnancy "Multiple pregnancy"
label variable Betamethasone "Mother treated with Betamethasone"
label variable Tocolysis "Tocolysis"
label variable Delivery_Mode "Mode of delivery"
label variable Apgar_score "Apgar score at 1 minute"
label variable Assisted_Ventilation "Assisted ventilation used"

label variable Pneumothorax "Pneumothorax occurred"
label variable PDA "Patent ductus arteriosus occurred"
label variable Sex "Sex of baby"
label variable Died "Baby died"


label define Race 1"white" 2"black" 3"native American" 4"Oriental"
label values Race Race

label define Delivery_Place 1"this hospital" 2"delivered from elsewhere"
label values Delivery_Place Delivery_Place

label define Multi_Pregnancy 1"yes" 0"No"
label values Multi_Pregnancy Multi_Pregnancy

label values Betamethasone Multi_Pregnancy 
label values Tocolysis Multi_Pregnancy

label define Delivery_Mode 1"abdominal" 2"vaginal" 
label values Delivery_Mode Delivery_Mode

label values Assisted_Ventilation Multi_Pregnancy
label values Pneumothorax Multi_Pregnancy
label values PDA Multi_Pregnancy

label define Sex 1"female" 2"male"
label values Sex Sex

label values Died Multi_Pregnancy


codebook


**No missing variables

misstable summarize PlateletCount Race Birthweight Gestate Delivery_Place Multi_Pregnancy Betamethasone Tocolysis Delivery_Mode Apgar_score Assisted_Ventilation Pneumothorax PDA Sex Died

codebook Race
gen Race_Cat =1 if Race ==1
replace Race_Cat =0 if Race!=1

label variable Race_Cat "Race categorized as White versus other races"
label define Race_Cat 1"White" 0"other Races"
label values Race_Cat Race_Cat

codebook Race_Cat





gen RaceCat2=1 if Race==1
replace RaceCat2=2 if Race ==2
replace RaceCat2=0 if Race ==3
replace RaceCat2=0 if Race ==4
label variable RaceCat2 "Race categorized into White versus black versus other races"
label define RaceCat2 1"white" 2"black" 0"other races"
label values RaceCat2 RaceCat2
codebook RaceCat2



gen Race_cat3=1 if Race==2
replace Race_cat3=0 if Race!=2
codebook Race_cat3
label variable Race_cat3 "Race categorized into black race versus the rest of races"
label define Race_cat3 1"black" 0"other races"
label values Race_cat3 Race_cat3


logit Died PlateletCount i.Race Birthweight Gestate i.Delivery_Place i.Multi_Pregnancy i.Betamethasone i.Tocolysis i.Delivery_Mode Apgar_score i.Assisted_Ventilation i.Pneumothorax i.PDA i.Sex

estimates store Race_as_is

logit Died PlateletCount i.Race_Cat Birthweight Gestate i.Delivery_Place i.Multi_Pregnancy i.Betamethasone i.Tocolysis i.Delivery_Mode Apgar_score i.Assisted_Ventilation i.Pneumothorax i.PDA i.Sex

estimates store Racecat

logit Died PlateletCount i.RaceCat2 Birthweight Gestate i.Delivery_Place i.Multi_Pregnancy i.Betamethasone i.Tocolysis i.Delivery_Mode Apgar_score i.Assisted_Ventilation i.Pneumothorax i.PDA i.Sex

estimates store RaceCat2

logit Died PlateletCount i.Race_cat3 Birthweight Gestate i.Delivery_Place i.Multi_Pregnancy i.Betamethasone i.Tocolysis i.Delivery_Mode Apgar_score i.Assisted_Ventilation i.Pneumothorax i.PDA i.Sex

estimates store Race_cat3

estimates stats Race_as_is Racecat RaceCat2 Race_cat3




**Race best analysed using model Racecat WHITE VERSUS OTHER RACES

gen BwtCat= 1 if Birthweight>=1000 
replace BwtCat=0 if Birthweight<1000
codebook BwtCat
label variable BwtCat "Birth weight categorized"
 label define BwtCat 1"1000gm and Above" 0"below 1000gm"
label values BwtCat BwtCat


logit Died PlateletCount i.Race_Cat i.BwtCat Gestate i.Delivery_Place i.Multi_Pregnancy i.Betamethasone i.Tocolysis i.Delivery_Mode Apgar_score i.Assisted_Ventilation i.Pneumothorax i.PDA i.Sex

estimates store BWTCAT

estimates stats BWTCAT Racecat


**Birth weight is better analyzed as Numerical


logit Died PlateletCount i.Race_Cat Birthweight Gestate i.Delivery_Place i.Multi_Pregnancy i.Betamethasone i.Tocolysis i.Delivery_Mode Apgar_score i.Assisted_Ventilation i.Pneumothorax i.PDA i.Sex

regress Died PlateletCount Birthweight Gestate i.Delivery_Place i.Multi_Pregnancy i.Betamethasone i.Tocolysis i.Delivery_Mode Apgar_score i.Assisted_Ventilation i.Pneumothorax i.PDA i.Sex i.Race_Cat



estat vif

**No collinearity

logit Died PlateletCount i.Race_Cat Birthweight Gestate i.Delivery_Place i.Multi_Pregnancy i.Betamethasone i.Tocolysis i.Delivery_Mode Apgar_score i.Assisted_Ventilation i.Pneumothorax i.PDA i.Sex

predict Dbeta, dbeta
predict Leverage, hat

sum Dbeta Leverage

**No outliers 

**CHECKING FOR INTERACTION 

**we have adequate sample size

logit Died PlateletCount i.Race_Cat Birthweight Gestate i.Delivery_Place i.Multi_Pregnancy i.Betamethasone i.Tocolysis i.Delivery_Mode Apgar_score i.Assisted_Ventilation i.Pneumothorax i.PDA i.Sex

estimates store reducedmodel


**logit Died PlateletCount i.Race_Cat Birthweight Gestate i.Delivery_Place i.Multi_Pregnancy i.Betamethasone i.Tocolysis i.Delivery_Mode Apgar_score i.Assisted_Ventilation i.Pneumothorax i.PDA i.Sex         c.PlateletCount#i.Race_Cat c.PlateletCount#c.Birthweight c.PlateletCount#c.Gestate c.PlateletCount#i.Delivery_Place c.PlateletCount#i.Multi_Pregnancy c.PlateletCount#i.Betamethasone c.PlateletCount#i.Tocolysis c.PlateletCount#i.Delivery_Mode c.PlateletCount#c.Apgar_score c.PlateletCount#i.Assisted_Ventilation c.PlateletCount#i.Pneumothorax c.PlateletCount#i.PDA c.PlateletCount#i.Sex       i.Race_Cat#c.Birthweight i.Race_Cat#c.Gestate i.Race_Cat#i.Delivery_Place i.Race_Cat#i.Multi_Pregnancy i.Race_Cat#i.Betamethasone i.Race_Cat#i.Tocolysis i.Race_Cat#i.Delivery_Mode i.Race_Cat#c.Apgar_score i.Race_Cat#i.Assisted_Ventilation i.Race_Cat#i.Pneumothorax i.Race_Cat#i.PDA i.Race_Cat#i.Sex           c.Birthweight#c.Gestate c.Birthweight#i.Delivery_Place c.Birthweight#i.Multi_Pregnancy c.Birthweight#i.Betamethasone c.Birthweight#i.Tocolysis c.Birthweight#i.Delivery_Mode c.Birthweight#c.Apgar_score c.Birthweight#i.Assisted_Ventilation c.Birthweight#i.Pneumothorax c.Birthweight#i.PDA c.Birthweight#i.Sex      c.Gestate#i.Delivery_Place c.Gestate#i.Multi_Pregnancy c.Gestate#i.Betamethasone c.Gestate#i.Tocolysis c.Gestate#i.Delivery_Mode c.Gestate#c.Apgar_score c.Gestate#i.Assisted_Ventilation c.Gestate#i.Pneumothorax c.Gestate#i.PDA c.Gestate#i.Sex     i.Delivery_Place#i.Multi_Pregnancy i.Delivery_Place#i.Betamethasone i.Delivery_Place#i.Tocolysis i.Delivery_Place#i.Delivery_Mode i.Delivery_Place#c.Apgar_score i.Delivery_Place#i.Assisted_Ventilation i.Delivery_Place#i.Pneumothorax i.Delivery_Place#i.PDA i.Delivery_Place#i.Sex  i.Multi_Pregnancy#i.Betamethasone i.Multi_Pregnancy#i.Tocolysis i.Multi_Pregnancy#i.Delivery_Mode i.Multi_Pregnancy#c.Apgar_score i.Multi_Pregnancy#i.Assisted_Ventilation i.Multi_Pregnancy#i.Pneumothorax i.Multi_Pregnancy#i.PDA i.Multi_Pregnancy#i.Sex         i.Betamethasone#i.Tocolysis i.Betamethasone#i.Delivery_Mode i.Betamethasone#c.Apgar_score i.Betamethasone#i.Assisted_Ventilation i.Betamethasone#i.Pneumothorax i.Betamethasone#i.PDA i.Betamethasone#i.Sex        i.Tocolysis#i.Delivery_Mode  i.Tocolysis#c.Apgar_score  i.Tocolysis#i.Assisted_Ventilation  i.Tocolysis#i.Pneumothorax  i.Tocolysis#i.PDA  i.Tocolysis#i.Sex       i.Delivery_Mode#c.Apgar_score i.Delivery_Mode#i.Assisted_Ventilation i.Delivery_Mode#i.Pneumothorax i.Delivery_Mode#i.PDA i.Delivery_Mode#i.Sex          c.Apgar_score#i.Assisted_Ventilation c.Apgar_score#i.Pneumothorax c.Apgar_score#i.PDA c.Apgar_score#i.Sex            i.Assisted_Ventilation#i.Pneumothorax i.Assisted_Ventilation#i.PDA i.Assisted_Ventilation#i.Sex        i.Pneumothorax#i.PDA i.Pneumothorax#i.Sex   i.PDA#i.Sex 



stepwise, pr(0.05) : logit Died PlateletCount  Birthweight Gestate i.Multi_Pregnancy i.Multi_Pregnancy i.Betamethasone i.Tocolysis i.Delivery_Mode Apgar_score i.Assisted_Ventilation i.Pneumothorax i.PDA i.Sex i.Race_Cat

*** Pneumothorax Birthweight Gestate Race_Cat Assisted_Ventilation

*logit Died PlateletCount i.Race_Cat Birthweight Gestate i.Delivery_Place i.Multi_Pregnancy i.Betamethasone i.Tocolysis i.Delivery_Mode Apgar_score i.Assisted_Ventilation i.Pneumothorax i.PDA i.Sex            i.Pneumothorax#c.PlateletCount i.Pneumothorax#i.Race_Cat i.Pneumothorax#c.Birthweight i.Pneumothorax#c.Gestate i.Pneumothorax#i.Delivery_Place i.Pneumothorax#i.Multi_Pregnancy i.Pneumothorax#i.Betamethasone i.Pneumothorax#i.Tocolysis i.Pneumothorax#i.Delivery_Mode i.Pneumothorax#c.Apgar_score i.Pneumothorax#i.Assisted_Ventilation i.Pneumothorax#i.PDA i.Pneumothorax#i.Sex                c.Birthweight#c.PlateletCount c.Birthweight#i.Race_Cat c.Birthweight#c.Gestate c.Birthweight#i.Delivery_Place c.Birthweight#i.Multi_Pregnancy c.Birthweight#i.Betamethasone c.Birthweight#i.Tocolysis c.Birthweight#i.Delivery_Mode c.Birthweight#c.Apgar_score c.Birthweight#i.Assisted_Ventilation  c.Birthweight#i.PDA c.Birthweight#i.Sex             c.Gestate#c.PlateletCount c.Gestate#i.Race_Cat c.Gestate#i.Delivery_Place c.Gestate#i.Multi_Pregnancy c.Gestate#i.Betamethasone c.Gestate#i.Tocolysis c.Gestate#i.Delivery_Mode c.Gestate#c.Apgar_score c.Gestate#i.Assisted_Ventilation c.Gestate#i.PDA c.Gestate#i.Sex        i.Race_Cat#c.PlateletCount i.Race_Cat#i.Delivery_Place i.Race_Cat#i.Multi_Pregnancy i.Race_Cat#i.Betamethasone i.Race_Cat#i.Tocolysis i.Race_Cat#i.Delivery_Mode i.Race_Cat#c.Apgar_score i.Race_Cat#i.Assisted_Ventilation  i.Race_Cat#i.PDA i.Race_Cat#i.Sex                          i.Assisted_Ventilation#c.PlateletCount  i.Assisted_Ventilation#i.Delivery_Place i.Assisted_Ventilation#i.Multi_Pregnancy i.Assisted_Ventilation#i.Betamethasone i.Assisted_Ventilation#i.Tocolysis i.Assisted_Ventilation#i.Delivery_Mode i.Assisted_Ventilation#c.Apgar_score  i.Assisted_Ventilation#i.PDA i.Assisted_Ventilation#i.Sex 




**these are the possible interaction terms





logit Died PlateletCount i.Race_Cat Birthweight Gestate i.Delivery_Place i.Multi_Pregnancy i.Betamethasone i.Tocolysis i.Delivery_Mode Apgar_score i.Assisted_Ventilation i.Pneumothorax i.PDA i.Sex
estimates store reducedmodel

logit Died PlateletCount i.Race_Cat Birthweight Gestate i.Delivery_Place i.Multi_Pregnancy i.Betamethasone i.Tocolysis i.Delivery_Mode Apgar_score i.Assisted_Ventilation i.Pneumothorax i.PDA i.Sex   i.Pneumothorax#c.Birthweight  i.Pneumothorax#c.Gestate  i.Pneumothorax#i.Race_Cat  i.Pneumothorax#i.Assisted_Ventilation c.Birthweight#c.Gestate c.Birthweight#i.Race_Cat c.Birthweight#i.Assisted_Ventilation  c.Gestate#i.Race_Cat c.Gestate#i.Assisted_Ventilation  i.Race_Cat#i.Assisted_Ventilation 

estimates store fullmodel

**perform a likelihood ratio test

lrtest ( fullmodel ) ( reducedmodel ), stats

** the likelihood test is not significant. reduced is better. we do not reject the null hypothesis that hypothesis of no interaction

**CONFOUNDING 
**stepwise to identify independent significant variables
stepwise, pr(0.05) : logit Died PlateletCount i.Race_Cat Birthweight Gestate i.Delivery_Place i.Multi_Pregnancy i.Betamethasone i.Tocolysis i.Delivery_Mode Apgar_score i.Assisted_Ventilation i.Pneumothorax i.PDA i.Sex

logit Died  i.Race_Cat Birthweight Gestate  i.Assisted_Ventilation i.Pneumothorax

logistic Died  i.Race_Cat Birthweight Gestate  i.Assisted_Ventilation i.Pneumothorax 

logit Died  i.Race_Cat Birthweight Gestate  i.Assisted_Ventilation i.Pneumothorax, or

**add betamethasone
logit Died  i.Race_Cat Birthweight Gestate  i.Assisted_Ventilation i.Pneumothorax i.Betamethasone, or
**add Multiple pregnancy
logit Died  i.Race_Cat Birthweight Gestate  i.Assisted_Ventilation i.Pneumothorax i.Multi_Pregnancy, or

**add PlateletCount
logit Died  i.Race_Cat Birthweight Gestate  i.Assisted_Ventilation i.Pneumothorax PlateletCount, or

**Add PDA
logit Died  i.Race_Cat Birthweight Gestate  i.Assisted_Ventilation i.Pneumothorax i.PDA, or

**add place of delivery
logit Died  i.Race_Cat Birthweight Gestate  i.Assisted_Ventilation i.Pneumothorax i.Delivery_Place, or

**Add Apgar_score
logit Died  i.Race_Cat Birthweight Gestate  i.Assisted_Ventilation i.Pneumothorax Apgar_score, or

**Add Tocolysis
logit Died  i.Race_Cat Birthweight Gestate  i.Assisted_Ventilation i.Pneumothorax i.Tocolysis, or

**Add Sex
logit Died  i.Race_Cat Birthweight Gestate  i.Assisted_Ventilation i.Pneumothorax i.Sex, or

*Add delivery mode

logit Died  i.Race_Cat Birthweight Gestate  i.Assisted_Ventilation i.Pneumothorax i.Delivery_Mode, or

**Final Model is the Reduced model
logit Died  i.Race_Cat Birthweight Gestate  i.Assisted_Ventilation i.Pneumothorax

estimates store finalmodel


***testing goodness of the model

estat gof, group(10)




