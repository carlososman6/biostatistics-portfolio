* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.
FREQUENCIES VARIABLES=height weight FEV Bldgroup
  /STATISTICS=MINIMUM MAXIMUM
  /ORDER=ANALYSIS.

* Identify Duplicate Cases.
SORT CASES BY Patient(A).
MATCH FILES
  /FILE=*
  /BY Patient
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

* Identify Duplicate Cases.
SORT CASES BY Patient(A).
MATCH FILES
  /FILE=*
  /BY Patient
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast1.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast1.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast1 InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

COMPUTE BMI=weight / ((height  / 100) * (height/100)) .
EXECUTE.

DATASET ACTIVATE DataSet1.
RECODE height (Lowest thru 160=Copy) (175 thru Highest=Copy) (161 thru 169=Copy) INTO heightcat.
VARIABLE LABELS  heightcat 'height categories short moderate tall'.
EXECUTE.

RECODE height (Lowest thru 160=1) (161 thru 174=2) (175 thru Highest=3) INTO heightcat.
VARIABLE LABELS  heightcat 'height categories short moderate tall'.
EXECUTE.

DATASET ACTIVATE DataSet1.
FREQUENCIES VARIABLES=height weight
  /NTILES=4
  /STATISTICS=MEAN MEDIAN
  /ORDER=ANALYSIS.

FREQUENCIES VARIABLES=Bldgroup
  /STATISTICS=SUM
  /ORDER=ANALYSIS.

FREQUENCIES VARIABLES=height weight
  /FORMAT=NOTABLE
  /STATISTICS=MEAN MEDIAN MODE
  /ORDER=ANALYSIS.

FREQUENCIES VARIABLES=FEV
  /STATISTICS=MINIMUM MAXIMUM MEAN MEDIAN
  /ORDER=ANALYSIS.
