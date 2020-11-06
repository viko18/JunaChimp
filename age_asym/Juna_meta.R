### Create sample distribution plots & linear age regression ###


library("readr")
library("plyr")
library("dplyr")
library("ggplot2")


# Meta data for whole chimpanzee sample #
chimp.meta <- read.csv("Chimp_meta_new_223.csv")

# Meta data and whole brain volumes for #
# GM, WM, & CSF for QC passed chimps n = 194#
chimp.brain <- read.csv("Chimp_brain_meta.csv")

##############################################################################################
# Violin plot age, sex, scanner distribution - Sup Fig.1 #

# create violin plot #
# jitter of points may appear differently #
total.plot <- ggplot(data = chimp.meta, 
                     aes(x = Scanner, y = Age)) +
  geom_violin(alpha = 0.25, aes(fill = Scanner), size = 1,
              trim = FALSE) +
  scale_fill_manual(values = c("#D95F02", "7570B3")) +
  geom_jitter(aes(shape = Sex, colour = Sex),
              position = position_jitter(0.2)) + 
  theme_classic()

# View plot #
total.plot

##############################################################################################
# Violin plot for QC passed sample showing #
# distribution of sex and age #

# jitter of points may appear differently as #
QC.plot <- ggplot(data = chimp.brain, 
                            aes(x = Sex, y = Age)) +
  geom_violin(alpha = 0.3, aes(fill = Sex), size = 0.5,
              trim = FALSE) +
  scale_fill_brewer(palette = "Set1") +
  geom_jitter(aes(shape = Sex), 
              position = position_jitter(0.1)) + 
  labs(y = "Age (years)") +
  theme_classic()

# View plot #
QC.plot

##############################################################################################

# Total GM volume age regression model and graph #

# create percentage GM of total intracranial volume #
perc.GM <- chimp.brain$GM/chimp.brain$TIV*100
chimp.brain$perc.GM <- perc.GM


# Total Age - GM linear model #
age.lm <- lm(perc.GM ~ Age + Sex, data = chimp.brain)
summary(age.lm)

# subset into sexes and run linear model #
male.age <- filter(chimp.brain, Sex == "Male")
female.age <- filter(chimp.brain, Sex == "Female")

male.lm <- lm(perc.GM ~ Age, data = male.age)
summary(male.lm)
female.lm <- lm(perc.GM ~ Age, data = female.age)
summary(female.lm)

# test for sex effect of aging effect on GM #
anova(age.lm)

# plot graph with different colour for each sex #
plot <- ggplot(chimp.brain, aes(x = Age, 
                             y = perc.GM, 
                             shape = Sex, 
                             color = Sex)) + 
  xlim(10,55) +
  ylim(25,55) +
  geom_point() +
  geom_smooth(method = lm, se = F) +
  labs(x = "Age (years)",
       y = "% GM of Total Intracranial Volume")

# make white background and nice colour of points #
plot + theme_classic() + scale_color_brewer(palette="Set1")

