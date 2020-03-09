source("latex_table_makers/longtablestargazer.R")
require(stargazer)
library(xtable)
library(memisc)
library(reporttools)

df<-read.csv("data/cleaned_data.csv")

#####This file makes latex tables usign the stargazer, xtable and reportools packages for the models outputs
####all tables are saved to report/tables

####import weights

#simple models
normal_popularity<-readRDS("model_weights/normal_popularity.RDS")
pois_views_tfidf<-readRDS("model_weights/pois_views_simple_tfidf.RDS")
pois_views_bow<-readRDS("model_weights/pois_views_simple_bow.RDS")

#mixed models themes
pois_views_themes_0<-readRDS("model_weights/pois_views_themes_0.RDS")
pois_views_themes_1<-readRDS("model_weights/pois_views_themes_1.RDS")
pois_views_themes_2<-readRDS("model_weights/pois_views_themes_2.RDS")
normal_popularity_themes_0<-readRDS("model_weights/normal_popularity_themes_0.RDS")
normal_popularity_themes_1<-readRDS("model_weights/normal_popularity_themes_1.RDS")
normal_popularity_themes_2<-readRDS("model_weights/normal_popularity_themes_2.RDS")

#mixed models times
pois_views_times_0<-readRDS("model_weights/pois_views_times_0.RDS")
pois_views_times_1<-readRDS("model_weights/pois_views_times_1.RDS")
pois_views_times_2<-readRDS("model_weights/pois_views_times_2.RDS")
normal_popularity_times_0<-readRDS("model_weights/normal_popularity_times_0.RDS")
normal_popularity_times_1<-readRDS("model_weights/normal_popularity_times_1.RDS")
normal_popularity_times_2<-readRDS("model_weights/normal_popularity_times_2.RDS")

#sumarize numeric variables
sink("report/tables/continous_variables_description.tex")
print(tableContinuous(df[,sapply(df, is.numeric)]))
sink()  # returns output to the console

#sumarize categorical variables
sink("report/tables/categorical_variables_description.tex")
print(tableNominal(df[,!sapply(df, is.numeric)])) #adds the table to the text file


#anova tables
sink("report/tables/anova_sex.tex")
out<-anova(ms1,mod_sex)
sink("report/tables/anova_region.tex")
print(xtable(anova(mr1,mod_region)))
sink("report/tables/anova_marriage.tex")
print(xtable(anova(mm1,mod_mariage)))
sink("report/tables/anova_recen.tex")
print(xtable(anova(mrec1,mod_recen)))

#AIC tables
sink("report/tables/aic_sex.tex")
print(xtable(AIC(ms,ms1)))
sink("report/tables/aic_region.tex")
print(xtable(AIC(mr,mr1)))
sink("report/tables/aic_marriage.tex")
print(xtable(AIC(mm,mm1)))
sink("report/tables/aic_recen.tex")
print(xtable(AIC(mrec,mrec1)))

#Logistic Regression Table results
longtable.stargazer(
  mod1,
  title = "Logistic Regression Results",
  align = TRUE,
  type = "latex",
  dep.var.labels   = "Heart Disease",
  omit.stat = c("LL", "ser", "f"),
  single.row = TRUE,
  filename = "report/tables/logistic_regression_results.tex"
)

#Logistic Regression Table results. with imputed income
longtable.stargazer(
  mod_predicted_income,
  title = "Logistic Regression Results With Imputed Income Data",
  align = TRUE,
  type = "latex",
  dep.var.labels   = "Heart Disease",
  omit.stat = c("LL", "ser", "f"),
  single.row = TRUE,
  filename = "report/tables/logistic_regression_results_with_imputed_data.tex"
)



#mixed models results
longtable.stargazer(
  mod_sex,
  mod_region,
  mod_mariage,
  mod_recen,
  title = "Logistic Mixed Effects Results",
  align = TRUE,
  type = "latex",
  column.labels = c("Gender", "Region", "Marriage", "Recency of Immigration"),
  dep.var.labels   = "Heart Disease",
  single.row = TRUE,
  filename = "report/tables/logistic_mixed_regression_results.tex",
  label= "mixed"
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
  single.row =T,
  filename = "report/tables/mixed_abridged_marriage_recency.tex"
)
    