library(glmmTMB)
df <- read.csv("data/cleaned_data.csv")
attach(df)

####
#Q3) Do the characteristics that predict popularity change over time?
####

######
#This file runs poisson and normal mixed models with for time
######
#The Poisson model predcts the average views per day, which is the most intuitive 
#score for popularity that accounts for length of time a video has been posted.
####
#The linear model predicts the popularity of a video. The response popularity is a composite 
#of languages, languages, standardized comments,standardized views,aggregate ratings, number of related talks

#Poisson models
pois_views_times_0 <-
  glm(
    avg_views_per_day ~ duration + num_speaker+ title_length+title_sentiment_tfidf + film_age,
    data = df,
    family = poisson(link = log)
  )
summary(pois_views_times_0)
#only random intercept
pois_views_times_1 <-
  glmmTMB(
    avg_views_per_day ~ duration + title_length+title_sentiment_tfidf+ num_speaker + film_age + (1 |
                                                               tags_label_tfidf),
    data = df,
    family = poisson(link = log)
  )
summary(pois_views_times_1)
#random intercept and slope
pois_views_times_2 <-
  glmmTMB(
    avg_views_per_day ~ duration+ title_length+title_sentiment_tfidf + num_speaker + film_age + (1 + duration + num_speaker + film_age+ title_length+title_sentiment_tfidf |
                                                               tags_label_tfidf),
    data = df,
    family = poisson(link = log)
  )
summary(pois_views_times_2)

#save the weights
saveRDS(pois_views_times_0, "model_weights/pois_views_times_0.RDS")
saveRDS(pois_views_times_1, "model_weights/pois_views_times_1.RDS")
saveRDS(pois_views_times_2, "model_weights/pois_views_times_2.RDS")


######Normal models on popularity score
#no randomness
normal_popularity_times_0 <-
  lm(
    popularity ~ duration + title_length+title_sentiment_tfidf+ num_speaker + film_age,
    data = df
  )
summary(normal_popularity_times_0)
#only random intercept
normal_popularity_times_1 <-
  glmmTMB(
    popularity ~ duration + title_length+title_sentiment_tfidf+ num_speaker + film_age + (1 |
                                                        tags_label_tfidf),
    data = df
  )
summary(normal_popularity_times_1)
#random intercept and slope
normal_popularity_times_2 <-
  glmmTMB(
    popularity ~ duration + title_length+title_sentiment_tfidf+ num_speaker + film_age + (1 + duration + num_speaker + film_age |
                                                        tags_label_tfidf),
    data = df
  )
summary(normal_popularity_times_2)

#save the weights
saveRDS(normal_popularity_times_0, "model_weights/normal_popularity_times_0.RDS")
saveRDS(normal_popularity_times_1, "model_weights/normal_popularity_times_1.RDS")
saveRDS(normal_popularity_times_2, "model_weights/normal_popularity_times_2.RDS")