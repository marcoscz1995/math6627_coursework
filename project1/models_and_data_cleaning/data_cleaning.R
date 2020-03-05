library(dplyr) 
library(plyr)
#import the data
load("data/cchs11.RData")
load("data/cchs21.RData")
load("data/cchs31.RData")
dat = read.csv("data/tester.csv", header = TRUE) 
dat<-dat[-1,]

#create new data frames with only relevant variables
df1<-cchs11[,c("ADMA_RNO", as.character(dat$Variable.names.in.3.cycles))]
df2<-cchs21[,c("ADMC_RNO", as.character(dat$Variable.names.in.3.cycles.1))]
df3<-cchs31[,c("ADME_RNO", as.character(dat$Variable.names.in.3.cycles.2))]

#rename variables
colnames(df1)<-c("id",as.character(dat$nan))
colnames(df2)<-c("id",as.character(dat$nan))
colnames(df3)<-c("id",as.character(dat$nan))

#add the period variables
df1$period<-c(1)
df2$period<-c(2)
df3$period<-c(3)


#concatenate the data
df<-rbind(df1,df2,df3)
#we do not need id
df<-df[-c(1)]

#add the region variable
df$region<-ifelse(df$Province == "YUKON/NWT/NUNAVT" | df$Province == "YUKON/NWT/NUNA.", "north", "south")


#remove ages not from 20-64
ages<-levels(df$Age)
ages<-ages[3:11]
df<-df[is.element(df$Age, ages),]

#keep only osteoarthiritis and not aplicable
kind<-levels(df$`Kind of arthritis`)
kind<-kind[c(2,4)]
df<-df[is.element(df$`Kind of arthritis`, kind),]

#we can drop kind of arthritis and copd
df<-df[-c(3,19,20,21, 23)]

#keep only yes and no for has heart disease
yesno<-levels(df$`Has heart disease`)
yesno<-yesno[c(1,2)]
df<-df[is.element(df$`Has heart disease`, yesno),]

#rename the colums
colnames(df)<-c("hrt_disease", "OA", "age", "sex", "marriage", "race", "immigrant","time_since_immig", "educ", "income", "bmi", "physical", "has_doctor", "smoker", "drinker", 
                "blood_pres", "diabetes", "province","period", "region")



attach(df)
#change cases where "NOT APPLICABLE MAKES SENSE"
df$time_since_immig<-recode(df$time_since_immig, "NOT APPLICABLE"="NOT IMMIGRANT")
#df<-df %>% mutate(time_since_immig = replace(time_since_immig, which(time_since_immig == "NOT APPLICABLE"), "NOT IMMIGRANT" )) #for some reason this converts them to NA
df<-df %>% mutate(time_since_immig = replace(time_since_immig, which(time_since_immig == "10 OR MORE YEARS"), "10 YEARS OR MORE" ))


#drop observations that are incomplete except for immigrant and time since immigrant
#this results with 200478 values which means majority of invalid responses come from the immigrant and time_since_immig variables which suggests
#individuals tend to give invalid responses in this field most likely due to fear of deportation consequences.
  keywords <-  c("NOT APPLICABLE" ,"NOT STATED" , "DON'T KNOW", "REFUSAL" ,"drop" )

df_predict<-df[!Reduce(`|`,lapply(df[,-c(7,8,10)], `%in%`, keywords)),] #this applyes to everything except immigrant and time since immigrant
df<-df[!Reduce(`|`,lapply(df[,-c(7,8)], `%in%`, keywords)),] #this applyes to everything except immigrant and time since immigrant



#transform variables

df$hrt_disease<- ifelse(df$hrt_disease == "YES", 1, 0)

df<-df %>% mutate(province = replace(province, which(province == "QU\xc9BEC"), "QUEBEC" ))

#bing BMI
b <- c(-Inf, 18.5, 25, Inf)
names <- c("underweight", "healthy", "overweight")
df$bmi<-cut((as.numeric(df$bmi)), breaks = b, labels = names)

#transform variables
attach(df_predict)

df_predict$hrt_disease<- ifelse(df_predict$hrt_disease == "YES", 1, 0)

df_predict<-df_predict %>% mutate(province = replace(province, which(province == "QU\xc9BEC"), "QUEBEC" ))

#bing BMI
b <- c(-Inf, 18.5, 25, Inf)
names <- c("underweight", "healthy", "overweight")
df_predict$bmi<-cut((as.numeric(df_predict$bmi)), breaks = b, labels = names)



#save the data.
save(df,file='data/cleaned_data.RData')
save(df_predict,file='data/cleaned_data_predict.RData')
write.csv(df,'data/cleaned_data.csv', row.names=FALSE)
write.csv(df_predict,'data/cleaned_data_predict.csv', row.names=FALSE)

    
