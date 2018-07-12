# week 6b
# 13 Relational Data

library(tidyverse)
library(nycflights13)

# 13.2.1 Exercises

# 1 
# draw a map of flights
# would need airports joined to flights 
# lat long most important, plus direction

# 2 
# weather$origin = airports$faa

# 3
# new relation what? 

# 4 
# holiday data frame
# year, month, day, name


# 13.3 Keys

# look for counts greater than one
planes %>% 
  count(tailnum) %>% 
  filter(n > 1)

weather %>% 
  count(year, month, day, hour, origin) %>% 
  filter(n > 1)

# there isn't a good key for flights
flights %>% 
  count(year, month, day, flight) %>% 
  filter(n > 1)

flights %>% 
  count(year, month, day, flight, tailnum) %>% 
  filter(n > 1)

# 13.3.1 Exercises
# 1 add a surrogate key
flights %>% 
  mutate(surrogate = row_number())

# 2
Lahman::Batting %>% 
  count(playerID, yearID, stint, teamID) %>% 
  filter(n > 1)

babynames::babynames %>% 
  count(year, sex, name) %>% 
  filter(nn > 1)

nasaweather::atmos %>% 
  count(lat, long, year, month) %>% 
  filter(n > 1)

fueleconomy::vehicles %>% 
  count(id) %>% 
  filter(n > 1)

ggplot2::diamonds
# need a surrogate here!

# 3 
Lahman::Batting
Lahman::Pitching
# looks similar


# 13.4 Mutating Joins

flights2 <- flights %>% 
  select(year:day, hour, origin, dest, tailnum, carrier)
flights2

flights2 %>% 
  select(-origin, -dest) %>% 
  left_join(airlines, by = "carrier")

# understanding joins
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  3, "x3"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  4, "y3"
)

x %>% 
  inner_join(y, by = "key")

# Duplicate keys
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  2, "x3",
  1, "x4"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2"
)
left_join(x, y, by = "key")

# cartesian product - all observations crossed with each other
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  2, "x3",
  3, "x4"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  2, "y3",
  3, "y4"
)
left_join(x, y, by = "key")


# 13.4.5 defining key columns

# natural join, whatever is common between two tables
flights2 %>% 
  left_join(weather)

# by a character, occurs in both tables
flights2 %>% 
  left_join(planes, by = "tailnum")

# by a character vector, first col in first table, second col in second table
flights2 %>% 
  left_join(airports, c("dest" = "faa"))

# 13.4.6 Exercises

# 1 map delays be airport
library(maps)
flights %>% 
  group_by(dest) %>% 
  summarise(delay = mean(dep_delay, na.rm = TRUE)) %>% 
  left_join(airports, c("dest" = "faa")) %>% 
  ggplot(aes(lon, lat, color = delay)) +
  borders("state") +
  geom_point() + 
  coord_quickmap()

# 2 add origin and destination to flights
flights %>% 
  left_join(airports, c("origin" = "faa")) %>% 
  left_join(airports, c("dest" = "faa"))

# 3 relationship between age of plane and delays
# undetermined
flights %>% 
  group_by(tailnum) %>% 
  summarise(delay = mean(dep_delay, na.rm = TRUE)) %>% 
  left_join(planes, by = "tailnum") %>% 
  ggplot(aes(year, delay)) +
  geom_point(position = "jitter") +
  geom_smooth()

# 4 weather conditions for a delay
flights %>% 
  group_by(origin, year, month, day, hour) %>% 
  summarise(delay = mean(dep_delay, na.rm = TRUE)) %>% 
  left_join(weather) %>% 
  ggplot(aes(temp, delay)) +
  geom_point(position = "jitter") +
  geom_smooth()

flights %>% 
  group_by(origin, year, month, day, hour) %>% 
  summarise(delay = mean(dep_delay, na.rm = TRUE)) %>% 
  left_join(weather) %>% 
  ggplot(aes(dewp, delay)) +
  geom_point(position = "jitter") +
  geom_smooth()

flights %>% 
  group_by(origin, year, month, day, hour) %>% 
  summarise(delay = mean(dep_delay, na.rm = TRUE)) %>% 
  left_join(weather) %>% 
  ggplot(aes(humid, delay)) +
  geom_point(position = "jitter") +
  geom_smooth()

flights %>% 
  group_by(origin, year, month, day, hour) %>% 
  summarise(delay = mean(dep_delay, na.rm = TRUE)) %>% 
  left_join(weather) %>% 
  ggplot(aes(wind_speed, delay)) +
  geom_point(position = "jitter") +
  geom_smooth() + 
  xlim(0,50)

flights %>% 
  group_by(origin, year, month, day, hour) %>% 
  summarise(delay = mean(dep_delay, na.rm = TRUE)) %>% 
  left_join(weather) %>% 
  ggplot(aes(visib, delay)) +
  geom_point(position = "jitter") +
  geom_smooth()

# 5 June 13, 2013
flights %>% 
  filter(year == 2013, month == 6, day == 13) %>% 
  group_by(dest) %>% 
  summarise(delay = mean(dep_delay, na.rm = TRUE)) %>% 
  left_join(airports, c("dest" = "faa")) %>% 
  ggplot(aes(lon, lat, color = delay)) +
  borders("state") +
  geom_point() + 
  coord_quickmap()

# 13.4.7 Other Implementations
# base::merge can also be used


# 13.5 Filtering Joins
# semi_join(x, y) keeps observations
# anti_join(x, y) drops observations

# find the top 10 destinations
top_dest <- flights %>% 
  count(dest, sort = TRUE) %>% 
  head(10)
top_dest

# find each flight that went to those destinations
flights %>% 
  filter(dest %in% top_dest$dest)

# instead just do a semi join, keeps entries from first table
flights %>% 
  semi_join(top_dest)

# opposite is an anti_join
flights %>% 
  anti_join(planes, by = "tailnum") %>% 
  count(tailnum, sort = TRUE)

# 13.5.1 Exercises

# 1 flight with missing tailnum
miss_plane <- flights %>% 
  anti_join(planes, by = "tailnum")

# 2 filter for planes that have flown more than 100 times
flights %>% 
  group_by(tailnum) %>% 
  summarise(
    count = n()
  ) %>% 
  filter(count > 100) %>% 
  left_join(flights)

# 3 most common vehicle types?
library(fueleconomy)
vehicles
common

vehicles %>% 
  semi_join(
common %>% 
  filter(
    n > mean(n)
  ))

# 4 
flights %>% 
  group_by(year,month,day,hour) %>% 
  summarise(delayed = mean(dep_delay, na.rm = TRUE),count = n()) %>% 
  arrange(-delayed) %>% 
  ungroup() %>% 
  left_join(weather)

# 5 
f_a <- anti_join(flights, airports, by = c("dest" = "faa"))
a_f <- anti_join(airports, flights, by = c("faa" = "dest"))


# 13.6 Join Problems
# make data tidy

# 13.7 Set operations
# intersect(x,y)
# union(x,y)
# setdiff(x,y)