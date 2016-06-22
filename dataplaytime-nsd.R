#######################################################
### Looking at results of different parameters/runs ###
##      of Net Squared Displacement analyses         ##
########  NSERP - Kristin Barker - June 2016  #########
#######################################################

##WD
####Work computer or personal laptop; RUN X
wd_workcomp <- "C:\\Users\\kristin.barker\\Documents\\GitHub\\NSD"
wd_laptop <- "C:\\Users\\kjbark3r\\Documents\\GitHub\\NSD"

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

##DATA - ADD PRELIM LOOK RESULTS

# nsd - combine different runs

# run1
nsd14.r1 <- read.csv('./run1/2014/AICtable.csv') %>%
  mutate(run1.2014 = ifelse(bestmodel == 1, "Migrant",
    ifelse(bestmodel == 2, "MixedMigrant", 
      ifelse(bestmodel == 3, "Disperser",
        ifelse(bestmodel == 4, "Resident", "Nomad"))))) %>%
  rename(mod1.2014 = bestmodel)

nsd15.r1 <- read.csv('./run1/2015/AICtable.csv') %>%
  mutate(run1.2015 = ifelse(bestmodel == 1, "Migrant",
    ifelse(bestmodel == 2, "MixedMigrant", 
      ifelse(bestmodel == 3, "Disperser",
        ifelse(bestmodel == 4, "Resident", "Nomad"))))) %>%
  rename(mod1.2015 = bestmodel)

r1 <- full_join(nsd14.r1, nsd15.r1, by = "animal") %>%
  select(matches('animal|run|mod'))

# run2
nsd14.r2 <- read.csv('./run2/2014/AICtable.csv') %>%
  mutate(run2.2014 = ifelse(bestmodel == 1, "Migrant",
    ifelse(bestmodel == 2, "MixedMigrant", 
      ifelse(bestmodel == 3, "Disperser",
        ifelse(bestmodel == 4, "Resident", "Nomad"))))) %>%
  rename(mod2.2014 = bestmodel)

nsd15.r2 <- read.csv('./run2/2015/AICtable.csv') %>%
  mutate(run2.2015 = ifelse(bestmodel == 1, "Migrant",
    ifelse(bestmodel == 2, "MixedMigrant", 
      ifelse(bestmodel == 3, "Disperser",
        ifelse(bestmodel == 4, "Resident", "Nomad"))))) %>%
  rename(mod2.2015 = bestmodel)

r2 <- full_join(nsd14.r2, nsd15.r2, by = "animal") %>%
  select(matches('animal|run|mod'))

# run3
nsd14.r3 <- read.csv('./run3/2014/AICtable.csv') %>%
  mutate(run3.2014 = ifelse(bestmodel == 1, "Migrant",
    ifelse(bestmodel == 2, "MixedMigrant", 
      ifelse(bestmodel == 3, "Disperser",
        ifelse(bestmodel == 4, "Resident", "Nomad"))))) %>%
  rename(mod3.2014 = bestmodel)


nsd15.r3 <- read.csv('./run3/2015/AICtable.csv') %>%
  mutate(run3.2015 = ifelse(bestmodel == 1, "Migrant",
    ifelse(bestmodel == 2, "MixedMigrant", 
      ifelse(bestmodel == 3, "Disperser",
        ifelse(bestmodel == 4, "Resident", "Nomad"))))) %>%
  rename(mod3.2015 = bestmodel)

r3 <- full_join(nsd14.r3, nsd15.r3, by = "animal") %>%
  select(matches('animal|run|mod'))

# all runs
nsd <- full_join(r1, r2, by = "animal") 
nsd <- full_join(nsd, r3, by = "animal") %>%
  rename(AnimalID = animal)

# if want to clean workspace
rm(nsd14.r1, nsd14.r2, nsd14.r3, nsd15.r1, nsd15.r2, nsd15.r3, 
   r1, r2, r3)

# prelim look results
look <- read.csv("migstatus-prelimlook.csv") %>%
  mutate(nsd.look = ifelse(Status == "Migrant", 1,
    ifelse(Status == "Resident", 4, 2))) #otherwise Mixed-Migrant
look <- look[, c("AnimalID", "Status", "nsd.look")]

# all together now
nsd.look <- full_join(nsd, look, by = "AnimalID")
rm(look, nsd)