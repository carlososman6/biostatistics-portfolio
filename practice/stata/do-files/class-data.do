* Set once: the folder that contains this repository, using forward slashes (e.g. C:/Users/you/biostatistics-portfolio)
if "$repo" == "" global repo "REPLACE-WITH-PATH/biostatistics-portfolio"
log using "class_data", replace
***always log using; at the begining of every do file

import excel "$repo/data/raw/class_data.xlsx", sheet("Sheet1") firstrow

*Exploring data

browse
*****show excel sheet

describe
***** Summary about data

summarize
******give details about data

codebook
********Give details of all data


summarize, detail
******** gives details of numeric data


rename ID studynumber
*** renaming a variable; old name starts first; then new one last


****renaming variable label; can use more than one word, but has to be in double quotes
label variable studynumber "ID given to the study participants"

****summarazing data
**categorical data
tabulate Sex

tab Sex

***to cross tabulate; write tab then the two variable to cross tabulate

***to get proportions by row
tab Sex Religion, row

***to get proportions by column
tab Sex Religion, col


sort Age
***this sorts age in ascending order

***to reverse; sort by study number
sort studynumber


****change string to numeric variables; we code
**Sex; 1= Female   2= Male

***generate a new variable Sex2
generate Sex2 =.

browse


***=(single equal sign); assigns, 
***==(double equal sign); tells stat to take the equivalent

replace Sex2=1 if Sex=="F"

*** Above command tells stata let (new variable)Sex2=1 if (variable)Sex is F

*** now repeat for male
replace Sex2=2 if Sex=="M"


***to verify
tab Sex Sex2


**shortcut command
encode Sex, gen (Sex3)
bro







log close
****always put it at the end( advisable to but both at the beginning before writing commands)

