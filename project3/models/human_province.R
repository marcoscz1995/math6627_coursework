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

#no randomness
human_province_0 <-
  lm(
    human_cost_comp_score ~ EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved,
    data = df
  )
#only random intercept
human_province_1 <-
  lmer(
    human_cost_comp_score ~ EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved + (1 |
                                                                                                  Province.Territory),
    data = df
  )
summary(human_province_1)
#random intercept and slope
human_province_2 <-
  lmer(
    human_cost_comp_score ~ EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved + (1 + EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved |
                                                                                                  Province.Territory),
    data = df
  )

#save the weights
saveRDS(human_province_0, "model_weights/human_province_0.RDS")
saveRDS(human_province_1, "model_weights/human_province_1.RDS")
saveRDS(human_province_2, "model_weights/human_province_2.RDS")
