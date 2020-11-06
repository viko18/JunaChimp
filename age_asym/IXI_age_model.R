### S.vickery October 2020 ##
### Age regression model for IXI human sample ###

library("readr")
library("plyr")
library("dplyr")
library("ggplot2")
library("stringr")
library("MatchIt")
library("optmatch")
library("rgenoud")
library("emmeans")

chimp.dat <- read.csv("Chimp_brain_meta.csv")
IXI.dat <- read.csv("IXI_meta.csv")
# Remove rows with missing values #
IXI.dat <- na.omit(IXI.dat)

# clean up data & create same labels for the same data #
chimp.clean <- chimp.clean %>%
  rename(., c("Subject" = "Name")) %>%
  select(., -Rear)

IXI.clean <- IXI.clean %>%
  rename(., c("Scanner" = "Site", "Sex" = "SEX_ID..1.m..2.f.",
              "Age" = "AGE")) %>%
  select(., -WMH, -IQR, -IXI_ID) %>%
  filter(., Scanner != "IOP") 

IXI.clean$Scanner <- revalue(IXI.clean$Scanner, c("GUYS" = "1.5T","HH" = "3T" ))
IXI.clean$Sex[IXI.clean$Sex == 1] <- c("Male")
IXI.clean$Sex[IXI.clean$Sex == 2] <- c("Female")
IXI.clean$Sex <- as.factor(IXI.clean$Sex)

##############################################################################################
# Violin plot age, sex, scanner distribution - Sup Fig.2 #

# violin plot of IXI sample without IOP #
# jitter of points may appear differently #
IXI.plot <- ggplot(data = IXI.clean, 
                     aes(x = Scanner, y = Age)) +
  geom_violin(alpha = 0.25, aes(fill = Scanner), size = 1,
              trim = FALSE) +
  scale_fill_manual(values = c("#D95F02", "7570B3")) +
  geom_jitter(aes(shape = Sex, colour = Sex),
              position = position_jitter(0.2)) + 
  scale_color_brewer(palette="Set1") +
  theme_classic()

# View plot #
IXI.plot

##############################################################################################
# Match IXI sample to QC passed chimp sample on Age, Sex, & Scanner

# Create percentage GM of TIV to account for different head sizes #
IXI.clean$Perc.GM <- IXI.clean$GM / IXI.clean$TIV * 100
# same for chimps #
chimp.clean$Perc.GM <- chimp.clean$GM / chimp.clean$TIV * 100


# create data frames to be matched #
chimp.match <- chimp.clean
IXI.match <- IXI.clean
chimp.match$Age <- 1.5 * chimp.clean$Age
# add species column #
IXI.match$Species <- 1
chimp.match$Species <- 0

# Join chimp and human sample for matching #
Age.sample <- rbind(IXI.match, chimp.match)
Age.sample$Group <- as.logical(Age.sample$Species == 0) 

# match IXI using optimal algorithm #
Age.match <- matchit(Group ~ Scanner + Age + Sex, 
                     data = Age.sample, 
                     method = "optimal", ratio = 1)
matched.sample <- match.data(Age.match)

# matched human IXI sample n = 194 #
IXI.194m <- filter(matched.sample, Species == 1)

##############################################################################################
# Violin plot matched IXI sample #

# Plot the data seperated by Sex of IXI sample matched to chimps #
IXI.plot <- ggplot(data = IXI.194m, 
                       aes(x = Sex, y = Age)) +
  geom_violin(alpha = 0.3, aes(fill = Sex), size = 0.5,
              trim = FALSE) +
  scale_fill_brewer(palette = "Set1") +
  geom_jitter(aes(shape = Sex), 
              position = position_jitter(0.1)) + 
  labs(y = "Age (years)") +
  theme_classic()
# view plot #
IXI.plot

##############################################################################################
# Total GM volume age regression model and graph  for IXI mathed sample#

# age regression mdoels for matched sample #
IXI.lm <- lm(Perc.GM ~ Age + Sex + Scanner, data = IXI.194m)
IXI.lm1 <- lm(Perc.GM ~ Age * Sex, data = IXI.194m)
IXI.lm2 <- lm(Perc.GM ~ Age + Sex, data = IXI.194m)

summary(IXI.lm)
summary(IXI.lm1)
summary(IXI.lm2)
# test for sex effect #
anova(IXI.age.M.lm1, IXI.age.M.lm2)

# Filter sex and run linear model #
IXI.male <- filter(IXI.194m, Sex == "Male")
IXI.female <- filter(IXI.194m, Sex == "Female")

male.IXI.lm <- lm(Perc.GM ~ Age, data = IXI.male)
female.IXI.lm <- lm(Perc.GM ~ Age, data = IXI.female) 
summary(male.IXI.lm)
summary(female.IXI.lm)

# plot age regression with IXI matched sample #
age.IXI.plot <- ggplot(IXI.194m, aes(x = Age, 
                                      y = Perc.GM, 
                                      shape = Sex, 
                                      color = Sex)) + 
  xlim(12,84) + #to match the chimp x-axis
  ylim(25,55) +
  geom_point() +
  geom_smooth(aes(group = 1), color = "black",
              method = glm, formula = y ~ x) +
  labs(x = "Age (years)",
       y = "% GM of Total Intracranial Volume")

# make white background and nice colour of points #
age.IXI.plot + theme_classic() + scale_color_brewer(palette="Set1")
