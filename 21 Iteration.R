# R for Data Science

# 21 Iteration

###################
# 21.1 Introduction

# reduce duplication

# easier to see intent
# respond to changes in requirements
# fewer bugs because used more often

# iteration is doing the same thing to multiple inputs

# imperative programming (loops, while loops)
# functional programming (extract out duplicated for loop code)

# 21.1.1 Prerequisites
library(tidyverse)

################
# 21.2 For loops

df <- tibble(
  j = rnorm(10), 
  k = rnorm(10), 
  l = rnorm(10), 
  m = rnorm(10)
)

# medians
median(df$j)
median(df$k)
# etc

# for loop
# output, sequence, body
output <- vector("double", ncol(df))  # output
for (i in seq_along(df)) {            # sequence
  output[[i]] <- median(df[[i]])      # body
}

output

# allocate space for output! otherwise very slow
# seq_along can handle weirdness - best to use instead of 1:length(x)
# body is run repeatedly

########
# 21.2.1 Exercises

# 1.1
mtcars
cars <- vector("double", ncol(mtcars))
for (i in seq_along(mtcars)) {
  cars[[i]] <- mean(mtcars[[i]])
}
cars

# 1.2 
library(nycflights13)

flights

typeof(nycflights13::flights$carrier)

columntype <- vector("list", ncol(flights))

names(columntype) <- names(flights)

for (i in names(flights)) {
  columntype[[i]] <- class(flights[[i]])
}

columntype

# 1.3 
# unique values in iris
iris
length(unique(iris$Petal.Width))

unique_iris <- vector("list", ncol(iris))

names(unique_iris) <- names(iris)

for (i in names(iris)) {
  unique_iris[[i]] <- length(unique(iris[[i]]))
}

# 1.4 
# 10 random normals for mu = -10, 0, 10, 100
?rnorm

gg <- rnorm(10, mean = -10)

normies <- vector("list", 4)

names(normies) <- c("d_10", "d0", "d10", "d100")

mu <- c(-10, 0, 10, 100)

for (i in seq_along(normies)) {
  normies[[i]] <- rnorm(10, mean = mu[i])
}

# 2 eliminate for loops
# 2.1
out <- ""
for (x in letters) {
  out <- stringr::str_c(out, x)
}

str_c(letters, sep = "", collapse = "")

# 2.2
x <- sample(100)
sd <- 0
for (i in seq_along(x)) {
  sd <- sd + (x[i] - mean(x)) ^ 2
}
sd <- sqrt(sd / (length(x) - 1))

sd(x)

# 2.3
x <- runif(100)
out <- vector("numeric", length(x))
out[1] <- x[1]
for (i in 2:length(x)) {
  out[i] <- out[i - 1] + x[i]
}

out <- x + lag(x)
  
# 3 nursery rhymes

# 4 preallocate
output <- vector("integer", 0)
for (i in seq_along(x)) {
  output <- c(output, lengths(x[[i]]))
}
output

######
# 21.3 For Loop Variations

# 21.3.1 Modify an existing object
# put the same element on both sides of the <- 
# use [[]] in all loops because we want to work with single elements

# 21.3.2 Looping patterns
# simple is loop along indices 
# for( i in seq_along(x))

# loop over elements
# for (x in xx)
# not that useful

# loop over names
# for nm in names(x)
# access names of a df or tibble
# use names(x) <- names(y) for named output

for (i in seq_along(x)) {
  name <- names(x)[[i]]
  value <- x[[i]]
}

# 21.3.3 unknown output length
# create vectors of random length

# vector of different means for generation
means <- c(0, 1, 2)

# list for each vector of outputs (doesn't matter about different lengths)0
out <- vector("list", length(means))

# function creating random length n vectors of normal distribution
for (i in seq_along(means)) {
  n <- sample(100, 1)
  out[[i]] <- rnorm(n, means[[i]])
}

str(out)

str(unlist(out))

# 21.3.4 unknown sequence length
# while (condition) { body }

# three heads in a row
flip <- function() sample(c("T", "H"), 1)

flips <- 0
nheads <- 0

while (nheads < 3) {
  if (flip() == "H") {
    nheads <- nheads + 1
  } else {
    nheads <- 0
  }
  flips <- flips + 1
}
flips

########
# 21.3.5 Exercises

# 1 
files <- dir("data/", pattern = "\\.csv$", full.names = TRUE)

outer <- vector("list", length(files))

for (i in seq_along(files)) {
  outer[[i]] <- read_csv(files[[i]])  
}

outer <- bind_rows(outer)

# 2 
nrm <- 1:5

for (nm in names(nrm)) {
  print(nm)
  print(nrm[[nm]])
}

nrm <- c(a = 1, 2, c = 3)

nrm <- c(a = 1, a = 2, c = 3)

# 3 

