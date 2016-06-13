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
  sample_n(size = 1) %>%
  as.data.frame()

#Transform lat/longs to zone 12 UTM
  #define projections
latlong <- CRS("+init=epsg:4326")
nad27 <- CRS("+init=epsg:26712")
  #transform data
xy.nsd <- data.frame("x" = locs$Long, "y" = locs$Lat)
xy.spdf <- SpatialPointsDataFrame(coords=xy.nsd, data=locs, proj4string = latlong)
utms <- spTransform(xy.spdf, nad27)
locs <- as.data.frame(utms)
write.csv(locs, file = "nsd-locs-all.csv")

#Separate datasets for 2014 and 2015
locs$Date <- as.character(locs$Date)
locs14 <- subset(locs, Date < "2015-01-01")
  write.csv(locs14, file = "nsd-locs-2014.csv")
locs15 <- subset(locs, Date >= "2015-01-01")
  write.csv(locs15, file = "nsd-locs-2015.csv")
