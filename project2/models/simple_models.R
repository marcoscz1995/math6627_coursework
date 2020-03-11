df <- read.csv("data/cleaned_data.csv")
attach(df)

####
#Q1 & 2) What characteristics of TED Talks predict their popularity?
####

####
#In this file I run a poisson glm and linear model. 
####
#The Poisson model predcts the average views per day, which is the most intuitive 
#score for popularity that accounts for length of time a video has been posted.
####
#The linear model predicts the popularity of a video. The response popularity is a composite 
#of languages, languages, standardized comments,standardized views,aggregate ratings, number of related talks
##

####simple poisson models

#response: avg views per day
#using kmeans with tfidf to determine the sentiment of the video title
pois_views_tfidf <-
  glm(
        avg_views_per_day ~ duration + num_speaker + film_age+title_sentiment_tfidf +title_length+ tags_label_tfidf+video_age_label,
    family = poisson(link = log)
  )
summary(pois_views_tfidf)

#Linear model
#response: composite popularity score (includes languages, standardized comments,
# standardized views,aggregate ratings, number of related talks)
normal_popularity <-
  lm(popularity ~ duration + num_speaker+title_sentiment_tfidf + title_length+film_age + tags_label_tfidf+video_age_label)
summary(normal_popularity)

saveRDS(normal_popularity, "model_weights/normal_popularity.RDS")
saveRDS(pois_views_tfidf, "model_weights/pois_views_simple_tfidf.RDS")
