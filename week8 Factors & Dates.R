#############

# 15 Factors
library(tidyverse)
library(forcats)

# 15.2 Creating Factors

# create vector
x1 <- c("Dec", "Apr", "Jan", "Mar")

# spelling mistake
x2 <- c("Dec", "Apr", "Jam", "Mar")

# sorting isn't helpful
sort(x1)

# create valid levels
month_levels <- c(
  "Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
)

# create factor
y1 <- factor(x1, levels = month_levels)

# sort makes sense
sort(y1)

# invalid values get converted to NA
y2 <- factor(x2, levels = month_levels)

y2

# possible to use parse_factor() to get an error

# levels are created in alphabetical order by default
factor(x1)

# maybe it's the appearance in the data that is important
# use unique() or fct_inorder()
f1 <- factor(x1, levels = unique(x1))
f1

f2 <- x1 %>% factor() %>% fct_inorder()
f2

# access levels directly 
levels(f2)

######
# 15.3 General Social Survey

gss_cat

# check levels of things
gss_cat %>% count(race)

# anything without a value gets dropped but that can be forced
ggplot(gss_cat, aes(race)) + 
  geom_bar() +
  scale_x_discrete(drop = FALSE)

########
# 15.3.1 Exercise

# explore rincome
gss_cat %>% count(rincome)

ggplot(gss_cat, aes(rincome)) +
  geom_bar() + 
  coord_flip()

# relig, partyid
gss_cat %>% count(relig)
gss_cat %>% count(partyid)

######
# 15.4 Modifying Factor Order

relig_summary <- gss_cat %>% 
  group_by(relig) %>% 
  summarise(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE), 
    n = n()
  )

ggplot(relig_summary, aes(tvhours, relig)) + geom_point()

# modify the plot to get order
ggplot(relig_summary, aes(tvhours, fct_reorder(relig, tvhours))) + 
  geom_point()

# remove complicated transformations out of aes()

relig_summary %>% 
  mutate(relig = fct_reorder(relig, tvhours)) %>% 
  ggplot(aes(tvhours, relig)) + 
    geom_point()

# age and income
rincome_summary <- gss_cat %>% 
  group_by(rincome) %>% 
  summarise(
    age = mean(age, na.rm = TRUE), 
    tvhours = mean(tvhours, na.rm = TRUE), 
    n = n()
  )

ggplot(rincome_summary, aes(age, fct_reorder(rincome, age))) + 
  geom_point()

# income order already makes sense, but do want to move not applicable
ggplot(rincome_summary, aes(age, fct_relevel(rincome, "Not applicable"))) + 
  geom_point()

# reorder according to the colours on a chart!!!!!

by_age <- gss_cat %>% 
  filter(!is.na(age)) %>% 
  group_by(age, marital) %>% 
  count() %>% 
  ungroup() %>% 
  group_by(age) %>% 
  mutate(prop = n / sum(n))

ggplot(by_age, aes(age, prop, colour = marital)) + 
  geom_line(na.rm = TRUE)

ggplot(by_age, aes(age, prop, colour = fct_reorder2(marital, age, prop))) + 
  geom_line() + 
  labs(colour = "marital")

# bar charts order by increasing frequency

gss_cat %>% 
  mutate(marital = marital %>% fct_infreq() %>% fct_rev()) %>% 
  ggplot(aes(marital)) + 
  geom_bar()

########
# 15.4.1 Exercises

# what other summary is possible? remove outliers? 
gss_cat %>% count(tvhours)

# levels() 
#marital, race, rincome, partyid, relig, denom
gss_cat
levels(gss_cat$marital) #meh
levels(gss_cat$race) #meh
levels(gss_cat$rincome) #nice
levels(gss_cat$partyid) #nice
levels(gss_cat$relig) #meh
levels(gss_cat$denom) #nearly

######
# 15.5 modifying factor levels

# not that good
gss_cat %>% count(partyid)

# improvements
gss_cat %>%
  mutate(partyid = fct_recode(partyid,
  "Republican, strong"    = "Strong republican",
  "Republican, weak"      = "Not str republican",
  "Independent, near rep" = "Ind,near rep",
  "Independent, near dem" = "Ind,near dem",
  "Democrat, weak"        = "Not str democrat",
  "Democrat, strong"      = "Strong democrat"
  )) %>%
  count(partyid)

gss_cat %>%
  mutate(partyid = fct_recode(partyid,
  "Republican, strong"    = "Strong republican",
  "Republican, weak"      = "Not str republican",
  "Independent, near rep" = "Ind,near rep",
  "Independent, near dem" = "Ind,near dem",
  "Democrat, weak"        = "Not str democrat",
  "Democrat, strong"      = "Strong democrat",
  "Other"                 = "No answer",
  "Other"                 = "Don't know",
  "Other"                 = "Other party"
  )) %>%
  count(partyid)

