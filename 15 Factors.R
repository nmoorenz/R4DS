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

  