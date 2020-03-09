df <- read.csv("data/cleaned_data.csv")
attach(df)

####
#What characteristics of TED Talks predict their popularity?
####

####simple poisson models

#response: avg views per day
#use kmeans with bow
pois_views_bow <-
  glm(
    avg_views_per_day ~ duration + num_speaker + film_age + BOW_Clus_with_Label,
    family = poisson(link = log)
  )
summary(pois_views_bow)
#use kmeans with tfidf
pois_views_tfidf <-
  glm(
    avg_views_per_day ~ duration + num_speaker + film_age + tfidf_Clus_with_Label,
    family = poisson(link = log)
  )
summary(pois_views_tfidf)

#will remove the clustering predictors as they add nothing by interpretability
#althought bow had a positive coefficient in growth....

#Linear model
#response: composite popularity score (includes languages, standardized comments,
# standardized views,aggregate ratings, number of related talks)
normal_popularity <-
  lm(
    popularity ~ duration + num_speaker + film_age +BOW_Clus_with_Label +main_speaker
  )
summary(normal_popularity)








