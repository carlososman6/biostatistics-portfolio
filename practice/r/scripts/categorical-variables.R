library(tidyverse)
bells <- read_csv(here::here("data", "raw", "bells.csv"))  # BELLS trial data

#FACTOR VARIABLES from yt equittble equations

library(tidyverse)

#using bells dataframe

glimpse(bells) # after running this command you see that R doesnt consider some categorical variables like "treatment group" as indeed categorical variables but rather characters

summary(bells$`Treatment Group`) # running this command you dont get the categorical data you expect


attach(bells) #allows you to refer to the variables in the bells data frame directly without using  $

treatment_group <- factor(`Treatment Group`) # using the factor command, we are able to convert the treatment group variable into a categorical variable and then assigning this newly formed categorical data as "treatment_group" using the <- function

summary(treatment_group) # when you now run the summary command you see that now its a categorical variable

treatment_group # when you print out this new categorical variable you will see that there is a levels line at the bottom denoting the different categories; this wasnt there before.

levels(treatment_group) # here you can easily print out the different categories in this categorical data if you want to know the different categories

# next you can specify which categories you want to focus on
# start by creating a new categorical variable "treatment_group2"

treatment_group2 <- factor(`Treatment Group`, levels = c("Acyclovir–Placebo", "Prednisolone–Placebo")) # here i have decided to have treatment_group2 be categorical variable that only focuses on; "Prednisolone–Placebo" and "Acyclovir–Placebo" and to ignore the rest. PS; notice how when writing the factor code, the first part of it is the original "Treatment group" from the dataframe

treatment_group2  # when you print this out notive how R ignores the rest;

summary(treatment_group2) # and when i get the summary of it;  (i) notice how it ignores the rest ; puts them into NA(ii) may not appear here but R writes them inorder in which you also wrote them.

as.numeric(treatment_group) # running this command shows you how R visualises categorical data, it essentially views factor variables as underlying numeric variables by as it attaches a number as a label for each variable ; with 1 corresponding to the 1st level, 2 corresponding to the 2nd level and so on;

#KNOWING THIS, WE CAN NOW BUILD FACTOR VARIABLES FROM SCRATCH

# for example;
nums <- sample(1:3, 50, replace = TRUE) # here we have created a numerical variable containing number 1 to 3 and we asked R to make 50 of them; the replace part kind of confused but it  has to be = true.
nums # when you print it out you see numeric variables from 1 to 3 and they are 50

# lets assume we have a vector "levels"

levels <- c("first", "second", "third") # essentially we have a vector with 3 levels as mentioned

levels.default(nums) #when we run the levels command on nums we find no levels; because its a numeric variable

# lets create a numerical version of nums called "nums_fct" 

nums_fct <- factor(nums, labels = levels) # here are converting nums to categorical by giving its numeric variables labels from the vector "levels" and we call this new variable nums_fct

nums_fct #we print out nums_fct we see that the numeric variables have been replaced the labels from levels

levels.default(nums_fct) #here you can see the new levels in this new categorical variable

# SO ESSENTIALLY WE HAVE REVERSE ENGINEERED A FACTOR VARIABLE FROM A NUMERIC VARIABLE

#we can then communicate to R that first second and third are ordered

nums_fct <- factor(nums, labels = levels, ordered = TRUE) #we just add the ordered argument

nums_fct # now when we print out nums_fct we see at the bottom that they are ranked

qplot(nums_fct, geom = "bar") # here we draw a bar graph
