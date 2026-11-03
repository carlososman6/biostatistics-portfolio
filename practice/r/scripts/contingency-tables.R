library(tidyverse)
bells <- read_csv(here::here("data", "raw", "bells.csv"))  # BELLS trial data

# CONTIGENCY TABLES

#was using the bells dataframe


library(tidyverse) # always necessary at the begining inorder to utilise the tidyverse tools

table(bells$`Treatment Group`, bells$`Full Recovery in 9 Months`) # while writing this code, exposures come first(rows) and then outcomes (columns) next

dim(t) #dimensions-gives us number of rows and then number of columns 

t <- table(bells$`Treatment Group`, bells$`Full Recovery in 9 Months`) # we are assigning the results from the above command to "t"

str(t) #structure

addmargins(t) #this command adds marginal totals to the table

dim(t) # notice how we now have an extra column

marginSums(t) # this command gives us the granda total of the table

marginSums(t, 1) # the 1 included specifies the row totals only

marginSums(t, 2) # the 2 specifies the column totals only

proportions(t) # this gives the proportions of the total in each cell 

proportions(t, 1) # proportions of rows; should add up to 1 for each row

proportions(t, 2) # proportions of columns ; should also add up to 1

# Now we make a table by hand; ie making a table from scratch

counts <- c(1, 2, 3, 4) # we are making a vector called "counts" using the c() tool; where we put random numbers that we are going to put in the table

# its important to note that a contigency table is essential just a matrix

m <- matrix(counts, nrow = 2) # as your making the matrix, the first part is the object you want to input("counts") , the second you specify the number of rows you want using the nrows= tool

m  # when you print m out you see thats its a 2 x 2 table ie contigency table

# the data in counts is arranged in the table by column as shown in table generated from m, if you want it to be arranged by row, you add the byrow = TRUE command

m <- matrix(counts, nrow = 2, byrow = TRUE)

m    # when you print m again you see its arranged going by row first.
