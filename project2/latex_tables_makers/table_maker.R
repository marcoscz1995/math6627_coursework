source("latex_tables_makers/longtablestargazer.R")
require(stargazer)
library(xtable)
library(reporttools)

df <- read.csv("data/cleaned_data.csv")

#####This file makes latex tables usign the stargazer, xtable and reportools packages for the models outputs
####all tables are saved to report/tables

########
####import weights
#simple models
normal_popularity <- readRDS("model_weights/normal_popularity.RDS")
pois_views_tfidf <-
  readRDS("model_weights/pois_views_simple_tfidf.RDS")

#mixed models themes
pois_views_themes_0 <-
  readRDS("model_weights/pois_views_themes_0.RDS")
pois_views_themes_1 <-
  readRDS("model_weights/pois_views_themes_1.RDS")
pois_views_themes_2 <-
  readRDS("model_weights/pois_views_themes_2.RDS")
normal_popularity_themes_0 <-
  readRDS("model_weights/normal_popularity_themes_0.RDS")
normal_popularity_themes_1 <-
  readRDS("model_weights/normal_popularity_themes_1.RDS")
normal_popularity_themes_2 <-
  readRDS("model_weights/normal_popularity_themes_2.RDS")

#mixed models times
pois_views_times_0 <-
  readRDS("model_weights/pois_views_times_0.RDS")
pois_views_times_1 <-
  readRDS("model_weights/pois_views_times_1.RDS")
pois_views_times_2 <-
  readRDS("model_weights/pois_views_times_2.RDS")
normal_popularity_times_0 <-
  readRDS("model_weights/normal_popularity_times_0.RDS")
normal_popularity_times_1 <-
  readRDS("model_weights/normal_popularity_times_1.RDS")
normal_popularity_times_2 <-
  readRDS("model_weights/normal_popularity_times_2.RDS")

#we only want untransformed variables ie those not normalized
df_categorical <-
  df[, c("title_sentiment_tfidf", "tags_label_tfidf")]
df_numeric <-
  df[, c(
    "avg_views_per_day",
    "duration_no_norm",
    "num_speaker_no_norm",
    "film_age_no_norm",
    "title_length_no_norm",
    "popularity"
  )]


######
#sumarize numeric variables
###
sink("report/tables/numeric_variables_description.tex")
print(tableContinuous(df_numeric))

#sumarize categorical variables
sink("report/tables/categorical_variables_description.tex")
print(tableNominal(df_categorical)) #adds the table to the text file

#####
#anova tables
#these test the random slope
sink("report/tables/anova/nova_pois_themes.tex")
print(xtable(anova(
  pois_views_themes_1, pois_views_themes_2
)))
sink("report/tables/anova/nova_pois_times.tex")
print(xtable(anova(pois_views_times_1, pois_views_times_2)))
sink("report/tables/anova/nova_normal_popularity_themes.tex")
print(xtable(
  anova(normal_popularity_themes_1, normal_popularity_themes_2)
))
sink("report/tables/anova/nova_normal_popularity_times.tex")
print(xtable(anova(
  normal_popularity_times_1, normal_popularity_times_2
)))

#####
#AIC tables
#these test random intercept
sink("report/tables/aic/aic_pois_themes.tex")
print(xtable(AIC(
  pois_views_themes_0, pois_views_themes_1
)))
sink("report/tables/aic/aic_pois_times.tex")
print(xtable(AIC(pois_views_times_0, pois_views_times_1)))
sink("report/tables/aic/aic_normal_popularity_themes.tex")
print(xtable(AIC(
  normal_popularity_themes_0, normal_popularity_themes_1
)))
sink("report/tables/aic/aic_normal_popularity_times.tex")
print(xtable(AIC(
  normal_popularity_times_0, normal_popularity_times_1
)))

#######
#simple models
####
#Poison tfidf
longtable.stargazer(
  pois_views_tfidf,
  normal_popularity,
  column.labels = c("Poisson", "Linear"),
  model.numbers = FALSE,
  model.names = FALSE,
  title = "Poisson and Linear Regression",
  align = TRUE,
  covariate.labels = c(
    "Duration",
    "Num. Speaker",
    "Film Age",
    "Title Label: Life",
    "Title Label: New",
    "Title Label: World",
    "Title Length",
    "Tags Label: Business",
    "Tags Label: Culture",
    "Tags Label: Design",
    "Tags Label: Energy",
    "Tags Label: Global",
    "Tags Label: Health",
    "Tags Label: Music",
    "Tags Label: Science",
    "Tags Label: Social",
    "Intercept"
  ),
  type = "latex",
  omit.stat = c("LL", "ser", "f"),
  single.row = TRUE,
  filename = "report/tables/regressions/simple_models.tex"
)



#######
#mixed models results
longtable.stargazer(
  pois_views_themes_2,
  pois_views_times_2,
  normal_popularity_themes_2,
  normal_popularity_times_2,
  column.labels = c(
    "Poisson Themes",
    "Poisson Times",
    "Normal Themes",
    "Normal Times"
  ),
  model.numbers = FALSE,
  model.names = FALSE,
  title = "Poisson and Normal Mixed Effects Results",
  align = TRUE,
  type = "latex",
  single.row = TRUE,
  filename = "report/tables/regressions/mixed_results.tex",
  label = "mixed",
  covariate.labels = c(
    "Duration",
    "Title Length",
    "Title Label: Life",
    "Title Label: New",
    "Title Label: World",
    "Num. Speaker",
    "Film Age",
    "Intercept"
  )
)

#mixed models abridged gender and region results
longtable.stargazer(
  mod_sex,
  mod_region,
  title = "Logistic Mixed Effects Results",
  align = TRUE,
  type = "latex",
  column.labels = c("Gender", "Region"),
  dep.var.labels   = "Heart Disease",
  single.row = TRUE,
  filename = "report/tables/mixed_abridged_gender_region1.tex",
  star.char = c("+", "*", "**", "***"),
  star.cutoffs = c(.1, .05, .01, .001)
)

#mixed models abridged marriage and recency results
longtable.stargazer(
  mod_mariage,
  mod_recen,
  title = "Logistic Mixed Effects Results",
  align = TRUE,
  type = "latex",
  column.labels = c("Marriage", "Recency of Immigration"),
  dep.var.labels   = "Heart Disease",
  single.row = T,
  filename = "report/tables/mixed_abridged_marriage_recency.tex"
)
