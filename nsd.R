######################################################
######## Migration - Net Squared Displacement ########
########  NSERP - Kristin Barker - June 2016  ########
######################################################

################################
#SET WD, INPUT PATH, OUTPUT PATH
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

################################
#LOAD PACKAGES
  library(gsubfn)
  library(sp) #for kernel centroid estimate
  library(adehabitatHR) #for kernel centroid estimate
  library(raster)
  library(rgdal)

################################
#CREATE BLANK AIC AND COEFFICIENT TABLES

#AICc
 #2014
  AICcsv2014 = array(NA,c(1,7))
  AICcsv2014[1,]=c("animal","migrant","mixed-migrant","disperser","resident","nomad","bestmodel")
  write.table(AICcsv2014, append=FALSE,
              paste0(outputpath,"AICtable2014.csv"), 
              sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE)
 #2015
  AICcsv2015 = array(NA,c(1,7))
  AICcsv2015[1,]=c("animal","migrant","mixed-migrant","disperser","resident","nomad","bestmodel")
  write.table(AICcsv2015, append=FALSE,
              paste0(outputpath,"AICtable2015.csv"), 
              sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE)

#Coefficient
 #2014  
  COEFcsv2014=array(NA,c(1,15))
  COEFcsv2014[1,]=c("animal","asym1","asym2","t1","t2","dur1","dur2","intercept","nomadbeta","day0","distance",
                "springstart","springend","fallstart","fallend")
  write.table(COEFcsv2014, append=FALSE,
              paste0(outputpath,"COEFFICIENTStable2014.csv"), 
              sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE)
 #2015
  COEFcsv2015=array(NA,c(1,15))
  COEFcsv2015[1,]=c("animal","asym1","asym2","t1","t2","dur1","dur2","intercept","nomadbeta","day0","distance",
                    "springstart","springend","fallstart","fallend")
  write.table(COEFcsv2015, append=FALSE,
              paste0(outputpath,"COEFFICIENTStable2015.csv"), 
              sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE)

################################
#SET PARAMETERS
  
#ASYMPTOTES - migration distance from starting point - km^2 
#Elk must migrate a minimum 1 miles from the Feb 15th location (2.2 km to be considered a migrant)
L_a1=4.84 #spring 2014 migration
L_a2=2.42 #fall 2014 return

#MIDPOINT DATES
#Elk must be at midpoint of spring migrate between April 1 and middle of July
#Elk must be at midpoint of fall migration between August 15 and Dec 15 (154 days post Feb 26 [starting date]
L_t1=35  #(35 days past Feb 26th start date is April 1)
U_t1=140 #July 15
L_t2=171 #August 15
U_t2=293 #December 15

#DURATION OF 1/4 of TRIP  - the coefficient dur is essentially 1/4 duration of migration
#Elk migration must be > 30 days in length, so set dur1 = 0- 8 and dur2 = 0-8
L_dur1=0
U_dur1=8
L_dur2=0
U_dur2=8

################################
#READ IN DATA AND PREP FOR ANALYSIS

#elk locations
locs2014 <- read.csv("nsd-locs-2014.csv")
locs2015 <- read.csv("nsd-locs-2015.csv")

#elklist
elklist2014 <- unique(locs2014$AnimalID)