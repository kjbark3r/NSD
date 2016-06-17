###################################################
## MISC CODE RELATED TO NET SQUARED DISPLACEMENT ##
###################################################

#################
#testing inpath/outpath 
#################
wd_workcomp <- "C:\\Users\\kristin.barker\\Documents\\GitHub\\NSD"
  out_workcomp <- "C:\\Users\\kristin.barker\\Documents\\GitHub\\NSD\\output"
wd_laptop <- "C:\\Users\\kjbark3r\\Documents\\GitHub\\NSD"
  out_laptop <- "C:\\Users\\kjbark3r\\Documents\\GitHub\\NSD\\output"

if (file.exists(wd_workcomp)) {
  setwd(wd_workcomp)
  inputpath = wd_workcomp
  outputpath = out_workcomp
} else {
  if(file.exists(wd_laptop)) {
    setwd(wd_laptop)
    inputpath = wd_laptop
    outputpath = out_laptop
  } else {
    cat("Are you SURE you got that file path right?\n")
    }
}

rm(wd_workcomp, wd_laptop, out_workcomp, out_laptop)

#################
# lat/long to utm
##################
#[run top part of dataformatting code 1st]
xy.nsd <- data.frame("x" = locs$Long, "y" = locs$Lat)
wgs84 <- CRS("+proj=utm +zone=12 +datum=WGS84")
utms <- SpatialPointsDataFrame(coords=xy.nsd, data=locs, proj4string = wgs84)
str(xy.nsd)
str(locs)
  #prob is that locs isn't a normal df
locs <- as.data.frame(locs)
str(locs)
locs <- as.data.frame(utms)
#ok made the code work, but stupidly wasn't actually transforming it to utms
nad27 <- CRS("+init=epsg:26712") #nope
nad27 <- CRS("+proj=utm +zone=12 +datum=NAD27") #nope
nad27 <- CRS("+proj=utm +zone=12 +ellps=clrk66 +datum=NAD27 +units=m +no_defs") #nope

#figure out how to make it do coords instead of degrees
wtf.locs <- locs
latlong <- CRS("+init=epsg:4326")
nad27 <- CRS("+init=epsg:26712")
wtf.xy <- data.frame("x" = wtf.locs$Long, "y" = wtf.locs$Lat)
wtf.spdf <- SpatialPointsDataFrame(coords=wtf.xy, data=wtf.locs, proj4string = latlong)
wtf.spdf2 <- SpatialPointsDataFrame(coords=wtf.xy, data=wtf.locs, proj4string = nad27)
#whyyyyyyyyy
test <- data.frame("x" = -113.9323, "y" = 46.44463)
test.spdf <- SpatialPointsDataFrame(test, test)
testutm <- spTransform(wtf.spdf, CRS("+proj=utm +zone=12 +ellps=clrk66 +datum=NAD27 +units=m +no_defs"))
testutm <- spTransform(wtf.spdf, nad27)
#because you need to first tell it projection of the original data
#before you can convert it, duh


#################
# determining parameters
##################

#midpoint dates
mid <- read.csv("migstatus-prelimlook.csv")
head(mid)
unique(mid$TimingSpr14)
unique(mid$TimingFall14)
unique(mid$TimingSpr15)
unique(mid$TimingFall15)

#################
# julian dates
##################
testj <- locs #play data
class(testj$Date)
testj$Date <- as.POSIXct(testj$Date)
mutate(testj, Julian_date = julian(testj$Date))

#easiest if data is POSIXct

#things that don't work
as.Date(testj$Date, format = "%Y-%m-%d")
julian(testj$Date) #you didn't store anything, durrrr

testj$Date <- as.Date(testj$Date)
testj$Julian_date <- julian(testj$Date) #makes vector

#################
# misc helpful stuff
##################

#remove all objects but one (locs) from workspace
rm(list=setdiff(ls(), "locs"))
