## Create asymmetry value for each Davi130 region ##
## Conduct one-sample t-test for hemispheric asymmetry ##

library("reshape2")
library("broom")
library("readr")
library("dplyr")
library("ggplot2")
library("lsr")
library("stringr")

# read in Davi ROI data # 
# data is a csv file with cols - Name, Age, Sex, Scanner, TIV & davi region acronyms #
chimp_ROIs <- read.csv("Davi_label_194_mean_masked01.csv")
ROIs <- select(chimp_ROIs, L.aSFG:R.CerII)

# Use AI formula on all odd or left hemi ROI's #
AI <- list()
for (label in 1:ncol(ROIs)) {
  if ((label%%2) != 0) {
   AI[[label]] <- (ROIs[label] - ROIs[label + 1]) / 
     0.5 * (ROIs[label] + ROIs[label + 1])
  }
  else  AI[[label]] <- NA
}
# Turn list into data frame
AI.df <- data.frame(matrix(unlist(AI), ncol = (ncol(ROIs)/2), 
                  byrow = FALSE))

# remove any NA's #
AI.df <- na.omit(AI.df)

# create AI labels from left ROI ´Davi labels #
# AI refers to asymmetry index #
AI.labels <- colnames(select(ROIs, contains("R."))) %>%
  str_replace_all(., "R.", "AI.")

# add colnames to AI data frame #
colnames(AI.df) <- AI.labels

# add meta data to AI data frame #
chimp_AI_new <- cbind(select(chimp_ROIs, Name:TIV), AI.df)

# write AI csv file #
write.csv(chimp_AI_new, "Davi130_Asym_194_mean.csv", row.names = F)

###############################################################################################
# whole brain one-sample t-test #
AI.ttest.br <- select(chimp_AI_new, -Name, -Sex,-Scanner,-Age, -Rear) %>%
  melt(., id.vars = 1) %>%
  group_by(variable) %>% 
  do(tidy(t.test(.$value, mu = 0, 
                 alternative = "two.sided", conf.level = 0.95)))

# multiple comparison adjustment #
AI.ttest.br$FWE <- p.adjust(AI.ttest.br$p.value, 
                            method = "holm")

# filter results at sig threshold p <= 0.05 #
AI.sig.br <- select(AI.ttest.br, variable, 
                    statistic, p.value, FWE) %>%
  filter(., FWE <= 0.05)

write.csv(AI.sig.br, "Davi130_Asym_sig_regions_p005.csv", 
          row.names = FALSE)
