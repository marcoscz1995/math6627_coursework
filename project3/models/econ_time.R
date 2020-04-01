#library(lme4)
source("models/model_makers.R")
df <- read.csv("data/final_cleaned_with_composite_scores.csv")

####
#Q1) How has the econ impact of natural disasters changed over time in Canada?
####

######
#This file runs normal mixed models for econom  ic impacts by time
######
#The linear model predicts the economic impact of natural disasters in canada. The response 'econ_cost_comp_score' is a composite
#
######Normal models on popularity score 
#no randomness
econ_time_0 <-
  lm(
    NORMALIZED.TOTAL.COST ~ EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved,
    data = df
  )
#only random intercept
econ_time_1 <-
  lmer(
    NORMALIZED.TOTAL.COST ~ EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved + (1 |
                                                                                                  closest_year),
    data = df
  )
summary(econ_time_1)
#random intercept and slope
econ_time_2 <-
  lmer(
    NORMALIZED.TOTAL.COST ~ EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved + (1 + EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved |
                                                                                                  closest_year),
    data = df
  )

#save the weights
saveRDS(econ_time_0, "model_weights/econ_time_0.RDS")
saveRDS(econ_time_1, "model_weights/econ_time_1.RDS")
saveRDS(econ_time_2, "model_weights/econ_time_2.RDS")