library(lme4)
df <- read.csv("data/cleaned_data.csv")
attach(df)

####
#Q4) Do the characteristics that predict popularity change by theme of the talk?
####

######
#This file runs poisson and normal mixed models with for ted talk themes
######
#The Poisson model predcts the average views per day, which is the most intuitive 
#score for popularity that accounts for length of time a video has been posted.
####
#The linear model predicts the popularity of a video. The response popularity is a composite 
#of languages, languages, standardized comments,standardized views,aggregate ratings, number of related talks
##




#######
###Mixed mdoels

#####variation by themes
#Poisson models with kmeans bow on avergae views per day
#no randomness
pois_views_themes_0 <-
  glm(
    avg_views_per_day ~ duration + num_speaker + film_age+ title_length+title_sentiment_bow,
    data = df,
    family = poisson(link = log)
  )
summary(pois_views_themes_0)
#only random intercept
pois_views_themes_1 <-
  glmer(
    avg_views_per_day ~ duration + num_speaker + title_length+title_sentiment_bow+ film_age + (1 |
                                                               BOW_Clus_with_Label),
    data = df,
    family = poisson(link = log)
  )
summary(pois_views_themes_1)
#random intercept and slope
pois_views_themes_2 <-
  glmer(
    avg_views_per_day ~ duration + title_length+title_sentiment_bow+ num_speaker + film_age + (1 + duration + num_speaker + film_age |
                                                               BOW_Clus_with_Label),
    data = df,
    family = poisson(link = log)
  )
summary(pois_views_themes_2)

#save the weights
saveRDS(pois_views_themes_0, "model_weights/pois_views_themes_0.RDS")
saveRDS(pois_views_themes_1, "model_weights/pois_views_themes_1.RDS")
saveRDS(pois_views_themes_2, "model_weights/pois_views_themes_2.RDS")


######Normal models on popularity score
#no randomness
normal_popularity_themes_0 <-
  lm(
    popularity ~ duration + num_speaker + film_age+ title_length+title_sentiment_bow,
    data = df
  )
summary(normal_popularity_themes_0)
#only random intercept
normal_popularity_themes_1 <-
  lmer(
    popularity ~ duration + num_speaker + title_length+title_sentiment_bow+ film_age + (1 |
                                                               BOW_Clus_with_Label),
    data = df
  )
summary(normal_popularity_themes_1)
  #random intercept and slope
normal_popularity_themes_2 <-
  lmer(
    popularity ~ duration + num_speaker+ title_length+title_sentiment_bow + film_age + (1 + duration + num_speaker + film_age |
                                                               BOW_Clus_with_Label),
    data = df
  )
summary(normal_popularity_themes_2)

#save the weights
saveRDS(normal_popularity_themes_0, "model_weights/normal_popularity_themes_0.RDS")
saveRDS(normal_popularity_themes_1, "model_weights/normal_popularity_themes_1.RDS")
saveRDS(normal_popularity_themes_2, "model_weights/normal_popularity_themes_2.RDS")
