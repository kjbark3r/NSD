######################################################
######## Migration - Net Squared Displacement ########
############# Geographic Distance Values #############
########  NSERP - Kristin Barker - June 2016  ########
######################################################

############
#SETUP
############

#working directory
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
  rm(wd_laptop, wd_workcomp)

#packages
library(dplyr)  #arrange, piping

#############
## 2014 NSD
#############
# start date = 2014-02-26

# data
dataall <- read.csv("nsd-locs-2014.csv") 
  dataall$Date <- as.Date(dataall$Date, format = "%m/%d/%Y")
elklist <- as.data.frame(unique(dataall$AnimalID))
numelk <- nrow(elklist)

## dfs to store results in

nsd.2014 <- data.frame(matrix(ncol = 7, nrow = 0))
  colnames(nsd.2014) <- c("AnimalID", "Date", "Julian_date", "J_day_new",
                     "X_UTM", "Y_UTM", "NSD")
  
nsd.avg.2014 <- data.frame(matrix(ncol = 2, nrow = 0))
  colnames(nsd.avg.2014) <- c("AnimalID", "avgNSD")

  
## per-animal code
for(i in 1:numelk) {  #subset each individual
  elk=elklist[i,]
  datasub <- subset(dataall, AnimalID==elk) %>%
	arrange(J_day_new) 

  #store start date UTMs  
  firstloc <- data.frame(datasub$X_UTM[1], datasub$Y_UTM[1]) 
	  colnames(firstloc) <- c("start_X", "start_Y")

  # calculate & store daily NSD during summer - distance from first location (km)
  datasub <- subset(datasub, Date > "2014-06-30" & Date < "2014-09-01")	#summer = jul 1 - aug 31
	datasub["NSD"] = a = ((((datasub$X_UTM - firstloc$start_X)/1000)^2) + (((datasub$Y_UTM - firstloc$start_Y)/1000)^2)) 
  nsd.2014 <- as.data.frame(bind_rows(nsd.2014, datasub), row.names = FALSE)

  # calculate & store average summer nsd  
  nsd.avg.2014[i,1] <- elk
  nsd.avg.2014[i,2] <- mean(a)
}  

write.csv(nsd.2014, file = "nsd-allsummer-2014.csv", row.names = FALSE)
write.csv(nsd.avg.2014, file = "nsd-avg-2014.csv", row.names = FALSE)

#############
## 2015 NSD
#############
# start date = 2015-01-24

# data
dataall <- read.csv("nsd-locs-2015.csv") 
  dataall$Date <- as.Date(dataall$Date, format = "%m/%d/%Y")
elklist <- as.data.frame(unique(dataall$AnimalID))
numelk <- nrow(elklist)

## dfs to store results in

nsd.2015 <- data.frame(matrix(ncol = 7, nrow = 0))
  colnames(nsd.2015) <- c("AnimalID", "Date", "Julian_date", "J_day_new",
                     "X_UTM", "Y_UTM", "NSD")
  
nsd.avg.2015 <- data.frame(matrix(ncol = 2, nrow = 0))
  colnames(nsd.avg.2015) <- c("AnimalID", "avgNSD")

  
## per-animal code
for(i in 1:numelk) {  #subset each individual
  elk=elklist[i,]
  datasub <- subset(dataall, AnimalID==elk) %>%
	arrange(J_day_new) 

  #store start date UTMs  
  firstloc <- data.frame(datasub$X_UTM[1], datasub$Y_UTM[1]) 
	  colnames(firstloc) <- c("start_X", "start_Y")

  # calculate & store daily NSD during summer - distance from first location (km)
  datasub <- subset(datasub, Date > "2015-06-30" & Date < "2015-09-01")	#summer = jul 1 - aug 31
	datasub["NSD"] = a = ((((datasub$X_UTM - firstloc$start_X)/1000)^2) + (((datasub$Y_UTM - firstloc$start_Y)/1000)^2)) 
  nsd.2015 <- as.data.frame(bind_rows(nsd.2015, datasub), row.names = FALSE)

  # calculate & store average summer nsd  
  nsd.avg.2015[i,1] <- elk
  nsd.avg.2015[i,2] <- mean(a)
}  

write.csv(nsd.2015, file = "nsd-allsummer-2015.csv", row.names = FALSE)
write.csv(nsd.avg.2015, file = "nsd-avg-2015.csv", row.names = FALSE)

#############
## BOTH YEARS
#############

prep.nsd.2014 <- nsd.2014 %>%
  select(AnimalID, Date, NSD) 

prep.nsd.2015 <- nsd.2015 %>%
  select(AnimalID, Date, NSD) 
  
nsd <- rbind(prep.nsd.2014, prep.nsd.2015)
	write.csv(nsd, file = "nsd-allsummer.csv", row.names = FALSE)

prep.nsd.avg.2014 <- nsd.avg.2014 %>%
  select(AnimalID, avgNSD) %>%
  rename(avgNSD2014 = avgNSD)

prep.nsd.avg.2015 <- nsd.avg.2015 %>%
  select(AnimalID, avgNSD) %>%
  rename(avgNSD2015 = avgNSD)
	
nsd.avg <- full_join(prep.nsd.avg.2014, prep.nsd.avg.2015, by = "AnimalID")
	write.csv(nsd.avg, file = "nsd-avg.csv", row.names = FALSE)
	
rm(list = ls()[grep("^prep", ls())])
	