# also use collapse for many levels
gss_cat %>%
  mutate(partyid = fct_collapse(partyid,
  other = c("No answer", "Don't know", "Other party"),
  rep = c("Strong republican", "Not str republican"),
  ind = c("Ind,near rep", "Independent", "Ind,near dem"),
  dem = c("Not str democrat", "Strong democrat")
  )) %>%
  count(partyid)

# lump together the smallest groups until it isn't the smallest any more
gss_cat %>% 
  mutate(relig = fct_lump(relig)) %>% 
  count(relig)

# to not oversimplify use number of groups
gss_cat %>% 
  mutate(relig = fct_lump(relig, n = 10)) %>% 
  count(relig, sort = TRUE) %>% 
  print(n = Inf)

########
# 15.5.1 Exercises

# how has party affiliation changed over time
party_year <- gss_cat %>%
  mutate(partyid = fct_collapse(partyid,
  other = c("No answer", "Don't know", "Other party"),
  rep = c("Strong republican", "Not str republican"),
  ind = c("Ind,near rep", "Independent", "Ind,near dem"),
  dem = c("Not str democrat", "Strong democrat")
  )) %>%
  group_by(year, partyid) %>% 
  count() %>% 
  ungroup() %>% 
  group_by(year) %>% 
  mutate(prop = n / sum(n))

  ggplot(party_year, aes(year, prop, colour = fct_reorder2(partyid, year, prop))) +
  geom_line() + 
  labs(colour = "party")

  
############################################
# 16 Dates and Times
  
library(tidyverse)
library(lubridate)
library(nycflights13)

# 16.2 Creating date/times
today()
now()

# 16.2.1 From strings

# ymd() mdy() dmy()
ymd("2017-01-31")
ymd(20170630)
ymd_hm("2017-12-25 10:00", tz = "NZ")

# 16.2.2 from components
flights %>% 
  select(year, month, day, hour, minute) %>% 
  mutate(departure = make_datetime(year, month, day, hour, minute))

# modulus arithmetic for some funky times
make_datetime_100 <- function(year, month, day, time) {
  make_datetime(year, month, day, time %/% 100, time %% 100)
}

flights_dt <- flights %>% 
  filter(!is.na(dep_time), !is.na(arr_time)) %>% 
  mutate(
    dep_time = make_datetime_100(year, month, day, dep_time),
    arr_time = make_datetime_100(year, month, day, arr_time), 
    sched_dep_time = make_datetime_100(year, month, day, sched_dep_time), 
    sched_arr_time = make_datetime_100(year, month, day, sched_arr_time)
  ) %>% 
  select(origin, dest, ends_with("delay"), ends_with("time"))
flights_dt

# visualise departures in a year
flights_dt %>% 
  ggplot(aes(dep_time)) + 
  geom_freqpoly(binwidth = 86400)

# or in a single day
flights_dt %>% 
  filter(dep_time < ymd(20130102)) %>% 
  ggplot(aes(dep_time)) +
  geom_freqpoly(binwidth = 600)

# 16.2.3 From other types
as_datetime(today())

as_date(now())

# Unix Epoch is 1970-01-01

########
# 16.2.4 Exercises

# invalid
ymd(c("20101010", "bananas"))

# tzone
today(tzone = "NZ")

# lubridate functions

d1 <- mdy("January 1, 2010")
d2 <- ymd("2015-Mar-07")
d3 <- dmy("06-Jun-2017")
d4 <- mdy(c("August 19 (2015)", "July 1 (2015)"))
d5 <- mdy("12/30/14") # Dec 30, 2014

######
# 16.3 Date-time components

datetime <- ymd_hms("2016-07-08 12:34:56")
year(datetime)
month(datetime)
mday(datetime) # day of month
yday(datetime) # day of year
wday(datetime) # day of week
month(datetime, label = TRUE) # abbreviated name of month
wday(datetime, label = TRUE, abbr = FALSE) # full name of weekday

flights_dt %>% 
  mutate(wday = wday(dep_time, label = TRUE)) %>% 
  ggplot(aes(x = wday)) + 
  geom_bar()

# on the hour or half hour don't have as much delay

flights_dt %>% 
  mutate(minute = minute(dep_time)) %>% 
  group_by(minute) %>% 
  summarise(
    avg_delay = mean(arr_delay, na.rm = TRUE),
    n = n()) %>% 
  ggplot(aes(minute, avg_delay)) +
  geom_line()

sched_dep <- flights_dt %>% 
  mutate(minute = minute(sched_dep_time)) %>% 
  group_by(minute) %>% 
  summarise(
    avg_delay = mean(arr_delay, na.rm = TRUE),
    n = n())

ggplot(sched_dep, aes(minute, avg_delay)) +
  geom_line()

