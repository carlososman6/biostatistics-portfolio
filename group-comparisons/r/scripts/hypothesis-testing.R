 # problem will be in the youtube video by equitable equations. https://youtu.be/oNpfjcIf2Es?si=zbAKoFGi6XTCAxp0

library(tidyverse)
library(moments)  # skewness()

# using air quality data set in R 

## PROBLEM 1;
# IS AVG Windspeed in city equal to 9mh?

View(airquality)

# Ho; AVG Windspeed in city equal to 9mh
# Ha; Average windspeed in city is not equal to 9mh

qplot(airquality$Wind, geom = "histogram") # good practice to visualise variable in graph format before continuing

any(is.na(airquality)) # checks if there are any NA values

sum(is.na(airquality))  # counts the number of NA values

sum(is.na(airquality$Wind)) # counts the number of NA values in chosen variable

skewness(airquality$Wind)  # checks for skewness; # Quick guide: How skewed is your data? (absolute skewness value)
# |skew|     Meaning                     What to do for mean test
# 0–0.5      Almost symmetric            → Use t-test (best choice)
# 0.5–1.0    Moderate skew               → t-test usually fine (esp. n > 50)
# 1.0–1.5    Clearly skewed              → t-test ok if n big (>100), else Wilcoxon safer
# 1.5–2.0    Heavily skewed              → Prefer Wilcoxon or transform data
# > 2.0      Extremely skewed            → Use Wilcoxon or transform (log/sqrt)

# so we shall now use the t test due to central limit theorem ; n> 30 hence we are dealing with sample means which is also normally distributed

t.test(airquality$Wind, mu = 9) # by adding the argument, "mu = 9"; we are telling R that the null hypothesis says that "AVG Windspeed in city equal to 9mh" and null always has =, if you dont include that argument then R defaults to mu = 0, ALWAYS ADD THE NULL ARGUMENT

t.test(airquality$Wind) # notice the difference

## PROBLEM 2
#2. A certain solar array will only be cost-effective if mean solar radiation is over 175 Langleys. Would it be a sound investment in light of this data?

#Ho;Solar mean radiation <= 175langles
#Ha; Solar mean radioation > 175 langleys

qplot(airquality$Solar.R, geom= "histogram")

t.test(airquality$Solar.R, mu = 175, alternative = "greater") # in this scenario, null = 175, but our problem focuses on  > 175, so we specify it


#from the results ; p >0.05; hence we should draw no conlusions from this and use it as justification to purchase that certain solar array as solar radiation > 175 can happen over 7% of the time



