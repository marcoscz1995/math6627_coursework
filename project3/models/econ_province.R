#library(lme4)
df <- read.csv("data/final_cleaned_with_composite_scores.csv")
attach(df)

####
#Q1) How has the econ impact of natural disasters changed over province in Canada?
####

######
#This file runs normal mixed models for econom  ic impacts by province
######
#The linear model predicts the economic impact of natural disasters in canada. The response 'econ_cost_comp_score' is a composite
#
##


######Normal models on popularity score 
#no randomness
econ_province_0 <-
  lm(
    NORMALIZED.TOTAL.COST ~ EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved,
    data = df
  )
#only random intercept
econ_province_1 <-
  lmer(
    NORMALIZED.TOTAL.COST ~ EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved + (1 |
                                                                                                  Province.Territory),
    data = df
  )
summary(econ_province_1)
#random intercept and slope
econ_province_2 <-
  lmer(
    NORMALIZED.TOTAL.COST ~ EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved + (1 + EVENT.TYPE + event_duration + MAGNITUDE + num_provinces_involved |
                                                                                                  Province.Territory),
    data = df
  )

#save the weights
saveRDS(econ_province_0, "model_weights/econ_province_0.RDS")
saveRDS(econ_province_1, "model_weights/econ_province_1.RDS")
saveRDS(econ_province_2, "model_weights/econ_province_2.RDS")
