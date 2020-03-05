source("latex_table_makers/longtablestargazer.R")
require(stargazer)
library(xtable)
library(memisc)
library(reporttools)

df<-read.csv("data/cleaned_data.csv")

mod1 <- readRDS("model_weights/mod1.RDS")
mod_predicted_income<-readRDS("model_weights/mod_predicted_income.RDS")
mod_region <- readRDS("model_weights/mod_region.RDS")
mod_sex <- readRDS("model_weights/mod_sex.RDS")
mod_mariage <- readRDS("model_weights/mod_mariage.RDS")
mod_recen <- readRDS("model_weights/mod_recen.RDS")

ms <- readRDS("model_weights/ms.RDS")
mrec <- readRDS("model_weights/mrec.RDS")
mm <- readRDS("model_weights/mm.RDS")
mr <- readRDS("model_weights/mr.RDS")

ms1 <- readRDS("model_weights/ms1.RDS")
mrec1 <- readRDS("model_weights/mrec1.RDS")
mm1 <- readRDS("model_weights/mm1.RDS")
mr1 <- readRDS("model_weights/mr1.RDS")

#sumarize numeric variables
sink("latex_tables/continous_variables_description.tex")
print(tableContinuous(df[,sapply(df, is.numeric)]))
sink()  # returns output to the console

#sumarize categorical variables
sink("latex_tables/categorical_variables_description.tex")
print(tableNominal(df[,!sapply(df, is.numeric)])) #adds the table to the text file


#anova tables
sink("latex_tables/anova_sex.tex")
out<-anova(ms1,mod_sex)
sink("latex_tables/anova_region.tex")
print(xtable(anova(mr1,mod_region)))
sink("latex_tables/anova_marriage.tex")
print(xtable(anova(mm1,mod_mariage)))
sink("latex_tables/anova_recen.tex")
print(xtable(anova(mrec1,mod_recen)))

#AIC tables
sink("latex_tables/aic_sex.tex")
print(xtable(AIC(ms,ms1)))
sink("latex_tables/aic_region.tex")
print(xtable(AIC(mr,mr1)))
sink("latex_tables/aic_marriage.tex")
print(xtable(AIC(mm,mm1)))
sink("latex_tables/aic_recen.tex")
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
  filename = "latex_tables/logistic_regression_results.tex"
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
  filename = "latex_tables/logistic_regression_results_with_imputed_data.tex"
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
  filename = "latex_tables/logistic_mixed_regression_results.tex",
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
  filename = "latex_tables/mixed_abridged_gender_region1.tex",
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
  filename = "latex_tables/mixed_abridged_marriage_recency.tex"
)
    