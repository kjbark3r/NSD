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
# adding julian days and dates
##################
rm(a)
a <- locs #play data
a$Date <- as.Date(a$Date)
class(a$Date)
b <- julian(a$Date) #works but wrong origin
b <- julian(a$Date, origin = as.Date("2014-01-01"))
#fuck yeah. now make it a column

a <- mutate(a, J_day = julian(a$Date, origin = as.Date("2014-01-01")))
#ok now make different origins for 2014 and 2015

rm(a)
a <- locs 
a$Date <- as.Date(a$Date)

a$J_day = ifelse(a$Date < "2015-01-01",
  julian(a$Date, origin = as.Date("2014-01-01")),
  julian(a$Date, origin = as.Date("2015-01-01")))


#things that don't work
as.Date(testj$Date, format = "%Y-%m-%d")
julian(testj$Date) #you didn't store anything, durrrr

testj$Date <- as.Date(testj$Date)
testj$Julian_date <- julian(testj$Date) #makes vector

testj$Date <- as.POSIXct(testj$Date) #Date prob easier

testj$Date <- as.Date(testj$Date) #also try as.Date
testj <- testj %>%
  mutate(ifelse(Date < "2015-01-01", 
        Julian_date = julian(testj$Date, origin = as.Date("2014-01-01")),
        Julian_date = julian(testj$Date, origin = as.Date("2015-01-01"))))
  #error: unused arguments

b <- julian(a$Date, origin = "2014-01-01")
#error: non-numeric argument to binary operator

a <- mutate(a, J_date = julian(a$Date, origin = as.Date("1970-01-01")))
#wrong origin

a <- mutate(a, J_date = julian(a$Date, origin = as.Date("1900-01-01")))
  #just realized J_date is never actually called in the code
  #not sure why it was in Kelly's example data but I'm gonna ignore it

ifelse(Date < "2015-01-01", 
  J_day = julian(a$Date, origin = as.Date("2014-01-01")),
  J_day = julian(a$Date, origin = as.Date("2015-01-01"))))
#error unused arg

#################
# error checking
##################

#making sure subsetted 2014/2015 data includes all locs
#i want everything except the 2015 capture date
tets <- subset(locs, Date == "2015-01-23")
nrow(locs14) + nrow(locs15) + nrow(tets)
#sweet

#################
# run1 error about coeff table
##################
COEFcsv=array(NA,c(1,15))
COEFcsv[1,]=c("animal","asym1","asym2","t1","t2","dur1","dur2","intercept","nomadbeta","day0","distance",
              "springstart","springend","fallstart","fallend")
write.table(COEFcsv, append=FALSE,
            paste0(outputpath,"COEFFICIENTStable.csv"), 
            sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE)

  
write.table(coefs, append=TRUE,
              paste0(outputpath,"COEFFICIENTStable.csv"),
              sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE, na="NA")
#yeah, i screwed that up when i moved that code around without
#actually looking hard enough to see what it was doing.
#reverting to previous...

###################################
#DELETED CODE
#THAT WORKS BUT IS NO LONGER USEFUL
###################################

# combining results of different runs
# (below runs i'm not interested in)

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

#################
# misc helpful stuff
##################

#remove all objects but one (locs) from workspace
rm(list=setdiff(ls(), "locs"))
