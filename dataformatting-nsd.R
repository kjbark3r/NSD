######################################################
###### Data setup for Net Squared Displacement #######
########  NSERP - Kristin Barker - June 2016  ########
######################################################

##WD
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
xy.nsd <- data.frame("X_UTM" = locs$Long, "Y_UTM" = locs$Lat)
xy.spdf <- SpatialPointsDataFrame(coords=xy.nsd, data=locs, proj4string = latlong)
utms <- spTransform(xy.spdf, nad27)
locs <- as.data.frame(utms)
rm(xy.nsd, alllocs, xy.spdf) #keep 'er clean

#Add julian day and #days from start date
  #julian day
locs$Date <- as.Date(locs$Date)
locs$Julian_date <- ifelse(locs$Date < "2015-01-01",
  julian(locs$Date, origin = as.Date("2014-01-01"))+1,
  julian(locs$Date, origin = as.Date("2015-01-01"))+1)
locs$J_day_new_spr <- locs$Julian_date - 56  #Feb. 26   
locs$J_day_new_fall <- locs$Julian_date - 211 #Jul. 31

#Remove extraneous columns
locs <- subset(locs, select = c("AnimalID", "Date", "Julian_date", "J_day_new_spr", 
                                "J_day_new_fall", "X_UTM", "Y_UTM"))
  
#Separate datasets for 2014 and 2015
locs14 <- subset(locs, Date < "2015-02-26")  #2015 start date
locs15 <- subset(locs, Date >= "2015-02-26")

#export data
write.csv(locs, file = "nsd-locs-all.csv", row.names = FALSE)
write.csv(locs14, file = "nsd-locs-2014.csv", row.names = FALSE)
write.csv(locs15, file = "nsd-locs-2015.csv", row.names = FALSE)
