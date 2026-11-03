library(tidyverse)
malaria_data <- read_csv(here::here("data", "raw", "Malaria cases, suspected, number.csv"))  # WHO GHO suspected malaria cases

diseases_data <- data.frame(  PatientID = 1:10,  Age = c(34, 45, 29, 56, 67, 38, 50, 41, 60, 27), 
                             Sex = c("F", "M", "F", "M", "F", "M", "F", "M", "F", "M"), 
                             Region = c("North", "South", "East", "West", "North", "East", "South", "West", "North", "East"), 
                             Hypertension = c(1, 0, 0, 1, 1, 0, 1, 0, 1, 0), 
                             Diabetes = c(0, 1, 0, 1, 0, 0, 1, 1, 0, 0), 
                             HeartDisease = c(0, 0, 1, 1, 0, 1, 0, 0, 1, 0), 
                             DiseaseStatus = c("Positive", "Negative", "Negative", "Positive", "Positive", "Negative", "Positive", "Negative", "Positive", "Negative"))

x <- 9

classmates <- data.frame(class_id = 1:4, names_classmates = c("susan","melvin","eunice","osman"), weight_kgs = c("cup",67,79,71))

classmates$weight_kgs <- as.numeric(classmates$weight_kgs)
getwd()

# (working-directory line removed; open the project folder or set your own path)

summary(malaria_data)

Bells_Palsy_Clinical_Trial <- read_csv(here::here("data", "raw", "bells.csv"))  # same BELLS data used below

summary(mtcars)
?summary

str(mtcars)

library(tidyverse)

glimpse(mtcars)

?glimpse

summary(Bells_Palsy_Clinical_Trial)

glimpse(Bells_Palsy_Clinical_Trial)

Bells_Palsy_Clinical_Trial$Sex <- as.factor(Bells_Palsy_Clinical_Trial$Sex)

glimpse(Bells_Palsy_Clinical_Trial)

table_sex <- table(Bells_Palsy_Clinical_Trial$Sex)

print(table_sex)

table_treatment <- table(Bells_Palsy_Clinical_Trial$`Treatment Group`)

