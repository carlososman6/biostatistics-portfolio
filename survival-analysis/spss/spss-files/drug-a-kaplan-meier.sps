* Set the working directory to the folder that contains this repository, then run.
CD 'REPLACE-WITH-PATH/biostatistics-portfolio'.
* Encoding: UTF-8.

*enter data

* Source: sheet 'Drug A- Data for software' of the instructor workbook (not redistributed), saved as Drug A.dta.
GET STATA FILE='data/raw/Drug A.dta'.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

*km

DATASET ACTIVATE DataSet1.
KM SurvivalTime
  /STATUS=Status(1)
  /PRINT TABLE MEAN.

KM SurvivalTime
  /STATUS=Status(1)
  /PRINT TABLE MEAN
  /PERCENTILES
  /PLOT SURVIVAL.
