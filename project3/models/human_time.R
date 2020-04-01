#library(lme4)
source("models/model_makers.R")
df <- read.csv("data/final_cleaned_with_composite_scores.csv")

####
#Q1) How has the human impact of natural disasters changed over time in Canada?
####

######  
#This file runs normal mixed models for human impacts by time
######
#The linear model predicts the humanomic impact of natural disasters in canada. The response 'human_cost_comp_score' is a composite
# measure
##

#no randomness
human_time_0 <-
  lm(
    human_cost_comp_score ~ EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved,
    data = df
  )
#only random intercept
human_time_1 <-
  lmer(
    human_cost_comp_score ~ EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved + (1 |
                                                                                                  closest_year),
    data = df
  )
summary(human_time_1)
#random intercept and slope
human_time_2 <-
  lmer(
    human_cost_comp_score ~ EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved + (1 + EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved |
                                                                                                  closest_year),
    data = df
  )

#save the weights
saveRDS(human_time_0, "model_weights/human_time_0.RDS")
saveRDS(human_time_1, "model_weights/human_time_1.RDS")
saveRDS(human_time_2, "model_weights/human_time_2.RDS")
