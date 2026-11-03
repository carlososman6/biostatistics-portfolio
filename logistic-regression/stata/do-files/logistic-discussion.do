* Set once: the folder that contains this repository, using forward slashes (e.g. C:/Users/you/biostatistics-portfolio)
if "$repo" == "" global repo "REPLACE-WITH-PATH/biostatistics-portfolio"
log using "number 1", replace

import excel "$repo/data/raw/assignment 2_Number one_2025_2026_revised.xls", sheet("Sheet1") firstrow

bro

*rename variables
rename Column3  platelet
rename Column4  race
rename Column5  birthwt
rename Column6  gestage
rename Column7  placedev
rename Column8  multpreg
rename Column9  betamet
rename Column10 tocolys
rename Column11 modedev
rename Column12 apgar1
rename Column13 ventil
rename Column14 pneumo
rename Column15 pda
rename Column16 sexbaby
rename Column17 died


*label 

label variable platelet  "Platelet count"
label variable race      "Race of mother (1=white,2=black,3=native American,4=oriental)"
label variable birthwt   "Birth weight of baby (grams)"
label variable gestage   "Gestation age"
label variable placedev  "Place of delivery (1=this hospital,2=elsewhere)"
label variable multpreg  "Multiple pregnancy (1=yes,0=no)"
label variable betamet   "Mother treated with betamethasone (1=yes,0=no)"
label variable tocolys   "Tocolysis (1=yes,0=no)"
label variable modedev   "Mode of delivery (1=abdominal,2=vaginal)"
label variable apgar1    "Apgar score at 1 minute"
label variable ventil    "Assisted ventilation used (1=yes,0=no)"
label variable pneumo    "Pneumothorax occurred (1=yes,0=no)"
label variable pda       "Patent ductus arteriosus occurred (1=yes,0=no)"
label variable sexbaby   "Sex of baby (1=female,2=male)"
label variable died      "Baby died (1=yes,0=no)"



*(i) as is

*(ii)
gen whiterace = 0
replace whiterace = 1 if race == 2 | race ==3 | race == 4
label variable whiterace "White=0 and Other races =1"
tab whiterace

*(iii)
gen whiteblackrace = 0
replace whiteblackrace =1 if race == 1
replace whiteblackrace =2 if race == 2
replace whiteblackrace =3 if race ==3 | race ==4 
label variable whiteblackrace "White=1 vs Black=2 vs Others=3"
tab whiteblackrace


*(iv)
gen blackrace = 0
replace blackrace =1 if race == 2
label variable blackrace "Black=1 vs Others=0"
tab blackrace

*generate the different models
*as is
logistic died platelet i.race birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby
estimates store race_estimates

*(ii)
logistic died platelet i.whiterace birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby
estimates store whiterace

*(iii)
logistic died platelet i.whiteblackrace birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby
estimates store whiteblack_race

*(iv)
logistic died platelet i.blackrace birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby
estimates store black_race


*now we compare the 4 models ;
estimates stats race_estimates whiterace whiteblack_race black_race


*our model now
logistic died platelet i.whiterace birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby


*part 	II
*birthwt as is
*birthwt_cat

gen birthwt_cat = 0
replace birthwt_cat = 1 if birthwt >= 1000
replace birthwt_cat = . if birthwt==.
label variable birthwt_cat "Birthweight 1000gm and above=1"
tab birthwt_cat

*model as is
logistic died platelet i.whiterace birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby
estimates store as_is

*birthwt_cat
logistic died platelet i.whiterace i.birthwt_cat gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby
estimates store birthwt_cat

*compare birthweight models
estimates stats as_is birthwt_cat


*model now 
logistic died platelet i.whiterace birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby


*CHECK FOR COLLINEARITY

*predict linear function
predict logitlog, xb

*run linear regression model with the linear function

regress logitlog platelet i.whiterace birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby

estat vif

*no multicollinearity

*model now
logistic died platelet i.whiterace birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby


*CHECK OUTLIERS
*Predict dbeta and leverage
predict dbetas, dbeta
sum dbetas

predict leverage, hat
sum leverage


*leverage <0.5, dbetas <1; so no outliers


*variable selection 
*run a stepwise backward to identify significant predictors; these will be used to form the interaction terms; due to sample size limitations
stepwise, pr(0.05) : logistic died platelet i.whiterace birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby


*ASSESS FOR INTERACTION

*Full model with interaction terms
logistic died c.platelet i.whiterace c.birthwt c.gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby i.pneumo#i.whiterace  i.pneumo#c.birthwt i.pneumo#c.gestage i.pneumo#i.ventil i.whiterace#c.birthwt i.whiterace#c.gestage i.whiterace#i.ventil  c.birthwt#c.gestage  c.birthwt#i.ventil c.gestage#i.ventil
estimates store fullmodel

*reduced model
logistic died platelet i.whiterace birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby
estimates store reducedmodel


lrtest ( reducedmodel) ( fullmodel), stats

*likelihood ratio test for the two models was nonsignificant: no interaction



*ASSESS FOR CONFOUNDING;
*remove nonsignificant variables
*apply stepwise to remain with  significant predictors
stepwise, pr(0.05) : logistic died platelet i.whiterace birthwt gestage i.placedev i.multpreg i.betamet i.tocolys i.modedev apgar1 i.ventil i.pneumo i.pda i.sexbaby

*final model with significant predictors; CRUDE MODEL
logistic died i.whiterace birthwt gestage i.ventil i.pneumo

*order of remove from last; betamet, multpreg,platelet, pda,placedev,apgar,tocolys,sexbaby,modedev

*bring back betamethasone
logistic died i.whiterace birthwt gestage i.ventil i.pneumo i.betamet
















log close