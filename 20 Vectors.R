# R For Data Science

# 20 Vectors

###################
# 20.1 Introduction
 
# vectors make up tibbles, vectors are important
 
# 20.1.1 Prerequisites
library(tidyverse)

####################
# 20.2 Vector basics
 
# atomic vectors: logical, integer, double, character, complex, raw
# lists: can contain other lists
# atomic vectors: homogeneous
# lists: heterogeneous
 
# properties: length and type
 
typeof(letters)
typeof(1:10)

y <- list("a", "b", 1:10)
length(y)

typeof(y)
 
# augmented vectors: additional metadata
# factors built on integer vectors
# date and datetime built on numeric vectors
# data frames and tibbles built on lists
 
########################################
# 20.3 important types of atomic vectors
 
# 20.3.1 Logical - usually created from comparisons
1:10 %% 3 == 0

# 20.3.2 Numeric - integers and doubles
# put an L after a number to explicitly make it an integer
typeof(1)
typeof(1L)
 
# doubles are not always exact because floating point accuracy is limited
sqrt(2) ^ 2 - 2

# use dplyr::near() when comparing numbers - has tolerance
 
# integers can be NA, doubles can be -Inf, NA, NaN, and Inf
c(-1, 0, 1) / 0

# use is.na(), is.nan(), is.finite(), is.infinite() to check
 
# 20.3.3 Character
# most complex because each element is a string
# R uses string pointers so not every string is written in memory
 
x <- "This is a reasonably long string."
pryr::object_size(x)

y <- rep(x, 1000)
pryr::object_size(y)

y[56] <- "this is another string"
pryr::object_size(y[56])

pryr::object_size(y)
 
# 20.3.4 Missing values
# each NA is slightly different depending on vector type
# don't really need to know this but does matter sometimes
NA
NA_integer_
NA_real_
NA_character_
  
########
# 20.3.5 Exercises

# 1 finite and infinite
y <- Inf
is.finite(y)
!is.infinite(y)
 
w <- 0
is.finite(w)
!is.infinite(w)
 
is.finite(w * y)
!is.infinite(w * y)

?is.finite

# is.finite tests for na and nan
z <- NA
is.finite(z)
!is.infinite(z)
    
# 2 
dplyr::near

# compares the absolute difference of two numbers to a very small value

# 3 How large can an integer be? 
.Machine$integer.max

# 4 
# round, ceiling, floor, trunc
?round
# be precise - ha! 
 
# 5 
?readr
 
# use col_double and col_integer to convert on import
# should be able to use these with any readr functions
 
###########################
# 20.4 using atomic vectors
 
# convert, types, lengths, names, elements

# 20.4.1 Coercion
 
# explicit: as.logical, as.integer, as.double, as.character
# maybe it's possible to change the type earlier in the workflow? 
 
# implicit: when you use a vector in a certain context 
# most common: logical to numeric, true = 1, false = 0
(x <- sample(20, 100, replace = TRUE))
(y <- x > 10)

sum(y) # how many greater than 10?
mean(y) # what proportion greater than 10?

# the most complex type is always created
typeof(c(TRUE, 1L))
typeof(c(1L, 1.5))
typeof(c(1.5, "a"))

# 20.4.3 scalars and recycling rules
# mixing vectors and scalars, R will make the same length
sample(10) + 100
runif(10) > 0.5

1:10 + 1:2

# might produce a warning of it isn't exact multiple
1:10 + 1:4

# can be clever, but can also be *too* clever
# tidyverse throws errors
tibble(x = 1:4, y = 1:2)

# use rep() to do it properly
tibble(x = 1:4, y = rep(1:2, 2))
tibble(x = 1:4, y = rep(1:2, each = 2))

# 20.4.4 Naming vectors
c(x = 1, y = 2, z = 5)

set_names(1:3, c("b", "c", "d"))

# numeric vector containing integers
x <- c("one", "two", "four", "five", "six")
x[c(2, 3, 5)]

# longer output than input
x[c(5, 4, 3, 2, 1, 5, 4, 3, 2, 1)]

# negative values drop elements
x[c(-1, -2, -3)]

# can't mix positive and negative
x[c(1, -2)]

# subset with logical values
y <- c(10, 8, NA, 6, 4, NA)
y[!is.na(y)]

# even values
y[y %% 2 == 0]

# named vector subsetted with character vector
z <- c(r = 1, s = 2, t = 3)
zz <- c("r", "s")
z[zz]

# 2 
?is.vector

# 3
?set_names

# 4
last_value <- function(vect) {
   z = length(vect)
   return(vect[z])
 }

yy <- c(2:66)
last_value(yy)

