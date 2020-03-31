#library(lme4)
source("models/model_makers.R")
df <- read.csv("data/final_cleaned_with_composite_scores.csv")

####
#Q1) How has the econ impact of natural disasters changed over province in Canada?
####

######
#This file runs normal mixed models for econom  ic impacts by province
######
#The linear model predicts the economic impact of natural disasters in canada. The response 'econ_cost_comp_score' is a composite
#
##
y <- "NORMALIZED.TOTAL.COST"
x <- c('EVENT.TYPE', 'event_duration', 'MAGNITUDE')
mixed_component <- c('Province.Territory') #province/territory 

#linear model
econ_province_0 <- linear_regression(y, x, df, 'econ_province_0', 'dont_save_weights')
#mixed model with random intercept
econ_province_1 <-
  mixed_models(y, x, mixed_component, df, 'no_slope', 'econ_province_1', 'dont_save_weights')
econ_province_2 <-
  mixed_models(y, x, mixed_component, df, 'with_slope', 'econ_province_2', 'dont_save_weights')

summary(econ_province_0)
coef(econ_province_0)
summary(econ_province_1)
summary(econ_province_2)
