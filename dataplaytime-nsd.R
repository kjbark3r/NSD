#######################################################
### Looking at results of different parameters/runs ###
##      of Net Squared Displacement analyses         ##
########  NSERP - Kristin Barker - June 2016  #########
#######################################################

##WD
####Work computer or personal laptop; RUN X
wd_workcomp <- "C:\\Users\\kristin.barker\\Documents\\GitHub\\NSD\\run1"
wd_laptop <- "C:\\Users\\kjbark3r\\Documents\\GitHub\\NSD\\run1"

if (file.exists(wd_workcomp)) {
  setwd(wd_workcomp)
} else {
  if(file.exists(wd_laptop)) {
    setwd(wd_laptop)
  } else {
      cat("Are you SURE you got that file path right?\n")
  }
}
rm(wd_workcomp, wd_laptop)

##PACKAGES
library(dplyr)

##LABEL MIGRATORY STATUS & COMBINE DATA
nsd14 <- read.csv('./output2014/AICtable.csv') %>%
  mutate(NSD14 = ifelse(bestmodel == 1, "Migrant",
    ifelse(bestmodel == 2, "MixedMigrant", 
      ifelse(bestmodel == 3, "Disperser",
        ifelse(bestmodel == 4, "Resident", "Nomad")))))


nsd15 <- read.csv('./output2015/AICtable.csv') %>%
  mutate(NSD15 = ifelse(bestmodel == 1, "Migrant",
    ifelse(bestmodel == 2, "MixedMigrant", 
      ifelse(bestmodel == 3, "Disperser",
        ifelse(bestmodel == 4, "Resident", "Nomad")))))

nsd <- full_join(nsd14, nsd15, by = "animal") %>%
  select(animal, NSD14, NSD15)