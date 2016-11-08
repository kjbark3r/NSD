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

# data
dataall <- read.csv("nsd-locs-all.csv") 
dataall$Date <- as.Date(dataall$Date, format = "%Y-%m-%d")
elklist <- as.data.frame(unique(dataall$AnimalID))
numelk <- nrow(elklist)


#############
## 2014 NSD
#############

# SPRING 
# start date = 2014-02-26

## dfs to store results in
nsd.spr2014 <- data.frame(matrix(ncol = 7, nrow = 0))
colnames(nsd.spr2014) <- c("AnimalID", "Date", "Julian_date", "J_day_new_spr",
                     "X_UTM", "Y_UTM", "SprNSD")
nsd.tot.spr2014 <- data.frame(matrix(ncol = 2, nrow = 0))
colnames(nsd.tot.spr2014) <- c("AnimalID", "SprTotalNSD")

##  per-animal code
for(i in 1:numelk) {  #subset each individual
  elk=elklist[i,]
  datasub <- subset(dataall, AnimalID==elk) %>%
  select(-J_day_new_fall)  %>%
    filter(Date < "2014-10-01")

  #store start date UTMs  
  firstloc <- data.frame(datasub$X_UTM[datasub$J_day_new_spr == 1], datasub$Y_UTM[datasub$J_day_new_spr == 1]) 
	colnames(firstloc) <- c("start_X", "start_Y")

  # calculate & store daily NSD during summer - distance from first location (km^2)
  datasub <- subset(datasub, Date > "2014-06-30" & Date < "2014-09-01")	#summer = jul 1 - aug 31
	datasub["SprNSD"] = a = ((((datasub$X_UTM - firstloc$start_X)/1000)^2) + (((datasub$Y_UTM - firstloc$start_Y)/1000)^2)) 
  nsd.spr2014 <- as.data.frame(bind_rows(nsd.spr2014, datasub))

  # calculate & store average summer nsd  
  nsd.tot.spr2014[i,1] <- elk
  nsd.tot.spr2014[i,2] <- sum(a)
}  
nsd.spr2014$IndivYr <- paste(nsd.spr2014$AnimalID, "-14", sep="")
nsd.tot.spr2014$IndivYr <- paste(nsd.tot.spr2014$AnimalID, "-14", sep="")
rm(datasub, firstloc)

# FALL 
# start date = 2014-07-31

## dfs to store results in
nsd.fall2014 <- data.frame(matrix(ncol = 7, nrow = 0))
colnames(nsd.fall2014) <- c("AnimalID", "Date", "Julian_date", "J_day_new_fall",
                            "X_UTM", "Y_UTM", "FallNSD")
nsd.tot.fall2014 <- data.frame(matrix(ncol = 2, nrow = 0))
  colnames(nsd.tot.fall2014) <- c("AnimalID", "FallTotalNSD")

## per-animal code  
for(i in 1:numelk) {  #subset each individual
  elk=elklist[i,]
  datasub <- subset(dataall, AnimalID==elk) %>%
	  select(-J_day_new_spr) %>%
    filter(Date < "2015-04-01")
  
  #store start date UTMs 
  firstloc <- data.frame(datasub$X_UTM[datasub$J_day_new_fall == 1], datasub$Y_UTM[datasub$J_day_new_fall == 1]) 
	colnames(firstloc) <- c("start_X", "start_Y")

  # calculate & store daily NSD during summer - distance from first location (km^2)
  datasub <- subset(datasub, Date > "2014-12-31" & Date < "2015-03-16")	#winter = jan 1 - mar 15
	datasub["FallNSD"] = a = ((((datasub$X_UTM - firstloc$start_X)/1000)^2) + (((datasub$Y_UTM - firstloc$start_Y)/1000)^2)) 
  nsd.fall2014 <- as.data.frame(bind_rows(nsd.fall2014, datasub))

  # calculate & store average summer nsd  
  nsd.tot.fall2014[i,1] <- elk
  nsd.tot.fall2014[i,2] <- sum(a)
}  
nsd.fall2014$IndivYr <- paste(nsd.fall2014$AnimalID, "-14", sep="")
nsd.tot.fall2014$IndivYr <- paste(nsd.tot.fall2014$AnimalID, "-14", sep="")
rm(datasub, firstloc)
  
## join data
nsd.tot.14 <- nsd.tot.spr2014 %>%
  select(-AnimalID) %>%
  full_join(nsd.tot.fall2014, by = "IndivYr") %>%
  select(IndivYr, AnimalID, SprTotalNSD, FallTotalNSD)