ggplot(sched_dep, aes(minute, n)) +
  geom_line()

# 16.3.2 Rounding (good for grouping)

flights_dt %>% 
  count(week = floor_date(dep_time, "week")) %>% 
  ggplot(aes(week, n)) + 
  geom_line()

# 16.3.3 setting components
(datetime <- ymd_hms("2016-07-08 12:34:56"))
year(datetime) <- 2010
month(datetime) <- 01
hour(datetime) <- 02
datetime

update(datetime, year = 2020, month = 4, mday = 22, minute = 22)

# large values will roll over, negatives go backwards
ymd("2015-01-01") %>% update(mday = 35)
ymd("2015-03-01") %>% update(hour = -20)

flights_dt %>% 
  mutate(dep_hour = update(dep_time, yday = 1)) %>% 
  ggplot(aes(dep_hour)) + 
  geom_freqpoly(binwidth = 600)

########
# 16.3.4 Exercises
flights_dt %>% 
  mutate(
    dep_hour = update(dep_time, yday = 1), 
    dep_month = month(dep_time)
    ) %>% 
  ggplot(aes(dep_hour, colour = dep_month, group = dep_month)) + 
  geom_freqpoly(binwidth = 600)

# dep_time, sched_dep_time, dep_delay
flights_dep <- flights %>% 
  filter(!is.na(dep_time)) %>% 
  mutate(
    dep_time = make_datetime_100(year, month, day, dep_time),
    sched_dep_time = make_datetime_100(year, month, day, sched_dep_time), 
    est_dep_time = sched_dep_time + dep_delay * 60
  ) %>% 
  select(origin, dest, ends_with("dep_time"), dep_delay) %>% 
  filter(dep_time != est_dep_time)

flights_dep

# adjusting timezones for airports and flight times!

# average delay time over day
flights_dt %>% 
  mutate(dep_hour = update(sched_dep_time, yday = 1)) %>% 
  group_by(dep_hour) %>% 
  mutate(delays = mean(dep_delay)) %>% 
  ggplot(aes(dep_hour, delays)) + 
  geom_line()

# day of week
flights_dt %>% 
  mutate(weekday = wday(sched_dep_time)) %>% 
  group_by(weekday) %>% 
  mutate(delays = mean(dep_delay)) %>% 
  ggplot(aes(weekday, delays)) + 
  geom_line()

# carats and sched_dep_time
flights_dt %>% 
  mutate(dep_hour = update(sched_dep_time, yday = 1, hour = 1)) %>% 
  ggplot(aes(dep_hour)) + 
  geom_freqpoly()

diamonds %>% 
  ggplot(aes(carat)) + 
  geom_freqpoly()

######
# 16.4 Time spans

# durations, periods, intervals

# lubridate always measures duration in seconds - vectorised construction
dseconds(20)
dminutes(30)
dhours(36)
ddays(0:7)
dweeks(2) + dyears(2)

today() + ddays(1)
today() + 1

# periods more human like
seconds(15)
minutes(15)
hours(15)
days(15)
months(15)
weeks(15)
years(0:3)

10 * months(10) 
today() + hours(50)

# can use these to fix some times in the flights data
flights_dt %>% 
  filter(arr_time < dep_time)

flights_dt <- flights_dt %>% 
  mutate(
    overnight = arr_time < dep_time, 
    arr_time = arr_time + days(overnight * 1), 
    sched_arr_time = sched_arr_time + days(overnight * 1)
  )

flights_dt %>% 
  filter(arr_time < dep_time) 

# 16.4.3 Intervals
dyears(1) / ddays(365) # should return one because both are actually in seconds
years(1) / days(1) # warning because not always true (leap year)

# more accurate to use intervals
next_year <- today() + years(1)
(today() %--% next_year) / ddays(1)

(today() %--% next_year) %/% days(1)

########
# 16.4.5 Exercises

# there's no dmonths() because months are all different!

# overnight is boolean, only multiplies if true

# vector of dates first of every month in 2015
ymd("2015-01-01") + months(0:11)

make_date(year(today()), 1, 1) + months(0:11)

# function for age from birthdate
my_age <- function(birthdate) {
  (birthdate %--% today()) / dyears(1)
}
my_age(ymd("1984-09-20"))

# wrong? 
(today() %--% (today() + years(1))) / months(1)
  
######
# 16.5 Timezones
Sys.time()
Sys.timezone()

(x1 <- ymd_hms("2015-06-01 12:00:00", tz = "America/New_York"))
(x2 <- ymd_hms("2015-06-01 18:00:00", tz = "Europe/Copenhagen"))
(x3 <- ymd_hms("2015-06-02 04:00:00", tz = "Pacific/Auckland"))

# these are all the same!
x1 - x2
x2 - x3

# can combine these
(x4 <- c(x1, x2, x3))
