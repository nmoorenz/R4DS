# 7 Exploratory Data Analysis

library(tidyverse)

# categorical - bar chart
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut))

# continuous - histogram
smaller <- diamonds %>% 
  filter(carat < 3)

ggplot(data = smaller, mapping = aes(x = carat)) +
  geom_histogram(binwidth = 0.1)

# compare with lines, easier than bars
ggplot(data = smaller, mapping = aes(x = carat, colour = cut)) +
  geom_freqpoly(binwidth = 0.1)

# typical values
ggplot(data = smaller, mapping = aes(x = carat)) +
  geom_histogram(binwidth = 0.01)

ggplot(data = faithful, mapping = aes(x = eruptions)) + 
  geom_histogram(binwidth = 0.1)

# unusual values
ggplot(diamonds) + 
  geom_histogram(mapping = aes(x = y), binwidth = 0.5)

# concentrate on lower counts
ggplot(diamonds) + 
  geom_histogram(mapping = aes(x = y), binwidth = 0.5) +
  coord_cartesian(ylim = c(0, 50))

# 7.3.4 Exercises
# x, y, z in diamonds
ggplot(diamonds) +
  geom_histogram(mapping = aes(x = x), binwidth = 0.5)

ggplot(diamonds) +
  geom_histogram(mapping = aes(x = y), binwidth = 0.5)

ggplot(diamonds) +
  geom_histogram(mapping = aes(x = z), binwidth = 0.5) + 
  coord_cartesian(ylim = c(0,50))

unusual_z <- diamonds %>% 
  filter(z < 1 | z > 10) %>% 
  select(price, x, y, z) %>% 
  arrange(z, x, y)
View(unusual_z)

# y and z outliers seem to be related

# explore price
ggplot(diamonds) +
  geom_histogram(mapping = aes(x = price), binwidth = 50)

ggplot(diamonds) +
  geom_histogram(mapping = aes(x = price), binwidth = 50) + 
  coord_cartesian(xlim = c(1000,2500))

# 0.99 carat v 1 carat
ggplot(diamonds) +
  geom_histogram(mapping = aes(x = carat), binwidth = 0.01)

ggplot(diamonds) +
  geom_histogram(mapping = aes(x = carat), binwidth = 0.01) + 
  coord_cartesian(xlim = c(0.95, 1.05))

# coord_cartesion v xlim() and ylim() - not inclusive
ggplot(diamonds) +
  geom_histogram(mapping = aes(x = carat), binwidth = 0.02) + 
  xlim(0.95, 1.05)

ggplot(diamonds) +
  geom_histogram(mapping = aes(x = carat), binwidth = 0.01) + 
  xlim(0.95, 1.05)

# 7.4 Missing Values
# missing values set to NA
diamonds2 <- diamonds %>% 
  mutate(y = ifelse(y < 3 | y > 20, NA, y))

ggplot(data = diamonds2, mapping = aes(x = x, y = y)) + 
  geom_point()

# 7.4.1 Exercises
# missing values in a histogram - removed
ggplot(data = diamonds2, mapping = aes(x = y)) + 
  geom_histogram()

# missing values in a bar chart
diamonds3 <- diamonds %>% 
  mutate(cut = ifelse(y < 3 | y > 20, NA, cut))

ggplot(data = diamonds3) +
  geom_bar(mapping = aes(x = cut))

# na.rm = TRUE removes NA values 
# this means that mean() and sum() can be calculated

# 7.5 covariation

# density of prices to give a distribution, allows fair comparison
ggplot(data = diamonds, mapping = aes(x = price, y = ..density..)) + 
  geom_freqpoly(mapping = aes(colour = cut), binwidth = 500)

# boxplots for distribution
ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_boxplot()

# boxplot without ordered variable - messy!
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot()

ggplot(data = mpg) + 
  geom_boxplot(mapping = aes(x = reorder(class, hwy, FUN = median), y = hwy))

# coord_flip() to fit in long names
ggplot(data = mpg) +
  geom_boxplot(mapping = aes(x = reorder(class, hwy, FUN = median), y = hwy)) +
  coord_flip()

# 7.5.1 exercises

# improve the plot for cancelled and non-cancelled flights
nycflights13::flights %>% 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>% 
  ggplot(mapping = aes(x = sched_dep_time, y = ..density..)) + 
  geom_freqpoly(mapping = aes(colour = cancelled), binwidth = 1/4)

# what is most important predictor for price? 
ggplot(data = diamonds, mapping = aes(x = carat, y = price)) +
  geom_point()
# these two plots look really similar!
ggplot(data = diamonds, mapping = aes(x = cut, y = carat)) +
  geom_boxplot()
ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_boxplot()

# ggstance
# what the flip?
library(ggstance)
library(lvplot)

# geom_lv
ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_lv()

# geom_violin
ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_violin()

ggplot(diamonds) +
  geom_histogram(mapping = aes(x = price), binwidth = 50) + 
  facet_wrap(~ cut)

# 6 ggbeeswarm
library(ggbeeswarm)


# 7.5.2 two categorical variables
ggplot(data = diamonds) +
  geom_count(mapping = aes(x = cut, y = color))

diamonds %>% 
  count(color, cut) %>% 
  ggplot(mapping = aes(x = color, y = cut)) +
  geom_tile(mapping = aes(fill = n))

# flights and delays
nycflights13::flights %>% 
  group_by(month) %>% 
  mutate(
    avg_delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  ggplot(mapping = aes(x = dest, y = month)) + 
    geom_tile(mapping = aes(fill = avg_delay))
  
# 7.5.2.1 3
diamonds %>% 
  count(color, cut) %>% 
  ggplot(mapping = aes(x = color, y = cut)) +
  geom_tile(mapping = aes(fill = n))
# this chart has left to right reading of colour

# 7.5.3 Two continuous variables
ggplot(data = diamonds) +
  geom_point(mapping = aes(x = carat, y = price), alpha = 1/100)

# hexbin
ggplot(data = smaller) +
  geom_bin2d(mapping = aes(x = carat, y = price))

ggplot(data = smaller) + 
  geom_hex(mapping = aes(x = carat, y = price))

# cut continuous into categorical
ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)))

ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_number(carat, 20)))

# 7.5.3.1 Exercises
# 1 
# blergh

#7.6 Patterns and Models
ggplot(data = faithful) + 
  geom_point(mapping = aes(x = eruptions, y = waiting))

library(modelr)

mod <- lm(log(price) ~ log(carat), data = diamonds)

diamonds2 <- diamonds %>% 
  add_residuals(mod) %>% 
  mutate(resid = exp(resid))

ggplot(data = diamonds2) +
  geom_point(mapping = aes(x = carat, y = resid))

ggplot(data = diamonds2) +
  geom_boxplot(mapping = aes(x = cut, y = resid))

# 7.7 ggplot2 calls
ggplot(data = faithful, mapping = aes(x = eruptions)) +
  geom_freqpoly(binwidth = 0.25)

# same plot
ggplot(faithful, aes(eruptions)) +
  geom_freqpoly(binwidth = 0.25)

# pipe to +
diamonds %>% 
  count(cut, clarity) %>% 
  ggplot(aes(clarity, cut, fill = n)) +
  geom_tile()
  
# 7.8 learn more
#  http://www.cookbook-r.com/Graphs/