show_mean <- function(df) { 
  for (i in seq_along(df)) {
    print(str_c(names(df)[[i]],mean(df[[i]])))
  }
}

show_mean(iris)

# 4 
trans <- list( 
  disp = function(x) x * 0.0163871,
  am = function(x) {
    factor(x, labels = c("auto", "manual"))
  }
)

for (var in names(trans)) {
  mtcars[[var]] <- trans[[var]](mtcars[[var]])
}

######
# 21.4 For Loops vs Functionals

# pass a function to another function

df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

col_summary <- function(df, fun) {
  out <- vector("double", length(df))
  for (i in seq_along(df)) {
    out[i] <- fun(df[[i]])
  }
  out
}

col_summary(df, median)

col_summary(df, mean)

# oh shit, purrr! 
# apply(), lapply, tapply() similar in base R

# break down common list manipulation challenges
# apply the solution for one element to the whole list
# break down complex problems into bite sized pieces

# 21.4.1 Exercises
# apply()
# generalises for loops across rows and across columns, names, length
?apply

# col_summary() for numeric only

df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10), 
  e = "e"
)


col_summary <- function(df, fun) {
  numer <- vector("logical", length(df))
  for (i in seq_along(numer)) {
    numer[[i]] <- is_numeric(df[[i]])
  }
  
  indx <- seq_along(df)[numer]
  
  out <- vector("double", sum(numer))
  for (i in indx) {
    out[i] <- fun(df[[i]])
  }
  out
}

col_summary(df, mean)

######
# 21.5 The Map Functions

# loop over a vector, do something to each element, save results
# purrr provides functions

# map() makes a list, map_lgl, map_int, map_dbl, map_chr

df2 <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

map_dbl(df2, mean)

# also pipe, focus on function
df2 %>% 
  map_dbl(sd)

# extra arguments, .f and ...
map_dbl(df2, median, trim = 0.5)

# preserves names
zz <- list(x = 1:3, y = 8:9)

map_int(zz, length)

########
# 21.5.1 Shortcuts

# fit linear model to each group in dataset
models <- mtcars %>% 
  split(.$cyl) %>% 
  map(function(df) lm(mpg ~ wt, data = df))

# map provides one-sided formula
# . is pronoun, similar to i in for loop
models <- mtcars %>% 
  split(.$cyl) %>% 
  map(~lm(mpg ~ wt, data = .))

# could extract R squared after running summary
models %>% 
  map(summary) %>% 
  map_dbl(~.$r.squared)

# but purrr also provides shortcut to that function
models %>% 
  map(summary) %>% 
  map_dbl("r.squared")

# extra: use integer to select elements by position
xd <- list(list(1, 2, 3), list(4, 5, 6), list(7, 8, 9))

xd %>% map_dbl(2)

########
# 21.5.2 Base R

# purrr similar to base apply functions
# lapply() identical to map(), but map has extra shortcuts
# sapply() is wrapper around lapply() but can cause trouble

x1 <- list(
  c(0.27, 0.37, 0.57, 0.91, 0.20),
  c(0.90, 0.94, 0.66, 0.63, 0.06), 
  c(0.21, 0.18, 0.69, 0.38, 0.77)
)

x2 <- list(
  c(0.50, 0.72, 0.99, 0.38, 0.78), 
  c(0.93, 0.21, 0.65, 0.13, 0.27), 
  c(0.39, 0.01, 0.38, 0.87, 0.34)
)

threshold <- function(x, cutoff = 0.8) x[x > cutoff]

# two in second list and none in third meet cutoff
x1 %>% sapply(threshold) %>% str()

# one from each list meet cutoff, makes vector
x2 %>% sapply(threshold) %>% str()

# vapply() safe compared to sapply(), additional argument
# can also produce matrices, but more typing

# 21.5.3 Exercises

# 1 map functions
# 1.1 
map_dbl(mtcars, mean)

# 1.2 
map(nycflights13::flights, class)
map_chr(nycflights13::flights, mode)

# 1.3 
map_int(iris, ~ length(unique(.)))

# 1.4
map(c(-10, 0, 10, 100), rnorm, n = 10)

# 2 single vector to indicate factor or not
factors <- map_lgl(mtcars, is.factor)

# 3 applies function to each element of vector, one at a time
map(1:5, runif)

# 4 
map(-2:2, rnorm, n = 5) # this is ok, returns whatever

map_dbl(-2:2, rnorm, n = 5) # this is an error

# 5 
map(x, function(df) lm(mpg ~ wt, data = df))

map(list(mtcars), ~ lm(mpg ~ wt, data = .))


######
# 21.6 Dealing with Failure

# safely() returns a list with two elements, result and error

safe_log <- safely(log)
str(safe_log(10))
str(safe_log("a"))

# safely() is designed to work with map()

x <- list(1, 10, "a")
y <- x %>% map(safely(log))
str(y)

