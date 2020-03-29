#library(lme4)
source("models/model_makers.R")
df <- read.csv("data/final_cleaned_with_composite_scores.csv")

####
#Q1) How deos the human impact of natural disasters change by provinces in Canada?
####

######
#This file runs normal mixed models for human impacts by province
######
#The linear model predicts the humanomic impact of natural disasters in canada. The response 'human_cost_comp_score' is a composite
#
##
y <- "human_cost_comp_score"
x <- c(names(df))[c(3,22, 25)]
mixed_component <- c(names(df))[6] #province/territory 

#linear model
human_province_0 <- linear_regression(y, x, df, 'human_province_0', 'dont_save_weights')
#mixed model with random intercept
human_province_1 <-
  mixed_models(y, x, mixed_component, df, 'no_slope', 'human_province_1', 'dont_save_weights')
human_province_2 <-
  mixed_models(y, x, mixed_component, df, 'with_slope', 'human_province_2', 'dont_save_weights')

summary(human_province_0)
coef(human_province_0)
summary(human_province_1)
summary(human_province_2)
