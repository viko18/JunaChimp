### conduct age regression model for all davi regions ###
### print out signifiant regions ### 

library("dplyr")
library("readr")
library("tidyr")
library("lsr")
library("broom")
library("reshape2")

# read in Davi ROI data # 
# data is a csv file with cols - Name, Age, Sex, Scanner, TIV & davi region acronyms #
chimp_ROIs <- read.csv("Davi_label_178_mean_masked01.csv")

# melts data into tribble then groups each roi #
# to conduct age linear regression model #
lm_Davi_age <- select(chimp_ROIs, -Name) %>%
  melt(., id.vars = 1:4, na.rm = TRUE) %>%
  group_by(variable) %>%
  do(tidy(lm(value ~ Age + TIV + Sex + Scanner, data=.)))

###############################################################################################
# filter out age p.values and conduct #
# multiple comparison correction #
pval.davi.age <- filter(lm_Davi_age, term == "Age")

pval.davi.age$FWE <- p.adjust(pval.davi.age$p.value, method = "holm")

# filter p value at threshold and write out results #
# showing signifiant davi regions #
pval.davi.age.FWE <- filter(pval.davi.age, FWE <= 0.05) %>%
  dplyr::select(., variable, statistic, p.value, FWE)

write.csv(pval.age.tiv.FWE, row.names = FALSE,
          "Davi130_age_sig_regions_p005.csv") 

