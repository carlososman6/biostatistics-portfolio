* Set once: the folder that contains this repository, using forward slashes (e.g. C:/Users/you/biostatistics-portfolio)
if "$repo" == "" global repo "REPLACE-WITH-PATH/biostatistics-portfolio"

log using "Drug A", replace

* Data: sheet "Drug A- Data for software" of the instructor workbook (survival_analysis example.xlsx, not redistributed),
* saved as Drug A.dta in data/raw.
use "$repo/data/raw/Drug A.dta", clear


stset SurvivalTime, failure(Status==1)

*Summary statisitcs
stsum

*avg hazard= incidence rate
*


*
stdescribe

*km table
sts list
*****note; it brings in time 11; which i supposed to be a censored ; but probability doesnt change till 13

*
sts list, failure
***gives a cumulative hazard function  Ht(-ln Stj)

*tabulate failure rate
strate

** km survival function
sts graph

**km failure function
sts graph, failure
*****gives the cumulative survival functions





log close