# probably want two lists, one of results and one of errors
y <- y %>% transpose()
str(y)

# options for dealing with output: x is an e
is_ok <- y$error %>% map_lgl(is_null)
x[!is_ok]

# other useful adverbs: possibly() always succeeds
x <- list(1, 10, "a")
x %>% map_dbl(possibly(log, NA_real_))

# quietly() captures printed output, messages, and warnings
x <- list(1, -1)
x %>% map(quietly(log)) %>% str()

######
# 21.7 Mapping over multiple arguments

# map along multiple related inputs with map2() and pmap()

# map along some random normals with different means
mu <- list(5, 10, -3)

mu %>% map(rnorm, n = 5) %>% str()

# vary the standard variation too! 
sigma <- list(1, 5, 10)

seq_along(mu) %>% 
  map(~rnorm(5, mu[[.]], sigma[[.]])) %>% 
  str()

# nah
# use map2() instead

map2(mu, sigma, rnorm, n = 5) %>% str()

# instead of map3, map4 etc, purrr provides pmap()
n <- list(3, 5, 7)

args1 <- list(n, mu, sigma)

args1 %>% 
  pmap(rnorm) %>% 
  str()

# better to name the elements in the list so that pmap gets it right
args2 <- list(mean = mu, sd = sigma, n = n)
args2 %>% 
  pmap(rnorm) %>% 
  str()

# better to store them in a dataframe since all the same length

params <- tribble(
  ~mean, ~sd, ~n, 
  5,      1,   3, 
  10,     5,   5, 
  -3,    10,   5
)

params %>% 
  pmap(rnorm)

# 21.7.1 Invoking different functions

f <- c("runif", "rnorm", "rpois")

param <- list(
  list(min = -1, max = 1), 
  list(sd = 10), 
  list(lambda = 5)
)

invoke_map(f, param, n = 5) %>% str()

# could also use tribble to create df

sim <- tribble(
  ~f, ~params, 
  "runif", list(min = -2, max = 2), 
  "rnorm", list(sd = 10), 
  "rpois", list(lambda = 5)
)

sim %>% 
  mutate(sim = invoke_map(f, params, n = 10))

######
# 21.8 Walk

# important thing is the action, not the return value 
x <- list(1, "a", 3L)

x %>% walk(print)

# not that useful compared to walk2() or pwalk()

library(ggplot2)

plots <- mtcars %>% 
  split(.$cyl) %>% 
  map(~ggplot(., aes(mpg, wt)) + geom_point())

paths <- stringr::str_c(names(plots), ".pdf")

pwalk(list(paths, plots), ggsave, path = tempdir())

######
# 21.9 Other patterns of for loops

# 21.9.1 predicate functions

# keep() and discard() work with TRUE and FALSE

iris %>% 
  keep(is.factor) %>% 
  str()

iris %>%
  discard(is.factor)

# some() and every() determine TRUE or FALSE 

x <- list(1:10, letters, list(15))

x %>% some(is_character)
x %>% every(is_character)
x %>% every(is_vector)

# detect() finds first element where true, detect_index() returns index

x <- sample(10)
x
x %>% detect(~ . > 5)

x %>% detect_index(~ . > 5)

# head_while() and tail_while() take information from head or tail conditionally
x %>% head_while(~ . > 5)

x %>% tail_while(~ . > 5)

# 21.9.2 reduce and accumulate
# reduce to a single data frame 
# keeps applying function until a single element is left

dfs <- list(
  age = tibble(name = "John", age = 30),
  sex = tibble(name = c("John", "Mary"), sex = c("M", "F")),
  trt = tibble(name = "Mary", treatment = "A")
)

dfs %>% reduce(full_join)

# maybe find the intersection of a list of vectors
vs <- list(
  c(1, 3, 5, 6, 10),
  c(1, 2, 3, 7, 8, 10),
  c(1, 2, 3, 4, 8, 9, 10)
)

vs %>% reduce(intersect)

# accumulate is similar but keeps interim results
x <- sample(15)

x %>% accumulate(`+`)


########
# 21.9.3 Exercises 

# 1 
# for loop for every() 
x <- list(1:10, letters, list(15))
x %>% every(is_character)
x %>% every(is_vector)
?every
# I probaly wouldn't look for NA

# 2
# create enhanced col_sum() applying a summary function to every numeric column

# 3 also this: 

col_sum3 <- function(df, f) {
  is_num <- sapply(df, is.numeric)
  df_num <- df[, is_num]
  
  sapply(df_num, f)
}

df <- tibble(
  x = 1:3, 
  y = 3:1,
  z = c("a", "b", "c")
)

col_sum3(df, mean)

# Has problems: don't always return numeric vector
col_sum3(df[1:2], mean)
col_sum3(df[1], mean)
col_sum3(df[0], mean)
