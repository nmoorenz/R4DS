# 3 Data Visualisation

#library(tidyverse)
#library(plotly)
library(ggplot2)
library(tibble)
library(readr)
library(tidyr)
library(purrr)
library(dplyr)
library(maps)


#3.2 
# miles per gallon data set
mpg
# data set help page
?mpg
# create a simple plot
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy))

#exercises
#3.2.4.1: produces blank plot (no aesthetic!)
ggplot(data = mpg)
#3.2.4.2
# 234 rows and 11 columns
#3.2.4.3 
# type of drive of vehicle: f=front, r=rear, 4=4wd
#3.2.4.4
ggplot(data = mpg) +
  geom_point(mapping = aes(x = hwy, y = cyl))
# cyl is categorical variable - distinct groups
#3.2.4.5
ggplot(data = mpg) +
  geom_point(mapping = aes(x = class, y = drv))
# not useful because only shows what categories exist, not how many there are in each. 

# 3.3 aesthetics
# different colours for different classes of car
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, color = class))
# change colour of each point
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue")

# 3.3.1 Exercises
# 1 set the manual aesthetic outside the aes function
# 2 categorical variables: manufacturer, model, trans, drv, fl, class, cyl
# continuos variables: displ, year, cty, hwy
# 3 
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, color = cty))
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, size = cty))
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, shape = hwy))
# 4 this is kind of pointless 
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, color = hwy))
# 5 stroke changes the size of the border
?geom_point
ggplot(mtcars, aes(wt, mpg)) +
  geom_point(shape = 21, colour = "black", fill = "white", size = 5, stroke = 1)
# 6 boolean colouring of charts!
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, colour = displ < 5))

# 3.4 Common Problems
# use google

# 3.5 Facets
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_wrap(~ class, nrow = 2)
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ cyl)
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)

# 3.5.1 Exercises
# 1 facet with continuous variable
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cty)
# groups of variables are rounded
# 2 empty cells in facet means those combinations don't exist
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = drv, y = cyl))
# the points where there is no point means there is no facet to consider either
# 3 
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)
# similar plots that could be considered separately
# split thee facets into their individual parts
# 4 
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2)
# advantage is easier to consider each one individually. 
# disadvantage is miss relativity between each group.
# larger dataset would mean messier in one plot
# 5 
?facet_wrap
# facet wrap gives groups on each table but allows those tables to be across
# multiple rows or columns. facet grid compares variables and allocates
# rows or columns to each element of the variables
# 6 
# more information in the rows would be difficult to see

# 3.6 Geometric Objects
# left 
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy))
#right
ggplot(data = mpg) + 
  geom_smooth(mapping = aes (x = displ, y = hwy))
# differentiate by drive
ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv))
# change the colour by drive
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, color = drv),
    show.legend = FALSE)
# multiple geoms
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  geom_smooth(mapping = aes(x = displ, y = hwy))
# same output 
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()
# individual mapping for different geom and aes
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth()
# different data for different geoms
# global is mpg, smooth is subcompact
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth(data = filter(mpg, class == "subcompact"), se = FALSE)

# 3.6.1 Exercises
# 1: line = geom_line. boxplot = geom_boxplot. histogram = geom_histogram
# area = geom_area
# 2 
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
  geom_point() + 
  geom_smooth(se = FALSE)
# 3 remove a legend. information might be clearer
# 4 se = standard error, description of range for line
# 5 same chart!
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()
ggplot() + 
  geom_point(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_smooth(data = mpg, mapping = aes(x = displ, y = hwy))
# 6 
# black dots, separate lines on second
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth(se = FALSE)
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, group = drv), se = FALSE)
# coloured charts by drve
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, colour = drv)) + 
  geom_point() + 
  geom_smooth(se = FALSE)
# overall data for line
ggplot() + 
  geom_point(data = mpg, mapping = aes(x = displ, y = hwy, colour = drv)) + 
  geom_smooth(data = mpg, mapping = aes(x = displ, y = hwy),se = FALSE)
# data split by drive incl linetype
ggplot() + 
  geom_point(data = mpg, mapping = aes(x = displ, y = hwy, colour = drv)) + 
  geom_smooth(data = mpg, mapping = aes(x = displ, y = hwy, linetype = drv),se = FALSE)
# change the shape and set the stroke to larger
ggplot() + 
  geom_point(data = mpg, mapping = aes(x = displ, y = hwy, fill = drv), shape = 21, size = 4, colour = "white", stroke = 3)

# 3.7 statistical transformations
?diamonds
# same charts!
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut))
ggplot(data = diamonds) + 
  stat_count(mapping = aes(x = cut))
# different uses for stats and geoms
demo <- tribble(
  ~cut,         ~freq,
  "Fair",       1610,
  "Good",       4906,
  "Very Good",  12082,
  "Premium",    13791,
  "Ideal",      21551
)
ggplot(data = demo) +
  geom_bar(mapping = aes(x = cut, y = freq), stat = "identity")
# proportions
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = ..prop.., group = 1))
# statistical summary in code
ggplot(data = diamonds) + 
  stat_summary(
    mapping = aes(x = cut, y = depth),
    fun.ymin = min,
    fun.ymax = max,
    fun.y = median
  )

# 3.7.1 Exercises
# 1 default of histogram
?stat_summary
# 2 geom_col represents values in the data, rather than counts
?geom_col
# 3 there's so many pairs!
?ggplot2
# 4 smooth lines - standard error around the data
?stat_smooth
# 5 these charts display the proportion within their own cut!
# need to put all the cuts into 1 group

# 3.8 Position adjustments
# meh
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, colour = cut))
# nice
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = cut))
# even better!
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity))
# not so good
ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) + 
  geom_bar(alpha = 1/5, position = "identity")
# not so good, behind each other
ggplot(data = diamonds, mapping = aes(x = cut, colour = clarity)) + 
  geom_bar(fill = NA, position = "identity")
# proportion in each group
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill")
# this is nice with "dodge"
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "dodge")
# avoid overplotting by adding jitter
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), position = "jitter")

# 3.8.1 Exercises
# 1 improve by adding jitter
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_point(position = "jitter")
# 2 change the amount by using height and width
?geom_jitter
# 3 could each be used in different circumstances
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_jitter()
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_count()
# 4 identity position adjustment
ggplot(data = mpg, mapping = aes(x = manufacturer, y = hwy)) +
  geom_boxplot()

# 3.9 Coordinate systems
# regular
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot()
# coord flip
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot() +
  coord_flip()
# maps
nz <- map_data("nz")
ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", colour = "black") + 
  coord_quickmap()

# polar coordinates
bar <- ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = cut, fill = cut), 
    show.legend = FALSE, 
    width = 1
    ) + 
  theme(aspect.ratio = 1) +
  labs(x = NULL, y = NULL) 
bar + coord_flip()
bar + coord_polar()

# 3.9.1 Exercises
# 1 stacked bar into pie
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity)) + 
  coord_polar()
# 2 modify charts information! 
?labs
# 3 quickmap is an approximation without consideration of projection
?coord_quickmap
?coord_map
# 4 abline adds trendline, fixed coords means x = y 
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point() + 
  geom_abline() +
  coord_fixed()
