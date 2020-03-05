library(dplyr)
df<-read.csv('data/cleaned_data_predict.csv')

#set income incompletes to NA
df$income<-ifelse(df$income =="NOT STATED" , NA, df$income)
# Construct linear model based on non-NA pairs
df2 <- df %>% filter(!is.na(df$income))

fit <- lm(income ~ age+sex+region, data = df2)

df3 <- df %>% 
  mutate(pred = predict(fit, .)) %>%
  # Replace NA with pred in income
  mutate(income = ifelse(is.na(income), pred, income))

#run logistic regression

mod_predicted_income<-glm(hrt_disease~(age+sex+ race+ educ+ income+ bmi+ physical+ has_doctor+ smoker+ drinker+ 
                         blood_pres+ diabetes)*OA, family = "binomial", data=df3)
summary(mod_predicted_income)#recall this is a binomial model so need to interpret this with logs
saveRDS(mod_predicted_income, "model_weights/mod_predicted_income.RDS")
