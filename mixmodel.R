#' # LINEAR MIXED MODELS FOR DIFFERENCES FROM BASELINE AFTER PRONE POSITIONING

#' ### Libraries
#' 
list.of.packages <- c(
  "rmarkdown", "tidyverse", "Rcpp", "knitr", "readxl", "xlsx"
)
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos='https://cran.rstudio.com/')
library(tidyverse)
library(lme4)



#' ### Scripts
source("./rscripts/kabler_tabler.R", echo=FALSE)
source("./data_import.R", echo=FALSE)



#' ## OUTCOME 1: difference between PaO2/FiO2 mmHg in pre-prone versus prone positioning
#' 
#' ### Set covariables of interest
covars0 <- c(
  "cama_paciente",
  ""
)
covars <- covars0[-length(covars0)]
new_vars <- c("pafi_status", "pafi")

#' Data in long format 
data_gathered <- mydata %>%
  select(
    !!covars,
    "po2_fio2_pre",
    "po2_fio2_prono"
  ) %>%
  gather(
    key = pafi_status,
    value = pafi,
    -!!covars
  ) 

  
#' ### PaO2/FiO2 qqplot (acceptable except in extremes)
qqnorm(data_gathered$pafi)
qqline(data_gathered$pafi)

#' ### PaO2/FiO2 boxplot
data_gathered %>%
  ggplot(
    aes(
      x=pafi_status,
      y=pafi,
      colour=pafi_status, fill=pafi_status
    )
  ) + geom_boxplot(alpha=0.5) + theme_bw()



#' ### Fit LMM
lmm1 <- lmer(pafi ~ pafi_status + (1 | cama_paciente), data_gathered) # cama_paciente is the patient ID, set as random effect
lmm1


#' ### Tidy LMM
new_vars_status <- new_vars[1] 
new_vars_value <- new_vars[2] 
new_vars_status_q <- rlang::sym(new_vars_status)
new_vars_status_num <- paste0(new_vars_status, "_num")
model_name <- "Changes in PaO2/FiO2 pre - prone"

data_gathered0 <- data_gathered %>%
  mutate(
    !!new_vars_status_num := case_when(
      str_locate(tolower(!!new_vars_status_q), "pre")[,1] >= 1 ~ 0,
      str_locate(tolower(!!new_vars_status_q), "prone")[,1] >= 1 ~ 1,
      str_locate(tolower(!!new_vars_status_q), "post")[,1] >= 1 ~ 1,
      TRUE ~ 1
    )
  )

# Write formula
my_formula <- as.formula(
  paste0(
    new_vars_value, " ~ ", new_vars_status_num, " + (1 | cama_paciente)"
  ))
# Fit LMM
lmm1 <- lmer(my_formula, data=data_gathered0) # rowid is the patient ID, set as random effect # lmm1; summary(lmm1)
sumlmm1 <- lmm1 %>% broom::tidy()
confints0 <- confint(lmm1) %>% broom::tidy() %>%
  rename(
    term = .rownames,
  ) %>%
  mutate(
    `95% CI` = paste0(
      "[", round(X2.5.., 3), "; ", round(X97.5.., 2), "]"
    )
  ) %>%
  select(term, `95% CI`)

# Tidy results
sumlmm1_estimate <-  sumlmm1 %>%
  mutate(
    group = case_when(
      group != "fixed" ~ "random effect",
      TRUE ~ "fixed effect"
    )
  ) %>%
  mutate(
    terms = c(
      "Intercept",
      model_name,
      "Intercept SD (random effect)",
      "Residual SD (random effect)"
    ),
    name = case_when(
      terms == "Intercept" ~ model_name,
      TRUE ~ ""
    )
  ) %>%
  left_join(
    confints0
  ) %>%
  select(
    name, terms, everything(), -term
  ) %>%
  mutate_at(
    vars(estimate:statistic),
    list(~round(., 2))
  )
  
#' ### LMM Table
#' 
sumlmm1_estimate %>% pander::pander() 
