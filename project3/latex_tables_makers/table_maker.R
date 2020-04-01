source("latex_tables_makers/longtablestargazer.R")
require(stargazer)
library(xtable)
library(reporttools)
library(readr)

df <- read.csv("data/final_cleaned_with_composite_scores.csv")

#####This file makes latex tables usign the stargazer, xtable and reportools packages for the models outputs
####all tables are saved to repo  rt/tables

########
####import weights

#linear models
econ_linear <-
  read_rds("model_weights/econ_linear.RDS")
human_linear <-
  read_rds("model_weights/human_linear.RDS")
summary(econ_linear)
#mixed models Province
econ_province_0 <-
  readRDS("model_weights/econ_province_0.RDS")
econ_province_1 <-
  readRDS("model_weights/econ_province_1.RDS")
econ_province_2 <-
  readRDS("model_weights/econ_province_2.RDS")
human_province_0 <-
  readRDS("model_weights/human_province_0.RDS")
human_province_1 <-
  readRDS("model_weights/human_province_1.RDS")
human_province_2 <-
  read_rds("model_weights/human_province_2.RDS")

#mixed models Times
econ_time_0 <-
  read_rds("model_weights/econ_time_0.RDS")
econ_time_1 <-
  read_rds("model_weights/econ_time_1.RDS")
econ_time_2 <-
  read_rds("model_weights/econ_time_2.RDS")
human_time_0 <-
  read_rds("model_weights/human_time_0.RDS")
human_time_1 <-
  read_rds("model_weights/human_time_1.RDS")
human_time_2 <-
  read_rds("model_weights/human_time_2.RDS")

#we only want untransformed variables ie those not Humanized
df_numeric <-
  df[, c(
    "percentage_fatalities",
    "percentage_evacuated",
    "human_cost_comp_score",
    "event_duration",
    "MAGNITUDE",
    "percentage_injured.infected",
    "num_provinces_involved",
    'govt_spending_percent_gdp'
  )]
df_categorical <-
  df[, c("EVENT.TYPE",
         "Province.Territory",
         "closest_year")]


######
#sumarize numeric variables
###
sink("report/tables/descriptive_stats/numeric_variables_description.tex")
print(tableContinuous(df_numeric))

#sumarize categorical variables
sink("report/tables/descriptive_stats/categorical_variables_description.tex")
print(tableNominal(df_categorical))

#####
#anova tables
#these test the random slope
  sink("report/tables/anova/anova_econ_province.tex")
  print(xtable(anova(econ_province_1, econ_province_2)))
  sink("report/tables/anova/anova_econ_time.tex")
  print(xtable(anova(econ_time_1, econ_time_2)))
  sink("report/tables/anova/anova_human_province.tex")
  print(xtable(anova(human_province_1, human_province_2)))
  sink("report/tables/anova/anova_human_time.tex")
  print(xtable(anova(human_time_1, human_time_2)))

#####
#AIC tables
#these test random intercept
sink("report/tables/aic/aic_econ_province.tex")
print(xtable(AIC(econ_province_0, econ_province_1)))
sink("report/tables/aic/aic_econ_time.tex")
print(xtable(AIC(econ_time_0, econ_time_1)))
sink("report/tables/aic/aic_human_province.tex")
print(xtable(AIC(human_province_0, human_province_1)))
sink("report/tables/aic/aic_human_time.tex")
print(xtable(AIC(human_time_0, human_time_1)))

#######
#Linear Regression Results
####
longtable.stargazer(
  econ_linear,
  human_linear,
  column.labels = c("Economic Cost(Millions)", "Human Cost"),
  label = "results_table",
  model.numbers = FALSE,
  model.names = FALSE,
  title = "Economic and Human Cost Linear Regression",
  align = TRUE,
  covariate.labels = c(
    event_type[2:length(event_type), ],
    "Event Duration (days)",
    "Earthquake Magnitude",
    "Num.Provinces Involved",
    prov[2:length(prov), ],
    "Year",
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
  econ_province_2,
  econ_time_2,
  human_province_2,
  human_time_2,
  column.labels = c(
    "Economic: Provinces",
    "Economic: Time ",
    "Human: Provinces",
    "Human: Time"
  ),
  model.numbers = FALSE,
  model.names = FALSE,
  title = "Economic and Human Cost Mixed Effects Results",
  align = TRUE,
  type = "latex",
  single.row = TRUE,
  filename = "report/tables/regressions/mixed_results.tex",
  label = "mixed",
  covariate.labels = c(
    event_type[2:length(event_type), ],
    "Event Duration (days)",
    "Earthquake Magnitude",
    "Num.Provinces Involved",
    "Intercept"
  )
)

#mixed models abridged for Economic
longtable.stargazer(
  econ_province_2,
  econ_time_2,
  column.labels = c("Economic: Provinces",
                    "Economic: Time"),
  model.numbers = FALSE,
  model.names = FALSE,
  title = "Economic Costs Mixed Effects Results",
  align = TRUE,
  type = "latex",
  single.row = TRUE,
  filename = "slides/tables/regressions/econ_mixed_results.tex",
  label = "mixed",
  covariate.labels = c(
    event_type[2:length(event_type), ],
    "Event Duration (days)",
    "Earthquake Magnitude",
    "Num.Provinces Involved",
    "Intercept"
  )
)
#mixed models abridged for Human
longtable.stargazer(
  human_province_2,
  human_time_2,
  column.labels = c("Human: Provinces",
                    "Human: Time"),
  model.numbers = FALSE,
  model.names = FALSE,
  title = "Human Mixed Effects Results",
  align = TRUE,
  type = "latex",
  single.row = TRUE,
  filename = "slides/tables/regressions/human_mixed_results.tex",
  label = "mixed",
  covariate.labels = c(
    event_type[2:length(event_type), ],
    "Event Duration (days)",
    "Earthquake Magnitude",
    "Num.Provinces Involved",
    "Intercept"
  )
)
  