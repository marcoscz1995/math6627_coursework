linear_regression <- function(dv, ivs, data, model_name, save_weights) {
  # run a linear model with text arguments for dv and ivs
  print(ivs)
  print(y)
  iv_string <- paste(ivs, collapse=" + ")
  regression_formula <- as.formula(paste(dv, iv_string, sep=" ~ "))
  if(save_weights == 'save_weights'){
    save_location = paste('model_weights/', model_name, '.RDS')
    saveRDS(lm(regression_formula, data), save_location) 
  }
  return(lm(regression_formula, data))
}

mixed_models <- function(dv, ivs, mixed_component, data, random_slope, model_name, save_weights) {
  # run a mixed model with text arguments for dv and ivs with mixed_comp as mixed component
  iv_string <- paste(ivs, collapse=" + ")
  if (random_slope == 'with_slope'){
    mixed_comp_string <-paste('+ (1 +',iv_string, '|', mixed_component, ')')
    full_model <- paste(iv_string, mixed_comp_string)
  }else{
    mixed_comp_string <-paste('+ (1 ', '|', mixed_component, ')')
    full_model <- paste(iv_string, mixed_comp_string)
  }
  mixed_regression_formula <- as.formula(paste(dv, full_model, sep=" ~ "))
  if(save_weights == 'save_weights'){
    save_location = paste('model_weights/', model_name, '.RDS')
    saveRDS(lmer(mixed_regression_formula, data), save_location) 
  }
  return(lmer(mixed_regression_formula, data))
}