#############
## 2015 NSD
#############

# SPRING 
# start date = 2015-02-26

## dfs to store results in
nsd.spr2015 <- data.frame(matrix(ncol = 7, nrow = 0))
colnames(nsd.spr2015) <- c("AnimalID", "Date", "Julian_date", "J_day_new_spr",
                     "X_UTM", "Y_UTM", "SprNSD")
nsd.tot.spr2015 <- data.frame(matrix(ncol = 2, nrow = 0))
colnames(nsd.tot.spr2015) <- c("AnimalID", "SprTotalNSD")

##  per-animal code
for(i in 1:numelk) {  #subset each individual
  elk=elklist[i,]
  datasub <- subset(dataall, AnimalID==elk) %>%
  select(-J_day_new_fall)  %>%
    filter(Date > "2014-12-31")

  #store start date UTMs  
  firstloc <- data.frame(datasub$X_UTM[datasub$J_day_new_spr == 1], datasub$Y_UTM[datasub$J_day_new_spr == 1]) 
	colnames(firstloc) <- c("start_X", "start_Y")

  # calculate & store daily NSD during summer - distance from first location (km^2)
  datasub <- subset(datasub, Date > "2015-06-30" & Date < "2015-09-01")	#summer = jul 1 - aug 31
	datasub["SprNSD"] = a = ((((datasub$X_UTM - firstloc$start_X)/1000)^2) + (((datasub$Y_UTM - firstloc$start_Y)/1000)^2)) 
  nsd.spr2015 <- as.data.frame(bind_rows(nsd.spr2015, datasub))

  # calculate & store average summer nsd  
  nsd.tot.spr2015[i,1] <- elk
  nsd.tot.spr2015[i,2] <- sum(a)
}  
nsd.spr2015$IndivYr <- paste(nsd.spr2015$AnimalID, "-15", sep="")
nsd.tot.spr2015$IndivYr <- paste(nsd.tot.spr2015$AnimalID, "-15", sep="")
rm(datasub, firstloc)

# FALL 
# start date = 2015-07-31

## dfs to store results in
nsd.fall2015 <- data.frame(matrix(ncol = 7, nrow = 0))
colnames(nsd.fall2015) <- c("AnimalID", "Date", "Julian_date", "J_day_new_fall",
                            "X_UTM", "Y_UTM", "FallNSD")
nsd.tot.fall2015 <- data.frame(matrix(ncol = 2, nrow = 0))
  colnames(nsd.tot.fall2015) <- c("AnimalID", "FallTotalNSD")

## per-animal code  
for(i in 1:numelk) {  #subset each individual
  elk=elklist[i,]
  datasub <- subset(dataall, AnimalID==elk) %>%
	  select(-J_day_new_spr) %>%
    filter(Date  > "2014-12-31")
  
  #store start date UTMs 
  firstloc <- data.frame(datasub$X_UTM[datasub$J_day_new_fall == 1], datasub$Y_UTM[datasub$J_day_new_fall == 1]) 
	colnames(firstloc) <- c("start_X", "start_Y")

  # calculate & store daily NSD during summer - distance from first location (km^2)
  datasub <- subset(datasub, Date > "2015-12-31" & Date < "2016-03-16")	#winter = jan 1 - mar 15
	datasub["FallNSD"] = a = ((((datasub$X_UTM - firstloc$start_X)/1000)^2) + (((datasub$Y_UTM - firstloc$start_Y)/1000)^2)) 
  nsd.fall2015 <- as.data.frame(bind_rows(nsd.fall2015, datasub))

  # calculate & store average summer nsd  
  nsd.tot.fall2015[i,1] <- elk
  nsd.tot.fall2015[i,2] <- sum(a)
}  
nsd.fall2015$IndivYr <- paste(nsd.fall2015$AnimalID, "-15", sep="")
nsd.tot.fall2015$IndivYr <- paste(nsd.tot.fall2015$AnimalID, "-15", sep="")
rm(datasub, firstloc)
  
## join data
nsd.tot.15 <- nsd.tot.spr2015 %>%
  select(-AnimalID) %>%
  full_join(nsd.tot.fall2015, by = "IndivYr") %>%
  select(IndivYr, AnimalID, SprTotalNSD, FallTotalNSD)

nsd.tot <- bind_rows(nsd.tot.14, nsd.tot.15)

nsd <- read.csv("nsd-avg.csv") %>%
full_join(nsd.tot)
write.csv(nsd, file = "nsd-avg-total.csv", row.names = FALSE)
	