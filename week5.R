# Wrangle
# 9 Introduction, 10 Tibbles, 11 Data Import

library(tidyverse)

# 9 Introduction
# tibbles, data import, tidy data
# relational data, strings, factors, dates and times

# 10 Tibbles
vignette("tibble")

# coerce data frames into tibbles
as_tibble(iris)

# create own tibble, recycle inputs of length 1
tibble(
  x = 1:5, 
  y = 1, 
  z = x ^ 2 + y
)

# will not work
tibble(
  x = 1:5, 
  y = 1:2, 
  z = x ^ 2 + y
)

# weird column names: backticks
tb <- tibble(
  `:)` = "smile",
  ` ` = "space",
  `2000` = "number"
)
tb

# tribble, transposed tibble, write code as displayed in tibble
tribble(
  ~x, ~y, ~z,
  #--/--/--     make it obvious where the header is
  "a", 2, 3.6,
  "b", 1, 8.5
)

# 10.3 tibbles vs data.frame
# 10.3.1 printing

tibble(
  a = lubridate::now() + runif(1e3) * 86400,
  b = lubridate::today() + runif(1e3) * 30,
  c = 1:1e3, 
  d = runif(1e3),
  e = sample(letters, 1e3, replace = TRUE)
)

# usually only display first 10 rows
# sometimes display more
nycflights13::flights %>% 
  print(n = 10, width = Inf)

nycflights13::flights %>% 
  print(n = 100)

# builtin viewer
nycflights13::flights %>% 
  View()

# 10.3.2 Subsetting
df <- tibble(
  x = runif(5), 
  y = rnorm(5)
)

# extract by name
df$x
df[["x"]]

# extract by position
df[[2]]

# when using with pipe use placeholder of period
df %>% .$x

# 10.4 interacting with older code
# use as.data.frame to convert back to old style data.frame
class(as.data.frame(tb))
as.data.frame(tb)

# 10.5 Exercises
# 1 tibble or data.frame?
mtcars
class(mtcars)

# 2 
df <- data.frame(abc = 1, xyz = "a")
# this column doesn't actually exist
df$x
# don't really want levels, want information
df[, "xyz"]
# this is weird for an array
df[, c("abc", "xyz")]

# 3 extract information using variable
var <- "mpg"
mtcars[[var]]

# 4 
annoying <- tibble(
  `1` = 1:10, 
  `2` = `1` * 2 + rnorm(length(`1`))
)

annoying$`1`

ggplot(annoying, aes(`1`, `2`)) + 
  geom_point()

annoying %>% 
  mutate(
    `3` = `2` / `1`
  )

annoying %>% 
  transmute(
    one = `1`, 
    two = `2`, 
    three = `2` / `1`
  )

# 5 what do we do with this? 
?enframe

# 6 
nycflights13::flights %>% 
  print(n = 10, width = 20)

?print


################################################
# 11 Data Import

# usually supply path and file - relative path is good!
heights <- read_csv("data/heights.csv")

# can also supply inline csv file
read_csv("
         a,b,c
         1,2,3
         4,5,6")

# skip metadata that isn't really necessary
read_csv("the first line of meta
         the second line of metadata
         x,y,z
         1,2,3", 
         skip = 2)

read_csv("# comment that I don't want
         x,y,z
         1,2,3", 
         comment = "#")

# maybe there aren't column names
read_csv("
         1,2,3
         4,5,6", 
         col_names = FALSE)

read_csv("1,2,3\n4,5,6", col_names = c("z", "y", "x"))

# missing values in the file
read_csv("a,b,c\n1,2,.", na = ".")

# 11.2.1 better than base R

# 11.2.2 Exercises
# 1 pipe separation
read_delim("a|b|c\n1|2|3", delim = "|")

# 2 
?read_csv
# many things in common with read_tsv

# 3
?read_fwf
# column positions

# 4 
read_delim("x,y\n'a,b'", delim = ",", quote = "'")
# do we want to say y is missing? x = a,b
# i don't understand

# 5 
read_csv("a,b\n1,2,3\n4,5,6")
# extra columns of data are ignored, need to specify third header

read_csv("a,b,c\n1,2\n1,2,3,4")
# is the line split in the wrong place? 

read_csv("a,b\n\"1")
# is 1 meant to be a character? interprets as int

read_csv("a,b\n1,2\na,b")
# this is strange to have data same as headings

read_csv("a;b\n1;3")
# change to csv2
read_csv2("a;b\n1;3")


# 11.3 Parsing a Vector
# parse_*()

x <- parse_integer(c("123", "345", "abc", "123.45"))
# creates an error

problems(x)

# logical, integer
# double
# character
# factor
# datetime, date, time

# 11.3.1 Numbers
parse_double("1,23", locale = locale(decimal_mark = ","))
parse_number("It cost $123.45")
parse_number("123'456'789", locale = locale(grouping_mark = "'"))

# 11.3.2 Strings
charToRaw("Hadley")
# UTF-8 is good!

# 11.3.3 Factors
fruit <- c("apple", "banana")
parse_factor(c("apple", "banana", "bananana"), levels = fruit)

# 11.3.4 Dates, date-times, times
parse_datetime("2010-10-01T2010")
# ISO-8601

parse_date("2010-10-01")
parse_time("01:10 am")

# create your own format
parse_date("01/02/15", "%m/%d/%y")
parse_date("01/02/15", "%d/%m/%y")
parse_date("01/02/15", "%y/%m/%d")

# 11.3.5 Exercises
?locale

# decimal and grouping
parse_double("3,456.78", grouping_mark = ",", decimal_mark = ",")
parse_double("3,456.78", locale = locale(grouping_mark = ","))
parse_double("3,456.78", locale = locale(decimal_mark = ","))

# date_format, time_format

# 4 dates are %d/%m/%y

# 5 read_csv is comma, read_csv2 is semicolon

# 6 encodings - good thing we usually use one type

# 7 
library(hms)
d1 <- parse_date("January 1, 2010", "%B %d, %Y")
d2 <- parse_date("2015-Mar-07", "%Y-%b-%d")
d3 <- parse_date("06-Jun-2017", "%d-%b-%Y")
d4 <- parse_date(c("August 19 (2015)", "July 1 (2015)"), "%B %d (%Y)")
d5 <- parse_date("12/30/14" , "%m/%d/%y")
t1 <- parse_time("17:05","%H%M")
t2 <- parse_time("11:15:10.12 PM", "%I:%M:%OS %p")


# 11.4 Parsing a file

guess_parser("2010-10-01")
str(parse_guess("2010-10-10"))

# problems
challenge <- read_csv(readr_example("challenge.csv"))
problems(challenge)

# update the read_csv call with output from original call
# this is what readr guesses from first 1000 rows
# change x from integer to double
# change y to date
challenge <- read_csv(
  readr_example("challenge.csv"), 
  col_types = cols(
    x = col_double(),
    y = col_date()
  )
)

tail(challenge)

# maybe just read in as characters and sort it out in R!


# 11.5 Writing to a file
# use write_csv to write to a csv file
# it's possible to use write_rds for R standard files
# feather is also an option for fast binary files


# 11.6 other types of data
# haven for SAS data
# readxl for xls and xlsx

