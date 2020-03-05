#to import glmnet:
#sudo apt-get install -y r-cran-glmnet
library("glmnet") #
library(lme4)
#load("cleaned_data.RData")
df<-read.csv("data/cleaned_data.csv")
attach(df)
set.seed(123) 
#note that if you are in linux you will have to run data_cleaning.R first to make the
#the cleaned_data.RData file work.

####question 1
#do a simple logistic regression. ignore time
#kind of arthritis is dependent on arthritis. ie put an interaction between arthritis and kind of arthirisitis (Look up way to code this in glm)
# leaving only the predictors


mod1<-glm(hrt_disease~(age+sex+ race+ educ+ income+ bmi+ physical+ has_doctor+ smoker+ drinker+ 
          blood_pres+ diabetes)*OA, family = "binomial", data=df)
summary(mod1)#recall this is a binomial model so need to interpret this with logs
saveRDS(mod1, "model_weights/mod1.RDS")



#lasso regressionL: the coefficients of some less contributive variables are forced to zero.
cv.lasso <- cv.glmnet(x=c(OA, sex), y, alpha = 1, family = "binomial")
mod3<-glmnet(x, y, family = "binomial", alpha = 1, lambda = cv.lasso$lambda.min)
coef(mod3)
#none of the variables are zero.

####question 2
#Does the relationship between osteoarthritis and heart disease vary 
#(a) between participants living in the northern parts of Canada versus those living in the southern parts, 
#(b) between men and women, 
#(c) by marital status, 
#or (d) by recency of immigration?   

#(a)
#slope and intercept vary by region
tester<-df[sample(nrow(df), 1000), ]
#system.time measures how long it takes to execute the model
system.time(mod_region<-glmer(hrt_disease~OA+ age+sex+ race+ educ+ income+ bmi+ physical+ has_doctor+ smoker+ drinker+ 
                   blood_pres+ diabetes+ 
                   (1+OA|region), data=tester, family=binomial))
mr<-glm(hrt_disease~OA+ age+sex+ race+ educ+ income+ bmi+ physical+ has_doctor+ smoker+ drinker+ 
                    blood_pres+ diabetes, data=tester, family=binomial)
mr1<-glmer(hrt_disease~OA+ age+sex+ race+ educ+ income+ bmi+ physical+ has_doctor+ smoker+ drinker+ 
                    blood_pres+ diabetes+ 
                    (1|region), data=tester, family=binomial)
summary(mod_region)
saveRDS(mod_region, "model_weights/mod_region.RDS")
saveRDS(mr, "model_weights/mr.RDS")
saveRDS(mr1, "model_weights/mr1.RDS")

#b)
ms<-glm(hrt_disease~OA+ age+sex+ race+ educ+ income+ bmi+ physical+ has_doctor+ smoker+ drinker+ 
             blood_pres+ diabetes, data=tester, family=binomial)
ms1<-glmer(hrt_disease~OA+ age+sex+ race+ educ+ income+ bmi+ physical+ has_doctor+ smoker+ drinker+ 
                     blood_pres+ diabetes+ 
                     (1|sex), data=tester, family=binomial)
system.time(mod_sex<-glmer(hrt_disease~OA+ age+sex+ race+ educ+ income+ bmi+ physical+ has_doctor+ smoker+ drinker+ 
                                blood_pres+ diabetes+ 
                                (1+OA|sex), data=tester, family=binomial))

saveRDS(mod_sex, "model_weights/mod_sex.RDS")
saveRDS(ms, "model_weights/ms.RDS")
saveRDS(ms1, "model_weights/ms1.RDS")

#c)
system.time(mod_mariage<-glmer(hrt_disease~OA+ age+sex+ race+ educ+ income+ bmi+ physical+ has_doctor+ smoker+ drinker+ 
                                blood_pres+ diabetes+ 
                                (1+OA|marriage), data=tester, family=binomial))
mm<-glm(hrt_disease~OA+ age+sex+ race+ educ+ income+ bmi+ physical+ has_doctor+ smoker+ drinker+ 
                     blood_pres+ diabetes, data=tester, family=binomial)
mm1<-glmer(hrt_disease~OA+ age+sex+ race+ educ+ income+ bmi+ physical+ has_doctor+ smoker+ drinker+ 
                     blood_pres+ diabetes+ 
                     (1|marriage), data=tester, family=binomial)
summary(mod_mariage)
saveRDS(mod_mariage, "model_weights/mod_mariage.RDS")
saveRDS(mm, "model_weights/mm.RDS")
saveRDS(mm1, "model_weights/mm1.RDS")

  
#d)
recdf<-df[df$immigrant=="YES",] #only want immigrants
rectester<-recdf[sample(nrow(recdf), 1000), ]
system.time(mod_recen<-glmer(hrt_disease~OA+ age+sex+ race+ educ+ income+ bmi+ physical+ has_doctor+ smoker+ drinker+ 
                                 blood_pres+ diabetes+ 
                                 (1+OA|time_since_immig), data=rectester, family=binomial))
mrec<-glm(hrt_disease~OA+ age+sex+ race+ educ+ income+ bmi+ physical+ has_doctor+ smoker+ drinker+ 
                   blood_pres+ diabetes, data=rectester, family=binomial)
mrec1<-glmer(hrt_disease~OA+ age+sex+ race+ educ+ income+ bmi+ physical+ has_doctor+ smoker+ drinker+ 
                   blood_pres+ diabetes+ 
                   (1|time_since_immig), data=rectester, family=binomial)
saveRDS(mod_recen, "model_weights/mod_recen.RDS")
saveRDS(mrec, "model_weights/mrec.RDS")
saveRDS(mrec1, "model_weights/mrec1.RDS")
summary(mod_recen)


