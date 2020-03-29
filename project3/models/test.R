#library(lme4)


mixed_models1 <- function(dv, ivs, mixed_component, data, random_slope, model_name, save_weights) {
  # run a mixed model with text arguments for dv and ivs with mixed_comp as mixed component
  iv_string <- paste(ivs, collapse=" + ")
  if (random_slope == 1){
    mixed_comp_string <-paste('+ (1 +',iv_string, '|', mixed_component, ')')
    full_model <- paste(iv_string, mixed_comp_string)
  }else{
    mixed_comp_string <-paste('+ (1 ', '|', mixed_component, ')')
    full_model <- paste(iv_string, mixed_comp_string)
  }
  mixed_regression_formula <- as.formula(paste(dv, full_model, sep=" ~ "))
  model_name<-lmer(mixed_regression_formula, data)
  summary(mod)
  if(save_weights == 1){
    save_location = paste('model_weights/', model_name, '.RDS')
    saveRDS(model_name, save_location) 
  }
}

Data <- data.frame(matrix(rnorm(102 * 200), ncol=102))
names(Data) <- c(paste("x", 1:5, sep=""), 
                 "asdfasdf", "y", paste("x", 6:10, sep=""))
PredictorVariables <- paste("x", 1:10, sep="")

mixed_models1("y", PredictorVariables[1:5],  PredictorVariables[6], Data, 0, 'test_mod', 0)

