# 5 Data Transformation

#library(tidyverse)
#library(plotly)
library(ggplot2)
library(tibble)
library(readr)
library(tidyr)
library(purrr)
library(dplyr)
library(maps)

# 5.1 intro
library(nycflights13)
?flights
flights
View(flights)

# 5.2 filter()
# prints information
filter(flights, month == 1, day == 1)
# saves information
jan1 <- filter(flights, month == 1, day == 1)
# saves and prints tibble
(dec25 <- filter(flights, month == 12, day == 25))

# logical comparison with floating points
near(1 / 49 * 49, 1)
1 / 49 * 49 == 1

# filter with OR condition - same thing here
filter(flights, month == 11 | month == 12)
filter(flights, month %in% c(11, 12))

# equivalent expressions
filter(flights, !(arr_delay > 120 | dep_delay > 120))
filter(flights, arr_delay <= 120, dep_delay <= 120)

# unknown values are contagious
NA > 5

# use is.na
x <- NA
is.na(x)

# 5.2.4 Exercises
# 1.1 
filter(flights, arr_delay >= 120)
# 1.2
filter(flights, dest %in% c('IAH', 'HOU'))
# 1.3
filter(flights, carrier %in% c('UA', 'AA', 'UL'))
# 1.4
filter(flights, month %in% c(7, 8, 9))
# 1.5
filter(flights, dep_delay <= 0, arr_delay > 120)
# 1.6 
delay.makeup <- filter(flights, dep_delay >= 60, arr_delay < dep_delay - 30)
# 1.7
filter(flights, dep_time <= 0600)
# 2 between
?between
filter(flights, between(dep_time, 0, 600))
# 3 missing dep_time - cancelled flights!
filter(flights, is.na(dep_time))
# 4 
# NA: anything with a general rule overrides the missing value
NA ^ 0
NA | TRUE
NA & FALSE

# 5.3 arrange()
# 1 
df <- tibble(x = c(5, 2, NA))
arrange(df, desc(is.na(x)))
# 2 most delayed and least delayed
arrange(flights, desc(dep_delay))
arrange(flights, dep_delay)
# 3 fastest flights
fast <- arrange(flights, distance/air_time)
# 4 longest / shortest
arrange(flights, distance)
arrange(flights, desc(distance))

# 5.4 select()
# 1 select dep_time, dep_delay, arr_time, arr_delay
select(flights, starts_with("arr"), starts_with("dep"))
select(flights, ends_with("time"), ends_with("delay"), -(starts_with("sched")), -(starts_with("air")))
select(flights, dep_time:arr_delay, -(starts_with("sched")))
# 2 multiple mentions doesn't matter
select(flights, month, month, day)
# 3 
vars <- c("year", "month", "day", "dep_delay", "arr_delay")
select(flights, one_of(vars))
# 4 case does not matter by default - could use ignore.case = FALSE
select(flights, contains("TIME"))
select(flights, contains("TIME", ignore.case = FALSE))

# 5.5 mutate()
flights_sml <- select(flights, 
                      year:day, 
                      ends_with("delay"), 
                      distance, 
                      air_time
)
mutate(flights_sml,
       gain = arr_delay - dep_delay,
       speed = distance / air_time * 60
)
mutate(flights_sml,
       gain = arr_delay - dep_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours
)
transmute(flights,
          gain = arr_delay - dep_delay,
          hours = air_time / 60,
          gain_per_hour = gain / hours
)
transmute(flights,
          dep_time,
          hour = dep_time %/% 100,
          minute = dep_time %% 100
)

# 5.5 Exercises
# 1
transmute(flights,
          dep_time, 
          dep_mins = dep_time %/% 100 * 60 + dep_time %% 100,
          sched_dep_time,
          sched_dep_mins = sched_dep_time %/% 100 * 60 + sched_dep_time %% 100
          )
# 2 weird air_time
depart_arrive = transmute(flights,
          dep_time,
          air_time,               
          arr_time,    
          air_calc = arr_time - dep_time, 
          dep_mins = (dep_time %/% 100 * 60 + dep_time %% 100),
          arr_mins = (arr_time %/% 100 * 60 + arr_time %% 100),
          air_mins = (arr_time %/% 100 * 60 + arr_time %% 100) - (dep_time %/% 100 * 60 + dep_time %% 100)
          )
          
ggplot(data = depart_arrive) + 
  geom_point(mapping = aes(x = air_time, y = air_mins))

