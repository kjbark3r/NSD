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
library(tidyr)

####################
##DATA - RUN COMPARISONS

# nsd - combine different runs

# run4
nsd14.r4 <- read.csv('./run4/2014/AICtable.csv') %>%
  mutate(run4.2014 = ifelse(bestmodel == 1, "Migrant",
    ifelse(bestmodel == 2, "MixedMigrant", 
      ifelse(bestmodel == 3, "Disperser",
        ifelse(bestmodel == 4, "Resident", "Nomad"))))) %>%
  rename(mod4.2014 = bestmodel)

nsd15.r4 <- read.csv('./run4/2015/AICtable.csv') %>%
  mutate(run4.2015 = ifelse(bestmodel == 1, "Migrant",
    ifelse(bestmodel == 2, "MixedMigrant", 
      ifelse(bestmodel == 3, "Disperser",
        ifelse(bestmodel == 4, "Resident", "Nomad"))))) %>%
  rename(mod4.2015 = bestmodel)

r4 <- full_join(nsd14.r4, nsd15.r4, by = "animal") %>%
  select(matches('animal|run|mod'))

# run5
nsd14.r5 <- read.csv('./run5/2014/AICtable.csv') %>%
  mutate(run5.2014 = ifelse(bestmodel == 1, "Migrant",
    ifelse(bestmodel == 2, "MixedMigrant", 
      ifelse(bestmodel == 3, "Disperser",
        ifelse(bestmodel == 4, "Resident", "Nomad"))))) %>%
  rename(mod5.2014 = bestmodel)

nsd15.r5 <- read.csv('./run5/2015/AICtable.csv') %>%
  mutate(run5.2015 = ifelse(bestmodel == 1, "Migrant",
    ifelse(bestmodel == 2, "MixedMigrant", 
      ifelse(bestmodel == 3, "Disperser",
        ifelse(bestmodel == 4, "Resident", "Nomad"))))) %>%
  rename(mod5.2015 = bestmodel)

r5 <- full_join(nsd14.r5, nsd15.r5, by = "animal") %>%
  select(matches('animal|run|mod'))


# all runs
nsd <- full_join(r4, r5, by = "animal") %>%
  dplyr::select(matches('animal|run|mod')) %>%
  rename(AnimalID = animal)

# comparing results of two runs
View(nsd)
par(mfrow=c(1,2))
boxplot(nsd$mod1.2014, nsd$mod4.2014, main = 2014)
boxplot(nsd$mod1.2015, nsd$mod4.2015, main = 2015)

# if want to clean workspace
rm(nsd14.r1, nsd14.r2, nsd14.r3, nsd15.r1, nsd15.r2, nsd15.r3, 
   r1, r2, r3)

####################
## AVG 2014-2015 RESULTS

r4$avg.r4 <- (r4$mod4.2014+r4$mod4.2015)/2 
r4$AnimalID <- r4$animal

r5$avg.r5 <- (r5$mod5.2014+r5$mod5.2015)/2 
r5$AnimalID <- r5$animal

# plus look, minus extra columns, reordered
look <- read.csv("migstatus-prelimlook.csv") %>%
  mutate(nsd.look = ifelse(Status == "Migrant", 1,
    ifelse(Status == "Resident", 4, 2))) #otherwise Mixed-Migrant
look <- look[, c("AnimalID", "Status", "nsd.look")]

r45 <- full_join(r4, r5, by = "AnimalID") 
avg.look <- full_join(r45, look, by = "AnimalID") 
avg.look <- avg.look[,c("AnimalID", "avg.r4", "avg.r5", "nsd.look")]
avg.look$diff <- (avg.look$nsd.look - avg.look$avg.r4)



####################
# DATA - ADD PRELIM LOOK RESULTS

# prelim look results
look <- read.csv("migstatus-prelimlook.csv") %>%
  mutate(nsd.look = ifelse(Status == "Migrant", 1,
    ifelse(Status == "Resident", 4, 2))) #otherwise Mixed-Migrant
look <- look[, c("AnimalID", "Status", "nsd.look")]

# all together now
nsd.look <- full_join(nsd, look, by = "AnimalID")
rm(look, nsd)
View(nsd.look)
