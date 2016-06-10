######################################################
###### Data setup for Net Squared Displacement #######
########  NSERP - Kristin Barker - June 2016  ########
######################################################

##SET WD, INPUT PATH, OUTPUT PATH
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
library(sp)
library(rgdal)

#############
##FORMAT DATA 
alllocs <- read.csv("collardata-locsonly-equalsampling.csv")
elklist <- unique(alllocs$AnimalID)

#Randomly select one location per day per elk
locs <- alllocs %>%
  group_by(AnimalID) %>%
  group_by(Date, add = TRUE) %>%
  sample_n(size = 1)

#Transform lat/longs to zone 12 UTM
xy <- data.frame("x" = locs$Long, "y" = locs$Lat)
wgs84 <- CRS("+proj=utm +zone=12 +datum=WGS84")

utms <- SpatialPointsDataFrame(coords=xy, data=locs, proj4string = wgs84)
locs <- as.data.frame(utms)



#Separate datasets for 2014 and 2015
locs14 <- subset(locs, Date < 2015-01-01)
locs15 <- subset(locs, Date >= 2015-01-01)
