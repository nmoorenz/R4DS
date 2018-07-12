# Week 6 in R4DS: Tidy Data and Relational Data

library(tidyverse)

# 12.2 Tidy Data

table1 %>% 
  mutate(rate = cases / population * 10000)

table1 %>% 
  count(year, wt = cases)

library(ggplot2)

ggplot(table1, aes(year, cases)) +
  geom_line(aes(group = country), colour = "grey50") +
  geom_point(aes(colour = country))

# 12.2 Exercises
# table1 is tidy!
# table2 has country and year OK, but then has type and count as columns.
# we need to restrict to type = cases or type = population if we want to work
# table3 is weird, with rate as a string in a cell
# table4a + table4b is unsustainable as we add more years to the columns

# 2 
t2case <- filter(table2, type == "cases")
t2pop <- filter(table2, type == "population")
t2rate = t2case$count / t2pop$count * 10000
# append data back to table2
# type = rate, count = t2rate

table4c <- table4a
table4c$`1999` <- table4a$`1999` / table4b$`2000` * 10000
table4c$`2000` <- table4a$`2000` / table4b$`2000` * 10000

# 3
# pretty much need to convert table2 into table1


# 12.3 spreading and gathering
# gather
tidy4a <- table4a %>% 
  gather(`1999`, `2000`, key = "year", value = "cases")

tidy4b <- table4b %>% 
  gather(`1999`, `2000`, key = "year", value = "population")

# join with left join
left_join(tidy4a, tidy4b)

# spread
spread(table2, key = type, value = count)

# 12.3.3 Exercises

# 1 year comes back as a character since it isa column header
stocks <- tibble(
  year   = c(2015, 2015, 2016, 2016),
  half  = c(   1,    2,     1,    2),
  return = c(1.88, 0.59, 0.92, 0.17)
)
stocks %>% 
  spread(year, return) %>% 
  gather("year", "return", `2015`:`2016`)

# 2 
table4a %>% 
  gather(1999, 2000, key = "year", value = "cases")
# backticks

# 3 
people <- tribble(
  ~name,             ~key,    ~value,
  #-----------------|--------|------
  "Phillip Woods",   "age",       45,
  "Phillip Woods",   "height",   186,
  "Phillip Woods",   "age",       50,
  "Jessica Cordero", "age",       37,
  "Jessica Cordero", "height",   156
)

people %>% 
  spread(key = key, value = value)
# duplicate identifiers! add another column with date of when Phillip was 45 and when he was 50

# 4 
preg <- tribble(
  ~pregnant, ~male, ~female,
  "yes",     NA,    10,
  "no",      20,    12
)

preg %>% 
  gather("male", "female", key = "gender", value = "count")


# 12.4 separating and uniting

table3 %>% 
  separate(rate, into = c("cases", "population"), convert = TRUE)

table5 %>% 
  unite(new, century, year, sep = "")

# 12.4.3 Exercises

tibble(x = c("a,b,c", "d,e,f,g", "h,i,j")) %>% 
  separate(x, c("one", "two", "three"), extra = "merge")
?separate

tibble(x = c("a,b,c", "d,e", "f,g,i")) %>% 
  separate(x, c("one", "two", "three"), fill = "left")

# 2 

tibble(x = c("a,b,c", "d,e", "f,g,i")) %>% 
  separate(x, c("one", "two", "three"), fill = "left", remove = FALSE)

# 3 
?extract
df <- data.frame(x = c(NA, "a-b", "a-d", "b-c", "d-e"))
df %>% extract(x, c("A", "B"), "([[:alnum:]]+)-([[:alnum:]]+)")


# 12.5 Missing values

stocks <- tibble(
  year   = c(2015, 2015, 2015, 2015, 2016, 2016, 2016),
  qtr    = c(   1,    2,    3,    4,    2,    3,    4),
  return = c(1.88, 0.59, 0.35,   NA, 0.92, 0.17, 2.66)
)
stocks
# 2015 Q4 is missing, but so is 2016 Q1

# possible to remove na missing values (good for sum) 
stocks %>% 
  spread(year, return) %>% 
  gather(year, return, `2015`:`2016`, na.rm = TRUE)

# find pairs of values and make sure all combinations are present
stocks %>% 
  complete(year, qtr)

# maybe the data is implied that a previous value should be carried forward
treatment <- tribble(
  ~ person,           ~ treatment, ~response,
  "Derrick Whitmore", 1,           7,
  NA,                 2,           10,
  NA,                 3,           9,
  "Katherine Burke",  1,           4
)

# use fill() to get carry values forward
treatment %>% 
  fill(person)

# 12.5.1 Exercises
# 1 
# fill doesn't add more rows, replaces missing values
# spread might create missing values if observations do not exist
# complete also creates missing values, doesn't change columns

# 2 
?fill

# 12.6 Case Study

# convert to tidy set and remove missing values

who1 <- who %>% 
  gather(new_sp_m014:newrel_f65, key = "key", value = "cases", na.rm = TRUE)

who1

# let us see if these have a structure
who1 %>% 
  count(key)

# data dictionary gives us some guidance
# types of cases, sex, and age
# need to fix newrel to be new_rel
who2 <- who1 %>% 
  mutate(key = stringr::str_replace(key, "newrel", "new_rel"))
who2

# separate at underscores to get types and new and sex-age
who3 <- who2 %>% 
  separate(key, c("new", "type", "sexage"), sep = "_")
who3

# iso2 and iso3 are unnecessary, plus they are all new
who3 %>%  count(new)
who4 <- who3 %>% 
  select(-new, -iso2, -iso3)
who4

# separate sexage into respective columns
who5 <- who4 %>% 
  separate(sexage, c("sex", "age"), sep = 1)
who5

# all in one go! 

who %>%
  gather(code, value, new_sp_m014:newrel_f65, na.rm = TRUE) %>% 
  mutate(code = stringr::str_replace(code, "newrel", "new_rel")) %>%
  separate(code, c("new", "var", "sexage")) %>% 
  select(-new, -iso2, -iso3) %>% 
  separate(sexage, c("sex", "age"), sep = 1)

# 12.6.1 
# 1 missing values mean no measurement, zero mean no TB cases
# need to make sure we don't remove 'nothing' only missing

# 2 miss out mutate step and we don't split properly

# 3 
who %>% 
  count(country, iso2, iso3)

# 4 
who %>%
  gather(code, value, new_sp_m014:newrel_f65, na.rm = TRUE) %>% 
  mutate(code = stringr::str_replace(code, "newrel", "new_rel")) %>%
  separate(code, c("new", "var", "sexage")) %>% 
  select(-new, -iso2, -iso3) %>% 
  separate(sexage, c("sex", "age"), sep = 1) %>% 
  group_by(country, year, sex) %>% 
  transmute(cases = sum(value)) %>% 
  ggplot(aes(x = year, y = cases, colour = country)) +
  geom_line() +
  theme(legend.position = "none") +
  facet_wrap(~ sex, nrow = 2) +
  coord_cartesian(xlim = c(1995, 2015))
  

