#library(lme4)
df <- read.csv("data/final_cleaned_with_composite_scores.csv")

####
#This is a simple linear model for both human and econ costs that use provinces and year as predictors
####
##


#linear model
econ_linear <-
  lm(
    NORMALIZED.TOTAL.COST ~  EVENT.TYPE + event_duration+MAGNITUDE+num_provinces_involved+Province.Territory+closest_year,
    data = df
  )
human_linear <-  lm(
    human_cost_comp_score ~  EVENT.TYPE + event_duration+MAGNITUDE+num_provinces_involved+Province.Territory+closest_year,
  data = df
)

saveRDS(econ_linear, "model_weights/econ_linear.RDS")
saveRDS(human_linear, "model_weights/human_linear.RDS")

summary(econ_linear)
summary(human_linear)

is.fact <- sapply(df, is.factor)
factors.df <- df[, is.fact]
test<-lapply(factors.df, levels)

event_type <- test[["EVENT.TYPE"]]
event_type <- sapply("Event Type: ", paste, event_type, sep = "" )
prov <- test[["Province.Territory"]]
prov<- sapply("Province: ", paste, prov, sep = "" )

prov[2:length(prov),]

