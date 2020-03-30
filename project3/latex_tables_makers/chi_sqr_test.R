library("bbmle")
#initialize the df
df_anova<-setNames(data.frame(matrix(ncol = 4, nrow = 0)), c("Test", "chi^2", "df", "p-value"))
#make the df to be added to df_anova
chi_sqr_test<-function(mod_simple, mod_full, test_name,df_anova){
  stat<- deviance(mod_simple) -deviance(mod_full) #deviance stat
  print(stat)
  deg_freedom <- length(mod_full$coefficients) - length(mod_simple$coefficients) #degrees of freedom
  print(deg_freedom)
  pval<-pchisq(stat, df = deg_freedom, lower.tail = FALSE) #p-val
  print(pval)
  df_row<-cbind(test_name,stat,deg_freedom, pval)
  df_anova<-rbind(df_anova, df_row)
}

df_anova<-chi_sqr_test(pois_views_themes_1,pois_views_themes_2,'testing random', df_anova)
AIC
pois_views_themes_1$fit
deviance(pois_views_themes_1)

f1<-fixef(pois_views_themes_1)
f2<-ranef(pois_views_themes_1)
f2$cond
  getXReTrms(pois_views_themes_1)
f1$cond
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
