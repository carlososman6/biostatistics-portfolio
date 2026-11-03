# learning SPSS; R replicate
library(haven)

library(tidyverse) 

hwg <- read_sav(here::here("data", "raw", "hwg.sav"))

hwg$Gender <- factor(hwg$Gender, levels = c(1,2), labels = c("Male", "Female"))  # converting to a factor variable of male and female

table(hwg$Gender)  # final table shows gender as 1 and 2
library(gtsummary)

hwg %>%
  select(Gender) %>%
  tbl_summary() #produces a lovely publication ready frequency table from gtsummary packages

summary(hwg) #descriptive statistics
sd(hwg$Height, na.rm = TRUE)  #sd height
sd(hwg$Weight, na.rm =TRUE)   #sd weight

glimpse(hwg) #also descriptive statistics with tidyverse

table(hwg$Gender) #repeat from earlier

library(ggplot2)

p <- ggplot(data = hwg, aes(x = Height)) # a plot(p) from the hwg data, with height at the x axis

p + geom_histogram(binwidth = 2, fill = "blue", colour = "white") + facet_wrap(~Gender) # plot p + bars added of width of 2 inches(binwidth), and fill colour is blue with colour white as the outline





