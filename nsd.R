######################################################
######## Migration - Net Squared Displacement ########
########  NSERP - Kristin Barker - June 2016  ########
######################################################

##SET WD, INPUT PATH, OUTPUT PATH
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

#LOAD PACKAGES
library(gsubfn)
library(sp) #for kernel centroid estimate
library(adehabitatHR) #for kernel centroid estimate
library(raster)
library(rgdal)

#CREATE BLANK AIC AND COEFFICIENT TABLES
##AICc
AICcsv = array(NA,c(1,7))
AICcsv[1,]=c("animal","migrant","mixed-migrant","disperser","resident","nomad","bestmodel")
write.table(AICcsv, append=FALSE,
            paste0(outputpath,"AICtable.csv"), 
            sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE)

##Coefficient
COEFcsv=array(NA,c(1,15))
COEFcsv[1,]=c("animal","asym1","asym2","t1","t2","dur1","dur2","intercept","nomadbeta","day0","distance",
              "springstart","springend","fallstart","fallend")
write.table(COEFcsv, append=FALSE,
            paste0(outputpath,"COEFFICIENTStable.csv"), 
            sep=",", col.names=FALSE, row.names=FALSE, quote=FALSE)


