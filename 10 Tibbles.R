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

