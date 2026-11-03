#DATA WRANGLING USING diamonds dataframe in R

library(tidyverse)

?diamonds

view(diamonds)
 
#subset by row with filter()[used to select rows]


?filter

diamonds_id <- filter(diamonds, cut == "Ideal") # Create new dataset; diamonds_id by going to diamonds dataframe and choosing  rows in which the variable cut=ideal

view(diamonds_id)

diamonds_id <- filter(diamonds, price > 10000)

diamonds_id <- filter(diamonds,
                      cut == "Ideal",
                      price > 10000)     # By using a comma, between cut and price ; it means "and"

diamonds_id <- filter(diamonds,
                      cut == "Ideal"|
                      price > 10000)     # By using a vertical bar | between cut and price ; it means "or"

# Filter for missing values; USING; is.na(have missing values) or !is.na(do not have missing values)


#SUBSET BY COLUMNS USING select()[used to choose columns]

?select

diamonds_id <- select(diamonds, clarity, depth) # create dataset ; diamonds_id by going to diamonds dataframe and choosing  columns clarity and depth

diamonds_id <- select(diamonds, 1:4)  # create dataset ; diamonds_id by going to diamonds dataframe and choosing columns 1 to 4

diamonds_id <- select(diamonds, starts_with("c"))   # create dataset ; diamonds_id by going to diamonds dataframe and choosing columns that starit with c

diamonds_id <- select(diamonds, price, everything()) # create dataset ; diamonds_id by going to diamonds dataframe, and putting price first before everything(every other column)

diamonds_id <- select(diamonds, -price) ## create dataset ; diamonds_id by going to diamonds dataframe, and removing the column price(-)


#using the pipe; %>% 
#the pipe %>% means "and then" ,Think of it like a factory conveyor belt; Each %>% sends the data to the next machine

diamonds_id <- diamonds %>% 
  select(-price) # create new dataset; diamonds_id; get diamonds and take( %>% )  and  select(-price)[ select columns without price]


#reorder with arrange

diamonds_arr <- diamonds %>%
  arrange(color)          #make new dataset ; diamonds_arr; get diamonds and ( %>% ) arrange column "colour" 


diamonds_arr <- diamonds %>%
  arrange(carat, color)     #first arrange by carat and then by color

diamonds_arr <- diamonds %>%
  arrange(desc(carat)) # adding desc() before the variable arranges it by descending order

view(diamonds_arr)   

glimpse(diamonds_arr)


#add or modify columns with mutate()
#mutate adds new columns


 