# 3 departures
select(flights, sched_dep_time, dep_time, dep_delay) %>%
  arrange(dep_delay)

# 4 
select(flights, sched_dep_time, dep_time, dep_delay) %>%
  arrange(desc(dep_delay))
?min_rank()

# 5 shorter vector is used over again
1:3 + 1:10

# 6 
?Trig

# 5.6 summarise()
summarise(flights, delay = mean(dep_delay, na.rm = TRUE))
by_day <- group_by(flights, year, month, day)
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))

# pipes
delays <- flights %>%
  group_by(dest) %>% 
  summarise(
    count = n(), 
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  filter(count > 20, dest != 'HNL')
  
ggplot(data = delays, mapping = aes(x = dist, y = delay)) +
  geom_point(aes(size = count), alpha = 1/3) +
  geom_smooth(se = FALSE)

# remove NA values
not_cancelled <- flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay))

not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(mean = mean(dep_delay))

# counting variables
delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay)
  )

ggplot(data = delays, mapping = aes(x = delay)) +
  geom_freqpoly(binwidth = 10)

# use a count to get better info
delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay), 
    n = n()
  )

ggplot(data = delays, mapping = aes(x = n, y = delay)) + 
  geom_point(alpha = 1/10)

delays %>% 
  filter(n > 25) %>% 
  ggplot(mapping = aes(x = n, y = delay)) + 
  geom_point(alpha = 1/10)

# batters
batting <- as_tibble(Lahman::Batting)

batters <- batting %>% 
  group_by(playerID) %>% 
  summarise(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE)
  )

batters %>% 
  filter(ab > 100) %>% 
  ggplot(mapping = aes(x = ab, y = ba)) + 
  geom_point() + 
  geom_smooth(se = FALSE)

# 5.6.7 Exercises
# 1: 15 minutes early 50% and 15 minutes late 50%
flights %>% 
  group_by(flight) %>% 
  filter(!is.na(arr_delay)) %>% 
  summarise(
    early = sum(arr_delay <= -15) / n(),  
    late = sum(arr_delay > 15) / n()
  ) %>% 
  filter(early == 0.5, late == 0.5)

# 2 always 10 minutes late
flights %>% 
  group_by(flight) %>% 
  filter(!is.na(arr_delay)) %>% 
  summarise(
    late = sum(arr_delay > 10) / n()
  ) %>% 
  filter(late == 1)

# a flight is either 30 minutes early or 30 minutes late
flights %>% 
  group_by(flight) %>% 
  filter(!is.na(arr_delay)) %>% 
  summarise(
    early = sum(arr_delay <= -30) / n(),  
    late = sum(arr_delay > 30) / n()
  ) %>% 
  filter(early + late == 1 & early > 0 & late > 0)
  
# 2
not_cancelled %>% count(dest)
# same query
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(
    counter = n()
  )

not_cancelled %>% count(tailnum, wt = distance)
# same query
not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    counter = sum(distance)
  )

# 3 not cancelled?? dep_delay is more important
filter(flights, is.na(arr_delay) | is.na(dep_delay)) %>% 
  select(dep_time:arr_delay)

# 4 
cancels <- flights %>% 
  group_by(year, month, day) %>% 
  summarise(
    cancel = sum(is.na(arr_delay)) / n(),
    delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  arrange(cancel) 

# 5.7 grouping with mutate and filter
# 1 useful functions are useful
# 2 tailnum worst
flights %>% 
  group_by(tailnum) %>% 
  summarise(
    late = mean(arr_delay, na.rm = TRUE),
    counter = n()
  ) %>% 
  arrange(desc(late))

# 3 
flights %>% 
  group_by(hour) %>% 
  summarise(
    late = mean(arr_delay, na.rm = TRUE)
  )

# 4 
dest_delay <- flights %>% 
  group_by(dest) %>% 
  summarise(
    late = sum(arr_delay, na.rm = TRUE)
  )

flights %>% 
  group_by(flight) %>% 
  summarise(
    lateness = sum(arr_delay, na.rm = TRUE) / dest_delay
  )

# 5 
flights %>%
  group_by(origin) %>%
  arrange(year, month, day, hour, minute) %>%
  filter(!is.na(dep_delay)) %>%
  mutate(lag_delay = lag(dep_delay)) %>%
  filter(!is.na(lag_delay) | day != lag(day)) %>% 
  ggplot(aes(x = dep_delay, y = lag_delay)) +
  geom_point() +
  geom_smooth()


