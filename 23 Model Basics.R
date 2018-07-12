## 22 Introduction

# exploration, not confirmation or formal inference
# capture signals, ignore noise
# predictive models, not data discovery
# build intuition, family of tools

# model basics: general tools for gaining insight
# model building: pull out known patterns in real data
# many models: many simple models to understand complex datasets
# combine modelling and programming tools

# doesn't include quantitative assessment
# big ideas, with links for other resources

######
# 22.1 hypothesis generation vs hypothesis confirmation

# exploration or confirmation, not both

# ultimately best to split into three parts
# 60% training or exploration
# 20% query for comparison
# 20% test final model

##################################################################
## 23 Model Basics

# 23.1 Introduction

# partition data into patterns and residuals
# peel back layers of structure as we explore

# simulated datasets for demonstration 

# family of models for a precise but generic pattern
# fitted model that is closest to your data

# implication is best model, not necessarily true or even good model 
# best according to some criteria

# goal is not to uncover truth (this is impossible)
# goal is to provide approximation that is useful

######
# 23.1.1 Prerequisites

library(tidyverse)
library(modelr)
options(na.action = na.warn)

######
# 23.2 A Simple Model

# sim1 included with modelr, x and y variables

ggplot(sim1, aes(x, y)) + 
  geom_point()

# relationship looks linear (y = a_0 + a_1 * x)
# family of models is linear: lets generate some random ones

models <- tibble(
  a1 = runif(250, -20, 40), 
  a2 = runif(250, -5, 5)
)

ggplot(sim1, aes(x, y)) + 
  geom_point() + 
  geom_abline(aes(intercept = a1, slope = a2), data = models, alpha = 1/4)

# the majority of these are horrible
# what defines a good model? 

# for something like this, vertical distance to y for each x value
# difference between prediction of model and actual y value response

# take model parameters and data as inputs, returns predicted values

model1 <- function(a, data) {
  a[1] + data$x * a[2]
}

model1(c(7, 1.5), sim1)

# next compute overall distance between predicted and actual values

# root-mean-squared deviation
# appealing mathematical qualities

measure_distance <- function(mod, data) {
  diff <- data$y - model1(mod, data)
  sqrt(mean(diff ^ 2))
}

measure_distance(c(7, 1.6), sim1)

# use purrr for helper functions 

sim1_dist <- function(a1, a2) {
  measure_distance(c(a1, a2), sim1)
}

models <- models %>%
  mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))

models

# get the 10 best models and colour by -dist for best colour

ggplot(sim1, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(
    aes(intercept = a1, slope = a2, colour = -dist), 
    data = filter(models, rank(dist) <= 10)
  )

# can think of models as observations
# compare models with each other, but lack comparison to data

ggplot(models, aes(a1, a2)) + 
  geom_point(data = filter(models, rank(dist) <= 10), size = 4, colour = "red") +
  geom_point(aes(colour = -dist))

# all the models come from the same region
# let's try a grid search around that region and then again choose the 10 best

grid <- expand.grid(
  a1 = seq(-5, 20, length = 25), 
  a2 = seq(1, 3, length = 25)
) %>% 
  mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))

grid %>% 
  ggplot(aes(a1, a2)) + 
  geom_point(data = filter(grid, rank(dist) <= 10), size = 4, colour = "red") + 
  geom_point(aes(colour = -dist))

# lets put those 10 models back on the original data
# they look quite good

ggplot(sim1, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") +
  geom_abline(
    aes(intercept = a1, slope = a2, colour = -dist), 
    data = filter(grid, rank(dist) <= 10)
  )

# keep making the grid smaller and smaller? 
# no thank you! 
# Newton-Raphson search can do that for us
# function in R is optim()

best <- optim(c(0,0), measure_distance, data = sim1)
best$par

ggplot(sim1, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(intercept = best$par[1], slope = best$par[2])

# just need to be able to write a function comparing model and dataset

# linear models are more generalised
# any amount of predictors for a set of observations

sim1_mod <- lm(y ~ x, data = sim1)
coef(sim1_mod)



# 23.2.1 Exercises

# 1 
# downside to linear model is sensitivity
# there doesn't seem to be anything going on with this model
sim1a <- tibble(
  x = rep(1:10, each = 3),
  y = x * 1.5 + 6 + rt(length(x), df = 2)
)

sim1a_mod <- lm(y ~ x, data = sim1a)

ggplot(sim1a, aes(x, y)) + 
  geom_point() + 
  geom_abline(intercept = sim1a_mod$coefficients[1], slope = sim1a_mod$coefficients[2])

# 2 
# more robust with different measure, mean-absolute distance
# model doesn't really make any difference
# might move slightly away from outlier point

measure_distance2 <- function(mod, data) {
  diff <- data$y - model1(mod, data)
  mean(abs(diff))
}

best <- optim(c(0,0), measure_distance2, data = sim1a)

best$par

ggplot(sim1a, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(intercept = best$par[1], slope = best$par[2])

# 3 
# one local optima
# what's the problem here? 
# We don't know how to attribute a[1] and a[3] properly 
# how much of the intercept is for each part? 

model2 <- function(a, data) {
  a[1] + data$x * a[2] + a[3]
}


######
# 23.3 Visualising Models
# study the predictions of a model, rather than the outputs, which might be weird

# 23.3.1 Predictions

# create grid for x
grid <- sim1 %>% 
  data_grid(x)

# add predictions for each value in the grid
grid <- grid %>% 
  add_predictions(sim1_mod)

# show the grid
grid

# now plot - this works with any model, as long as you can create visual
ggplot(sim1, aes(x)) +
  geom_point(aes(y = y)) +
  geom_line(aes(y = pred), data = grid, colour = "red", size = 1)



# 23.3.2 Residuals
# flip side of predictions, residuals tell us what we've missed

sim1 <- sim1 %>% 
  add_residuals(sim1_mod)

sim1

# possible to draw frequency polygon
ggplot(sim1, aes(resid)) + 
  geom_freqpoly(binwidth = 0.5)

# maybe plot residuals instead of original predictions
ggplot(sim1, aes(x, resid)) + 
  geom_ref_line(h = 0) +
  geom_point()

# it looks like random noise, meaning model has done well. 



# 23.3.3 Exercises

# 1 