# elements at even numbered positions
even_place <- function(vect) {
  z = c(1:length(vect))
  zz = z %% 2 == 0
  vect[zz]
}

even_place(yy)
ww <- c(-5:5) 
even_place(ww)

# every element except the last
all_but_last <- function(vect) {
  z = length(vect)
  vect[-z]
}

all_but_last(ww)

# only even numbers and no missing
vv <- c(-3:3, NA)

evens_only <- function(vect) {
  mods = vect[vect %% 2 == 0]
  mods[!is.na(mods)]
}

evens_only(vv)

# 5 these are sometimes not the same - I don't know why
vv[-which(vv > 0)]
vv[vv <= 0]
?which

ich <- c(1:5, NA, -Inf, Inf)
ich[-which(ich > 0)]
ich[ich <= 0]

# 6 subset with larger integer than length
# or with a name that doesn't exist
h <- c(1:5)
h[175]
# doesn't exist! 

j <- c(z = 1, y = 2, x = 3)
j["g"]
# doesn't exist! 

################################
# 20.5 Recursive vectors (lists)

# create a list with list()
LL <- list(1, 2, 3)

LL

# structure with str()
str(LL)

LL_name <- list(a = 1, b = 2, c = 3)
str(LL_name)

# mixture of objects
mix <- list("a", 1L, 1.5, TRUE)
str(mix)

# list can contain other lists
zz <- list(list(1, 2), list(5,6))
str(zz)

########
# 20.5.1 Visualising Lists

# lists are weird and embedded

########
# 20.5.2 Subsetting

aa <- list(a = 1:3, b = "a string", c = pi, d = list( -1, -5))

# sub list with []
str(aa[1:2])

# single component with [[]]
str(aa[[1]])

# named elements with $
aa$a
aa[["a"]]

########
# 20.5.3 Lists of Condiments

# x[1] is a pepper shaker container the first pepper packet
# x[[1]] is the first pepper packet
# x[[1]][[1]] is the pepper in the first packet 
# drill baby drill! 

########
# 20.5.4 Exercises

# 1 draw some lists

# 2 
tib <- tibble(
  x = 1:5, 
  y = 1, 
  z = x ^ 2 + y
)

tib[1]
tib[[1]]

# these look similar to me - first returns tibble, second returns elements

#################
# 20.6 Attributes

# get and set with attr() or all at once with attributes()
x <- 1:10
attr(x, "greeting")
attr(x,"message") <- "Hello"
attr(x, "farewell") <- "See you"
attributes(x)

# fundamental attributes
# names, dimensions, class
# names are common, dimensions are for matrices (not covered)
# classes control how generic functions work
as.Date
methods("as.Date")
# depending on first argument of function call, will use a specific method
getS3method("as.Date", "default")

########################
# 20.7 Augmented Vectors

# atomic vectors are building blocks for other types like factors and dates
# can be called augmented vectors, vectors with additional attributes

# factors, dates, date-times, tibbles

########
# 20.7.1 Factors

# designed to represent categorical data, built on top of integers, 
# have a levels attribute. check environment variables for view

x <- factor(c("ab", "cd", "ab"), levels = c("ab", "cd", "ef"))
x
typeof(x)
attributes(x)

########
# 20.7.2 Dates and date-times

# dates are number of days since 1 January 1970
d <- as.Date("1970-06-30")
unclass(d)
typeof(d)
attributes(d)

# date-times are numeric vectors with class POSIXct 
# represent number of seconds since 1 January 1970
# Portable Operating System Interface calendar time

tm <- lubridate::ymd_hm("1990-01-01 00:00")
unclass(tm)
typeof(tm)
attributes(tm)
tm

# tzone is optional, controls how it looks, not the value
# changing tzone can change the time
attr(tm, "tzone") <- "Pacific/Auckland"
tm

# also could be POSIXlt, built on lists
# rare in tidyverse - lubridate helps, so just convert to POSIXct!
tm_lt <- as.POSIXlt(tm)
typeof(tm_lt)
attributes(tm_lt)

########
# 20.7.3 Tibbles

# augmented lists with a few classes and attributes
# traditional data.frames are similar
# all elements are vectors of the same length
tbb <- tibble::tibble(x = 1:10, y = 10:1)
typeof(tbb)
attributes(tbb)

########
# 20.7.4 Exercises

# 1 
x1 <- hms::hms(3600)
typeof(x1)
attributes(x1)

# 2 
incorrect <- tibble::tibble(x = 1:10, y = 1:5)
# shorter vector is an error

# 3 list as a column of a tibble
tester <- tibble:tibble(x = 1:10, y = list(a = 1:10))
# this does not look valid

